
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/bases/luna_base_source.dart';

class Batoto extends ContentSource {
  Batoto() : super(
    contentType: "image",
    contentSource: "batoto",
    baseURI: "https://bato.to",
    browseURI: "/v3x-search"
  );

  @override
  Future<List<String>> fetchContentItem(ContentData contentData) async {
    try {
      final response = await http.get(Uri.parse(contentData.contentURI));
      final document = parse(response.body);
      List<Element> contentElementContainer = document.getElementsByTagName('astro-island');

      if (contentElementContainer.isEmpty) {
        return ['Chapter content not found'];
      }
      var images = [];

      for (int i = 0; i < contentElementContainer.length; i++) {
        Element astroIsland = contentElementContainer[i];
        if (!astroIsland.attributes.containsKey("props")){
          continue;
        }
        if (astroIsland.attributes.containsKey("props") && astroIsland.attributes['props'].toString().contains("imageFiles")) {
          var jsonString = astroIsland.attributes['props'].toString();
          images = jsonDecode(jsonDecode(jsonString)["imageFiles"][1]);
        }
      }

      List<String> imageURIs = [];
      for (var image in images) {
        var imageURI = image[1];
        imageURIs.add(imageURI);
      }
      return imageURIs;
    } catch (e) {
      return ['Error: $e'];
    }
  }

  @override
  Future<List<ContentData>> fetchBrowseList(List<int> pageNumbers, {String orderBy = 'field_upload', String status = 'all'}) async {
    try {
      Map<int, List<ContentData>> contentMap = {};
      var pageFutures = <Future>[];

      for (var pageNumber in pageNumbers) {
        pageFutures.add(() async {
          var statusConfig = "&status=$status";
          if (status == "all"){
            statusConfig = "";
          }
          var pageResponse = await http.get(Uri.parse('$baseURI$browseURI?sort=$orderBy$statusConfig&page=$pageNumber'));
          var pageDocument = parse(pageResponse.body);

          var pageContent = <ContentData>[];
          _fetchPageContentBrowse(pageDocument, pageContent);
          
          contentMap[pageNumber] = pageContent;
        }());
      }

      await Future.wait(pageFutures);

      // Flatten the contentMap into a list, sorted by the key
      List<ContentData> contentList = [];
      var sortedKeys = contentMap.keys.toList()..sort();
      for (var key in sortedKeys) {
        contentList.addAll(contentMap[key]!);
      }

      return contentList;
    } catch (e) {
      return [];
    }
  }



  Future<void> _fetchPageContentBrowse(Document document, List<ContentData> contentList) async {
    try {
      var contentElements = document.querySelectorAll('[class*="pb-5"]');
      if (contentElements.isEmpty) {
        return;
      }
      for (int i = 0; i < contentElements.length; i++) {
        Element contentElement = contentElements[i];
        List<Element> novelItem = contentElement.getElementsByTagName('a');
        if(novelItem.isEmpty){
          continue;
        }
        final contentCover = novelItem[0];
        final partialURI = contentCover.attributes['href'] as String;

        List<Element> contentImage = contentCover.getElementsByTagName('img');
        var imageURI = "https://via.placeholder.com/150";
        var title = "Undefined";
        if(contentImage.isNotEmpty){
          imageURI = contentImage[0].attributes['src'] as String;
          title = contentImage[0].attributes['title'] as String;
        }
        
        contentList.add(ContentData(
              imageURI: imageURI,
              contentURI: "$baseURI$partialURI",
              websiteURI: baseURI,

              title: title.trim(), 
              author: "Undefined", 
              chapterNo: "Undefined",
              lastUpdated: DateTime.now().toString(),
              
              summary:[],
              genre:[],
              contentList:[],

              contentIndex: contentList.length,
              contentType: contentType,
              contentSource: contentSource,
        ));
      }
    } catch (e) {
      return;
    }
  }

  @override
  Future<List<ContentData>> fetchContentList(Document document, ContentData cardItem) async {
    try {
      // Fetch the first page to get totalChapters
      var firstPageResponse = await http.get(Uri.parse(cardItem.contentURI));
      var firstPageDocument = parse(firstPageResponse.body);

      await _fetchPageContentChapter(firstPageDocument, cardItem);

      // Fix the ordering
      cardItem.contentList.sort((a, b) {
        double chapterNoA = double.tryParse(a.chapterNo) ?? a.contentIndex.toDouble();
        double chapterNoB = double.tryParse(b.chapterNo) ?? b.contentIndex.toDouble();
        return chapterNoA.compareTo(chapterNoB);
      });


      return cardItem.contentList;
    } catch (e) {
      return [];
    }
  }

  Future<void> _fetchPageContentChapter(Document document, ContentData cardItem) async {
    try {
      var contentElementContainer = document.querySelector('[class*="space-y-5"]');
      if (contentElementContainer != null) {
        List<Element> chapterElements = contentElementContainer.getElementsByTagName('astro-slot');
        if (chapterElements.isEmpty){
          return;
        }
        for (int i = 0; i < chapterElements[0].nodes.length; i++) {
          Node nodeElement = chapterElements[0].nodes[i];
          if (nodeElement is! Element) {
            continue;
          }

          Element divElement = nodeElement;
          var partialElement = divElement.getElementsByTagName('a');
          var chapterTitleElement = divElement.querySelector('[class*="space-x-1"]');
          var chapterNo = "Undefined";

          if (chapterTitleElement!= null){
            chapterNo = chapterTitleElement.text.trim();
          }
           
          var title = partialElement[0].text.trim();

          final partialURI = partialElement[0].attributes['href'] as String;
          
          final timeElement = divElement.getElementsByTagName('time');
          var lastUpdated = "Undefined";
          if (timeElement.isNotEmpty){
            lastUpdated = timeElement[0].attributes['time'] as String;
          }

          // If contentURI is not present, add it to the contentList
          cardItem.contentList.add(ContentData(
              imageURI: "",
              contentURI: "$baseURI$partialURI",
              websiteURI: "",

              title: title, 
              author: "",
              chapterNo: chapterNo, 
              lastUpdated: lastUpdated,

              summary:[],
              genre:[],
              contentList:[],
              
              contentIndex: cardItem.contentList.length+1,
              contentType: contentType,
              contentSource: contentSource,
          ));

          
        }
      }
    } catch (e) {
      return;
    }
  }


  @override
  String fetchContentImageUrl(Document document) {
    final imgElement = document.querySelector('img');
    final src = imgElement?.attributes['src'];
    if (src == null) {
      return 'https://via.placeholder.com/150';
    }

    return src;
  }
  
  @override
  Map<String, String> extractHeaderInfo(Document document, ContentData cardItem) {
    var headerMap = <String, String>{};

    var headerInfo = document.querySelector('[class*="flex items-center flex-wrap"]');
    
    if (headerInfo != null) {
      List<Element> headerInfoElement = headerInfo.querySelectorAll('[class*="attr-item"]');
      
      for (var header in headerInfoElement) {
        List<Element> property = header.getElementsByTagName('b').toList();
        List<Element> category = header.getElementsByTagName('span').toList();
        
        if (category.isNotEmpty && property.isNotEmpty) {
          var key = property.first.text.trim();
          var value = category.first.text.trim();
          headerMap[key] = value;
        }
      }
    }

    return headerMap;
  }

  @override
  List<String> fetchSummary(document) {
    final summaryElement = document.querySelector('[class*="limit-html"]');
    if (summaryElement == null) {
      return ['Summary not found'];
    }
    
    return [summaryElement.text];
  }

}
