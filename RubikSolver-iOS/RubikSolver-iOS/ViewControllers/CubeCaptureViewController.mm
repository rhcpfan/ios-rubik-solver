//
//  CubeCaptureViewController.m
//  RubikSolver-iOS
//
//  Created by rhcpfan on 15/01/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#import "CubeCaptureViewController.h"
#import "ColorCorrectionViewController.h"

@implementation CubeCaptureViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.faceImagesArray = [[NSMutableArray alloc] init];
    
    /// Flag describing if the user took the first picture
    didTakeFirstPicture = NO;
    
    // Load the SVM classifier
    [self loadSvmClassifier];
    
    // Alloc the detected colors array
    _acceptedColorsArray = [[NSMutableArray alloc] init];
    
    // Setup the camera parameters (force flash and 1280x720 resolution)
    _photoCamera = [[CvPhotoCamera alloc] initWithParentView:self.cameraImageView];
    _photoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    _photoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    _photoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    
    // Force the camera to use the flash (if available)
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

#pragma mark - Instance Methods -

- (void)loadSvmClassifier {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fManager = [NSFileManager defaultManager];
    NSString *svmClassifierPath = [documentsDirectory stringByAppendingPathComponent:@"svm-trained-on-device.yml"];

    if (![fManager fileExistsAtPath:svmClassifierPath]) {
        svmClassifierPath = [[NSBundle mainBundle] pathForResource: @"color-classification-svm" ofType: @"yml"];
    }

    _colorDetector.LoadSVMFromFile([svmClassifierPath cStringUsingEncoding:NSASCIIStringEncoding]);
}

#pragma mark - Protocol CvPhotoCameraDelegate

#ifdef __cplusplus

/**
 Method invoked after taking a picture (CvPhotoCameraDelegate method)
 @param photoCamera The CvPhotoCamera object
 @param image The UIImage captured by the device
 */
- (void)photoCamera:(CvPhotoCamera*)photoCamera capturedImage:(UIImage *)image {
    try {
        [_photoCamera stop];
        
        self.captureImageButton.hidden = YES;
        self.acceptButton.hidden = NO;
        self.rejectButton.hidden = NO;
        self.instructionsLabel.text = @"Make sure that the corners are detected properly :)";
        
        self.capturedImage = image;
        
        // Convert the UIImage to a cv::Mat object
        cv::Mat capturedImageMat;
        UIImageToMat(image, capturedImageMat);
        
        // Rotate clockwise 90 degrees (portrait orientation in iOS...)
        cv::transpose(capturedImageMat, capturedImageMat);
        cv::flip(capturedImageMat, capturedImageMat, 1);
        
        // Convert the image from RGBA (device color format) to BGR (default OpenCV color format)
        cv::Mat bgrImage, outputImage, rgbaImage;
        cv::cvtColor(capturedImageMat, bgrImage, CV_RGBA2BGR);
        
        // Apply the segmentation algorithm
        _cubeDetector.SegmentFaces(bgrImage, outputImage, topImage, leftImage, rightImage, !didTakeFirstPicture);
        
        
        auto topColors = _colorDetector.RecognizeColors(topImage);
        auto leftColors = _colorDetector.RecognizeColors(leftImage);
        auto rightColors = _colorDetector.RecognizeColors(rightImage);
        
        _computedColorsArray = [[NSMutableArray alloc] init];

        for (int i = 0; i < topColors.size(); i++) {
            [_computedColorsArray addObject: [NSString stringWithCString:topColors[i].c_str() encoding:[NSString defaultCStringEncoding]]];
        }

        for (int i = 0; i < leftColors.size(); i++) {
            [_computedColorsArray addObject: [NSString stringWithCString:leftColors[i].c_str() encoding:[NSString defaultCStringEncoding]]];
        }

        for (int i = 0; i < rightColors.size(); i++) {
            [_computedColorsArray addObject: [NSString stringWithCString:rightColors[i].c_str() encoding:[NSString defaultCStringEncoding]]];
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
    
    [_photoCamera start];
    
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
