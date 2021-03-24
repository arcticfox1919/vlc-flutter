part of vlcplayer;


enum VLCState {
  NothingSpecial,
  Opening,
  Buffering,
  Playing,
  Paused,
  Stopped,
  Ended,
  Error,
}

class VLCValue{
  final VLCState state;
  VLCValue.uninitialized():this(state:VLCState.NothingSpecial);

  VLCValue({@required this.state});

  VLCValue copyWith({VLCState state}){
    return VLCValue(
        state:state ?? this.state
    );
  }
}

class VLCEvent{
  EventType type;
  double buffering;
  int timeChanged;
  int lengthChanged;
  double positionChanged;
  int voutCount;
  int esChangedType;
  int esChangedID;
  bool seekable;
  bool pausable;
  bool recording;
  String recordPath;

  VLCEvent.fromMap(Map param){
    type = EventOriginalType.getType(param["type"]);
    buffering = param["Buffering"];
    timeChanged = param["Time"];
    lengthChanged = param["Length"];
    positionChanged = param["Position"];
    voutCount = param["VoutCount"];
    esChangedType = param["EsChangedType"];
    esChangedID = param["EsChangedID"];
    seekable = param["Seekable"];
    pausable = param["Pausable"];
    recording = param["Recording"];
    recordPath = param["RecordPath"];
  }

  @override
  String toString() {
    return '{type:$type,buffering:$buffering,timeChanged:$timeChanged,'
        'lengthChanged:$lengthChanged,positionChanged:$positionChanged,'
        'voutCount:$voutCount,esChangedType:$esChangedType,'
        'esChangedID:$esChangedID,seekable:$seekable,pausable:$pausable,'
        'recording:$recording,recordPath:$recordPath}';
  }
}

class VLCController extends ChangeNotifier implements ValueListenable<VLCValue>{

  VLCPlayerApi _vlcApi;

  int _textureId = -1;

  final Completer<int> _createTexture;

  bool _isDisposed = false;
  bool _isNeedDisposed = false;
  VLCValue _value;

  final StreamController<VLCState> _stateStreamController =
      StreamController.broadcast();

  final StreamController<VLCEvent> _eventStreamController =
      StreamController.broadcast();


  StreamSubscription _eventSubscription;

  VLCController({List<Object> args})
      : _createTexture = Completer(){
    _vlcApi = VLCPlayerApi();
    _value = VLCValue.uninitialized();
    _create(args:args);
  }

  Future<void> _create({List<Object> args}) async {
    var param = await _vlcApi.create(VLCPlayerOptions()..args=args);
    _textureId = param?.textureId ?? -1;

    _eventSubscription =
        EventChannel("xyz.bczl.vlc_flutter/VLCPlayer/id_$_textureId")
            .receiveBroadcastStream()
            .listen(_eventHandler, onError: _errorHandler);
    _createTexture.complete(_textureId);
  }

  ///
  /// For listening to the player status
  ///
  Stream<VLCState> get onPlayerState => _stateStreamController.stream;

  ///
  /// For listening to player events
  ///
  Stream<VLCEvent> get onEvent => _eventStreamController.stream;

  ///
  /// Event Type
  /// see:https://www.videolan.org/developers/vlc/doc/doxygen/html/group__libvlc__event.html#ga284c010ecde8abca7d3f262392f62fc6
  ///
  _eventHandler(event) {
    final  map = event;
    var type = map["type"];
    switch(type){
      case EventOriginalType.Opening:
        _changeState(VLCState.Opening);
        break;
      case EventOriginalType.Buffering:
        _changeState(VLCState.Buffering);
        break;
      case EventOriginalType.Playing:
        _changeState(VLCState.Playing);
        break;
      case EventOriginalType.Paused:
        _changeState(VLCState.Paused);
        break;
      case EventOriginalType.Stopped:
        _changeState(VLCState.Stopped);
        break;
      case EventOriginalType.EndReached:
        _changeState(VLCState.Ended);
        break;
      case EventOriginalType.EncounteredError:
        _changeState(VLCState.Error);
        break;
      default:
    }
    _eventStreamController.add(VLCEvent.fromMap(map));
  }

  _errorHandler(error) {}

  _ensureInitialized(){
    if(_isNeedDisposed) return -1;
    return _createTexture.future;
  }

   Future<int> get textureId {
    return _createTexture.future;
  }

  Future<void> setBufferSize(int width,int height)async{
    if(_isNeedDisposed) return;
    await _ensureInitialized();
    var size = BufferSize()
      ..textureId = _textureId
      ..width = (width*window.devicePixelRatio).toInt()
      ..height = (height*window.devicePixelRatio).toInt();
    return _vlcApi.setDefaultBufferSize(size);
  }

  ///
  /// Release resources
  ///
  @override
  void dispose() async {
    _isNeedDisposed = true;
    if(!_isDisposed){
      _isDisposed = true;
      await _ensureInitialized();
      await _vlcApi.dispose(TextureParam()..textureId=_textureId);
      _eventSubscription.cancel();
      _stateStreamController.close();
      _eventStreamController.close();
    }
    super.dispose();
  }

  ///
  /// Setting the data source
  ///
  /// [uri] and [path]
  ///
  /// see [play] method
  ///
  Future<void> setDataSource({String uri,String path}) async {
    assert(uri != null || path !=null);
    await _ensureInitialized();
    if(_isNeedDisposed) return;
    var p = PlayParam();
    p.textureId = _textureId;
    p.uri = uri;
    p.path = path;
    await _vlcApi.setDataSource(p);
  }

  ///
  /// Play the media
  ///
  /// [uri] Uri of the media to play
  /// [path] Path of the media file to play
  ///
  Future<void> play({String uri,String path}) async {
    await _ensureInitialized();
    if(_isNeedDisposed) return;
    var p = PlayParam();
    p.textureId = _textureId;
    p.uri = uri;
    p.path = path;
    await _vlcApi.play(p);
  }


  ///
  /// Set the video scale type, by default, scaletype is set to ScaleType.SURFACE_BEST_FIT
  ///  [ScaleType] to rule the video surface filling
  ///
  void setVideoScale(ScaleType type) async {
    await _ensureInitialized();
    if(_isNeedDisposed) return;
    await _vlcApi.setVideoScale(IntParam()
      ..textureId = _textureId
      ..value = type.index);
  }

  ///
  /// Get the current video scale type
  /// return the current [ScaleType] used by MediaPlayer
  ///
  Future<ScaleType> getVideoScale() async {
    await _ensureInitialized();
    if(_isNeedDisposed) return ScaleType.SURFACE_BEST_FIT;
    IntParam ip = await _vlcApi.getVideoScale(TextureParam()..textureId=_textureId);
    return ScaleType.values[ip.value];
  }

  ///
  /// Stops the playing media
  ///
  void stop() async{
    await _ensureInitialized();
    if(_isNeedDisposed) return ;
    await _vlcApi.stop(TextureParam()..textureId=_textureId);
  }

  ///
  /// Get the current video scaling factor
  ///
  /// return the currently configured zoom factor, or 0. if the video is set to fit to the
  /// output window/drawable automatically.
  ///
  Future<double> getScale()async{
    await _ensureInitialized();
    if(_isNeedDisposed) return -1;
    DoubleParam dp = await _vlcApi.getScale(TextureParam()..textureId=_textureId);
    return dp.value;
  }

  ///
  /// Set the video scaling factor
  ///
  /// That is the ratio of the number of pixels on screen to the number of pixels in the original
  /// decoded video in each dimension. Zero is a special value; it will adjust the video to the
  /// output window/drawable (in windowed mode) or the entire screen.
  ///
  /// [scale] the scaling factor, or zero
  ///
  void setScale(double scale) async {
    await _ensureInitialized();
    if(_isNeedDisposed) return ;
    await _vlcApi.setScale(DoubleParam()
      ..textureId = _textureId
      ..value = scale);
  }

  ///
  /// Get current video aspect ratio
  ///
  /// return the video aspect ratio or NULL if unspecified
  ///
  Future<String> getAspectRatio() async {
    await _ensureInitialized();
    if(_isNeedDisposed) return null;
    StringParam sp =
        await _vlcApi.getAspectRatio(TextureParam()..textureId = _textureId);
    return sp.value;
  }

  ///
  /// Set new video aspect ratio.
  ///
  /// [aspect] new video aspect-ratio or NULL to reset to default
  ///
  void setAspectRatio(String aspect)async{
    await _ensureInitialized();
    if(_isNeedDisposed) return;
    await _vlcApi.setAspectRatio(StringParam()
      ..textureId = _textureId
      ..value = aspect);
  }

  ///
  /// Sets the speed of playback (1 being normal speed, 2 being twice as fast)
  ///
  /// [rate]
  ///
  void setRate(double rate)async{
    await _ensureInitialized();
    if(_isNeedDisposed) return;
    await _vlcApi.setRate(DoubleParam()
      ..textureId = _textureId
      ..value = rate);
  }

  ///
  /// Get the current playback speed
  ///
  Future<double> getRate()async{
    await _ensureInitialized();
    if(_isNeedDisposed) return 0.0;
    DoubleParam dp =
        await _vlcApi.getRate(TextureParam()..textureId = _textureId);
    return dp.value;
  }

  ///
  /// Returns true if any media is playing
  ///
  Future<bool> isPlaying() async {
    await _ensureInitialized();
    if(_isNeedDisposed) return false;
    BoolParam bp =
        await _vlcApi.isPlaying(TextureParam()..textureId = _textureId);
    return bp.value;
  }

  ///
  /// Returns true if any media is seekable
  ///
  Future<bool> isSeekable()async{
    await _ensureInitialized();
    if(_isNeedDisposed) return false;
    BoolParam bp =
        await _vlcApi.isSeekable(TextureParam()..textureId = _textureId);
    return bp.value;
  }

  ///
  /// Pauses any playing media
  ///
  void pause() async {
    await _ensureInitialized();
    if(_isNeedDisposed) return;
    await _vlcApi.pause(TextureParam()..textureId = _textureId);
  }

  ///
  /// Get player state.
  ///
  Future<VLCState> getPlayerState() async {
    await _ensureInitialized();
    if(_isNeedDisposed) return VLCState.Stopped;
    IntParam ip =
        await _vlcApi.getPlayerState(TextureParam()..textureId = _textureId);

    return VLCState.values[ip.value];
  }

  ///
  /// Gets volume as integer
  ///
  Future<int> getVolume() async {
    await _ensureInitialized();
    if(_isNeedDisposed) return -1;
    IntParam ip =
        await _vlcApi.getVolume(TextureParam()..textureId = _textureId);
    return ip.value;
  }

  ///
  /// Sets volume as integer
  /// [volume] Volume level passed as integer
  ///
  Future<int> setVolume(int volume) async {
    await _ensureInitialized();
    if(_isNeedDisposed) return -1;
    IntParam ip = await _vlcApi.setVolume(IntParam()
      ..textureId = _textureId
      ..value = volume);
    return ip.value;
  }

  ///
  /// Gets the current movie time (in ms).
  /// return the movie time (in ms), or -1 if there is no media.
  ///
  Future<int> getTime() async {
    await _ensureInitialized();
    if(_isNeedDisposed) return -1;
    IntParam ip =
        await _vlcApi.getTime(TextureParam()..textureId = _textureId);
    return ip.value;
  }

  ///
  /// Sets the movie time (in ms), if any media is being played.
  /// [time] Time in ms.
  /// return the movie time (in ms), or -1 if there is no media.
  ///
  Future<int> setTime(int time)async{
    await _ensureInitialized();
    if(_isNeedDisposed) return -1;
    IntParam ip = await _vlcApi.setTime(IntParam()
      ..textureId = _textureId
      ..value = time);
    return ip.value;
  }

  ///
  /// Gets the movie position.
  /// return the movie position, or -1 for any error.
  ///
  Future<double> getPosition()async{
    await _ensureInitialized();
    if(_isNeedDisposed) return -1;
    DoubleParam dp =
        await _vlcApi.getPosition(TextureParam()..textureId = _textureId);
    return dp.value;
  }

  ///
  /// Sets the movie position.
  ///
  /// [pos]  movie position.
  ///
  void setPosition(double pos)async{
    await _ensureInitialized();
    if(_isNeedDisposed) return;
    await _vlcApi.setPosition(DoubleParam()
      ..textureId = _textureId
      ..value = pos);
  }

  ///
  /// Gets current movie's length in ms.
  ///
  /// return the movie length (in ms), or -1 if there is no media.
  ///
  Future<int> getLength()async{
    await _ensureInitialized();
    if(_isNeedDisposed) return -1;
    IntParam ip =
        await _vlcApi.getLength(TextureParam()..textureId = _textureId);
    return ip.value;
  }

  ///
  /// Add a slave (or subtitle) to the current media player.
  ///
  /// [type] Subtitle = 0,Audio = 1
  /// [uri] Uri of the slave(a valid RFC 2396 Uri)
  /// [path] a local path
  /// [select] True if this slave should be selected when it's loaded
  /// return true on success.
  ///
  Future<bool> addSlave({int type=0, String uri,String path, bool select=true}) async {
    assert(uri != null || path !=null);
    await _ensureInitialized();
    if(_isNeedDisposed) return false;
    BoolParam bp = await _vlcApi.addSlave(SlaveParam()
      ..textureId = _textureId
      ..type = type
      ..uri = uri
      ..path = path
      ..select = select);
    return bp.value;
  }

  ///
  /// Set if, and how, the video title will be shown when media is played
  ///
  /// [position] see [Position]
  /// [timeout] title display timeout in milliseconds
  ///
  void setVideoTitleDisplay(int position, int timeout) async {
    await _ensureInitialized();
    if(_isNeedDisposed) return;
    await _vlcApi.setVideoTitleDisplay(TitleDisplayParam()
      ..textureId = _textureId
      ..position = position
      ..timeout = timeout);
  }

  ///
  /// Start/stop recording
  ///
  /// [directory] path of the recording directory or null to stop
  /// recording
  /// return true on success.
  ///
  Future<bool> _record(String directory) async {
    await _ensureInitialized();
    if(_isNeedDisposed) return false;
    BoolParam bp = await _vlcApi.record(StringParam()
      ..textureId = _textureId
      ..value = directory);
    return bp.value;
  }

  ///
  /// Start recording
  ///
  Future<bool> startRecord(String directory){
    return _record(directory);
  }

  ///
  /// Stop recording
  ///
  Future<bool> stopRecord(){
    return _record(null);
  }

  @override
  VLCValue get value => _value;

  set value(VLCValue val){
    if (_value == val) return;
    _value = val;
    notifyListeners();
  }

  _changeState(VLCState playerState){
    value = _value.copyWith(state: playerState);
    _stateStreamController.add(playerState);
  }
}

enum ScaleType {
  SURFACE_BEST_FIT,
  SURFACE_FIT_SCREEN,
  SURFACE_FILL,
  SURFACE_16_9,
  SURFACE_4_3,
  SURFACE_ORIGINAL
}

class EventOriginalType{
  static const int MediaChanged        = 0x100;
  //static const int NothingSpecial      = 0x101;
  static const int Opening             = 0x102;
  static const int Buffering           = 0x103;
  static const int Playing             = 0x104;
  static const int Paused              = 0x105;
  static const int Stopped             = 0x106;
  //static const int Forward             = 0x107;
  //static const int Backward            = 0x108;
  static const int EndReached          = 0x109;
  static const int EncounteredError   = 0x10a;
  static const int TimeChanged         = 0x10b;
  static const int PositionChanged     = 0x10c;
  static const int SeekableChanged     = 0x10d;
  static const int PausableChanged     = 0x10e;
  //static const int TitleChanged        = 0x10f;
  //static const int SnapshotTaken       = 0x110;
  static const int LengthChanged       = 0x111;
  static const int Vout                = 0x112;
  //static const int ScrambledChanged    = 0x113;
  static const int ESAdded             = 0x114;
  static const int ESDeleted           = 0x115;
  static const int ESSelected          = 0x116;
  // static const int Corked              = 0x117;
  // static const int Uncorked            = 0x118;
  // static const int Muted               = 0x119;
  // static const int Unmuted             = 0x11a;
  // static const int AudioVolume         = 0x11b;
  // static const int AudioDevice         = 0x11c;
  // static const int ChapterChanged      = 0x11d;
  static const int RecordChanged       = 0x11e;

  static const Map<int,EventType> _map = const {
    MediaChanged:EventType.MediaChanged,
    Opening:EventType.Opening,
    Buffering:EventType.Buffering,
    Playing:EventType.Playing,
    Paused:EventType.Paused,
    Stopped:EventType.Stopped,
    EndReached:EventType.EndReached,
    EncounteredError:EventType.EncounteredError,
    TimeChanged:EventType.TimeChanged,
    PositionChanged:EventType.PositionChanged,
    SeekableChanged:EventType.SeekableChanged,
    PausableChanged:EventType.PausableChanged,
    LengthChanged:EventType.LengthChanged,
    Vout:EventType.Vout,
    ESAdded:EventType.ESAdded,
    ESDeleted:EventType.ESDeleted,
    ESSelected:EventType.ESSelected,
    RecordChanged:EventType.RecordChanged,
  };

  static EventType getType(int type){
    return _map[type];
  }
}

enum EventType {
  MediaChanged,
  Opening,
  Buffering,
  Playing,
  Paused,
  Stopped,
  EndReached,
  EncounteredError,
  TimeChanged,
  PositionChanged,
  SeekableChanged,
  PausableChanged,
  LengthChanged,
  Vout,
  ESAdded,
  ESDeleted,
  ESSelected,
  RecordChanged,
}

class Position {
  static const Disable = -1;
  static const Center = 0;
  static const Left = 1;
  static const Right = 2;
  static const Top = 3;
  static const TopLeft = 4;
  static const TopRight = 5;
  static const Bottom = 6;
  static const BottomLeft = 7;
  static const BottomRight = 8;
}