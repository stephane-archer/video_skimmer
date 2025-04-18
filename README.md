# 🎞️ video_skimmer

A lightweight Flutter widget that brings Final Cut-style video skimming to your apps.
Hover your mouse across the video container and preview frames instantly, just like pro editing tools!

Built with ❤️ for MacOS and Windows. Contributions welcome to extend platform support and squash bugs!

## ✨ Features

- Skim through video by simply hovering your mouse.
- Preview frames dynamically with minimal lag.
- Timestamp indicator follows your cursor.
- Tap to select a frame and get the video timestamp + image.
- Supports 16:9 video preview layout by default.

## 📦 Installation

You can add video_skimmer to your project in two ways:

### Option 1: Manually edit pubspec.yaml

Add video_skimmer to your pubspec.yaml dependencies:
```yaml
dependencies:
  video_skimmer: ^0.0.1  # Replace with the latest version
```

Then run:
```bash
flutter pub get
```
### Option 2: Using flutter pub add
Alternatively, you can use the flutter pub add command to automatically add the package to your project:

```bash
flutter pub add video_skimmer
```
This will add the latest version to your pubspec.yaml and run flutter pub get automatically.

## 🚀 Getting Started
Import the package and drop the `VideoSkimmer` widget into your UI:

```dart
import 'package:video_skimmer/video_skimmer.dart';

class MyVideoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoSkimmer(
        'assets/videos/demo.mp4',
        onTap: (selectedFrame) {
          // Do something with selectedFrame.image and selectedFrame.videoTimestampInSeconds
        },
        skimmerColor: Colors.blueAccent,
      ),
    );
  }
}
```

## 🖥️ Supported Platforms

- ✅ MacOS
- ✅ Windows
- ⚠️ Linux / Web / Mobile: Not currently supported — PRs welcome!

## 🧩 Contributing
Want to improve compatibility or fix bugs? You're very welcome!