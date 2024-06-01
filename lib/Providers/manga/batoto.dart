
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/bases/luna_base_source.dart';

class Batoto extends ContentSource {
  Batoto() : super(
    contentType: "image",
    contentSource: "bato_to",
    baseURI: "https://bato.to"
  );

  @override
  Future<List<ContentData>> fetchBrowseList(List<int> pageNumbers, {String genre = 'all', String orderBy = 'field_upload', String status = 'all', String searchTerm='_any'}) async {
    try {
      Map<int, List<ContentData>> contentMap = {};
      var pageFutures = <Future>[];

      for (var pageNumber in pageNumbers) {
        pageFutures.add(() async {
          var statusConfig = "&status=$status";
          if (status == "all"){
            statusConfig = "";
          }
          var searchConfig = "&word=$searchTerm";
          if (searchTerm == "_all"){
            searchConfig = "";
          }
          var pageResponse = await http.get(Uri.parse('$baseURI/v3x-search?sort=$orderBy$searchConfig&lang=en$statusConfig&page=$pageNumber'));
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
        
        var fetchedData= ContentData.empty();
        fetchedData.imageURI = imageURI;
        fetchedData.contentURI = "$baseURI$partialURI";
        fetchedData.websiteURI = baseURI;
        fetchedData.title = title.trim();
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
  Future<List<String>> fetchBrowseGenreList() async {
    List<String> genres = [
      'Artbook', 'Cartoon', 'Comic', 'Doujinshi', 'Imageset', 'Manga', 'Manhua', 'Manhwa', 'Webtoon', 'Western', 
      '4-Koma', 'Oneshot', 'Shoujo(G)', 'Shounen(B)', 'Josei(W)', 'Seinen(M)', 'Yuri(GL)', 'Yaoi (BL)', 'Bara(ML)', 
      'Kodomo(Kid)', 'Silver & Golden', 'Non-human', 'Gore', 'Bloody', 'Violence', 'Ecchi', 'Adult', 'Mature', 
      'Smut', 'Hentai', 'Action', 'Boys', 'Adaptation', 'Adventure', 'Age Gap', 'Aliens', 'Animals', 'Cars', 
      'Cheating/Infidelity', 'Childhood Friends', 'College life', 'Comedy', 'Anthology', 'Contest winning', 
      'Crossdressing', 'Delinquents', 'Dementia', 'Demons', 'Drama', 'Dungeons', 'Fetish', 'Full Color', 'Game', 
      'Gender Bender', 'Genderswap', 'Ghosts', 'Emperor\'s daughter', 'Girls', 'Fantasy', 'Gyaru', 'Harlequin', 
      'Historical', 'Horror', 'Incest', 'Isekai', 'Kids', 'Magic', 'Mecha', 'Medical', 'Military', 'Monster Girls', 
      'Monsters', 'Music', 'Mystery', 'Netorare/NTR', 'Office Workers', 'Reverse Harem', 'Shoujo ai', 'Supernatural', 
      'Villainess', 'Revenge', 'Omegaverse', 'Parody', 'Philosophical', 'Police', 'Reverse Isekai', 'Romance', 
      'Royal family', 'Post-Apocalyptic', 'Royalty', 'Psychological', 'Regression', 'Samurai', 'School Life', 
      'Shounen ai', 'Showbiz', 'Slice of Life', 'SM/BDSM/SUB-DOM', 'Space', 'Sports', 'Survival', 'Thriller', 
      'Time Travel', 'Video Games', 'Virtual Reality', 'Wuxia', 'Tower Climbing', 'Xianxia', 'Traditional Games', 
      'Tragedy', 'Xuanhuan', 'Yakuzas', 'Beasts', 'Cooking', 'Magical Girls', 'Super Power', 'Transmigration', 
      'Zombies', 'Bodyswap', 'Crime', 'Fan-Colored', 'Harem', 'Martial Arts', 'Ninja', 'Reincarnation', 'Sci-Fi', 
      'Superhero', 'Vampires'
    ];
    return genres;
  }

  @override
  Future<List<ContentData>> fetchContentList(ContentData cardItem, Document document) async {
    try {
      // Fetch the first page to get totalChapters
      var firstPageResponse = await http.get(Uri.parse(cardItem.contentURI));
      var firstPageDocument = parse(firstPageResponse.body);

      await _fetchPageContentChapter(cardItem, document);

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
          final timeElement = divElement.getElementsByTagName('time');

          var itemID = "Undefined";
          if (chapterTitleElement!= null){
            itemID = chapterTitleElement.text.trim();
          }
          var title = partialElement[0].text.trim();
          final partialURI = partialElement[0].attributes['href'] as String;
          
          var lastUpdated = "Undefined";
          if (timeElement.isNotEmpty){
            lastUpdated = timeElement[0].attributes['time'] as String;
          }


          var fetchedData= ContentData.empty();
          fetchedData.contentURI = "$baseURI$partialURI";
          fetchedData.title = title;
          fetchedData.itemID = itemID;
          fetchedData.lastUpdated = lastUpdated;
          fetchedData.contentIndex = cardItem.contentList.length+1;
          fetchedData.contentType = contentType;
          fetchedData.contentSource = contentSource;

          cardItem.contentList.add(fetchedData);

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
      List<Element> contentElementContainer = document.getElementsByTagName('astro-island');

      if (contentElementContainer.isEmpty) {
        return;
      }
      

      for (int i = 0; i < contentElementContainer.length; i++) {
        Element astroIsland = contentElementContainer[i];
        if (!astroIsland.attributes.containsKey("props")){
          continue;
        }
        if (astroIsland.attributes.containsKey("props") && astroIsland.attributes['props'].toString().contains("imageFiles")) {
          var jsonString = astroIsland.attributes['props'].toString();
          List<dynamic> images = jsonDecode(jsonDecode(jsonString)["imageFiles"][1]);
          
          for (var image in images) {
            var imageURI = image[1];
            contentData.contentList.add(imageURI);
          }
        }
      }
    
      return;
    } catch (e) {
      return;
    }
  }


  @override
  String fetchContentImageUrl(ContentData cardItem, Document document) {
    final imgElement = document.querySelector('img');
    final src = imgElement?.attributes['src'];
    if (src == null) {
      return 'https://via.placeholder.com/150';
    }

    return src;
  }

  @override
  String fetchContentAuthor(ContentData cardItem, Document document) {
    var author = "Author not found";
    var authorElement = document.querySelector('[class*="mt-2 text-sm md:text-base opacity-80"]');
    if (authorElement != null){
      author = authorElement.text.trim();
    }
    return author;
  }

  @override
  List<String> fetchContentSummary(ContentData cardItem, Document document) {
    final summaryElement = document.querySelector('[class*="limit-html-p"]');
    if (summaryElement == null) {
      return ['Summary not found'];
    }
    return [utf8.decode(latin1.encode(summaryElement.text))];
  }

  @override
  List<String> fetchContentGenre(ContentData cardItem, Document document) {
    List<String> genres = [];
    var contentElementContainer = document.querySelector('[class*="flex items-center flex-wrap"]');
    if (contentElementContainer != null){
      var excludeGenreProp = contentElementContainer.text.trim().substring(7);
      genres = excludeGenreProp.split(",");
    }
    return genres;
  }
}
