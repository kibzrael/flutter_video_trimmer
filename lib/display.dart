import 'package:flutter/material.dart';

class VideoDisplay extends StatefulWidget {
  final String video;

  VideoDisplay(this.video);

  @override
  _VideoDisplayState createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(widget.video),
      ),
    );
  }
}
