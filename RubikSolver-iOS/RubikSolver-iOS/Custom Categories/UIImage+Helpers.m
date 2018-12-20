//
//  UIImage+Helpers.m
//  RubikSolver-iOS
//
//  Created by Andrei Ciobanu on 20/12/2018.
//  Copyright © 2018 HomeApps. All rights reserved.
//

#import "UIImage+Helpers.h"

@implementation UIImage (Helpers)

/**
 Saves an image of type <b>UIImage</b> to the documents folder (you can access it via iTunes)
 @param imageName The name of the image, without extension (ex. "accepted_image")
 */
- (void)saveToDocumentsFolderWithName:(NSString*)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", imageName]];
    NSData *imageData = UIImageJPEGRepresentation(self, 1);
    [imageData writeToFile:appFile atomically:NO];
}

@end
