#import <Flutter/Flutter.h>
#import "FLVLCPlayer.h"

@interface VlcFlutterPlugin : NSObject<FlutterPlugin>

+ (FLVLCPlayer *)players:(NSNumber *)viewId;
+ (void)setPlayers:(FLVLCPlayer *)player forKey:(NSNumber *)key;
@end
