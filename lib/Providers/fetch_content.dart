import 'package:luna/Providers/manga/mangasee.dart';
import 'package:luna/components/pages/controllers/shared_preferences.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/Providers/novels/light_novel_pub.dart';
import 'package:luna/Providers/manga/batoto.dart';
import 'package:luna/models/page_info.dart';
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

Future<void> fetchBrowseList(PageData pageData, List<int> pageNumbers, {String searchTerm = ""}) async {
  var sourceList = getActiveSources(pageData.selectedSources);

  // Check if the source list is empty or if it doesn't match the expected source list
  if (sourceList.isEmpty) {
    switch (sanitize(pageData.selectedTab)) {
      case 'novel':
        pageData.cardItems.addAll(await _lightNovelPub.fetchBrowseList(pageNumbers));
        break;
      case 'manga':
        pageData.cardItems.addAll(await _mangasee.fetchBrowseList(pageNumbers));
        break;
    }
  }

  for (var entry in sourceList) {
    switch (entry) {
      case 'light_novel_pub':
        pageData.cardItems.addAll(await _lightNovelPub.fetchBrowseList(pageNumbers));
        break;
      case 'batoto':
        pageData.cardItems.addAll(await _batoto.fetchBrowseList(pageNumbers));
        break;
      case 'mangasee':
        pageData.cardItems.addAll(await _mangasee.fetchBrowseList(pageNumbers));
        break;
    }
  }
}

Future<void> fetchBrowseGenreList(PageData pageData) async {
  if (!pageData.selectedSources.containsValue(true)){
    switch (sanitize(pageData.selectedTab)) {
      case 'manga':
        for(var genre in await _mangasee.fetchBrowseGenreList()){
          pageData.selectedFilters[genre] = false;
        }
    }
  }

  for (var entry in pageData.selectedSources.entries) {
    if (entry.value == false) {
      continue;
    }
    switch (entry.key) {
      case 'batoto':
        for(var genre in await _batoto.fetchBrowseGenreList()){
          pageData.selectedFilters[genre] = false;
        }
      case 'mangasee':
        for(var genre in await _mangasee.fetchBrowseGenreList()){
          pageData.selectedFilters[genre] = false;
        }
    }
  }
}

Future<void> fetchSearch(PageData pageData, List<int> pageNumbers, {String searchTerm = "_any"}) async {
  var sourceList = getActiveSources(pageData.selectedSources);

  if (sourceList.isEmpty){
    switch (sanitize(pageData.selectedTab)) {
      case 'novel':
        pageData.searchResults.addAll(await _lightNovelPub.fetchBrowseList(pageNumbers));
        break;
      case 'manga':
        // since mangasee returns everything on initial call to fetchBrowseList, we can search within our card items
        pageData.searchResults.addAll(await _mangasee.fetchSearch(pageData, pageNumbers, searchTerm: searchTerm));
        break;
    }
  }

  for (var entry in sourceList) {
    switch (entry) {
      case 'light_novel_pub':
        pageData.searchResults.addAll(await _lightNovelPub.fetchBrowseList(pageNumbers));
        break;
      case 'batoto':
        pageData.searchResults.addAll(await _batoto.fetchBrowseList(pageNumbers, searchTerm: searchTerm));
        break;
      case 'mangasee':
        // since mangasee returns everything on initial call to fetchBrowseList, we can search within our card items
        pageData.searchResults.addAll(await _mangasee.fetchSearch(pageData, pageNumbers, searchTerm: searchTerm));
        break;
    }
  }
}
