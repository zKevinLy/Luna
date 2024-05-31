
import 'package:luna/Providers/manga/mangasee.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/Providers/novels/light_novel_pub.dart';
import 'package:luna/Providers/manga/batoto.dart';

Future<List<String>> fetchContentItem(ContentData cardItem, ContentData contentData) async {
  switch (cardItem.contentSource) {
    case 'light_novel_pub':
      return await LightNovelPub().fetchContentItem(contentData);
    case 'bato_to':
      return await Batoto().fetchContentItem(contentData);
    case 'mangasee':
      return await Mangasee().fetchContentItem(contentData);
  }
  return [];
}

Future<ContentData> fetchContentDetails(ContentData cardItem) async {
  switch (cardItem.contentSource) {
    case 'light_novel_pub':
      return await LightNovelPub().fetchContentDetails(cardItem);
    case 'bato_to':
      return await Batoto().fetchContentDetails(cardItem);
    case 'mangasee':
      return await Mangasee().fetchContentDetails(cardItem);
  }
  return ContentData.empty();
}

Future<List<ContentData>> fetchBrowseList(String tabType, List<int> pageNumbers, {Map<String, dynamic> selectedSources = const {}}) async {
  List<ContentData> results = [];
  if (!selectedSources.containsValue(true)) {
    switch (tabType) {
      case 'novel':
        results.addAll(await LightNovelPub().fetchBrowseList(pageNumbers));
        break;
      case 'manga':
        results.addAll(await Mangasee().fetchBrowseList(pageNumbers));
        break;
    }
  }

  for (var entry in selectedSources.entries) {
    if (entry.value == false) {
      continue;
    }
    switch (entry.key) {
      case 'light_novel_pub':
        results.addAll(await LightNovelPub().fetchBrowseList(pageNumbers));
        break;
      case 'batoto':
        results.addAll(await Batoto().fetchBrowseList(pageNumbers));
        break;
      case 'mangasee':
        results.addAll(await Mangasee().fetchBrowseList(pageNumbers));
        break;
    }
  }

  return results;
}


List<String> fetchBrowseGenreList(String tabType) {
  switch (tabType) {
    case 'manga':
      return Batoto().fetchBrowseGenreList();
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