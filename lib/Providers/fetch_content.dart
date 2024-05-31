
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

Future<List<ContentData>> fetchBrowseList(String tabType, List<int> pageNumbers, List<String> sourceList, {String searchTerm = ""}) async {
  List<ContentData> results = [];
  if (sourceList.isEmpty) {
    switch (tabType) {
      case 'novel':
        results.addAll(await LightNovelPub().fetchBrowseList(pageNumbers));
        break;
      case 'manga':
        results.addAll(await Mangasee().fetchBrowseList(pageNumbers));
        break;
    }
  }

  for (var entry in sourceList) {
    switch (entry) {
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


Future<List<String>> fetchBrowseGenreList(String tabType, {Map<String, dynamic> selectedSources = const {}}) async {
  if (!selectedSources.containsValue(true)){
    switch (tabType) {
      case 'manga':
        return Mangasee().fetchBrowseGenreList();
    }
  }

  for (var entry in selectedSources.entries) {
    if (entry.value == false) {
      continue;
    }
    switch (entry.key) {
      case 'batoto':
        return Batoto().fetchBrowseGenreList();
      case 'mangasee':
        return Mangasee().fetchBrowseGenreList();
    }
  }
  return [];
}

Future<List<ContentData>> fetchSearch(List<ContentData> cardItems, String tabType, List<int> pageNumbers, List<String> genreList, List<String> sourceList, {String searchTerm = "_any"}) async {
  List<ContentData> results = [];
  if (sourceList.isEmpty){
    switch (tabType) {
      case 'novel':
        results.addAll(await LightNovelPub().fetchBrowseList(pageNumbers));
        break;
      case 'manga':
        // since mangasee returns everything on initial call to fetchBrowseList, we can serch within our carditems
        results.addAll(await Mangasee().fetchSearch(cardItems, pageNumbers, genreList, searchTerm: searchTerm));
        break;
    }
  }

  for (var entry in sourceList) {
    switch (entry) {
      case 'light_novel_pub':
        results.addAll(await LightNovelPub().fetchBrowseList(pageNumbers));
        break;
      case 'batoto':
        results.addAll(await Batoto().fetchBrowseList(pageNumbers, searchTerm: searchTerm));
        break;
      case 'mangasee':
        // since mangasee returns everything on initial call to fetchBrowseList, we can serch within our carditems
        results.addAll(await Mangasee().fetchSearch(cardItems, pageNumbers, genreList, searchTerm: searchTerm));
        break;
    }
  }
  return results;  
}