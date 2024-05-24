import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:luna/models/content_info.dart';

class VideoViewer extends StatefulWidget {
  final List<String> contentItems;
  final ContentData contentData;

  const VideoViewer({super.key, required this.contentData, required this.contentItems});

  @override
  _VideoViewerState createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  final _controller = WebviewController();

  @override
  void initState() {
    super.initState();
    _initializeWebview();
  }

  Future<void> _initializeWebview() async {

    await _controller.initialize();
    
    _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
    
    await _controller.loadUrl('https://vidsrc.to/embed/movie/tt0848228');

    if (!mounted) return;
    setState(() {});
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contentData.title),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? Webview(_controller)
            : const CircularProgressIndicator(),
      ),
    );
  }
}
