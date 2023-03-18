#import "VlcFlutterPlugin.h"
#import "VLCPlayerAPI.h"
#import "VLCPlayerView.h"
#import "FLVLCPlayer.h"

#define STATE_SIZE 7
static int play_state[STATE_SIZE] = {
    5,  // VLCMediaPlayerStateStopped
    1,  // VLCMediaPlayerStateOpening
    2,  // VLCMediaPlayerStateBuffering
    6,  // VLCMediaPlayerStateEnded
    7,  // VLCMediaPlayerStateError
    3,  // VLCMediaPlayerStatePlaying
    4,  // VLCMediaPlayerStatePaused
};

@interface VlcFlutterPlugin ()<VLCPlayerApi>

@end

static NSMutableDictionary *dict = nil;

@implementation VlcFlutterPlugin

- (void)dealloc{
    dict = nil;
}

+ (FLVLCPlayer *)players:(NSNumber *)viewId{
    if(dict == nil){
        dict = [NSMutableDictionary dictionary];
    }
    return dict[viewId];
}

+ (void)setPlayers:(FLVLCPlayer *)player forKey:(NSNumber *)key{
    if(dict == nil){
        dict = [NSMutableDictionary dictionary];
    }
    [dict setObject:player forKey:key];
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    VlcFlutterPlugin *api = [[VlcFlutterPlugin alloc]init];
    VLCPlayerApiSetup(registrar.messenger, api);
    VLCPlayerViewFactory *factory = [[VLCPlayerViewFactory alloc]initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:factory withId:@"VLCPlayerView"];
}


- (nullable NSNumber *)createOptions:(NSArray<NSString *> *)options error:(FlutterError *_Nullable *_Nonnull)error{
    return nil;
}

- (void)createByIOSOptions:(NSArray<NSString *> *)options viewId:(NSNumber *)viewId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[viewId];
    if (player) {
        [player create:options];
    }else{
        *error = [FlutterError errorWithCode:@"vlc-flutter" message:@"createByIOSOptions failed!" details:nil];
    }
}

- (void)disposeId:(NSNumber *)vid error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[vid];
    if (player) {
        [player dispose];
        [dict removeObjectForKey:vid];
    }
}

- (void)releaseWithError:(FlutterError *_Nullable *_Nonnull)error{
    for (NSNumber *k in dict) {
        FLVLCPlayer *p = dict[k];
        [p dispose];
    }
    [dict removeAllObjects];
}

- (void)setDefaultBufferSizeWidth:(NSNumber *)width height:(NSNumber *)height textureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{}

- (void)setDataSourceUri:(NSString *)uri path:(NSString *)path textureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        [player setDataSourceUri:uri path:path];
    }
}

- (void)setVideoScaleValue:(NSNumber *)value textureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        [[player player] setScaleFactor:[value floatValue]];
    }
}

- (nullable NSNumber *)getVideoScaleTextureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    
    return nil;
}

- (void)playUri:(NSString *)uri path:(NSString *)path textureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        [player play:uri path:path];
    }
}

- (void)stopTextureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        [[player player] stop];
    }
}

- (nullable NSNumber *)getScaleTextureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        float val = [[player player] scaleFactor];
        return [NSNumber numberWithFloat:val];
    }
    return nil;
}

- (void)setScaleScale:(NSNumber *)scale textureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        [[player player] setScaleFactor:[scale floatValue]];
    }
}

- (nullable NSString *)getAspectRatioTextureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        char *val = [[player player] videoAspectRatio];
        return [[NSString alloc]initWithUTF8String:val];
    }
    return nil;
}

- (void)setAspectRatioAspect:(NSString *)aspect textureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        const char *cs = [aspect UTF8String];
        char chs[20] = {0};
        strncpy(chs, cs, strlen(cs));
        [[player player] setVideoAspectRatio:chs];
    }
}

- (void)setRateRate:(NSNumber *)rate textureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        [[player player] setRate:[rate floatValue]];
    }
}

- (nullable NSNumber *)getRateTextureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        float val = [[player player] rate];
        return [NSNumber numberWithFloat:val];
    }
    return nil;
}

- (nullable NSNumber *)isPlayingTextureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        BOOL val = [[player player] isPlaying];
        return [NSNumber numberWithBool:val];
    }
    return nil;
}

- (nullable NSNumber *)isSeekableTextureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        BOOL val = [[player player] isSeekable];
        return [NSNumber numberWithBool:val];
    }
    return nil;
}

- (void)pauseTextureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        [[player player] pause];
    }
}

- (nullable NSNumber *)getPlayerStateTextureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        long i = [player player].state;
        if(i < STATE_SIZE){
            return [NSNumber numberWithInt: play_state[i]];
        }
    }
    return nil;
}

- (nullable NSNumber *)getVolumeTextureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        return [NSNumber numberWithInt: [player player].audio.volume];
    }
    return nil;
}

- (nullable NSNumber *)setVolumeVolume:(NSNumber *)volume textureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        [player player].audio.volume = volume.intValue;
    }
    return nil;
}

- (nullable NSNumber *)getTimeTextureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        return [[player player] time].value;
    }
    return nil;
}

- (nullable NSNumber *)setTimeTime:(NSNumber *)time textureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        VLCTime *vt = [[VLCTime alloc]initWithNumber:time];
        [[player player] setTime:vt];
    }
    return nil;
}

- (nullable NSNumber *)getPositionTextureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        float val = [[player player] position];
        return [NSNumber numberWithFloat:val];
    }
    return nil;
}

- (void)setPositionPos:(NSNumber *)pos textureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        [[player player] setPosition:[pos floatValue]];
    }
}

- (nullable NSNumber *)getLengthTextureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        return [player player].media.length.value;
    }
    return nil;
}

- (nullable NSNumber *)addSlaveType:(NSNumber *)type uri:(NSString *)uri path:(NSString *)path select:(NSNumber *)select textureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    if (player) {
        int val =[[player player] addPlaybackSlave:[NSURL URLWithString:uri] type:0 enforce:[select boolValue]];
        
        return [NSNumber numberWithInt:val];
    }
    return nil;
}

- (void)setVideoTitleDisplayPosition:(NSNumber *)position timeout:(NSNumber *)timeout textureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    
}

- (nullable NSNumber *)recordDirectory:(NSString *)directory textureId:(NSNumber *)textureId error:(FlutterError *_Nullable *_Nonnull)error{
    FLVLCPlayer *player = dict[textureId];
    BOOL r = NO;
    if (player) {
        if (directory !=nil && directory.length > 0) {
            r = [[player player] startRecordingAtPath:directory];
        }else{
            r = [[player player] stopRecording];
        }
    }
    return [NSNumber numberWithBool:r];
}


@end
