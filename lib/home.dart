import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? video;

  MediaInfo? videoInfo;

  double videoDuration = 180;

  double maxDuration = 90;

  bool error = false;

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  loadVideo() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      ByteData videoBytes = await rootBundle.load('assets/video.mp4');
      Uint8List videoData = videoBytes.buffer
          .asUint8List(videoBytes.offsetInBytes, videoBytes.lengthInBytes);
      String path = join(directory.path, 'reflectly.mp4');
      if (!await File(path).exists()) {
        video = await File(path).writeAsBytes(videoData);
      } else {
        video = File(path);
      }
      final jsonStr = await VideoCompress.channel
          .invokeMethod('getMediaInfo', {'path': video!.path});
      final jsonMap = json.decode(jsonStr!);
      videoInfo = MediaInfo.fromJson(jsonMap);
      setState(() {
        videoDuration = videoInfo?.duration ?? 180 / 1000;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video trimer'),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: kToolbarHeight),
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: Container(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              padding: EdgeInsets.symmetric(horizontal: 45, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // video Thumbnail
                  Container(
                    // height: width / aspect ratio
                    height: (constraints.maxWidth - 90) * (9 / 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context).cardColor,
                        image: DecorationImage(
                            image: AssetImage('assets/thumb.jpg'))),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Reflectly - Flutter Developer Story',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow),
                        SizedBox(width: 5),
                        // video duration
                        Text(
                          videoInfo == null
                              ? ''
                              : durationToString(videoDuration.ceil()),
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  // Maximum duration of the video to be trimmed

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Set max duration:',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16.5, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(durationToString(maxDuration.ceil()))
                      ],
                    ),
                  ),
                  Slider.adaptive(
                      value: maxDuration,
                      max: videoDuration,
                      onChanged: (value) {
                        //  the minimum is 15 seconds
                        setState(() {
                          if (value >= 15) {
                            maxDuration = value;
                          } else {
                            maxDuration = 15;
                          }
                        });
                      }),
                  SizedBox(height: 12),
                  MaterialButton(
                      child: Text('Trim Video'),
                      elevation: 4,
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Coming soon...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500)),
                          backgroundColor: Colors.blue,
                        ));
                      })
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

String durationToString(int seconds) {
  int minutes = seconds ~/ 60;
  seconds = seconds - (minutes * 60);

  int hours = minutes ~/ 60;
  minutes = minutes - (hours * 60);
  return '${hours > 0 ? '$hours:' : ''}${(minutes < 10) && (hours > 0) ? '0' : ''}$minutes:${seconds < 10 ? '0' : ''}$seconds';
}
