//
//  UIButton+Helpers.m
//  RubikSolver-iOS
//
//  Created by Andrei Ciobanu on 16/12/2018.
//  Copyright © 2018 HomeApps. All rights reserved.
//

#import "UIButton+Helpers.h"
#import "UIColor+Helpers.h"

@implementation UIButton (Helpers)

- (void)removeBorders {
    self.layer.borderWidth = 0;
}

- (void)addBordersWithColor:(UIColor*)borderColor andWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setCubieColor:(NSString*)cubieColor {
    [self setBackgroundColor:[UIColor colorFromString:cubieColor]];
}

@end
