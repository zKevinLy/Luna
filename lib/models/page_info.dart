import 'package:flutter/material.dart';
import 'package:luna/models/content_info.dart';

class PageData {
  String pageID;
  String pageName;
  String pageURI;

  bool isSearching;
  bool isFiltering;

  List<ContentData> cardItems;
  List<ContentData> searchResults;

  String selectedTab;
  Map<String, dynamic> selectedSources;
  Map<String, dynamic> selectedFilters;

  Map<String, List<String>> tabSources;

  PageData({
    required this.pageID,
    required this.pageName,
    required this.pageURI,

    required this.isSearching,
    required this.isFiltering,

    required this.cardItems,
    required this.searchResults,

    required this.selectedTab,
    required this.selectedSources,
    required this.selectedFilters,

    required this.tabSources,
  });

  // Factory constructor to create an empty ContentData instance
  factory PageData.empty() {
    return PageData(
      pageID: '',
      pageName: '',
      pageURI: '',

      isSearching: false,
      isFiltering: false,

      cardItems: [],
      searchResults: [],

      selectedTab: '',
      selectedSources: {},
      selectedFilters: {},

      tabSources: {},
    );
  }
}
