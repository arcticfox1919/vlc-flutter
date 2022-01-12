import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class VLCPlayerApi{

  int create(List<String> options);
  void createByIOS(List<String> options,int viewId);
  void dispose(int vid);
  void release();
  void setDefaultBufferSize(int width,int height,int textureId);

  void setDataSource(String uri, String path, int textureId);

  void setVideoScale(int value,int textureId);

  int getVideoScale(int textureId);

  void play(String uri, String path, int textureId);


  void stop(int textureId);


  double getScale(int textureId);


  void setScale(double scale,int textureId);


  String getAspectRatio(int textureId);


  void setAspectRatio(String aspect,int textureId);


  void setRate(double rate,int textureId);


  double getRate(int textureId);


  bool isPlaying(int textureId);


  bool isSeekable(int textureId);


  void pause(int textureId);


  int getPlayerState(int textureId);


  int getVolume(int textureId);


  int setVolume(int volume,int textureId);


  int getTime(int textureId);


  int setTime(int time,int textureId);


  double getPosition(int textureId);


  void setPosition(double pos,int textureId);

  int getLength(int textureId);

  bool addSlave(int type, String uri, String path, bool select, int textureId);

  void setVideoTitleDisplay(int position,int timeout,int textureId);

  bool record(String directory,int textureId);
}