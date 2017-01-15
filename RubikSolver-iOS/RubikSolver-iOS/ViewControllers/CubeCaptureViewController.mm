//
//  CubeCaptureViewController.m
//  RubikSolver-iOS
//
//  Created by rhcpfan on 15/01/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#import "CubeCaptureViewController.h"
#import "ColorCorrectionViewController.h"

@interface CubeCaptureViewController ()

@end

@implementation CubeCaptureViewController

@synthesize acceptedColorsArray = _acceptedColorsArray;
@synthesize computedColorsArray = _computedColorsArray;
@synthesize photoCamera = _photoCamera;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.faceImagesArray = [[NSMutableArray alloc] init];
    
    /// Flag describing if the user took the first picture
    didTakeFirstPicture = NO;
    
    // Load the SVM classifier
    NSString *svmClassifierPath = [[NSBundle mainBundle] pathForResource: @"color-classification-svm-2" ofType: @"yml"];
    std::string svmClassifierPathStd = std::string([svmClassifierPath UTF8String]);
    _colorDetector.LoadSVMFromFile(svmClassifierPathStd);
    
    // Load the region mask
    cv::Mat regionsMask;
    UIImageToMat([UIImage imageNamed:@"guideline-overlay.png"], regionsMask);
    _cubeDetector.SetRegionsMask(regionsMask);
    
    // Alloc the detected colors array
    _acceptedColorsArray = [[NSMutableArray alloc] init];
    
    // Setup the camera parameters
    _photoCamera = [[CvPhotoCamera alloc] initWithParentView:self.cameraImageView];
    _photoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    _photoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    _photoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device isFlashAvailable]) {
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = AVCaptureFlashModeOn;
            [device unlockForConfiguration];
        } else {
            NSLog(@"unable to lock device for flash configuration %@", [error localizedDescription]);
        }
    }
    
    // Set the camera delegate
    _photoCamera.delegate = self;
    
    // Start the aquisition process
    [_photoCamera start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Protocol CvPhotoCameraDelegate

#ifdef __cplusplus

- (void)saveMatImageToDocumentsFolder:(const cv::Mat&)image named:(NSString*)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.jpg", imageName, photoIndex]];
    NSData *imageData = UIImageJPEGRepresentation(MatToUIImage(image), 1);
    [imageData writeToFile:appFile atomically:NO];
}

- (void)saveUIImageToDocumentsFolder:(UIImage*)image named:(NSString*)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.jpg", imageName, photoIndex]];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    [imageData writeToFile:appFile atomically:NO];
}

/// Method called after "takePicture" method is called (delegate)
- (void)photoCamera:(CvPhotoCamera*)photoCamera capturedImage:(UIImage *)image {
    try {
        [_photoCamera stop];
        
        self.captureImageButton.hidden = YES;
        self.acceptButton.hidden = NO;
        self.rejectButton.hidden = NO;
        self.instructionsLabel.text = @"Make sure that the corners are detected properly :)";
        
        cv::Mat capturedImage;
        UIImageToMat(image, capturedImage);
        
        // Rotate clockwise 90 degrees (portrait orientation in iOS...)
        cv::transpose(capturedImage, capturedImage);
        cv::flip(capturedImage, capturedImage, 1);
        
        cv::Mat bgrImage, outputImage, rgbaImage;
        cv::cvtColor(capturedImage, bgrImage, CV_RGBA2BGR);
        
        _cubeDetector.SegmentFaces(bgrImage, outputImage, topImage, leftImage, rightImage, !didTakeFirstPicture);
        
        
        auto topColors = _colorDetector.RecognizeColors(topImage);
        auto leftColors = _colorDetector.RecognizeColors(leftImage);
        auto rightColors = _colorDetector.RecognizeColors(rightImage);
        
        _computedColorsArray = [[NSMutableArray alloc] init];
        
        std::cout << std::endl;
        for (int i = 0; i < topColors.size(); i++) {
            [_computedColorsArray addObject: [NSString stringWithCString:topColors[i].c_str() encoding:[NSString defaultCStringEncoding]]];
            std::cout << topColors[i] << " ";
        }
        std::cout << std::endl;
        for (int i = 0; i < leftColors.size(); i++) {
            [_computedColorsArray addObject: [NSString stringWithCString:leftColors[i].c_str() encoding:[NSString defaultCStringEncoding]]];
            std::cout << leftColors[i] << " ";
        }
        std::cout << std::endl;
        for (int i = 0; i < rightColors.size(); i++) {
            [_computedColorsArray addObject: [NSString stringWithCString:rightColors[i].c_str() encoding:[NSString defaultCStringEncoding]]];
            std::cout << rightColors[i] << " ";
        }
        
        cv::cvtColor(outputImage, rgbaImage, CV_BGR2RGBA);
        cv::cvtColor(topImage, topImage, CV_BGR2RGBA);
        cv::cvtColor(leftImage, leftImage, CV_BGR2RGBA);
        cv::cvtColor(rightImage, rightImage, CV_BGR2RGBA);
        
        
        UIImage *segmentationImage = MatToUIImage(rgbaImage);
        
        photoIndex++;
        
        self.overlayImageView.image = segmentationImage;
        self.overlayImageView.alpha = 1.0;
        
    } catch (const std::out_of_range &exception) {
        // TODO: display error
        std::cout << exception.what() << std::endl;
        
        NSString *errorMessage = [NSString stringWithUTF8String:exception.what()];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ooops :-(" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didPressRetakeImage:nil];
        }];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}



/// Declared to conform to the delegation pattern (not used)
- (void)photoCameraCancel:(CvPhotoCamera*)photoCamera {
    
}

#endif


- (IBAction)didPressCaptureImage:(UIButton *)sender {
    [_photoCamera takePicture];
}

- (IBAction)didPressRetakeImage:(UIButton *)sender {
    
    if(!didTakeFirstPicture) {
        self.instructionsLabel.text = @"Take the picture of the first three faces.";
    } else {
        self.instructionsLabel.text = @"Take the picture of the last three faces.";
    }
    
    self.overlayImageView.image = [UIImage imageNamed:@"guide-overlay"];
    self.overlayImageView.alpha = 0.5;
    
    [self.photoCamera start];
    
    self.captureImageButton.hidden = NO;
    self.acceptButton.hidden = YES;
    self.rejectButton.hidden = YES;
}

- (IBAction)didPressAcceptImage:(UIButton *)sender {
    // Add the accepted colors to the accepted array
    [_acceptedColorsArray addObjectsFromArray:_computedColorsArray];
    
    // Add the face images to the array
    [self.faceImagesArray addObject:MatToUIImage(topImage)];
    [self.faceImagesArray addObject:MatToUIImage(leftImage)];
    [self.faceImagesArray addObject:MatToUIImage(rightImage)];
    
    
    // If the user has taken the second photo, go to the correction view
    if(didTakeFirstPicture) {
        
        for (UIImage *faceImage in self.faceImagesArray) {
            NSString* fileName = [NSString stringWithFormat:@"color_recognition_%d", rand()];
            [self saveUIImageToDocumentsFolder:faceImage named:fileName];
        }
        
        [self performSegueWithIdentifier:@"captureToCorrectionSegue" sender:self];
    } else {
        didTakeFirstPicture = YES;
        [self didPressRetakeImage:nil];
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqual: @"captureToCorrectionSegue"]) {
        
        ColorCorrectionViewController *destinationVC = [segue destinationViewController];
        
        destinationVC.faceColors = self.acceptedColorsArray;
        destinationVC.faceImages = self.faceImagesArray;
    }
    
}


@end
