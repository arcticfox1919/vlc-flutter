//
//  QueuingEventSink.h
//  vlc_flutter
//

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QueuingEventSink : NSObject

- (void)setDelegate:(FlutterEventSink _Nullable)sink;

- (void)endOfStream;

- (void)error:(NSString *)code
      message:(NSString *_Nullable)message
      details:(id _Nullable)details;

- (void)success:(NSObject *)event;

@end

NS_ASSUME_NONNULL_END
