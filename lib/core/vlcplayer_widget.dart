
part of vlcplayer;

class VLCVideoWidget extends StatefulWidget {

  final VLCController controller;

  VLCVideoWidget({@required this.controller}):assert(controller != null);


  @override
  _VLCVideoWidgetState createState() => _VLCVideoWidgetState();
}

class _VLCVideoWidgetState extends State<VLCVideoWidget> {
  int _textureId = -1;
  _BufferSize _size;

  @override
  void initState() {
    super.initState();
    widget.controller.textureId.then((val) {
      debugPrint("initState _textureId=$val");
      setState(() {
        _textureId = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){
        debugPrint("VLCVideoWidget width=${constraints.maxWidth*window.devicePixelRatio}, height=${constraints.maxHeight*window.devicePixelRatio}");
        if(_size == null){
          _size = _BufferSize(constraints.maxWidth, constraints.maxHeight);
          widget.controller.setBufferSize(_size.width, _size.height);
        }else {
          var size = _BufferSize(constraints.maxWidth, constraints.maxHeight);
          if(_size != size) {
            _size = size;
            widget.controller.setBufferSize(_size.width, _size.height);
          }
        }

        return _textureId == -1
            ? Container()
            : Texture(textureId: _textureId);
      },
    );
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
    return o is BufferSize && width == o.width && height == o.height;
  }

  @override
  int get hashCode => (width + height).hashCode;

}