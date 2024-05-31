
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/bases/luna_base_source.dart';
import 'package:flutter/foundation.dart';

class Mangasee extends ContentSource {
  Mangasee() : super(
    contentType: "image",
    contentSource: "mangasee",
    baseURI: "https://mangasee123.com"
  );

  @override
  Future<List<ContentData>> fetchBrowseList(List<int> pageNumbers, {String genre = 'all', String orderBy = 'field_upload', String status = 'all', String searchTerm='_any'}) async {
    try {
      var pageResponse = await http.get(Uri.parse('$baseURI/search/?sort=lt&desc=true&name=$searchTerm'));
      var pageDocument = parse(pageResponse.body);

      var contentList = <ContentData>[];

      var scriptNodes = pageDocument.querySelectorAll('script');
      List<dynamic> dataList = [];

      for (var scriptNode in scriptNodes) {
        if (!scriptNode.text.contains("MainFunction")) {
          continue;
        }
        var content = scriptNode.text;
        var directory = substringBefore(
            substringAfter(content, "vm.Directory = "), "vm.GetIntValue")
            .replaceAll(";", " ")
            .trim();
        dataList = jsonDecode(directory);
        // Process each object in the array
        for (var dataObject in dataList) {
          // Deserialize JSON into MangaData object

          var mangaData = MangaData.fromJson(dataObject);

          var fetchedData= ContentData.empty();
          fetchedData.imageURI = 'https://temp.compsci88.com/cover/${mangaData.id}.jpg';
          fetchedData.contentURI = "$baseURI/manga/${mangaData.id}";
          fetchedData.websiteURI = baseURI;
          fetchedData.title = mangaData.series;
          fetchedData.author = mangaData.authors.join(", ");
          fetchedData.status = mangaData.status;
          fetchedData.year = mangaData.year;
          fetchedData.itemID = mangaData.id;
          fetchedData.lastUpdated = mangaData.lastUpdated;
          fetchedData.nsfw = mangaData.hentai;
          fetchedData.genre = mangaData.genres;
          fetchedData.contentIndex = contentList.length;
          fetchedData.contentType = contentType;
          fetchedData.contentSource = contentSource;
          
          // Add MangaData object to the list
          contentList.add(fetchedData);
        }
      }
      return contentList;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<String>> fetchBrowseGenreList() async {
    return ['Action','Adult','Adventure','Comedy','Doujinshi','Drama','Ecchi',
    'Fantasy','Gender Bender','Harem','Hentai','Historical','Horror','Isekai',
    'Josei','Lolicon','Martial Arts','Mature','Mecha','Mystery','Psychological',
    'Romance','School Life','Sci-fi','Seinen','Shotacon','Shoujo','Shoujo Ai',
    'Shounen','Shounen Ai','Slice of Life','Smut','Sports','Supernatural','Tragedy',
    'Yaoi','Yuri'];
  }

  @override
  Future<List<ContentData>> fetchSearch(List<ContentData> cardItems, List<int> pageNumbers, List<String> genreList, {String searchTerm = '_any'}) async {
    // Function to sanitize input by removing non-alphanumeric characters and converting to lowercase
    String sanitize(String input) {
      return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    }

    // Sanitize the search input
    String sanitizedSearchInput = sanitize(searchTerm);

    // Filter card items based on title and genres
    List<ContentData> results = cardItems.where((card) {
      bool matchesTitle = true;

      if (searchTerm != '_any'){
        matchesTitle = sanitize(card.title).contains(sanitizedSearchInput);
      }

      bool matchesGenres = genreList.every((genre) => card.genre.contains(genre));

      return matchesTitle && matchesGenres;
    }).toList();

    return results;
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
      var nodes = document.querySelectorAll('script');
      // Process each script node
      List<dynamic> chapterList = [];
      for (var scriptNode in nodes) {
        if (!scriptNode.text.contains("MainFunction")) {
          continue;
        }
        // Extract content from the script tag
        var content = scriptNode.text;
        var chapterListString = substringBefore(
            substringAfter(content, "vm.Chapters = "), ";")
            .trim();
        chapterList = jsonDecode(chapterListString);
        for (var chapter in chapterList){
          var chapterData = Chapter.fromJson(chapter);

          int mainChapterNumber = int.parse(chapterData.chapter.substring(2, 5));
          double fractionalPart = int.parse(chapterData.chapter.substring(5)) / 10.0;

          double actualChapterNumber = mainChapterNumber + fractionalPart;

          var fetchedData= ContentData.empty();
            fetchedData.contentURI = '$baseURI/read-online/${cardItem.itemID}-chapter-$actualChapterNumber.html';
            fetchedData.title = (chapterData.chapterName.trim() == "null" || chapterData.chapterName.trim() == "") ? "Chapter ${cardItem.contentList.length+1}": chapterData.chapterName;
            fetchedData.itemID = cardItem.itemID;
            fetchedData.lastUpdated = chapterData.date;
            fetchedData.contentIndex = cardItem.contentList.length+1;
            fetchedData.contentType = contentType;
            fetchedData.contentSource = contentSource;
            if (!cardItem.contentList.contains(fetchedData)){
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
      List<String> imageURIs = [];

      var nodes = document.querySelectorAll('script');
      // Process each script node
      for (var scriptNode in nodes) {
        if (!scriptNode.text.contains("MainFunction")) {
          continue;
        }
        // Extract content from the script tag
        var content = scriptNode.text;
        var directory = substringBefore(
          substringAfter(content, "vm.CurPathName = \""), "\"")
          .replaceAll(";", " ")
          .trim();
        

        var chapterListString = substringBefore(
            substringAfter(content, "vm.CHAPTERS = "), ";")
            .trim();

        List<dynamic> chapterList = [];
        chapterList = jsonDecode(chapterListString);
        for (var chapter in chapterList) {
          var chapterData = Chapter.fromJson(chapter);
          int totalPages = int.parse(chapterData.page); 
          int mainChapterNumber = int.parse(chapterData.chapter.substring(2, 5));
          double fractionalPart = int.parse(chapterData.chapter.substring(5)) / 10.0;

          num actualChapterNumber; // Use num type to accommodate both int and double

          if (fractionalPart == 0.0) {
            actualChapterNumber = mainChapterNumber; // If fractional part is 0, assign integer
          } else {
            actualChapterNumber = mainChapterNumber + fractionalPart; // If fractional part is not 0, assign double
          }

          for (int i = 1; i <= totalPages; i++) {
            String paddedContentIndex;
            if (fractionalPart == 0.0) {
              paddedContentIndex = actualChapterNumber.toInt().toString().padLeft(4, '0');
            } else {
              paddedContentIndex = actualChapterNumber.toString().padLeft(4, '0');
            }

            String paddedPage = i.toString().padLeft(3, '0'); 
                    
            var chapterURI = "https://$directory/manga/${contentData.itemID}/${paddedContentIndex}-${paddedPage}.png";

            imageURIs.add(chapterURI);
          }
        }
      }

      return imageURIs;
    } catch (e) {
      return ['Error: $e'];
    }
  }


  @override
  String fetchContentImageUrl(Document document, ContentData cardItem) {
    if (cardItem.imageURI != ""){
      return cardItem.imageURI;
    }
    return "https://via.placeholder.com/150";
  }

  @override
  String fetchContentAuthor(Document document, ContentData cardItem) {
    if (cardItem.author != ""){
      return cardItem.author;
    }
    return "cardItem.author";
  }

  @override
  List<String> fetchContentSummary(Document document, ContentData cardItem) {
    var nodes = document.querySelectorAll('li.list-group-item div');

    List<String> descriptions = [];
    for (var node in nodes) {
      if (node.previousElementSibling?.text == "Description:"){
        descriptions.add(node.text);
      }
    }

    return descriptions;
  }

  @override
  List<String> fetchContentGenre(Document document, ContentData cardItem) {
    var nodes = document.querySelectorAll('li.list-group-item a');

    List<String> genres = [];
    for (var node in nodes) {
      var text = node.parentNode?.text?.trim();
      if (text != null && text.contains("Genre(s):")){
        genres.add(node.text);
      }
    }
    return genres;
  }
}


class MangaData {
  final String id;
  final String series;
  final String ongoing;
  final String status;
  final String type;
  final String volume;
  final String volumeId;
  final String year;
  final List<String> authors;
  final List<String> altTitles;
  final String lastUpdated;
  final List<String> genres;
  final bool hentai;

  MangaData({
    required this.id,
    required this.series,
    required this.ongoing,
    required this.status,
    required this.type,
    required this.volume,
    required this.volumeId,
    required this.year,
    required this.authors,
    required this.altTitles,
    required this.lastUpdated,
    required this.genres,
    required this.hentai,
  });

  factory MangaData.fromJson(dynamic json) {
    if (json is String) {
      json = jsonDecode(json);
    }

    return MangaData(
      id: json['i'].toString(),
      series: json['s'].toString(),
      ongoing: json['o'].toString(),
      status: json['ss'].toString(),
      type: json['t'].toString(),
      volume: json['v'].toString(),
      volumeId: json['vm'].toString(),
      year: json['y'].toString(),
      authors: List<String>.from(json['a'] ?? []),
      altTitles: List<String>.from(json['al'] ?? []),
      lastUpdated: json['ls'].toString(),
      genres: List<String>.from(json['g'] ?? []),
      hentai: json['h'] ?? false,
    );
  }
}

class Chapter {
  String chapter;
  String type;
  String date;
  String chapterName;
  String page;

  Chapter({
    required this.chapter,
    required this.type,
    required this.date,
    required this.chapterName,
    required this.page,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapter: json['Chapter'].toString(),
      type: json['Type'].toString(),
      date: json['Date'].toString(),
      chapterName: json['ChapterName'].toString(),
      page: json['Page'].toString(),
    );
  }
}