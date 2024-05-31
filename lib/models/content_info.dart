class BaseContent {
  int contentIndex;
  String contentType; //(novel, anime, movie, etc...)
  String contentSource; //(light_novel_pub, 9anime, etc...)

  bool visible;
  bool viewed;
  int viewedAmount;
  
  BaseContent({
    required this.contentIndex,
    required this.contentType,
    required this.contentSource,

    required this.visible,
    required this.viewed,
    required this.viewedAmount
  });
}

// Specific content data (chapter/episode data)
// Intentionally keeping it in one ContentData class 
// instead of separating it for the content items within the cards 
class ContentData extends BaseContent{
  String imageURI;
  String contentURI;
  String websiteURI;

  String title;
  String author;
  String status;
  String year;
  String itemID;
  String lastUpdated;
  bool nsfw;

  List<String> summary;
  List<String> genre;
  List<ContentData> contentList;

  ContentData({
    required this.imageURI,
    required this.contentURI,
    required this.websiteURI,
    
    required this.title,
    required this.author,
    required this.status,
    required this.year,
    required this.itemID,
    required this.lastUpdated,
    required this.nsfw,

    required this.summary,
    required this.genre,
    required this.contentList,

    required super.contentIndex,
    required super.contentType,
    required super.contentSource,

    required super.visible,
    required super.viewed,
    required super.viewedAmount,
  });

  // Factory constructor to create an empty ContentData instance
  factory ContentData.empty() {
    return ContentData(
      imageURI: '',
      contentURI: '',
      websiteURI: '',

      title: '',
      author: '',
      status: '',
      year: '',
      itemID: '',
      lastUpdated: '',
      nsfw: false,

      summary: [],
      genre: [],
      contentList: [],

      contentIndex: 0,
      contentType: '',
      contentSource: '',

      visible: true,
      viewed: false,
      viewedAmount: 0,
    );
  }
}
