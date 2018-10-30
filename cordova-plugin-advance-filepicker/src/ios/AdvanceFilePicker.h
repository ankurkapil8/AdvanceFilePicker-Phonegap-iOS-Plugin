//
//  AdvanceFilePicker.h
//
//  Created by @ankurKapil
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface AdvanceFilePicker : CDVPlugin <UIDocumentMenuDelegate,UIDocumentPickerDelegate>

@property (strong, nonatomic) CDVPluginResult * pluginResult;
@property (strong, nonatomic) CDVInvokedUrlCommand * command;

- (void)isAvailable:(CDVInvokedUrlCommand*)command;
- (void)pickFile:(CDVInvokedUrlCommand*)command;

@end
