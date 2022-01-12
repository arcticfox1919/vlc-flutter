//
//  FLVLCPlayer.h
//  vlc_flutter
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <MobileVLCKit/MobileVLCKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLVLCPlayer : NSObject<FlutterStreamHandler,VLCMediaPlayerDelegate>

@property(readonly) VLCMediaPlayer *player;

-(instancetype)initWithVideoView:(UIView*)view
                        andWidth:(int)width
                       andHeight:(int)height
                       binaryMsg:(NSObject<FlutterBinaryMessenger>*)messenger
                          viewId:(NSNumber *)viewId;

-(void)create:(NSArray<NSString *> *)options;
-(void)dispose;
- (void)setDataSourceUri:(NSString *)uri path:(NSString *)path;
- (void)play:(NSString *)uri path:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
