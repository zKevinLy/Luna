// All Content has these  basic info
import 'dart:ffi';

class BaseContent {
  final String contentType; //(novel, anime, movie, etc...)
  final String contentSource; //(light-novel-pub, 9anime, etc...)

  BaseContent({
    required this.contentType,
    required this.contentSource
  });
}

// Card previews
class ContentPreview extends BaseContent{
  final String title;
  final String contentURI;
  final String imageURI;

  ContentPreview({
    required this.title,
    required this.contentURI,
    required this.imageURI,

    required super.contentType,
    required super.contentSource,
  });
}

// Specific content data (chapter/episode data)
class ContentData extends ContentPreview {
  final double number;
  final DateTime lastUpdated;

  ContentData({
    required this.number,
    required this.lastUpdated,

    required super.title,
    required super.contentURI,
    required super.imageURI,

    required super.contentType,
    required super.contentSource,
  });
}

// Content Info to display when a user clicks a card
class ContentInfo extends BaseContent{
  final String imageURI;
  final String title;
  final String author;
  final List<String> summary;
  final List<String> genre;
  final List<ContentData> contentList;
  final String websiteURI;

  ContentInfo({
    required this.imageURI,
    required this.title,
    required this.author,
    required this.summary,
    required this.genre,
    required this.contentList,
    required this.websiteURI,

    required super.contentType,
    required super.contentSource,
  });
}
