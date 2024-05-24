import 'dart:ffi';

class BaseContent {
  int contentIndex;
  String contentType; //(novel, anime, movie, etc...)
  String contentSource; //(light_novel_pub, 9anime, etc...)

  bool viewed;
  int viewedAmount;
  
  BaseContent({
    required this.contentIndex,
    required this.contentType,
    required this.contentSource,

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
      chapterNo: '',
      lastUpdated: '',
      summary: [],
      genre: [],
      contentList: [],
      contentIndex: 0,
      contentType: '',
      contentSource: '',
      viewed: false,
      viewedAmount: 0,
    );
  }
}
