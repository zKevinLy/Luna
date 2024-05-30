import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:luna/models/content_info.dart';
import 'package:flutter/foundation.dart';

abstract class ContentSource {
  final String contentType;
  final String contentSource;
  final String baseURI;

  ContentSource({
    required this.contentType,
    required this.contentSource,
    required this.baseURI
  });

  Future<ContentData> fetchContentDetails(ContentData cardItem) async {
    try {
      final response = await http.get(Uri.parse(cardItem.contentURI));
      final document = parse(response.body);

      // Fetch details concurrently using compute for parallel processing
      final imageURIFuture = compute(fetchContentImageUrl, document);
      final authorFuture = compute(fetchContentAuthor, document);
      final summaryFuture = compute(fetchContentSummary, document);
      final genreFuture = compute(fetchContentGenre, document);
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

  Future<List<ContentData>> fetchSearch(List<int> pageNumbers, String searchInput) async {
    // Implement this method in the derived class
    return [];
  }

  Future<List<ContentData>> fetchBrowseList(List<int> pageNumbers, {String genre = 'all', String orderBy = 'new', String status = 'all'}) async {
    // Implement this method in the derived class
    return [];
  }

  Future<List<String>> fetchBrowseGenreList() async {
    // Implement this method in the derived class
    return [];
  }

  Future<List<ContentData>> fetchContentList(Document document, ContentData cardItem) async {
    // Implement this method in the derived class
    return [];
  }

  Future<List<String>> fetchContentItem(ContentData contentData) async {
    // Implement this method in the derived class
    // This should return the list of strings representing either the result, or URL to the source content
    return [];
  }

  // Miscellaneous header info that may not exist on all content types
  Future<Map<String, String>> extractHeaderInfo(Document document, ContentData cardItem) async {
    // Implement this method in the derived class
    // The header may have other information like the Author, summary, etc.. 
    //    so we can set it directly to the cardItem
    return <String, String>{};
  }

  String fetchContentImageUrl(Document document) {
    // Implement this method in the derived class
    return 'https://via.placeholder.com/150';
  }

  String fetchContentAuthor(Document document) {
    // Implement this method in the derived class
    return "Author not found";
  }
  
  List<String> fetchContentSummary(Document document) {
    // Implement this method in the derived class
    return ['Summary not found'];
  }

  List<String> fetchContentGenre(Document document) {
    // Implement this method in the derived class
    return ['Tags not found'];
  }

}
