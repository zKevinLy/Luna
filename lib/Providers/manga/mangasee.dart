
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:luna/components/pages/controllers/shared_preferences.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/bases/luna_base_source.dart';
import 'package:luna/models/page_info.dart';
import 'package:luna/utils/text_parser.dart';
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
    if (json is String) json = jsonDecode(json);

    return MangaData(
      id: json['i']?.toString() ?? '',
      series: json['s']?.toString() ?? '',
      ongoing: json['o']?.toString() ?? '',
      status: json['ss']?.toString() ?? '',
      type: json['t']?.toString() ?? '',
      volume: json['v']?.toString() ?? '',
      volumeId: json['vm']?.toString() ?? '',
      year: json['y']?.toString() ?? '',
      authors: List<String>.from(json['a'] ?? []),
      altTitles: List<String>.from(json['al'] ?? []),
      lastUpdated: json['ls']?.toString() ?? '',
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
      chapter: json['Chapter']?.toString() ?? '',
      type: json['Type']?.toString() ?? '',
      date: json['Date']?.toString() ?? '',
      chapterName: json['ChapterName']?.toString() ?? '',
      page: json['Page']?.toString() ?? '',
    );
  }
}

class Mangasee extends ContentSource {
  Mangasee() : super(
    contentType: "image",
    contentSource: "mangasee",
    baseURI: "https://mangasee123.com"
  );

  @override
  Future<String> fetchFaviconURI() async {
    return "https://mangasee123.com/media/favicon.png";
  }

  @override
  Future<List<ContentData>> fetchBrowseList(List<int> pageNumbers, {String genre = 'all', String orderBy = 'field_upload', String status = 'all', String searchTerm = '_any'}) async {
    try {
      var pageResponse = await http.get(Uri.parse('$baseURI/search/?sort=lt&desc=true&name=$searchTerm'));
      var pageDocument = parse(pageResponse.body);

      var contentList = <ContentData>[];

      var nodes = pageDocument.querySelectorAll('script')
        .where((script) => script.text.contains("MainFunction"));
      
      List<dynamic> dataList = [];

      for (var script in nodes) {
        var directory = substringBetween(script.text, "vm.Directory = ", "vm.GetIntValue").replaceAll(";", " ").trim();
        dataList = jsonDecode(directory);
        
        for (var dataObject in dataList) {
          var mangaData = MangaData.fromJson(dataObject);

          var fetchedData = ContentData.empty()
            ..imageURI = 'https://temp.compsci88.com/cover/${mangaData.id}.jpg'
            ..contentURI = "$baseURI/manga/${mangaData.id}"
            ..websiteURI = baseURI
            ..title = mangaData.series
            ..author = mangaData.authors.join(", ")
            ..status = mangaData.status
            ..year = mangaData.year
            ..itemID = mangaData.id
            ..lastUpdated = mangaData.lastUpdated
            ..nsfw = mangaData.hentai
            ..genre = mangaData.genres
            ..contentIndex = contentList.length
            ..contentType = contentType
            ..contentSource = contentSource;

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

  Future<List<ContentData>> fetchSearch(PageData pageData, List<int> pageNumbers, {String searchTerm = '_any'}) async {
    // Sanitize the search input
    String sanitizedSearchInput = sanitize(searchTerm);

    // Filter card items based on title and genres
    List<ContentData> results = pageData.cardItems.where((card) {
      bool matchesTitle = true;

      if (searchTerm != '_any'){
        matchesTitle = sanitize(card.title).contains(sanitizedSearchInput);
      }

      bool matchesGenres = getActiveGenres(pageData.selectedFilters).every((genre) => card.genre.contains(genre));

      return matchesTitle && matchesGenres;
    }).toList();

    return results;
  }

  @override
  Future<List<ContentData>> fetchContentList(ContentData cardItem, Document document) async {
    try {
      // Fetch the first page to get totalChapters
      var firstPageResponse = await http.get(Uri.parse(cardItem.contentURI));
      var firstPageDocument = parse(firstPageResponse.body);

      await _fetchPageContentChapter(cardItem, firstPageDocument);

      // Fix the ordering
      cardItem.contentList.sort((a, b) {
        double itemIDA = double.tryParse(a.itemID) ?? a.contentIndex.toDouble();
        double itemIDB = double.tryParse(b.itemID) ?? b.contentIndex.toDouble();
        return itemIDA.compareTo(itemIDB);
      });

      return cardItem.contentList.cast<ContentData>();
    } catch (e) {
      return [];
    }
  }

  Future<void> _fetchPageContentChapter(ContentData cardItem, Document document) async {
    try {
      final nodes = document.querySelectorAll('script').where((script) => script.text.contains("MainFunction"));

      for (var scriptNode in nodes) {
        final content = scriptNode.text;
        final chapterListString = substringBetween(content, "vm.Chapters = ", ";");
        if (chapterListString == '') continue;

        final chapterList = List<dynamic>.from(jsonDecode(chapterListString));
        
        for (var chapter in chapterList) {
          final chapterData = Chapter.fromJson(chapter);
          final mainChapterNumber = int.parse(chapterData.chapter.substring(2, 5));
          final fractionalPart = int.parse(chapterData.chapter.substring(5)) / 10.0;
          final actualChapterNumber = mainChapterNumber + fractionalPart;

          final fetchedData = ContentData.empty()
            ..contentURI = '$baseURI/read-online/${cardItem.itemID}-chapter-$actualChapterNumber.html'
            ..title = (chapterData.chapterName.trim().isEmpty || chapterData.chapterName.trim() == "null")
                ? "Chapter ${cardItem.contentList.length + 1}"
                : chapterData.chapterName
            ..itemID = cardItem.itemID
            ..lastUpdated = chapterData.date
            ..contentIndex = cardItem.contentList.length + 1
            ..contentType = contentType
            ..contentSource = contentSource;

          if (!cardItem.contentList.contains(fetchedData)) {
            cardItem.contentList.add(fetchedData);
          }
        }
      }
    } catch (e) {
      return;
    }
  }


  @override
  Future<void> fetchContentItem(ContentData cardItem, ContentData contentData) async {
    try {
      final response = await http.get(Uri.parse(contentData.contentURI));
      final document = parse(response.body);

      final nodes = document.querySelectorAll('script')
          .where((script) => script.text.contains("MainFunction"));

      for (var script in nodes) {
        final directory = substringBetween(script.text, "vm.CurPathName = \"", "\"").replaceAll(";", "").trim();
        final chapterListString = substringBetween(script.text, "vm.CHAPTERS = ", ";");

        if (directory == '' || chapterListString == '') continue;

        final chapterList = List<dynamic>.from(jsonDecode(chapterListString));
        
        for (var chapter in chapterList) {
          final chapterData = Chapter.fromJson(chapter);
          final totalPages = int.parse(chapterData.page);
          final mainChapterNumber = int.parse(chapterData.chapter.substring(2, 5));
          final fractionalPart = int.parse(chapterData.chapter.substring(5)) / 10.0;
          final actualChapterNumber = mainChapterNumber + (fractionalPart == 0.0 ? 0 : fractionalPart);

          for (int i = 1; i <= totalPages; i++) {
            final paddedContentIndex = actualChapterNumber.toStringAsFixed(fractionalPart == 0.0 ? 0 : 1).padLeft(4, '0');
            final paddedPage = i.toString().padLeft(3, '0');
            contentData.contentList.add("https://$directory/manga/${contentData.itemID}/$paddedContentIndex-$paddedPage.png");
          }
        }
      }
    } catch (e) {
      return;
    }
  }


  @override
  String fetchContentImageUrl(ContentData cardItem, Document document) {
    if (cardItem.imageURI != ""){
      return cardItem.imageURI;
    }
    return "https://via.placeholder.com/150";
  }

  @override
  String fetchContentAuthor(ContentData cardItem, Document document) {
    if (cardItem.author != ""){
      return cardItem.author;
    }
    return "cardItem.author";
  }

  @override
  List<String> fetchContentSummary(ContentData cardItem, Document document) {
    return document
        .querySelectorAll('li.list-group-item div')
        .where((node) => node.previousElementSibling?.text == "Description:")
        .map((node) => node.text)
        .toList();
  }

  @override
  List<String> fetchContentGenre(ContentData cardItem, Document document) {
    return document
        .querySelectorAll('li.list-group-item a')
        .where((node) => node.parentNode?.text?.trim().contains("Genre(s):") ?? false)
        .map((node) => node.text)
        .toList();
  }
}
