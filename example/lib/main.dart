import 'package:flutter/material.dart';
import 'package:vlc_flutter/vlcplayer.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  VLCController _controller = VLCController(args:["-vvv"]);

  @override
  void initState() {
    super.initState();

    _controller.onEvent.listen((event) {
      debugPrint("==[$event==");
      if(event.type == EventType.PositionChanged){
        debugPrint("==[${event.positionChanged}]==");
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('VLCPlayer Plugin example'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16/9,
              child: VLCVideoWidget(
                controller: _controller,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    child: Text("play"),
                    onPressed: () async {
                      await _controller.setDataSource(
                          uri: "rtmp://58.200.131.2:1935/livetv/natlgeo");
                      _controller.play();
                    }),
                ElevatedButton(
                    child: Text("pause"),
                    onPressed: () {
                      _controller.pause();
                    }),
                ElevatedButton(
                    child: Text("stop"),
                    onPressed: () {
                      _controller.stop();
                    }),
                ElevatedButton(
                    child: Text("startRecord"),
                    onPressed: () {
                      _controller.startRecord("/sdcard/test/");
                    }),

                ElevatedButton(
                    child: Text("stopRecord"),
                    onPressed: () {
                      _controller.stopRecord();
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
