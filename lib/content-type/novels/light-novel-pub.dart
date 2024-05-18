import 'package:synchronized/synchronized.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:luna/models/content-info.dart';
import 'package:flutter/foundation.dart';

class LightNovelPub {
  final String baseUrl = "https://www.lightnovelpub.com";

  Future<ContentInfo> fetchContentInfo(String title) async {
    try {
      var pageURI = '$baseUrl/novel/$title';
      final response = await http.get(Uri.parse(pageURI));
      final document = parse(response.body);
      final List<Element> novelContent = document.getElementsByTagName('article');
      if (novelContent.isNotEmpty) {
        pageURI = novelContent[0].attributes['itemid'] as String;
      }
      // Fetch details concurrently using compute for parallel processing
      final imageUrlFuture = compute(_fetchContentImageUrl, document);
      final authorFuture = compute(_fetchAuthor, document);
      final summaryFuture = compute(_fetchSummary, document);
      final genreFuture = compute(_fetchGenre, document);
      final contentListFuture = fetchContentList(document, pageURI, title);

      // Wait for all futures to complete
      final results = await Future.wait([
        imageUrlFuture,
        authorFuture,
        summaryFuture,
        genreFuture,
        contentListFuture,
      ]);

      final imageUrl = results[0] as String;
      final author = results[1] as String;
      final summary = results[2] as List<String>;
      final genre = results[3] as List<String>;
      final contentList = results[4] as List<ContentData>;
      final websiteURI = pageURI;

      return ContentInfo(
        imageUrl: imageUrl,
        title: title,
        author: author,
        summary: summary,
        genre: genre,
        contentList: contentList,
        websiteURI: websiteURI,
        contentType: "novel",
        contentSource: "light-novel-pub", 
      );
    } catch (e) {
      return ContentInfo(
        imageUrl: 'https://via.placeholder.com/150',
        title: title,
        author: '',
        summary: ['Error: $e'],
        genre: [],
        contentList: [],
        websiteURI: '',
        contentType: "novel",
        contentSource: "",
      );
    }
  }

  Future<List<String>> fetchContentItem(String contentURI) async {
    try {
      final response = await http.get(Uri.parse(contentURI));
      
      if (response.statusCode != 200) {
        return ['Error: Unable to fetch chapter. Status code: ${response.statusCode}'];
      }
      
      final document = parse(response.body);
      final contentElement = document.querySelector('[class^="chapter-content"]');
      
      if (contentElement == null) {
        return ['Chapter content not found'];
      }

      return contentElement
          .getElementsByTagName('p')
          .map((element) => element.text.trim())
          .toList();
    } catch (e) {
      return ['Error: $e'];
    }
  }

  Future<List<ContentData>> fetchContentList(Document document, String pageURI,String title) async {
    try {
      const pagination = 100;
      var totalChapters = -1;

      List<ContentData> contentList = [];

      // Fetch the first page to get totalChapters
      var firstPageResponse = await http.get(Uri.parse('$pageURI/chapters?chorder=desc'));
      var firstPageDocument = parse(firstPageResponse.body);

      _fetchPageContent(firstPageDocument, contentList);
      totalChapters = contentList[0].number;

      // Loop through subsequent pages in parallel
      var pageFutures = <Future>[];
      var lock = Lock(); // Create a lock for Multithreading
      var totalPages = (totalChapters / pagination).ceil();

      for (int page = totalPages; page > 1; page--) {
        pageFutures.add(() async {
          var pageResponse = await http.get(Uri.parse('$pageURI/chapters?page=$page&chorder=desc'));
          var pageDocument = parse(pageResponse.body);
          
          await lock.synchronized(() { // Use the lock to synchronize access to contentList
            _fetchPageContent(pageDocument, contentList);
          });
        }());
      }

      await Future.wait(pageFutures);

      contentList.sort((a, b) => a.number.compareTo(b.number));
      return contentList;
    } catch (e) {
      return [];
    }
  }

  Future<void> _fetchPageContent(Document document, List<ContentData> contentList) async {
    try {
      var contentElement = document.querySelector('[class^="chapter-list"]');
      if (contentElement != null) {
        List<Element> paragraphElements = contentElement.getElementsByTagName('a');
        for (int i = 0; i < paragraphElements.length; i++) {
          Element paraElement = paragraphElements[i];
          final partialURI = paraElement.attributes['href'] as String;

          final chapterNo = paraElement.querySelector('[class^="chapter-no"]')?.text.trim() as String;
          final chapterTitle = paraElement.querySelector('[class^="chapter-title"]')?.text.trim() as String;
          final lastUpdated = paraElement.querySelector('[class^="chapter-update"]');
          final lastUpdatedDatetime = lastUpdated?.attributes['datetime'] as String;
          contentList.add(ContentData(
                number: int.parse(chapterNo), 
                title: 'Chapter $chapterNo: $chapterTitle', 
                lastUpdated: DateTime.parse(lastUpdatedDatetime.trim()),
                contentURL: "$baseUrl$partialURI"
          ));
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
