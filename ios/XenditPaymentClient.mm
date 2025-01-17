#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(XenditPaymentClient, NSObject)

RCT_EXTERN_METHOD(multiply:(float)a withB:(float)b
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(initialize:(NSString *)publicKey)

RCT_EXTERN_METHOD(createSingleUseToken:(NSDictionary *)cardDict 
                  withAmount:(nonnull NSNumber *)amount
                  shouldAuthenticate:(BOOL)shouldAuthenticate
                  withOnBehalfOf:(NSString *)onBehalfOf
                  withCurrency:(NSString *)currency
                  withBillingDetails:(NSDictionary *)billingDetails
                  withCustomer:(NSDictionary *)customer
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(createMultipleUseToken:(NSDictionary *)cardDict 
                  withOnBehalfOf:(NSString *)onBehalfOf
                  withMidLabel:(NSString *)midLabel
                  withBillingDetails:(NSDictionary *)billingDetails
                  withCustomer:(NSDictionary *)customer
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(createAuthentication:(NSString *)tokenId 
                  withAmount:(nonnull NSNumber *)amount
                  withCurrency:(NSString *)currency
                  withCardCvn:(NSString *)cardCvn
                  withOnBehalfOf:(NSString *)onBehalfOf
                  withMidLabel:(NSString *)midLabel
                  withCardHolder:(NSDictionary *)cardHolder
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

@end
