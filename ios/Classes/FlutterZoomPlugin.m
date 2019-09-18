#import "FlutterZoomPlugin.h"
#import <flutter_zoom_plugin/flutter_zoom_plugin-Swift.h>

@implementation FlutterZoomPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterZoomPlugin registerWithRegistrar:registrar];
}
@end
