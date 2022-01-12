//
//  VLCPlayerView.m
//  vlc_flutter
//

#import "VLCPlayerView.h"
#import "VlcFlutterPlugin.h"



@implementation VLCPlayerView{
    UIView *_view;
    NSObject<FlutterBinaryMessenger>* _messenger;
}

- (UIView*)view{
    return _view;
}

-(instancetype)initWithFrame:(CGRect)frame
                            viewIdentifier:(int64_t)viewID
                            arguments:(id _Nullable)args
    binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;{
    
    if(self = [super init]){
        _messenger = messenger;
        [self createNativeView:args];
        [self initPlayer:viewID args:args];
    }
    return self;
}

-(void)createNativeView:(id _Nullable)arguments{
    UIView *view = [[UIView alloc]init];
    _view = view;
}

-(void)initPlayer:(int64_t)viewID args:(id _Nullable)arguments{
    NSNumber *_id = [NSNumber numberWithLongLong:viewID];
    
    NSDictionary *args = arguments;
    int width = [args[@"width"] intValue];
    int height = [args[@"height"] intValue];
    
    FLVLCPlayer *player = [[FLVLCPlayer alloc]initWithVideoView:_view andWidth:width andHeight:height binaryMsg:_messenger viewId:_id];

    [VlcFlutterPlugin setPlayers:player forKey:_id];
}

@end


@implementation VLCPlayerViewFactory{
    NSObject<FlutterBinaryMessenger>* _messenger;
}

-(instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger{
    self = [super init];
    if(self){
        _messenger = messenger;
    }
    return self;
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args{
    return [[VLCPlayerView alloc]initWithFrame:frame
                                viewIdentifier:viewId
                                     arguments:args
                               binaryMessenger:_messenger];
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}


@end

