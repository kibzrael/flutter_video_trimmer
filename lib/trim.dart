import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_player/video_player.dart';
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
    });
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
      appBar: AppBar(
        title: Text('Trim Video'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: (video.info.height ?? 9) / (video.info.width ?? 16),
            child: videoController.value.isInitialized
                ? VideoPlayer(videoController)
                : null,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Trimmer(
              position: position,
              duration: duration,
              speed: speed,
              max: maxDuration,
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
