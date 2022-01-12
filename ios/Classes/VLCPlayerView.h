//
//  VLCPlayerView.h
//  vlc_flutter
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface VLCPlayerView : NSObject<FlutterPlatformView>

-(instancetype)initWithFrame:(CGRect)frame
                            viewIdentifier:(int64_t)viewID
                            arguments:(id _Nullable)args
    binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;


- (nonnull UIView *)view;
@end

@interface VLCPlayerViewFactory : NSObject<FlutterPlatformViewFactory>
-(instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end

NS_ASSUME_NONNULL_END
