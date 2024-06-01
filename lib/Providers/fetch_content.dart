import 'package:luna/Providers/manga/mangasee.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/Providers/novels/light_novel_pub.dart';
import 'package:luna/Providers/manga/batoto.dart';
import 'package:luna/utils/text_parser.dart';

// Create singleton instances of your provider classes
final LightNovelPub _lightNovelPub = LightNovelPub();
final Batoto _batoto = Batoto();
final Mangasee _mangasee = Mangasee();

Future<void> fetchContentItem(ContentData cardItem, ContentData contentData) async {
  switch (cardItem.contentSource) {
    case 'light_novel_pub':
      return await _lightNovelPub.fetchContentItem(cardItem, contentData);
    case 'batoto':
      return await _batoto.fetchContentItem(cardItem, contentData);
    case 'mangasee':
      return await _mangasee.fetchContentItem(cardItem, contentData);
  }
}

Future<ContentData> fetchContentDetails(ContentData cardItem) async {
  switch (cardItem.contentSource) {
    case 'light_novel_pub':
      return await _lightNovelPub.fetchContentDetails(cardItem);
    case 'batoto':
      return await _batoto.fetchContentDetails(cardItem);
    case 'mangasee':
      return await _mangasee.fetchContentDetails(cardItem);
  }
  return ContentData.empty();
}

Future<List<ContentData>> fetchBrowseList(String tabName, List<int> pageNumbers, List<String> sourceList, {String searchTerm = ""}) async {
  List<ContentData> results = [];
  if (sourceList.isEmpty) {
    switch (sanitize(tabName)) {
      case 'novel':
        results.addAll(await _lightNovelPub.fetchBrowseList(pageNumbers));
        break;
      case 'manga':
        results.addAll(await _mangasee.fetchBrowseList(pageNumbers));
        break;
    }
  }

  for (var entry in sourceList) {
    switch (entry) {
      case 'light_novel_pub':
        results.addAll(await _lightNovelPub.fetchBrowseList(pageNumbers));
        break;
      case 'batoto':
        results.addAll(await _batoto.fetchBrowseList(pageNumbers));
        break;
      case 'mangasee':
        results.addAll(await _mangasee.fetchBrowseList(pageNumbers));
        break;
    }
  }

  return results;
}

Future<List<String>> fetchBrowseGenreList(String tabName, {Map<String, dynamic> selectedSources = const {}}) async {
  if (!selectedSources.containsValue(true)){
    switch (sanitize(tabName)) {
      case 'manga':
        return _mangasee.fetchBrowseGenreList();
    }
  }

  for (var entry in selectedSources.entries) {
    if (entry.value == false) {
      continue;
    }
    switch (entry.key) {
      case 'batoto':
        return _batoto.fetchBrowseGenreList();
      case 'mangasee':
        return _mangasee.fetchBrowseGenreList();
    }
  }
  return [];
}

Future<List<ContentData>> fetchSearch(List<ContentData> cardItems, String tabName, List<int> pageNumbers, List<String> genreList, List<String> sourceList, {String searchTerm = "_any"}) async {
  List<ContentData> results = [];
  if (sourceList.isEmpty){
    switch (sanitize(tabName)) {
      case 'novel':
        results.addAll(await _lightNovelPub.fetchBrowseList(pageNumbers));
        break;
      case 'manga':
        // since mangasee returns everything on initial call to fetchBrowseList, we can search within our card items
        results.addAll(await _mangasee.fetchSearch(cardItems, pageNumbers, genreList, searchTerm: searchTerm));
        break;
    }
  }

  for (var entry in sourceList) {
    switch (entry) {
      case 'light_novel_pub':
        results.addAll(await _lightNovelPub.fetchBrowseList(pageNumbers));
        break;
      case 'batoto':
        results.addAll(await _batoto.fetchBrowseList(pageNumbers, searchTerm: searchTerm));
        break;
      case 'mangasee':
        // since mangasee returns everything on initial call to fetchBrowseList, we can search within our card items
        results.addAll(await _mangasee.fetchSearch(cardItems, pageNumbers, genreList, searchTerm: searchTerm));
        break;
    }
  }
  return results;  
}
