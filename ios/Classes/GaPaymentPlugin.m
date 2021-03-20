#import "GaPaymentPlugin.h"
#if __has_include(<ga_payment/ga_payment-Swift.h>)
#import <ga_payment/ga_payment-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ga_payment-Swift.h"
#endif

@implementation GaPaymentPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGaPaymentPlugin registerWithRegistrar:registrar];
}
@end
