import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path/path.dart' hide context;
import 'package:path_provider/path_provider.dart';
import 'package:video_trimmer/display.dart';
import 'package:video_trimmer/home.dart';

class TrimDialog extends StatefulWidget {
  final Video video;
  final int trimStart;
  final int trimEnd;

  TrimDialog(this.video, {required this.trimStart, required this.trimEnd});

  @override
  _TrimDialogState createState() => _TrimDialogState();
}

class _TrimDialogState extends State<TrimDialog> {
  bool error = false;

  late File video;

  @override
  void initState() {
    super.initState();
    video = widget.video.video;
    trim();
  }

  trim() async {
    FlutterFFmpeg ffmpeg = FlutterFFmpeg();
    Directory directory = await getApplicationDocumentsDirectory();
    String start = durationToString(widget.trimStart);
    String end = durationToString(widget.trimEnd);
    String outputPath = join(directory.absolute.path,
        '${DateTime.now().toString().replaceAll(" ", '_')}video_trim.mp4');
    String command =
        '-i ${video.absolute.path} -ss $start -to $end $outputPath';
    int response = await ffmpeg.execute(command);
    if (response != 0) {
      setState(() {
        error = true;
      });
    } else {
      Navigator.pop(context);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => VideoDisplay(outputPath),
      ));
    }
  }

  String durationToString(int milliseconds) {
    int seconds = milliseconds ~/ 1000;
    milliseconds = milliseconds - (seconds * 1000);

    int minutes = seconds ~/ 60;
    seconds = seconds - (minutes * 60);

    int hours = minutes ~/ 60;
    minutes = minutes - (hours * 60);

    String millipad = milliseconds < 10
        ? "00"
        : milliseconds < 100
            ? "0"
            : "";
    return '${hours > 0 ? '$hours:' : ''}${minutes < 10 ? '0' : ''}$minutes:${seconds < 10 ? '0' : ''}$seconds.$millipad$milliseconds';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (!error)
              ? [
                  CircularProgressIndicator(),
                  SizedBox(width: 15),
                  Text(
                    'Processing...',
                    style:
                        TextStyle(fontSize: 16.5, fontWeight: FontWeight.w500),
                  )
                ]
              : [
                  Icon(Icons.error_outline, size: 50, color: Colors.red),
                  SizedBox(width: 15),
                  Text(
                    'Error trimming',
                    style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.red),
                  )
                ],
        ),
      ),
    );
  }
}
