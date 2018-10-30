//
//  AdvanceFilePicker.m
//
//  Created by @ankurKapil
//
//

#import "AdvanceFilePicker.h"

@implementation AdvanceFilePicker
//: id <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (void)isAvailable:(CDVInvokedUrlCommand*)command
{
    BOOL supported = [UIDocumentPickerViewController class] != nil;
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:supported] callbackId:command.callbackId];
}

- (void)pickFile:(CDVInvokedUrlCommand*)command
{
    self.command = command;
    id UTIs = [command.arguments objectAtIndex:0];
    BOOL supported = YES;
    NSArray * UTIsArray = nil;
    CGRect frame = CGRectZero;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if(command.arguments.count > 1) {
            NSDictionary * frameValues = [command.arguments objectAtIndex:1];
            frameValues = [frameValues isEqual:[NSNull null]]?nil:frameValues;
            if (frameValues) {
                frame.origin.x   = [[frameValues valueForKey:@"x"] integerValue];
                frame.origin.y   = [[frameValues valueForKey:@"y"] integerValue];
                frame.size.width = [[frameValues valueForKey:@"width"] integerValue];
                frame.size.height= [[frameValues valueForKey:@"height"] integerValue];
            }
        }
    }
    
    if ([UTIs isEqual:[NSNull null]]) {
        UTIsArray =  @[@"public.data"];
    } else if ([UTIs isKindOfClass:[NSString class]]){
        UTIsArray = @[UTIs];
    } else if ([UTIs isKindOfClass:[NSArray class]]){
        UTIsArray = UTIs;
    } else {
        supported = NO;
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"not supported"] callbackId:self.command.callbackId];
    }
    
    if (![UIDocumentPickerViewController class]) {
        supported = NO;
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"your device can't show the file picker"] callbackId:self.command.callbackId];
    }
    
    if (supported) {
        self.pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
        [self.pluginResult setKeepCallbackAsBool:YES];
        [self displayDocumentPicker:UTIsArray withSenderRect:frame];
    }
}

#pragma mark - UIDocumentMenuDelegate
-(void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker
{
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.viewController presentViewController:documentPicker animated:YES completion:nil];
}

-(void)documentMenuWasCancelled:(UIDocumentMenuViewController *)documentMenu
{
    self.pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"canceled"];
    [self.pluginResult setKeepCallbackAsBool:NO];
    [self.commandDelegate sendPluginResult:self.pluginResult callbackId:self.command.callbackId];
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    
    self.pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[url path]];
    [self.pluginResult setKeepCallbackAsBool:NO];
    [self.commandDelegate sendPluginResult:self.pluginResult callbackId:self.command.callbackId];
    
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    self.pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"canceled"];
    [self.pluginResult setKeepCallbackAsBool:NO];
    [self.commandDelegate sendPluginResult:self.pluginResult callbackId:self.command.callbackId];
}

- (void)displayDocumentPicker:(NSArray *)UTIs withSenderRect:(CGRect)senderFrame
{
    UIDocumentMenuViewController * vc = nil;
    //    if (!IsAtLeastiOSVersion(@"11.0")) {
    vc = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:UTIs inMode:UIDocumentPickerModeImport];
    ((UIDocumentMenuViewController *)vc).delegate = self;
    vc.popoverPresentationController.sourceView = self.viewController.view;
    //******* Custom gallery / camera option added over UIDocumentMenuViewController *******
    [vc addOptionWithTitle:@"Gallery" image: [UIImage imageNamed:@"gallery"] order:UIDocumentMenuOrderFirst handler:^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self.viewController presentViewController:picker animated:YES completion:NULL];
    }];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [vc addOptionWithTitle:@"Camera" image: [UIImage imageNamed:@"camera"] order:UIDocumentMenuOrderFirst handler:^{
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self.viewController presentViewController:picker animated:YES completion:NULL];
        }];
    }
    //*******
    if (!CGRectEqualToRect(senderFrame, CGRectZero)) {
        vc.popoverPresentationController.sourceRect = senderFrame;
    }
    //    } else {
    //        vc = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:UTIs inMode:UIDocumentPickerModeImport];
    //        ((UIDocumentPickerViewController *)vc).delegate = self;
    //        vc.modalPresentationStyle = UIModalPresentationFullScreen;
    //    }
    [self.viewController presentViewController:vc animated:YES completion:nil];
}

//MARK:- Image Picker Controller Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *webData = UIImagePNGRepresentation(image);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent:@"image.png"];
    [webData writeToFile:localFilePath atomically:YES];
    //    }
    self.pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:localFilePath];
    [self.pluginResult setKeepCallbackAsBool:NO];
    [self.commandDelegate sendPluginResult:self.pluginResult callbackId:self.command.callbackId];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    self.pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"canceled"];
    [self.pluginResult setKeepCallbackAsBool:NO];
    [self.commandDelegate sendPluginResult:self.pluginResult callbackId:self.command.callbackId];
}

@end
