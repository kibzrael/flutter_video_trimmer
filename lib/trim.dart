import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/dialog.dart';
import 'package:video_trimmer/home.dart';
import 'package:video_trimmer/trimmer.dart';

class TrimVideoPage extends StatefulWidget {
  final Video video;
  final double maxDuration;
  TrimVideoPage(this.video, {required this.maxDuration});
  @override
  _TrimVideoPageState createState() => _TrimVideoPageState();
}

class _TrimVideoPageState extends State<TrimVideoPage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late Video video;

  List<Uint8List?> thumbnails = [];

  late VideoPlayerController videoController;

  double speed = 1.0;

  // in milliseconds
  double position = 0.0;
  double duration = 3000.0;

  int get maxDuration => widget.maxDuration.floor();

  int trimStart = 0;
  late int trimEnd;

  @override
  void initState() {
    super.initState();
    video = widget.video;
    duration = video.info.duration ?? 3000.0;
    _ticker = this.createTicker((elapsed) {
      position = videoController.value.position.inMilliseconds.toDouble();

      if ((position >= (trimEnd * speed)) || (position < (trimStart * speed))) {
        videoController
            .seekTo(Duration(milliseconds: (trimStart * speed).floor()));
      }
      if (position < trimStart * speed) {
      } else {
        setState(() {});
      }
    });

    videoController = VideoPlayerController.file(video.video);
    videoController.initialize().then((value) {
      videoController.setLooping(true);
      trimEnd = videoController.value.duration.inMilliseconds > maxDuration
          ? maxDuration
          : videoController.value.duration.inMilliseconds;
      duration = videoController.value.duration.inMilliseconds.toDouble();
      videoController.play();
      _ticker.start();
      getThumbnails();
    });
  }

  getThumbnails() async {
    int stepSize = maxDuration ~/ 9;
    for (int step = 0; step < duration / stepSize; step++) {
      int position = stepSize * step;
      Uint8List? thumbnail = await VideoCompress.getByteThumbnail(
          video.video.path,
          position: position * 1000);
      thumbnails.add(thumbnail);
    }
  }

  @override
  void dispose() {
    videoController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text('Trim Video'), actions: [
        TextButton(
            onPressed: () {
              videoController.pause();
              setState(() {});
              showDialog(
                context: context,
                builder: (context) {
                  return TrimDialog(
                    video,
                    trimStart: trimStart,
                    trimEnd: trimEnd,
                  );
                },
              );
            },
            child: Text('Done',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)))
      ]),
      body: Stack(
        alignment: Alignment.center,
        children: [
          InkWell(
            onTap: () {
              if (videoController.value.isPlaying) {
                videoController.pause();
              } else {
                videoController.play();
              }
              setState(() {});
            },
            child: AspectRatio(
              aspectRatio: (video.info.height ?? 9) / (video.info.width ?? 16),
              child: videoController.value.isInitialized
                  ? VideoPlayer(videoController)
                  : null,
            ),
          ),
          if (videoController.value.isInitialized &&
              !videoController.value.isPlaying)
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 96),
          Align(
            alignment: Alignment.bottomCenter,
            child: Trimmer(
              position: position,
              duration: duration,
              speed: speed,
              max: maxDuration,
              thumbnails: thumbnails,
              onUpdate: (start, end) {
                setState(() {
                  trimStart = start.floor();
                  trimEnd = end.floor();
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
