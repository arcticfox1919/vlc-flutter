# vlc-flutter

This is a Flutter wrapper plugin for libvlc.See their [website](https://www.videolan.org/).

Todo:

- [x]  Android
- [x]  iOS



## Usage

```yaml
dependencies:
  vlc_flutter: ^0.0.1
```


```dart
import 'package:vlc_flutter/vlcplayer.dart';
```

Create `VLCController`:

```dart
// "-vvv" option
// print as detailed a log as possible for debugging purposes
VLCController _controller = VLCController(args:["-vvv"]);
```

Create a view for playback:
```dart
AspectRatio(
      aspectRatio: 16/9,
      child: VLCVideoWidget(
        controller: _controller,
      ),
    )
```

Play video according to `uri`:
```dart
ElevatedButton(
    child: Text("play"),
    onPressed: () async {
      await _controller.setDataSource(uri:"rtmp://58.200.131.2:1935/livetv/natlgeo");
      _controller.play();
    }),
```

Or just use the `play`:
```dart
_controller.play(uri:"rtmp://58.200.131.2:1935/livetv/natlgeo");
```

Play local resources:
```dart
_controller.play(path:"/sdcard/test/test.mp4");
```

Listening to the status of the player:

```dart
_controller.onPlayerState.listen((event) {
  debugPrint("=*= $event =*=");
});
```



Listening to player events:

```dart
_controller.onEvent.listen((event) {
    if(event.type == EventType.PositionChanged){
    	debugPrint("==[${event.positionChanged}]==");
    }
});
```

Add subtitles:

```dart
// Loading local subtitles
await _controller.addSlave(path: "/sdcard/test/Test.srt");
// Set the position of the subtitles
_controller.setVideoTitleDisplay(Position.Bottom, 1000);
```

Recorded video:

```dart
// Specify a directory and start recording
_controller.startRecord("/sdcard/test/");
// Stop Recording
_controller.stopRecord();
```

Don't forget to add network permissions to the `AndroidManifest.xml` to play network resources:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

If you need to record video, you may also need the following permissions:(These are dangerous permissions on Android 6.0 and above, so you may also need the [flutter_easy_permission](https://pub.dev/packages/flutter_easy_permission) plugin)

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```



## Example

```dart
class _MyAppState extends State<MyApp> {
  VLCController _controller = VLCController();

  @override
  void initState() {
    super.initState();

    _controller.onEvent.listen((event) {
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
```
