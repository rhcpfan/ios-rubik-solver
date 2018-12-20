//
//  ViewController.h
//  RubikSolver-iOS
//
//  Created by rhcpfan on 15/01/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#import <UIKit/UIKit.h>

// Import CTAssetsPickerController for multiple image selection
#import <CTAssetsPickerController/CTAssetsPickerController.h>

@interface MainViewController : UIViewController <CTAssetsPickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *startButton;

- (void) presentMultipleSelectionImagePicker;

- (IBAction)didPressStartButton:(UIButton *)sender;

@end

