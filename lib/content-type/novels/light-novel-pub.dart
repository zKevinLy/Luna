import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:luna/models/content-info.dart';
import 'package:flutter/foundation.dart';

class LightNovelPub {
  final String baseUrl = "https://www.lightnovelpub.com";

  Future<List<String>> fetchChapter(String title, int chapterNumber) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/novel/$title/chapter-$chapterNumber'));
      final document = parse(response.body);
      final contentElement = document.getElementById('chapter-container');
      if (contentElement != null) {
        final List<String> paragraphs = [];
        final List<Element> paragraphElements = contentElement.getElementsByTagName('p');
        paragraphElements.forEach((element) {
          paragraphs.add(element.text.trim());
        });
        return paragraphs;
      } else {
        return ['Chapter content not found'];
      }
    } catch (e) {
      return ['Error: $e'];
    }
  }

  Future<ContentInfo> fetchContentInfo(String title) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/novel/$title'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded', 
        },
      );
      final document = parse(response.body);

      // Fetch details concurrently using compute for parallel processing
      final imageUrlFuture = compute(_fetchImageUrl, document);
      final authorFuture = compute(_fetchAuthor, document);
      final summaryFuture = compute(_fetchSummary, document);
      final genreFuture = compute(_fetchGenre, document);
      final contentListFuture = _fetchContentList(document, title);

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
      final contentList = results[4] as List<String>;
      final websiteUrl = '$baseUrl/novel/$title';

      return ContentInfo(
        imageUrl: imageUrl,
        title: title,
        author: author,
        summary: summary,
        genre: genre,
        contentList: contentList,
        websiteUrl: websiteUrl,
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
        websiteUrl: '',
        contentType: "novel",
        contentSource: "",
      );
    }
  }


  String _fetchImageUrl(document) {
    final summaryElement = document.querySelector('[class^="cover"]');
    if (summaryElement != null) {
      final Element paragraphElements = summaryElement.querySelector('img');
      final src = paragraphElements.attributes['data-src'];
      if (src != null) {
        return src;
      }
    } 
    return "https://via.placeholder.com/150";
  }

  String _fetchAuthor(document) {
    final authorElement = document.querySelector('[itemprop="author"]');
    if (authorElement != null) {
      final authorText = authorElement.text.trim();
      if (authorText.isNotEmpty) {
        return authorText;
      }
    }
    return "Not Found"; 
  }


  List<String> _fetchSummary(document) {
    final summaryElement = document.querySelector('[class^="summary"]');
    List<String> summary = [];
    if (summaryElement != null) {
      final List<Element> paragraphElements = summaryElement.getElementsByTagName('p');
      paragraphElements.forEach((element) {
        summary.add(element.text.trim());
      });
    } else {
      summary.add('Summary not found');
    }
    return summary;
  }

  List<String> _fetchGenre(document) {
    final genreElement = document.querySelector('[class^="categories"]');
    List<String> genres = [];
    if (genreElement != null) {
      final List<Element> linkElements = genreElement.getElementsByTagName('a');
      linkElements.forEach((element) {
        final title = element.text;
        genres.add(title.trim());
      });
    } else {
      genres.add('Tags not found');
    }
    return genres;
  }

  Future<List<String>> _fetchContentList(document, String title) async {
    try {
      final latestElement = document.querySelector('[class^="latest"]');
      final latestCHTitle = latestElement.text.trim();
      RegExp regex = RegExp(r"Chapter \d+: (.+)");
      Match? match = regex.firstMatch(latestCHTitle);
      var latestTitle = "";
      if (match != null) {
        latestTitle = match.group(1)!;
      }
      
      var pageNumber = 1;
      String? nextPageUri = "";
      List<String> contentList = [];

      while(!contentList.contains(latestTitle)){
        var uri = nextPageUri != "" ?  '$baseUrl$nextPageUri' : '$baseUrl/novel/$title/chapters';
        var response = await http.get(Uri.parse(uri));
        var documentChapters = parse(response.body);
        var contentElement = documentChapters.querySelector('[class^="chapter-list"]');
        if (contentElement != null) {
          List<Element> paragraphElements = contentElement.querySelectorAll('[class^="chapter-title"]');
          paragraphElements.forEach((element) {
            contentList.add(element.text.trim());
          });
        } else {
          break;
        }
        final nextPage = documentChapters.querySelector('[class^="PagedList-skipToNext"]');
        if (nextPage != null){
          final List<Element> linkElements = nextPage.getElementsByTagName('a');
          if (linkElements.length > 0){
            nextPageUri = linkElements[0].attributes['href'];
          }
        }
        pageNumber += 1;
      }
      return contentList;
    } catch (e) {
      return ['Error: $e'];
    }
  }
}
