
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

Future<List<ContentData>> fetchBrowseList(String tabType, List<int> pageNumbers) async {
  switch (tabType) {
    case 'novel':
      var temp = await LightNovelPub().fetchBrowseList(pageNumbers);
      return temp;
    case 'manga':
      return await Batoto().fetchBrowseList(pageNumbers);
    default:
      return [];
  }
}

Future<List<ContentData>> fetchSearch(String tabType, List<int> pageNumbers, String searchTerm) async {
  switch (tabType) {
    case 'novel':
      return await LightNovelPub().fetchBrowseList(pageNumbers);
    case 'manga':
      return await Batoto().fetchBrowseList(pageNumbers, searchTerm:searchTerm);
    default:
      return [];
  }
}