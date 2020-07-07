#import <Cordova/CDV.h>

@interface Textocr : CDVPlugin

@property CDVInvokedUrlCommand* commandglo;
@property UIImage* image;

- (void) recText:(CDVInvokedUrlCommand*)command;
- (UIImage *)resizeImage:(UIImage *)image;
- (NSData *)retrieveAssetDataPhotosFramework:(NSURL *)urlMedia;

@end
