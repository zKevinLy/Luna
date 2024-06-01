import 'package:luna/models/page_info.dart';
import 'package:shared_preferences/shared_preferences.dart';


void saveSelectedSources(PageData pageData) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  for (var entry in pageData.selectedSources.entries) {
    prefs.setBool(entry.key, entry.value);
  }
}

List<String> getActiveGenres(Map<String, dynamic> selectedFilters) {
  return selectedFilters.entries
    .where((entry) => entry.value == true)
    .map((entry) => entry.key)
    .toList();
}

List<String> getActiveSources(Map<String, dynamic> selectedSources) {
  return selectedSources.entries
    .where((entry) => entry.value == true)
    .map((entry) => entry.key)
    .toList();
}
