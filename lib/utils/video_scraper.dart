// import 'dart:html';

// import 'package:http/http.dart' as http;
// import 'package:html/parser.dart' as html_parser;
// import 'package:html/dom.dart';

// class VideoScraper {
//   Future<String?> scrapeVideoUrl(String pageUrl) async {
//     try {
//       final response = await http.get(Uri.parse(pageUrl));
//       if (response.statusCode == 200) {
//         final document = html_parser.parse(response.body);
//         Element? iframeEmbed = document.getElementById('iframe-embed');
//         if (iframeEmbed != null && iframeEmbed is IFrameElement) {
//           // Listen to the onLoad event of the iframe
//           await iframeEmbed.onLoad.first;

//           // Accessing the contentWindow of the iframe
//           final contentWindow = iframeEmbed.contentWindow;

//           if (contentWindow != null) {
//             // Accessing elements inside the iframe
//             Element? videoElement = contentWindow.document.querySelector('jw-video');
//             if (videoElement != null) {
//               String? videoUrl = videoElement.attributes['src'];
//               return videoUrl;
//             } else {
//               throw Exception('Video element not found inside the iframe');
//             }
//           } else {
//             throw Exception('Content window of iframe is null');
//           }
//         } else {
//           throw Exception('iframe element not found');
//         }
//       } else {
//         throw Exception('Failed to load page: ${response.statusCode}');
//       }
//     } catch (e) {
//       print(e);
//       return null;
//     }
//   }
// }
