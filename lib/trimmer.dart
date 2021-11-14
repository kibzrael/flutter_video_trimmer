import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_trimmer/home.dart';

class Trimmer extends StatefulWidget {
  final double position;
  final double duration;
  final double speed;
  final int max;
  final List<Uint8List?> thumbnails;
  final Function(double start, double end) onUpdate;

  Trimmer({
    required this.position,
    required this.duration,
    required this.speed,
    required this.max,
    required this.onUpdate,
    required this.thumbnails,
  });

  @override
  _TrimmerState createState() => _TrimmerState();
}

class _TrimmerState extends State<Trimmer> {
  late ScrollController scrollController;

  double get max => widget.max * widget.speed;
  int get maxMilli => max.floor();

  int get min => (3000 * widget.speed).floor();

  double leftHandle = 0.0;
  double rightHandle = 0.0;

  double trimStart = 0.0;
  double trimEnd = 0.0;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);
  }

  scrollListener() {
    setState(() {});
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - (30 + 42 + 5);
    double widthNoCursor = MediaQuery.of(context).size.width - (30 + 42);

    double duration = (widget.duration / 1000) > (maxMilli / 1000)
        ? maxMilli.toDouble()
        : widget.duration;
    double cursor = ((widget.position / duration) * width) + 21.toDouble();

    double minWidth = (min / duration) * width;
    double moveableWidth =
        MediaQuery.of(context).size.width - (30 + 42 + minWidth);

    trimStart = ((leftHandle / widthNoCursor) * duration) / widget.speed;
    trimEnd =
        (duration - ((rightHandle / widthNoCursor) * duration)) / widget.speed;

    double scrollFactor = 0;
    if (scrollController.hasClients) {
      double scrollPosition = scrollController.position.pixels;
      double maxScroll = scrollController.position.maxScrollExtent;
      if (maxScroll > 0) {
        scrollFactor =
            (scrollPosition / maxScroll) * (widget.duration - duration);
      }
      double cursorMovement =
          scrollPosition / (widthNoCursor + 42) * widthNoCursor;
      // cursorMovement -= 42;
      cursor -= cursorMovement;
    }

    trimStart += scrollFactor;
    trimEnd += scrollFactor;

    double thumbsWidth = (widget.duration * (widthNoCursor + 42)) / maxMilli;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: SizedBox(
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: double.infinity,
                height: 75,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white10),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification) {
                      widget.onUpdate(trimStart, trimEnd);
                    }
                    return false;
                  },
                  child: ListView.builder(
                      itemCount: widget.thumbnails.length,
                      scrollDirection: Axis.horizontal,
                      controller: scrollController,
                      itemBuilder: (context, index) {
                        Uint8List? thumbnail = widget.thumbnails[index];
                        return Container(
                          width: thumbsWidth / widget.thumbnails.length,
                          height: 75,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white12, width: 1),
                              image: thumbnail == null
                                  ? null
                                  : DecorationImage(
                                      fit: BoxFit.cover,
                                      image: MemoryImage(thumbnail))),
                        );
                      }),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: Text('${durationToString(trimStart ~/ 1000)}'),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: Text('${durationToString(trimEnd ~/ 1000)}'),
              ),
            ),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: Padding(
            //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            //     child: Text(
            //       'max:${scrollController.hasClients ? scrollController.position.maxScrollExtent : null}\nposition:${scrollController.hasClients ? scrollController.position.pixels : null}\nviewport:${widthNoCursor + 42}\ntotal:$thumbsWidth\nscrollFactor:$scrollFactor',
            //       textAlign: TextAlign.center,
            //     ),
            //   ),
            // ),
            Positioned(
              right: rightHandle,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    if (rightHandle - details.delta.dx < 0) {
                      rightHandle = 0;
                    } else if (rightHandle - details.delta.dx >=
                        (moveableWidth + -leftHandle)) {
                      rightHandle = moveableWidth - leftHandle;
                    } else {
                      rightHandle -= details.delta.dx;
                    }
                  });
                },
                onPanEnd: (_) {
                  widget.onUpdate(trimStart, trimEnd);
                },
                child: Container(
                  width: 21,
                  height: 75,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius:
                          BorderRadius.horizontal(right: Radius.circular(15))),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 3,
                          height: 25,
                          decoration: BoxDecoration(
                              color: Colors.white60,
                              borderRadius: BorderRadius.circular(3)),
                        ),
                        Container(
                          width: 3,
                          height: 25,
                          decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(3)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: leftHandle,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    if (leftHandle + details.delta.dx < 0) {
                      leftHandle = 0;
                    } else if (leftHandle + details.delta.dx >=
                        (moveableWidth - rightHandle)) {
                      leftHandle = moveableWidth - rightHandle;
                    } else {
                      leftHandle += details.delta.dx;
                    }
                  });
                },
                onPanEnd: (_) {
                  widget.onUpdate(trimStart, trimEnd);
                },
                child: Container(
                  width: 21,
                  height: 75,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(15))),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.horizontal(left: Radius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 3,
                          height: 25,
                          decoration: BoxDecoration(
                              color: Colors.white60,
                              borderRadius: BorderRadius.circular(3)),
                        ),
                        Container(
                          width: 3,
                          height: 25,
                          decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(3)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: leftHandle + 21,
              right: rightHandle + 21,
              top: (120 - 75) / 2,
              child: Container(
                width: double.infinity,
                height: 1.5,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Positioned(
              left: leftHandle + 21,
              right: rightHandle + 21,
              bottom: (120 - 75) / 2,
              child: Container(
                width: double.infinity,
                height: 1.5,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Positioned(
              left: cursor,
              child: Container(
                width: 5,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
