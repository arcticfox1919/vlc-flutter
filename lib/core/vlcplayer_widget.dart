
part of vlcplayer;

class VLCVideoWidget extends StatefulWidget {

  final VLCController controller;

  VLCVideoWidget({required this.controller});


  @override
  _VLCVideoWidgetState createState() => _VLCVideoWidgetState();
}

class _VLCVideoWidgetState extends State<VLCVideoWidget> {
  int _textureId = -1;
  _BufferSize? _size;

  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid){
      widget.controller.textureId.then((val) {
        debugPrint("initState _textureId=$val");
        setState(() {
          _textureId = val;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){
        debugPrint("VLCVideoWidget width=${constraints.maxWidth*window.devicePixelRatio}, height=${constraints.maxHeight*window.devicePixelRatio}");
        var size = _BufferSize(constraints.maxWidth, constraints.maxHeight);
        if(_size == null || _size != size){
          _size = size;
        }
        switch(defaultTargetPlatform){
          case TargetPlatform.android:
            widget.controller.setBufferSize(_size!.width, _size!.height);
            return _textureId == -1
                ? Container()
                : Texture(textureId: _textureId);
          case TargetPlatform.iOS:
            var map = {
              'width':_size!.width*window.devicePixelRatio,
              'height':_size!.height*window.devicePixelRatio
            };
            return UiKitView(
                creationParamsCodec:const StandardMessageCodec(),
                creationParams: map,
                viewType: 'VLCPlayerView',
                onPlatformViewCreated: (id){
                  widget.controller._initViewId(id);
                });
          default:
            throw UnsupportedError('Unsupported platform view');
        }
      });
  }
}

class _BufferSize{
  int width;
  int height;

  _BufferSize(double width,double height):
        this.width=width.toInt(),
        this.height=height.toInt();

  @override
  bool operator ==(Object o){
    return o is _BufferSize && width == o.width && height == o.height;
  }

  @override
  int get hashCode => (width + height).hashCode;

}