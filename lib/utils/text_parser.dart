
String substringBetween(String source, String delimiterBefore, String delimiterAfter) {
  return substringBefore(substringAfter(source, delimiterBefore), delimiterAfter).trim();
}

String substringBefore(String source, String delimiter) {
  final index = source.indexOf(delimiter);
  return index == -1 ? source : source.substring(0, index);
}

String substringAfter(String source, String delimiter) {
  final index = source.indexOf(delimiter);
  return index == -1 ? '' : source.substring(index + delimiter.length);
}

String sanitize(String input) {
  return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();
}