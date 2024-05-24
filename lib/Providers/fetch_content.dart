
import 'package:luna/models/content_info.dart';
import 'package:luna/Providers/novels/light_novel_pub.dart';
import 'package:luna/Providers/manga/batoto.dart';

Future<List<String>> fetchContentItem(ContentData cardItem, ContentData contentData) async {
  switch (cardItem.contentSource) {
    case 'light_novel_pub':
      return await LightNovelPub().fetchContentItem(contentData);
    case 'bato_to':
      return await Batoto().fetchContentItem(contentData);
  }
  return [];
}

Future<ContentData> fetchContentData(ContentData cardItem) async {
  switch (cardItem.contentSource) {
    case 'light_novel_pub':
      return await LightNovelPub().fetchContentDetails(cardItem);
    case 'bato_to':
      return await Batoto().fetchContentDetails(cardItem);
  }
  return ContentData.empty();
}