//
//  UIButton+Helpers.h
//  RubikSolver-iOS
//
//  Created by Andrei Ciobanu on 16/12/2018.
//  Copyright © 2018 HomeApps. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Helpers)

- (void)removeBorders;
- (void)addBordersWithColor:(UIColor*)borderColor andWidth:(CGFloat)borderWidth;
- (void)setCubieColor:(NSString*)cubieColor;


@end

NS_ASSUME_NONNULL_END
