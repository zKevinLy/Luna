import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:luna/models/content_info.dart';

class VideoViewer extends StatefulWidget {
  final List<String> contentItems;
  final ContentData contentData;

  const VideoViewer({super.key, required this.contentData, required this.contentItems});

  @override
  _VideoViewerState createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    
    if(widget.contentItems.isNotEmpty) {
      _initVideoPlayer();
    }
  }

  void _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.contentItems.first),
    );

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9, // Adjust as needed
    );

    setState(() {}); // Trigger a rebuild after initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contentData.title),
      ),
      body: Center(
        child: _chewieController.videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController)
            : const CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
