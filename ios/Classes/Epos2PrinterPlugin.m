#import "Epos2PrinterPlugin.h"
#if __has_include(<epos2_printer/epos2_printer-Swift.h>)
#import <epos2_printer/epos2_printer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "epos2_printer-Swift.h"
#endif

@implementation Epos2PrinterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEpos2PrinterPlugin registerWithRegistrar:registrar];
}
@end
