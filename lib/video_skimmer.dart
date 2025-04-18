import 'dart:ui' as ui;

import 'package:extract_video_frame/extract_video_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_duration/video_duration.dart';

String _formatTimestamp(double timestampInSeconds) {
  final int hours = timestampInSeconds ~/ 3600;
  final int minutes = (timestampInSeconds % 3600) ~/ 60;
  final int seconds = (timestampInSeconds % 60).toInt();

  final hoursStr = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
  final String minutesStr = minutes.toString().padLeft(2, '0');
  final String secondsStr = seconds.toString().padLeft(2, '0');

  return '$hoursStr$minutesStr:$secondsStr';
}

double _getTimestampInSeconds(
  double progressPercentage,
  double videoDurationInSeconds,
) {
  if (progressPercentage < 0 || progressPercentage > 100) {
    throw ArgumentError(
      "Progress percentage must be between 0 and 100: $progressPercentage",
    );
  }
  final double timestampInSeconds =
      videoDurationInSeconds * progressPercentage / 100;
  return timestampInSeconds;
}

@immutable
class SelectedFrame {
  final ui.Image image;
  final double videoTimestampInSeconds;

  const SelectedFrame({
    required this.image,
    required this.videoTimestampInSeconds,
  });
}

class VideoSkimmer extends StatefulWidget {
  final String videoPath;
  final Future<double> futureVideoDuration;
  final void Function(SelectedFrame)? onTap;
  final Color skimmerColor;

  VideoSkimmer(
    this.videoPath, {
    super.key,
    this.onTap,
    this.skimmerColor = Colors.deepOrange,
  }) : futureVideoDuration = getVideoDuration(videoPath);

  @override
  VideoSkimmerState createState() => VideoSkimmerState();
}

class VideoSkimmerState extends State<VideoSkimmer> {
  double progressPercentage = 0;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double skimmerHeight = screenWidth * (9 / 16); // 16:9 aspect ratio

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30), // for timecode
        child: FutureBuilder<double>(
          future: widget.futureVideoDuration,
          builder: (context, durationSnapshot) {
            if (!durationSnapshot.hasData) {
              return SizedBox(
                width: screenWidth,
                height: skimmerHeight,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final double videoDurationInSeconds = durationSnapshot.data!;
            final double timestampInSeconds = _getTimestampInSeconds(
              progressPercentage,
              videoDurationInSeconds,
            );
            return SizedBox(
              width: screenWidth,
              height: skimmerHeight,
              child: ColoredBox(
                color: Colors.black,
                child: MouseRegion(
                  onHover: (PointerHoverEvent event) {
                    final box = context.findRenderObject() as RenderBox;
                    final ui.Offset localPosition = box.globalToLocal(
                      event.position,
                    );
                    final double progress =
                        (localPosition.dx / box.size.width) * 100;
                    setState(() {
                      progressPercentage = progress.clamp(0, 100);
                    });
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.expand,
                    children: [
                      _VideoThumbnailPreview(
                        widget.videoPath,
                        timestampInSeconds,
                        onThumbnailTap: widget.onTap,
                      ),
                      Positioned(
                        left:
                            progressPercentage == 0
                                ? 0
                                : progressPercentage *
                                    (context.findRenderObject() as RenderBox)
                                        .size
                                        .width /
                                    100,
                        top: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: Container(
                            width: 2,
                            color: widget.skimmerColor,
                          ),
                        ),
                      ),
                      // Positioned timestamp text that follows the play head
                      Positioned(
                        left:
                            progressPercentage == 0
                                ? 0
                                : progressPercentage *
                                    (context.findRenderObject() as RenderBox)
                                        .size
                                        .width /
                                    100,
                        bottom: -30,
                        child: Transform.translate(
                          offset:
                              timestampInSeconds > (60 * 60)
                                  ? Offset(
                                    -35,
                                    0,
                                  ) // offset for timestamp longer than 1h
                                  : Offset(-25, 0),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatTimestamp(timestampInSeconds),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VideoThumbnailPreview extends StatefulWidget {
  final void Function(SelectedFrame)? onThumbnailTap;
  final Future<ui.Image> futureImage;
  final double timestampInSeconds;

  _VideoThumbnailPreview(
    String sourceVideoPath,
    this.timestampInSeconds, {
    this.onThumbnailTap,
  }) : futureImage = extractVideoFrameAt(
         videoFilePath: sourceVideoPath,
         positionInSeconds: timestampInSeconds,
       );

  @override
  State<_VideoThumbnailPreview> createState() => _VideoThumbnailPreviewState();
}

class _VideoThumbnailPreviewState extends State<_VideoThumbnailPreview> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: widget.futureImage,
      builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final ui.Image? image = snapshot.data;
        if (image == null) {
          return const Center(child: Text("Failed to load thumbnail"));
        }
        return GestureDetector(
          onTap:
              () => widget.onThumbnailTap?.call(
                SelectedFrame(
                  image: image,
                  videoTimestampInSeconds: widget.timestampInSeconds,
                ),
              ),
          child: RawImage(
            image: image,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      },
    );
  }
}
