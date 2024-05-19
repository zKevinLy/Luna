
import 'package:synchronized/synchronized.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:luna/models/content_info.dart';
import 'package:flutter/foundation.dart';

class LightNovelPub {
  final String contentType = "novel";
  final String contentSource = "light-novel-pub";

  final String baseURI = "https://www.lightnovelpub.com";
  final String browseURI = "/browse/genre-all-25060123";

  Future<ContentData> fetchContentDetails(ContentData cardItem) async {
    try {
      final response = await http.get(Uri.parse(cardItem.contentURI));
      final document = parse(response.body);

      // Fetch details concurrently using compute for parallel processing
      final imageURIFuture = compute(_fetchContentImageUrl, document);
      final authorFuture = compute(_fetchAuthor, document);
      final summaryFuture = compute(_fetchSummary, document);
      final genreFuture = compute(_fetchGenre, document);
      final contentListFuture = fetchContentList(document, cardItem);

      // Wait for all futures to complete
      final results = await Future.wait([
        imageURIFuture,
        authorFuture,
        summaryFuture,
        genreFuture,
        contentListFuture,
      ]);

      final imageURI = results[0] as String;
      final contentURI = cardItem.contentURI;
      final author = results[1] as String;
      final summary = results[2] as List<String>;
      final genre = results[3] as List<String>;
      final contentList = results[4] as List<ContentData>;
      
      // Set the data for that particular card
      cardItem.imageURI=imageURI;
      cardItem.author=author;
      cardItem.summary=summary;
      cardItem.genre=genre;
      cardItem.contentList=contentList;
      cardItem.contentURI=contentURI;

      return cardItem;
    } catch (e) {
      return cardItem;
    }
  }

  Future<List<String>> fetchContentItem(ContentData contentData) async {
    try {
      final response = await http.get(Uri.parse(contentData.contentURI));
      
      if (response.statusCode != 200) {
        return ['Error: Unable to fetch chapter. Status code: ${response.statusCode}'];
      }
      
      final document = parse(response.body);
      final contentElementContainer = document.querySelector('[class^="chapter-content"]');
      
      if (contentElementContainer == null) {
        return ['Chapter content not found'];
      }

      return contentElementContainer
          .getElementsByTagName('p')
          .map((element) => element.text.trim())
          .toList();
    } catch (e) {
      return ['Error: $e'];
    }
  }

  Future<List<ContentData>> fetchBrowseList(List<int> pageNumbers, {String orderBy = 'new', String status = 'all'}) async {
    try {
      Map<int, List<ContentData>> contentMap = {};
      var pageFutures = <Future>[];

      for (var pageNumber in pageNumbers) {
        pageFutures.add(() async {
          var pageResponse = await http.get(Uri.parse('$baseURI$browseURI/order-$orderBy/status-$status?page=$pageNumber'));
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
      var contentElementContainer = document.querySelector('[class^="novel-list"]');
      if (contentElementContainer == null) {
      return;
      }
      List<Element> coverWraps = contentElementContainer.querySelectorAll('[class^="cover-wrap"]');
      for (int i = 0; i < coverWraps.length; i++) {
        Element contentElement = coverWraps[i];
        List<Element> novelItem = contentElement.getElementsByTagName('a');
        if(novelItem.isEmpty){
          continue;
        }
        var contentCover = novelItem[0];
        final partialURI = contentCover.attributes['href'] as String;
        final title = contentCover.attributes['title'] as String;
        List<Element> contentImage = contentCover.getElementsByTagName('img');
        var imageURI = "https://via.placeholder.com/150";
        if(contentImage.isNotEmpty){
          imageURI = contentImage[0].attributes['data-src'] as String;
        }
        contentList.add(ContentData(
              imageURI: imageURI,
              contentURI: "$baseURI$partialURI",
              websiteURI: baseURI,

              title: title, 
              author: "Undefined", 
              chapterNo: "Undefined",
              lastUpdated: DateTime.now(),
              
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

  Map<String, String> extractHeaderStats(Document document) {
    var headerMap = <String, String>{};

    var headerStats = document.querySelector('[class^="header-stats"]');
    
    if (headerStats != null) {
      List<Element> headerInfo = headerStats.getElementsByTagName('span').toList();
      
      for (var header in headerInfo) {
        List<Element> strongElements = header.getElementsByTagName('strong').toList();
        List<Element> smallElements = header.getElementsByTagName('small').toList();
        
        if (strongElements.isNotEmpty && smallElements.isNotEmpty) {
          var key = smallElements.first.text.trim();
          var value = strongElements.first.text.trim();
          headerMap[key] = value;
        }
      }
    }

    return headerMap;
  }

  Future<List<ContentData>> fetchContentList(Document document, ContentData cardItem) async {
    try {
      const pagination = 100;
      var headerMap = extractHeaderStats(document);
      // total chapters used to calculate number of pages
      double totalChapters = headerMap.containsKey('Chapters') && headerMap['Chapters'] != null
          ? double.parse(headerMap['Chapters']!)
          : 0.0;


      // Fetch the first page to get totalChapters
      var firstPageResponse = await http.get(Uri.parse('${cardItem.contentURI}/chapters'));
      var firstPageDocument = parse(firstPageResponse.body);

      await _fetchPageContentChapter(firstPageDocument, cardItem);

      // Loop through subsequent pages in parallel
      var pageFutures = <Future>[];
      var lock = Lock(); // Create a lock for Multithreading
      var totalPages = (totalChapters / pagination).ceil();

      for (int page = totalPages; page > 1; page--) {
        pageFutures.add(() async {
          var pageResponse = await http.get(Uri.parse('${cardItem.contentURI}/chapters?page=$page'));
          var pageDocument = parse(pageResponse.body);
          
          await lock.synchronized(() { // Use the lock to synchronize access to cardItem
            return _fetchPageContentChapter(pageDocument, cardItem);
          });
        }());
      }

      await Future.wait(pageFutures);

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

  Future<void> _fetchPageContentChapter(Document document,ContentData cardItem) async {
    try {
      var contentElementContainer = document.querySelector('[class^="chapter-list"]');
      if (contentElementContainer != null) {
        List<Element> paragraphElements = contentElementContainer.getElementsByTagName('a');
        for (int i = 0; i < paragraphElements.length; i++) {
          Element paraElement = paragraphElements[i];
          final partialURI = paraElement.attributes['href'] as String;

          final chapterNo = paraElement.querySelector('[class^="chapter-no"]')?.text.trim() as String;
          final chapterTitle = paraElement.querySelector('[class^="chapter-title"]')?.text.trim() as String;
          final lastUpdated = paraElement.querySelector('[class^="chapter-update"]');
          final lastUpdatedDatetime = lastUpdated?.attributes['datetime'] as String;

          bool contentURIPresent = false;

          // Iterate through existing contentList to check if contentURI already exists
          for (var existingContent in cardItem.contentList) {
              if (existingContent.contentURI == "$baseURI$partialURI") {
                  contentURIPresent = true;
                  break;
              }
          }

          // If contentURI is not present, add it to the contentList
          if (!contentURIPresent) {
              cardItem.contentList.add(ContentData(
                  imageURI: "",
                  contentURI: "$baseURI$partialURI",
                  websiteURI: "",

                  title: chapterTitle, 
                  author: "",
                  chapterNo: chapterNo, 
                  lastUpdated: DateTime.parse(lastUpdatedDatetime.trim()),

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


  String _fetchContentImageUrl(Document document) {
    final summaryElement = document.querySelector('[class^="cover"]');
    if (summaryElement == null) {
      return 'https://via.placeholder.com/150';
    }

    final imgElement = summaryElement.querySelector('img');
    final src = imgElement?.attributes['data-src'];
    if (src == null) {
      return 'https://via.placeholder.com/150';
    }

    return src;
  }

  String _fetchAuthor(Document document) {
    final authorElement = document.querySelector('[itemprop^="author"]');
    if (authorElement == null || authorElement.text.trim().isEmpty) {
      return 'Author not found';
    }
    return authorElement.text.trim();
  }

  List<String> _fetchSummary(document) {
    final summaryElement = document.querySelector('[class^="summary"]');
    if (summaryElement == null) {
      return ['Summary not found'];
    }
    
    final paragraphElements = summaryElement.getElementsByTagName('p');
    if (paragraphElements.isEmpty) {
      return ['Summary not found'];
    }

    return paragraphElements.map((element) => element.text.trim()).toList().cast<String>();
  }


  List<String> _fetchGenre(Document document) {
    final genreElement = document.querySelector('[class^="categories"]');
    if (genreElement == null) {
      return ['Tags not found'];
    }

    final linkElements = genreElement.getElementsByTagName('a');
    if (linkElements.isEmpty) {
      return ['Tags not found'];
    }

    return linkElements.map((element) => element.text.trim()).toList();
  }
}
