//
//  ViewController.m
//  RubikSolver-iOS
//
//  Created by rhcpfan on 15/01/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#import "MainViewController.h"
#import "CubeCaptureViewController.h"

// Import search.hpp for applying the Kociemba algorithm at starup in order to
// create the pruning tables needed for solving
#import "search.hpp"


@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Solve a cube configuration just to generate the pruning tables and store them in cache
    char* solutionArray = ApplyKociembaAlgorithm(strdup("ULURURRLDLDLBRUDBUUUFDFLDBRBUFBDDDRFLUBDLFBRLFFBFBLRFR"), 24, 1000, 0, "cache");
    NSLog(@"Solution: %@", [NSString stringWithUTF8String:solutionArray]);
    
    [self.startButton setEnabled:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)didPressStartButton:(UIButton *)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Where would you like to get the cube images from?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Capture from camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self performSegueWithIdentifier:@"mainToCubeCaptureSegue" sender:self];
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Select from gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentMultipleSelectionImagePicker];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void) presentMultipleSelectionImagePicker {
    // request authorization status
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            
            picker.showsEmptyAlbums = NO;
            // set delegate
            picker.delegate = self;
            
            // Optionally present picker as a form sheet on iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
}

- (void) assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker {
    
}

- (void) assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    if(assets.count == 2) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please select the two images of the cube!" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [picker presentViewController:alertController animated:YES completion:nil];
    }
}

@end
