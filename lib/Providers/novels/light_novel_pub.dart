
import 'package:synchronized/synchronized.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/bases/luna_base_source.dart';

class LightNovelPub extends ContentSource {
  LightNovelPub() : super(
    contentType: "text",
    contentSource: "light_novel_pub",
    baseURI: "https://www.lightnovelpub.com"
  );
 
  @override
  Future<List<ContentData>> fetchBrowseList(List<int> pageNumbers, {String genre = 'all', String orderBy = 'updated', String status = 'all'}) async {
    try {
      // Remap Retreived content based on the original page number order
      Map<int, List<ContentData>> contentMap = {};
      var pageFutures = <Future>[];

      for (var pageNumber in pageNumbers) {
        pageFutures.add(() async {
          var pageResponse = await http.get(Uri.parse('$baseURI/browse/genre-all-25060123/order-$orderBy/status-$status?page=$pageNumber'));
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
      var contentElementContainer = document.querySelector('[class*="novel-list"]');
      if (contentElementContainer == null) {
        return;
      }

      List<Element> coverWraps = contentElementContainer.querySelectorAll('[class*="cover-wrap"]');
      for (Element contentElement in coverWraps) {
        List<Element> novelItem = contentElement.getElementsByTagName('a');
        if (novelItem.isEmpty) {
          continue;
        }

        var contentCover = novelItem[0];
        final partialURI = contentCover.attributes['href'] ?? '';
        final title = contentCover.attributes['title'] ?? 'Unknown Title';

        List<Element> contentImage = contentCover.getElementsByTagName('img');
        var imageURI = "https://via.placeholder.com/150";
        if (contentImage.isNotEmpty) {
          imageURI = contentImage[0].attributes['data-src'] ?? imageURI;
        }

        var fetchedData= ContentData.empty();
        fetchedData.imageURI = imageURI;
        fetchedData.contentURI = "$baseURI$partialURI";
        fetchedData.websiteURI = baseURI;
        fetchedData.title = title;
        fetchedData.lastUpdated = DateTime.now().toString();
        fetchedData.contentIndex = contentList.length;
        fetchedData.contentType = contentType;
        fetchedData.contentSource = contentSource;

        contentList.add(fetchedData);
      }
    } catch (e) {
      return;
    }
  }


  @override
  Future<List<ContentData>> fetchContentList(Document document, ContentData cardItem) async {
    try {
      const pagination = 100;
      var headerMap = await extractHeaderInfo(document, cardItem);
      
      // total chapters used to calculate number of pages
      double totalChapters = headerMap.containsKey('Chapters') && headerMap['Chapters'] != null
          ? double.parse(headerMap['Chapters']!)
          : 0.0;

      // Create a lock for synchronization
      var lock = Lock();
      var totalPages = (totalChapters / pagination).ceil();
      var pageFutures = <Future>[];

      for (int page = 1; page <= totalPages; page++) {
        pageFutures.add(() async {
          var pageResponse = await http.get(Uri.parse('${cardItem.contentURI}/chapters?page=$page'));
          var pageDocument = parse(pageResponse.body);
          
          await lock.synchronized(() {
            return _fetchPageContentChapter(pageDocument, cardItem);
          });
        }());
      }

      await Future.wait(pageFutures);

      // Fix the ordering
      cardItem.contentList.sort((a, b) {
        double itemIDA = double.tryParse(a.itemID) ?? a.contentIndex.toDouble();
        double itemIDB = double.tryParse(b.itemID) ?? b.contentIndex.toDouble();
        return itemIDA.compareTo(itemIDB);
      });

      return cardItem.contentList;
    } catch (e) {
      return [];
    }
  }


  Future<void> _fetchPageContentChapter(Document document, ContentData cardItem) async {
    try {
      var contentElementContainer = document.querySelector('[class*="chapter-list"]');
      if (contentElementContainer != null) {
        List<Element> paragraphElements = contentElementContainer.getElementsByTagName('a');
        for (var paraElement in paragraphElements) {
          final partialURI = paraElement.attributes['href'] ?? '';
          final itemIDFuture = Future(() => paraElement.querySelector('[class*="chapter-no"]')?.text.trim() ?? '');
          final chapterTitleFuture = Future(() => paraElement.querySelector('[class*="chapter-title"]')?.text.trim() ?? '');
          final lastUpdatedFuture = Future(() => paraElement.querySelector('[class*="chapter-update"]'));

          // Wait for all Futures to complete
          var results = await Future.wait([itemIDFuture, chapterTitleFuture, lastUpdatedFuture]);

          String itemID = results[0] as String;
          String chapterTitle = results[1] as String;
          Element lastUpdated = results[2] as Element;

          String lastUpdatedDatetime = lastUpdated.attributes['datetime']?.trim() ?? '';

          final contentURI = "$baseURI$partialURI";

          // Check if contentURI already exists
          bool contentURIPresent = cardItem.contentList.any((existingContent) => existingContent.contentURI == contentURI);

          // If contentURI is not present, add it to the contentList
          if (!contentURIPresent) {
            var fetchedData= ContentData.empty();
            fetchedData.contentURI = contentURI;
            fetchedData.title = chapterTitle;
            fetchedData.itemID = itemID;
            fetchedData.lastUpdated = lastUpdatedDatetime;
            fetchedData.contentIndex = cardItem.contentList.length+1;
            fetchedData.contentType = contentType;
            fetchedData.contentSource = contentSource;

            cardItem.contentList.add(fetchedData);
          }
        }
      }
    } catch (e) {
      return;
    }
  }

  @override
  Future<List<String>> fetchContentItem(ContentData contentData) async {
    try {
      final response = await http.get(Uri.parse(contentData.contentURI));
      final document = parse(response.body);
      final contentElementContainer = document.querySelector('[class*="chapter-content"]');
      
      if (contentElementContainer == null) {
        return [];
      }

      return contentElementContainer
          .getElementsByTagName('p')
          .map((element) => element.text.trim())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, String>> extractHeaderInfo(Document document, ContentData cardItem) async {
    var headerMap = <String, String>{};
    
    // Call in parallel
    var headerInfoFuture = Future(() => document.querySelector('[class*="header-stats"]'));
    var rankInfoFuture = Future(() => document.querySelector('[class*="rank"]'));
    var ratingInfoFuture = Future(() => document.querySelector('[class*="rating-star"]'));

    // Wait for all Futures to complete
    var results = await Future.wait([headerInfoFuture, rankInfoFuture, ratingInfoFuture]);
    
    var headerInfo = results[0];
    var rankInfo = results[1];
    var ratingInfo = results[2];
    
    if (headerInfo != null) {
      // Extract Novel Stats
      List<Element> headerInfoElement = headerInfo.getElementsByTagName('span').toList();
      for (var header in headerInfoElement) {
        List<Element> category = header.getElementsByTagName('strong').toList();
        List<Element> property = header.getElementsByTagName('small').toList();
        
        if (category.isNotEmpty && property.isNotEmpty) {
          headerMap[property.first.text.trim()] = category.first.text.trim();
        }
      }
    }

    // Rank Info
    if (rankInfo != null) {
      headerMap["rank"] = rankInfo.text.trim();
    }
    
    // Rating Info
    if (ratingInfo != null) {
      headerMap["rating"] = ratingInfo.text.trim();
    }
    
    return headerMap;
  }


  @override
  String fetchContentImageUrl(Document document, ContentData cardItem) {
    final summaryElement = document.querySelector('[class*="cover"]');
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

  @override
  String fetchContentAuthor(Document document, ContentData cardItem) {
    final authorElement = document.querySelector('[itemprop*="author"]');
    if (authorElement == null || authorElement.text.trim().isEmpty) {
      return 'Author not found';
    }
    return authorElement.text.trim();
  }

  @override
  List<String> fetchContentSummary(document, ContentData cardItem) {
    final summaryElement = document.querySelector('[class*="summary"]');
    if (summaryElement == null) {
      return ['Summary not found'];
    }
    
    final paragraphElements = summaryElement.getElementsByTagName('p');
    return paragraphElements.map((element) => element.text.trim()).toList().cast<String>();
  }

  @override
  List<String> fetchContentGenre(Document document, ContentData cardItem) {
    final genreElement = document.querySelector('[class*="categories"]');
    if (genreElement == null) {
      return ['Genre not found'];
    }
    final linkElements = genreElement.getElementsByTagName('a');
    return linkElements.map((element) => element.text.trim()).toList();
  }
}
