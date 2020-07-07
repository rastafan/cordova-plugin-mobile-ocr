#import "Textocr.h"
#import <Photos/Photos.h>

@import UIKit;
@import Firebase;
@import MLKit;

@implementation Textocr
#define NORMFILEURI ((int) 0)
#define NORMNATIVEURI ((int) 1)
#define FASTFILEURI ((int) 2)
#define FASTNATIVEURI ((int) 3)
#define BASE64 ((int) 4)



- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [FIRApp configure];
  return YES;
}

- (void)recText:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        self->_commandglo = command;
        int stype = NORMFILEURI; // sourceType
        NSString* name;
        self.image = NULL;
        @try {
            NSString *st = [[self->_commandglo arguments] objectAtIndex:0];
            stype = [st intValue];
            // 0 NORMFILEURI
            // 1 NORMNATIVEURI
            // 2 FASTFILEURI
            // 3 FASTNATIVEURI
            // 4 BASE64
            
            name = [[self->_commandglo arguments] objectAtIndex:1];
        }
        @catch (NSException *exception) {
            CDVPluginResult* result = [CDVPluginResult
                                       resultWithStatus:CDVCommandStatus_ERROR
                                       messageAsString:@"argument/parameter type mismatch error"];
            [self.commandDelegate sendPluginResult:result callbackId:self->_commandglo.callbackId];
        }
        
        if (stype == NORMFILEURI || stype == NORMNATIVEURI || stype == FASTFILEURI || stype == FASTNATIVEURI)
        {
            if (stype==NORMFILEURI)
            {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:name]];
                self.image = [UIImage imageWithData:imageData];
            }
            else if (stype==NORMNATIVEURI)
            {
                NSString *urlString = [NSString stringWithFormat:@"%@", name];
                NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                NSData *imageData = [self retrieveAssetDataPhotosFramework:url];
                self.image = [UIImage imageWithData:imageData];
            }
            else if (stype==FASTFILEURI)
            {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:name]];
                self.image = [UIImage imageWithData:imageData];
                self.image = [self resizeImage:self.image];
            }
            else if (stype==FASTNATIVEURI)
            {
                NSString *urlString = [NSString stringWithFormat:@"%@", name];
                NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                NSData *imageData = [self retrieveAssetDataPhotosFramework:url];
                self.image = [UIImage imageWithData:imageData];
                self.image = [self resizeImage:self.image];
            }
            
        }
        else if (stype==BASE64)
        {
            NSData *data = [[NSData alloc]initWithBase64EncodedString:name options:NSDataBase64DecodingIgnoreUnknownCharacters];
            self.image = [UIImage imageWithData:data];
        }
        else
        {
            CDVPluginResult* result = [CDVPluginResult
                                       resultWithStatus:CDVCommandStatus_ERROR
                                       messageAsString:@"sourceType argument should be 0,1,2,3 or 4"];
            [self.commandDelegate sendPluginResult:result callbackId:self->_commandglo.callbackId];
        }
        
        
        if (self.image!=NULL)
        {
            
            MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithImage:self.image];
            visionImage.orientation = self.image.imageOrientation;

            MLKTextRecognizer *textRecognizer = [MLKTextRecognizer textRecognizer];

            [textRecognizer processImage:visionImage
                  completion:^(MLKText *_Nullable result,
                               NSError *_Nullable error) {
              if (error != nil || result == nil) {
                // Error handling
                return;
              }
              // Recognized text
                
                
            //self.textDetector = [GMVDetector detectorOfType:GMVDetectorTypeText options:nil];
            //NSArray<GMVTextBlockFeature *> *features = [self.textDetector featuresInImage:self.image
            //                                                                      options:nil];
            int count = 0;
            
            NSMutableDictionary* resultobjmut = [[NSMutableDictionary alloc] init];
            NSMutableDictionary* blockobj = [[NSMutableDictionary alloc] init];
            NSMutableDictionary* lineobj = [[NSMutableDictionary alloc] init];
            NSMutableDictionary* wordobj = [[NSMutableDictionary alloc] init];
            
            NSMutableArray* blocktext = [[NSMutableArray alloc] init];
            NSMutableArray* blocklanguages = [[NSMutableArray alloc] init];
            NSMutableArray* blockpoints = [[NSMutableArray alloc] init];
            NSMutableArray* blockframe = [[NSMutableArray alloc] init];
            
            NSMutableArray* linetext = [[NSMutableArray alloc] init];
            NSMutableArray* linelanguages = [[NSMutableArray alloc] init];
            NSMutableArray* linepoints = [[NSMutableArray alloc] init];
            NSMutableArray* lineframe = [[NSMutableArray alloc] init];
            
            NSMutableArray* wordtext = [[NSMutableArray alloc] init];
            NSMutableArray* wordlanguages = [[NSMutableArray alloc] init];
            NSMutableArray* wordpoints = [[NSMutableArray alloc] init];
            NSMutableArray* wordframe = [[NSMutableArray alloc] init];

            // Iterate over each text block.
            for (MLKTextBlock *textBlock in result.blocks) {
                count++;

                //Block Text
                [blocktext addObject:textBlock.text];
                
                //Block Language
                if( textBlock.recognizedLanguages && textBlock.recognizedLanguages[0] && textBlock.recognizedLanguages[0].languageCode){
                    // do something if object isn't nil
                    [blocklanguages addObject:textBlock.recognizedLanguages[0].languageCode];
                } else {
                    // initialize object and do something
                    [blocklanguages addObject:[NSNull null]];
                }
                
                //Block Corner Points
                NSString *x1 = [NSString stringWithFormat:@"%f",textBlock.cornerPoints[0].CGPointValue.x];
                NSString *y1 = [NSString stringWithFormat:@"%f",textBlock.cornerPoints[0].CGPointValue.y];
                
                NSString *x2 = [NSString stringWithFormat:@"%f",textBlock.cornerPoints[1].CGPointValue.x];
                NSString *y2 = [NSString stringWithFormat:@"%f",textBlock.cornerPoints[1].CGPointValue.y];
                
                NSString *x3 = [NSString stringWithFormat:@"%f",textBlock.cornerPoints[2].CGPointValue.x];
                NSString *y3 = [NSString stringWithFormat:@"%f",textBlock.cornerPoints[2].CGPointValue.y];
                
                NSString *x4 = [NSString stringWithFormat:@"%f",textBlock.cornerPoints[3].CGPointValue.x];
                NSString *y4 = [NSString stringWithFormat:@"%f",textBlock.cornerPoints[3].CGPointValue.y];
                
                NSDictionary* bpoobj = @{
                                         @"x1": x1,
                                         @"y1": y1,
                                         @"x2": x2,
                                         @"y2": y2,
                                         @"x3": x3,
                                         @"y3": y3,
                                         @"x4": x4,
                                         @"y4": y4,
                                         };
                [blockpoints addObject:bpoobj];
                
                //Block Frame
                CGFloat xfloat =  textBlock.frame.origin.x;
                CGFloat yfloat =  textBlock.frame.origin.y;
                CGFloat heightfloat =  textBlock.frame.size.height; //bounds.size.height;
                CGFloat widthfloat =  textBlock.frame.size.width;
                
                NSString *x = [NSString stringWithFormat:@"%f",xfloat];
                NSString *y = [NSString stringWithFormat:@"%f",yfloat];
                NSString *height = [NSString stringWithFormat:@"%f",heightfloat];
                NSString *width = [NSString stringWithFormat:@"%f",widthfloat];
                
                NSDictionary* bframeobj = @{
                                            @"x": x,
                                            @"y": y,
                                            @"height": height,
                                            @"width": width
                                            };
                [blockframe addObject:bframeobj];
                
                
                // For each text block, iterate over each line.
                for (MLKTextLine *textLine in textBlock.lines) {
                
                    //Line Text
                    [linetext addObject:textLine.text];
                    
                    //Line Language
                    if( textBlock.recognizedLanguages && textBlock.recognizedLanguages[0] && textBlock.recognizedLanguages[0].languageCode ){
                        // do something if object isn't nil
                        [linelanguages addObject:textLine.recognizedLanguages[0].languageCode];
                    } else {
                        // initialize object and do something
                        [linelanguages addObject:[NSNull null]];
                    }
                    
                    ////Line Corner Points
                    NSString *x1 = [NSString stringWithFormat:@"%f",textLine.cornerPoints[0].CGPointValue.x];
                    NSString *y1 = [NSString stringWithFormat:@"%f",textLine.cornerPoints[0].CGPointValue.y];
                    
                    NSString *x2 = [NSString stringWithFormat:@"%f",textLine.cornerPoints[1].CGPointValue.x];
                    NSString *y2 = [NSString stringWithFormat:@"%f",textLine.cornerPoints[1].CGPointValue.y];
                    
                    NSString *x3 = [NSString stringWithFormat:@"%f",textLine.cornerPoints[2].CGPointValue.x];
                    NSString *y3 = [NSString stringWithFormat:@"%f",textLine.cornerPoints[2].CGPointValue.y];
                    
                    NSString *x4 = [NSString stringWithFormat:@"%f",textLine.cornerPoints[3].CGPointValue.x];
                    NSString *y4 = [NSString stringWithFormat:@"%f",textLine.cornerPoints[3].CGPointValue.y];
                    
                    NSDictionary* lpoobj = @{
                                             @"x1": x1,
                                             @"y1": y1,
                                             @"x2": x2,
                                             @"y2": y2,
                                             @"x3": x3,
                                             @"y3": y3,
                                             @"x4": x4,
                                             @"y4": y4,
                                             };
                    [linepoints addObject:lpoobj];
                    
                    //Line Frame
                    CGFloat xfloat =  textLine.frame.origin.x;
                    CGFloat yfloat =  textLine.frame.origin.y;
                    CGFloat heightfloat =  textLine.frame.size.height;
                    CGFloat widthfloat =  textLine.frame.size.width;
                    
                    NSString *x = [NSString stringWithFormat:@"%f",xfloat];
                    NSString *y = [NSString stringWithFormat:@"%f",yfloat];
                    NSString *height = [NSString stringWithFormat:@"%f",heightfloat];
                    NSString *width = [NSString stringWithFormat:@"%f",widthfloat];
                    
                    NSDictionary* lframeobj = @{
                                                @"x": x,
                                                @"y": y,
                                                @"height": height,
                                                @"width": width
                                                };
                    [lineframe addObject:lframeobj];
                    
                    
                    // For each line, iterate over each word.
                    for (MLKTextElement *textElement in textLine.elements) {

                        //Word Text
                        [wordtext addObject:textElement.text];
                        
                        //Word Language
                        if( textBlock.recognizedLanguages && textBlock.recognizedLanguages[0] && textBlock.recognizedLanguages[0].languageCode ){
                            // do something if object isn't nil
                            [wordlanguages addObject:textLine.recognizedLanguages[0].languageCode];
                        } else {
                            // initialize object and do something
                            [wordlanguages addObject:[NSNull null]];
                        }
                        //Word Corner Points
                        NSString *x1 = [NSString stringWithFormat:@"%f",textElement.cornerPoints[0].CGPointValue.x];
                        NSString *y1 = [NSString stringWithFormat:@"%f",textElement.cornerPoints[0].CGPointValue.y];
                        
                        NSString *x2 = [NSString stringWithFormat:@"%f",textElement.cornerPoints[1].CGPointValue.x];
                        NSString *y2 = [NSString stringWithFormat:@"%f",textElement.cornerPoints[1].CGPointValue.y];
                        
                        NSString *x3 = [NSString stringWithFormat:@"%f",textElement.cornerPoints[2].CGPointValue.x];
                        NSString *y3 = [NSString stringWithFormat:@"%f",textElement.cornerPoints[2].CGPointValue.y];
                        
                        NSString *x4 = [NSString stringWithFormat:@"%f",textElement.cornerPoints[3].CGPointValue.x];
                        NSString *y4 = [NSString stringWithFormat:@"%f",textElement.cornerPoints[3].CGPointValue.y];
                        
                        NSDictionary* wpoobj = @{
                                                 @"x1": x1,
                                                 @"y1": y1,
                                                 @"x2": x2,
                                                 @"y2": y2,
                                                 @"x3": x3,
                                                 @"y3": y3,
                                                 @"x4": x4,
                                                 @"y4": y4,
                                                 };
                        [wordpoints addObject:wpoobj];
                        
                        //Word Frame
                        CGFloat xfloat =  textElement.frame.origin.x;
                        CGFloat yfloat =  textElement.frame.origin.y;
                        CGFloat heightfloat =  textElement.frame.size.height;
                        CGFloat widthfloat =  textElement.frame.size.width;
                        
                        NSString *x = [NSString stringWithFormat:@"%f",xfloat];
                        NSString *y = [NSString stringWithFormat:@"%f",yfloat];
                        NSString *height = [NSString stringWithFormat:@"%f",heightfloat];
                        NSString *width = [NSString stringWithFormat:@"%f",widthfloat];
                        
                        NSDictionary* wframeobj = @{
                                                    @"x": x,
                                                    @"y": y,
                                                    @"height": height,
                                                    @"width": width
                                                    };
                        [wordframe addObject:wframeobj];
                    }
                }
            }
            if (count==0) {
                // Used to return error if no text was found in image
                // CDVPluginResult* result = [CDVPluginResult
                //                            resultWithStatus:CDVCommandStatus_ERROR
                //                            messageAsString:@"No text in image"];
                // [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
                
                // Return success with an object if no text found
                NSNumber *foundText = @NO;
                resultobjmut = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                 foundText,@"foundText", nil] mutableCopy];
                NSDictionary *resultobj = [NSDictionary dictionaryWithDictionary:resultobjmut];
                
                CDVPluginResult* resultcor = [CDVPluginResult
                                              resultWithStatus:CDVCommandStatus_OK
                                              messageAsDictionary:resultobj];
                [self.commandDelegate sendPluginResult:resultcor callbackId:self->_commandglo.callbackId];
            }
            else
            {
                blockobj = [[[NSDictionary alloc] initWithObjectsAndKeys:
                             blocktext,@"blocktext",
                             blocklanguages,@"blocklanguages",
                             blockpoints,@"blockpoints",
                             blockframe,@"blockframe", nil] mutableCopy];
                
                NSDictionary *bobj = [NSDictionary dictionaryWithDictionary:blockobj];
                
                
                lineobj = [[[NSDictionary alloc] initWithObjectsAndKeys:
                            linetext,@"linetext",
                            linelanguages,@"linelanguages",
                            linepoints,@"linepoints",
                            lineframe,@"lineframe", nil] mutableCopy];
                NSDictionary *lobj = [NSDictionary dictionaryWithDictionary:lineobj];
                
                
                wordobj = [[[NSDictionary alloc] initWithObjectsAndKeys:
                            wordtext,@"wordtext",
                            wordlanguages,@"wordlanguages",
                            wordpoints,@"wordpoints",
                            wordframe,@"wordframe", nil] mutableCopy];
                NSDictionary *wobj = [NSDictionary dictionaryWithDictionary:wordobj];
                
                NSNumber *foundText = @YES;
                resultobjmut = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                 foundText,@"foundText",
                                 bobj,@"blocks",
                                 lobj,@"lines",
                                 wobj,@"words", nil] mutableCopy];
                NSDictionary *resultobj = [NSDictionary dictionaryWithDictionary:resultobjmut];
                
                CDVPluginResult* resultcor = [CDVPluginResult
                                              resultWithStatus:CDVCommandStatus_OK
                                              messageAsDictionary:resultobj];
                [self.commandDelegate sendPluginResult:resultcor callbackId:self->_commandglo.callbackId];
            }
                

                }];

        }
        else
        {
            CDVPluginResult* result = [CDVPluginResult
                                       resultWithStatus:CDVCommandStatus_ERROR
                                       messageAsString:@"Image was null"];
            [self.commandDelegate sendPluginResult:result callbackId:self->_commandglo.callbackId];
        }
    }];
}


-(UIImage *)resizeImage:(UIImage *)image
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 600;
    float maxWidth = 600;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.50;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    return [UIImage imageWithData:imageData];
    
}

-(NSData *)retrieveAssetDataPhotosFramework:(NSURL *)urlMedia
{
    NSData *data = [NSData dataWithContentsOfURL:urlMedia];
    
    if (data != nil)
    {
        return data;
    }
    else
    {
        return NULL;
    }
    
}

@end

