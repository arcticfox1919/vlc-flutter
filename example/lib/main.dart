import 'package:flutter/material.dart';
import 'package:vlc_flutter/vlcplayer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final VLCController _controller = VLCController(args: ["-vvv"]);

  @override
  void initState() {
    super.initState();
    _controller.onEvent.listen((event) {
      if (event.type == EventType.TimeChanged) {
        debugPrint("==[${event.timeChanged}]==");
      }
    });

    _controller.onPlayerState.listen((state) {
      debugPrint("--[$state]--");
    });

    load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  load() async {
    // rtmp://58.200.131.2:1935/livetv/natlgeo
    await _controller.setDataSource(
        uri: "https://v-cdn.zjol.com.cn/276996.mp4");
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
              aspectRatio: 16 / 9,
              child: VLCVideoWidget(
                controller: _controller,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                    child: const Text("play"),
                    onPressed: () async {
                      _controller.play();
                    }),
                TextButton(
                    child: const Text("pause"),
                    onPressed: () {
                      _controller.pause();
                    }),
                TextButton(
                    child: const Text("stop"),
                    onPressed: () {
                      _controller.stop();
                    }),
                TextButton(
                    child: const Text("startRecord"),
                    onPressed: () {
                      _controller.startRecord("/sdcard/test/");
                    }),
                TextButton(
                    child: const Text("stopRecord"),
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
