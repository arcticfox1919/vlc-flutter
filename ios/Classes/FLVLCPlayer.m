//
//  FLVLCPlayer.m
//  vlc_flutter
//

#import "FLVLCPlayer.h"
#import "QueuingEventSink.h"

static int play_state_i[] = {
    0x106,  // VLCMediaPlayerStateStopped
    0x102,  // VLCMediaPlayerStateOpening
    0x103,  // VLCMediaPlayerStateBuffering
    0x109,  // VLCMediaPlayerStateEnded
    0x10a,  // VLCMediaPlayerStateError
    0x104,  // VLCMediaPlayerStatePlaying
    0x105,  // VLCMediaPlayerStatePaused
    0x114   // VLCMediaPlayerStateESAdded
};

@implementation FLVLCPlayer{
    QueuingEventSink *_eventSink;
    FlutterEventChannel *_eventChannel;
    UIView* _view;
    int _width;
    int _height;
    VLCMedia *_media;
}


-(instancetype)initWithVideoView:(UIView*)view
                        andWidth:(int)width
                       andHeight:(int)height
                       binaryMsg:(NSObject<FlutterBinaryMessenger>*)messenger
                          viewId:(NSNumber *)viewId{
    if(self = [super init]){
        _view = view;
        _width = width;
        _height = height;
        
        NSString *channelName = [NSString stringWithFormat:@"xyz.bczl.vlc_flutter/VLCPlayer/id_%@",viewId];
        
        _eventSink = [[QueuingEventSink alloc]init];
        _eventChannel = [FlutterEventChannel eventChannelWithName:channelName binaryMessenger:messenger];
            [_eventChannel setStreamHandler:self];
    }
    return self;
}

-(void)create:(NSArray<NSString *> *)options{
    _player = [[VLCMediaPlayer alloc]initWithOptions:options];
    _player.drawable = _view;
    _player.delegate = self;
    char str[20]={0};
    sprintf(str, "%d:%d",_width,_height);
    [_player setVideoAspectRatio:str];
}

-(void)dispose{
    if (_player) {
        [_player stop];
        _player = nil;
    }
    
    [_eventChannel setStreamHandler:nil];
}

- (void)setDataSourceUri:(NSString *)uri path:(NSString *)path{
    if (_player == nil) {
        return;
    }
    
    if (uri !=nil && uri.length > 0) {
        _player.media = [VLCMedia mediaWithURL: [NSURL URLWithString:uri]];
    }else if(path !=nil && path.length > 0){
        _player.media = [VLCMedia mediaWithPath:path];
    }
}

- (void)play:(NSString *)uri path:(NSString *)path{
    [self setDataSourceUri:uri path:path];
    if (_player) {
        [_player play];
    }
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events{
    [_eventSink setDelegate:events];
    return nil;
}


- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments{
    [_eventSink setDelegate:nil];
    return nil;
}

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification{
    NSNumber *type = [NSNumber numberWithInt: play_state_i[_player.state]];
    NSDictionary *data = @{
        @"type":type
    };
    [_eventSink success: data];
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification{
    NSNumber *type = [NSNumber numberWithInt: 0x10b];
    NSNumber *time = _player.time.value;
    NSDictionary *data = @{
        @"Time":time,
        @"type":type
    };
    [_eventSink success: data];
}

- (void)mediaPlayerTitleChanged:(NSNotification *)aNotification{
    
}


- (void)mediaPlayerChapterChanged:(NSNotification *)aNotification{
    
}

- (void)mediaPlayerLoudnessChanged:(NSNotification *)aNotification{
    
}


- (void)mediaPlayerSnapshot:(NSNotification *)aNotification{
    
}


- (void)mediaPlayerStartedRecording:(VLCMediaPlayer *)player{
    
}


- (void)mediaPlayer:(VLCMediaPlayer *)player recordingStoppedAtPath:(NSString *)path{
    
}
@end
