
import 'package:synchronized/synchronized.dart';
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
    browseURI: "/browse?langs=en"
  );

  @override
  Future<List<String>> fetchContentItem(ContentData contentData) async {
    try {
      final response = await http.get(Uri.parse(contentData.contentURI));
      final document = parse(response.body);
      final contentElementContainer = document.getElementById('viewer');

      if (contentElementContainer == null) {
        return ['Chapter content not found'];
      }

      return contentElementContainer.querySelectorAll('[class*="page-img"]')
          .map((element) {
            final src = element.attributes['src'];
            return src ?? 'https://via.placeholder.com/150';
          })
          .toList();
    } catch (e) {
      return ['Error: $e'];
    }
  }

  @override
  Future<List<ContentData>> fetchBrowseList(List<int> pageNumbers, {String orderBy = 'update', String status = 'all'}) async {
    try {
      Map<int, List<ContentData>> contentMap = {};
      var pageFutures = <Future>[];

      for (var pageNumber in pageNumbers) {
        pageFutures.add(() async {
          var statusConfig = "&release=$status";
          if (status == "all"){
            statusConfig = "";
          }
          var pageResponse = await http.get(Uri.parse('$baseURI$browseURI$statusConfig&sort=$orderBy.za&page=$pageNumber'));
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
      var contentElementContainer = document.getElementById("series-list");
      if (contentElementContainer == null) {
      return;
      }
      List<Element> coverWraps = contentElementContainer.querySelectorAll('[class*="col item"]');
      for (int i = 0; i < coverWraps.length; i++) {
        Element contentElement = coverWraps[i];
        List<Element> novelItem = contentElement.getElementsByTagName('a');
        if(novelItem.isEmpty){
          continue;
        }
        final contentCover = novelItem[0];
        final partialURI = contentCover.attributes['href'] as String;

        List<Element> contentImage = contentCover.getElementsByTagName('img');
        var imageURI = "https://via.placeholder.com/150";
        if(contentImage.isNotEmpty){
          imageURI = contentImage[0].attributes['src'] as String;
        }
        
        final title = novelItem[1].text.trim();
        List<Element> genreElementContainer = contentElement.querySelectorAll('[class*="item-genre"]');
        List<String> genres = [];

        if (genreElementContainer.isNotEmpty) {
          final container = genreElementContainer[0].nodes;
          for (int i = 0; i < container.length; i++) {
            if (container[i].nodeType == Node.ELEMENT_NODE) {
              String? text = container[i].text;
              if (text != null) {
                genres.add(text.trim());
              }
            }
          }
        }

        contentList.add(ContentData(
              imageURI: imageURI,
              contentURI: "$baseURI$partialURI",
              websiteURI: baseURI,

              title: title, 
              author: "Undefined", 
              chapterNo: "Undefined",
              lastUpdated: DateTime.now().toString(),
              
              summary:[],
              genre:genres,
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
      var contentElementContainer = document.querySelector('[class*="episode-list"]');
      if (contentElementContainer != null) {
        List<Element> chapterElements = contentElementContainer.querySelectorAll('[class*="item"]');
        for (int i = 0; i < chapterElements.length; i++) {
          Element paraElement = chapterElements[i];
          var novelItem = paraElement.querySelector('[class*="visited chapt"]');
          if(novelItem != null){
            List<Element> chapterNoElements = paraElement.getElementsByTagName('b');
            var chapterNo = "Undefined";
            var title = "Undefined";

            if(chapterNoElements.isNotEmpty){
              chapterNo = chapterNoElements[0].text.trim();
              var titleElement = chapterNoElements[0].nextElementSibling;
              if (titleElement != null){
                title = titleElement.text.trim();
              }
            }

            final partialURI = novelItem.attributes['href'] as String;
            final extraElements = paraElement.getElementsByTagName('i');
            var lastUpdated = "Undefined";
            if (extraElements.isNotEmpty){
              lastUpdated = extraElements[extraElements.length-1].text;
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
      }
    } catch (e) {
      return;
    }
  }


  @override
  String fetchContentImageUrl(Document document) {
    final summaryElement = document.querySelector('[class*="attr-cover"]');
    if (summaryElement == null) {
      return 'https://via.placeholder.com/150';
    }

    final imgElement = summaryElement.querySelector('img');
    final src = imgElement?.attributes['src'];
    if (src == null) {
      return 'https://via.placeholder.com/150';
    }

    return src;
  }
  
  @override
  Map<String, String> extractHeaderInfo(Document document, ContentData cardItem) {
    var headerMap = <String, String>{};

    var headerInfo = document.querySelector('[class*="attr-main"]');
    
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
