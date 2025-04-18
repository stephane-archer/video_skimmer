import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_skimmer/video_skimmer.dart';

void main() {
  runApp(const VideoSkimmerApp());
}

class VideoSkimmerApp extends StatelessWidget {
  const VideoSkimmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const VideoSelectorScreen(),
    );
  }
}

class VideoSelectorScreen extends StatefulWidget {
  const VideoSelectorScreen({super.key});

  @override
  State<VideoSelectorScreen> createState() => _VideoSelectorScreenState();
}

class _VideoSelectorScreenState extends State<VideoSelectorScreen> {
  String? _videoPath;

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _videoPath = result.files.single.path!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Video Skimmer Demo')),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Pick another video',
            onPressed: _pickVideo,
          ),
        ],
      ),
      body: Center(
        child:
            _videoPath == null
                ? ElevatedButton(
                  onPressed: _pickVideo,
                  child: const Text('Select a Video'),
                )
                : VideoSkimmer(
                  _videoPath!,
                  onTap: (frame) {
                    debugPrint(
                      'Selected frame at: ${frame.videoTimestampInSeconds}s',
                    );
                  },
                ),
      ),
    );
  }
}
