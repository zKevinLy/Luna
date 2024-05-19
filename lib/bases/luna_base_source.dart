import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:luna/models/content_info.dart';
import 'package:flutter/foundation.dart';

abstract class ContentSource {
  final String contentType;
  final String contentSource;
  final String baseURI;
  final String browseURI;

  ContentSource({
    required this.contentType,
    required this.contentSource,
    required this.baseURI,
    required this.browseURI,
  });

  Future<ContentData> fetchContentDetails(ContentData cardItem) async {
    try {
      final response = await http.get(Uri.parse(cardItem.contentURI));
      final document = parse(response.body);

      // Fetch details concurrently using compute for parallel processing
      final imageURIFuture = compute(fetchContentImageUrl, document);
      final authorFuture = compute(fetchAuthor, document);
      final summaryFuture = compute(fetchSummary, document);
      final genreFuture = compute(fetchGenre, document);
      final contentListFuture = fetchContentList(document, cardItem);

      // Wait for all futures to complete
      final results = await Future.wait([
        imageURIFuture,
        authorFuture,
        summaryFuture,
        genreFuture,
        contentListFuture,
      ]);

      // Set the data for that particular card
      cardItem.imageURI=results[0] as String;
      cardItem.contentURI=cardItem.contentURI;
      cardItem.author=results[1] as String;
      cardItem.summary=results[2] as List<String>;
      cardItem.genre=results[3] as List<String>;
      cardItem.contentList=results[4] as List<ContentData>;
      
      return cardItem;
    } catch (e) {
      return cardItem;
    }
  }

  Future<List<String>> fetchContentItem(ContentData contentData) async {
    // Implement this method in the derived class
    return [];
  }

  Future<List<ContentData>> fetchBrowseList(List<int> pageNumbers, {String orderBy = 'new', String status = 'all'}) async {
    // Implement this method in the derived class
    return [];
  }

  Map<String, String> extractHeaderStats(Document document) {
    // Implement this method in the derived class
    return <String, String>{};
  }

  Future<List<ContentData>> fetchContentList(Document document, ContentData cardItem) async {
    // Implement this method in the derived class
    return [];
  }

  String fetchContentImageUrl(Document document) {
    return 'https://via.placeholder.com/150';
  }

  String fetchAuthor(Document document) {
    return "Author not found";
  }
  
  List<String> fetchSummary(Document document) {
    return ['Summary not found'];
  }

  List<String> fetchGenre(Document document) {
    return ['Tags not found'];
  }

}
