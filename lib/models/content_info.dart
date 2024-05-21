class BaseContent {
  int contentIndex;
  final String contentType; //(novel, anime, movie, etc...)
  final String contentSource; //(light_novel_pub, 9anime, etc...)
  
  BaseContent({
    required this.contentIndex,
    required this.contentType,
    required this.contentSource
  });
}

// Specific content data (chapter/episode data)
// Intentionally keeping it in one ContentData class 
// instead of separating it for the content items within the cards 
class ContentData extends BaseContent{
  String imageURI;
  String contentURI;
  final String websiteURI;

  final String title;
  String author;
  String chapterNo;
  String lastUpdated;

  List<String> summary;
  List<String> genre;
  List<ContentData> contentList;



  ContentData({
    required this.imageURI,
    required this.contentURI,
    required this.websiteURI,
    
    required this.title,
    required this.author,
    required this.chapterNo,
    required this.lastUpdated,

    required this.summary,
    required this.genre,
    required this.contentList,

    required super.contentIndex,
    required super.contentType,
    required super.contentSource,
  });
}
