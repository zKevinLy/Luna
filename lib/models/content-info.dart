class ContentData {
  final int number;
  final String title;
  final DateTime lastUpdated;

  ContentData({
    required this.number,
    required this.title,
    required this.lastUpdated,
  });
}

class ContentInfo {
  final String imageUrl;
  final String title;
  final String author;
  final List<String> summary;
  final List<String> genre;
  final List<ContentData> contentList;
  final String websiteUrl;


  final String contentType;
  final String contentSource;

  ContentInfo({
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.summary,
    required this.genre,
    required this.contentList,
    required this.websiteUrl,


    required this.contentType,
    required this.contentSource,
  });
}
