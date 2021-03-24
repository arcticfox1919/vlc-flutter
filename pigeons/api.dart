


import 'package:pigeon/pigeon.dart';

class TextureParam{
  int textureId;
}

class DoubleParam{
  double value;
  int textureId;
}

class BoolParam{
  bool value;
  int textureId;
}

class IntParam{
  int value;
  int textureId;
}


class StringParam{
  String value;
  int textureId;
}

class PlayParam{
  String uri;
  String path;
  int textureId;
}

class BufferSize{
  int width;
  int height;
  int textureId;
}

class VLCPlayerOptions{
  List args;
}

class SlaveParam{
  int type;
  String uri;
  String path;
  bool select;
  int textureId;
}

class TitleDisplayParam{
  int position;
  int timeout;
  int textureId;
}

@HostApi()
abstract class VLCPlayerApi{

  TextureParam create(VLCPlayerOptions options);
  void dispose(TextureParam arg);
  void release();
  void setDefaultBufferSize(BufferSize size);

  void setDataSource(PlayParam data);

  void setVideoScale(IntParam type);

  IntParam getVideoScale(TextureParam param);

  void play(PlayParam param);


  void stop(TextureParam param);


  DoubleParam getScale(TextureParam param);


  void setScale(DoubleParam scale);


  StringParam getAspectRatio(TextureParam param);


  void setAspectRatio(StringParam aspect);


  void setRate(DoubleParam rate);


  DoubleParam getRate(TextureParam param);


  BoolParam isPlaying(TextureParam param);


  BoolParam isSeekable(TextureParam param);


  void pause(TextureParam param);


  IntParam getPlayerState(TextureParam param);


  IntParam getVolume(TextureParam param);


  IntParam setVolume(IntParam volume);


  IntParam getTime(TextureParam param);


  IntParam setTime(IntParam time);


  DoubleParam getPosition(TextureParam param);


  void setPosition(DoubleParam pos);

  IntParam getLength(TextureParam param);

  BoolParam addSlave(SlaveParam param);

  void setVideoTitleDisplay(TitleDisplayParam param);

  BoolParam record(StringParam directory);
}