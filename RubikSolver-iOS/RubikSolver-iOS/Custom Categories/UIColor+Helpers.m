//
//  UIColor+Helpers.m
//  RubikSolver-iOS
//
//  Created by Andrei Ciobanu on 16/12/2018.
//  Copyright © 2018 HomeApps. All rights reserved.
//

#import "UIColor+Helpers.h"

@implementation UIColor (Helpers)

+ (UIColor *)colorFromString:(NSString *)colorString {
    if ([colorString isEqualToString:@"R"]) return [UIColor redColor];
    if ([colorString isEqualToString:@"G"]) return [UIColor greenColor];
    if ([colorString isEqualToString:@"B"]) return [UIColor blueColor];
    if ([colorString isEqualToString:@"O"]) return [UIColor orangeColor];
    if ([colorString isEqualToString:@"W"]) return [UIColor whiteColor];
    if ([colorString isEqualToString:@"Y"]) return [UIColor yellowColor];
    
    return [UIColor blackColor];
}

@end
