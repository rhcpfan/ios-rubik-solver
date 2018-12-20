//
//  ColorCorrectionViewController.m
//  RubikSolver-iOS
//
//  Created by rhcpfan on 15/01/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#import "ColorCorrectionViewController.h"
#import "CubeSolverViewController.h"
#import "UIButton+Helpers.h"
#import "UIImage+Helpers.h"

@interface ColorCorrectionViewController ()

@end

@implementation ColorCorrectionViewController

#pragma mark - Application Lifecycle -

- (void)viewDidLoad {
    [super viewDidLoad];    // Do any additional setup after loading the view.
    
    self.currentFaceIndex = 0;
    [self setColorsFromArray:self.currentFaceIndex];
    self.faceImageView.image = [self.faceImages objectAtIndex:self.currentFaceIndex];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"correctionToSolveSegue"]) {
        CubeSolverViewController *solverViewController = [segue destinationViewController];
        solverViewController.allColorsArray = self.faceColors;
    }
}

#pragma mark - IBActions -

- (IBAction)didPressFirstPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9;
    [self.selectedButton addBordersWithColor:[UIColor blackColor] andWidth:5];
}

- (IBAction)didPressSecondPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 1;
    [self.selectedButton addBordersWithColor:[UIColor blackColor] andWidth:5];
}

- (IBAction)didPressThirdPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 2;
    [self.selectedButton addBordersWithColor:[UIColor blackColor] andWidth:5];
}

- (IBAction)didPressFourthPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 3;
    [self.selectedButton addBordersWithColor:[UIColor blackColor] andWidth:5];
}

- (IBAction)didPressFifthPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 4;
    [self.selectedButton addBordersWithColor:[UIColor blackColor] andWidth:5];
}

- (IBAction)didPressSixthPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 5;
    [self.selectedButton addBordersWithColor:[UIColor blackColor] andWidth:5];
}

- (IBAction)didPressSeventhPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 6;
    [self.selectedButton addBordersWithColor:[UIColor blackColor] andWidth:5];
}

- (IBAction)didPressEightPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 7;
    [self.selectedButton addBordersWithColor:[UIColor blackColor] andWidth:5];
}

- (IBAction)didPressNinethPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 8;
    [self.selectedButton addBordersWithColor:[UIColor blackColor] andWidth:5];
}

- (IBAction)didPressRedColorButton:(UIButton *)sender {
    [self.selectedButton setBackgroundColor:[UIColor redColor]];
    [self.faceColors replaceObjectAtIndex:self.currentSquareIndexInCube withObject:@"R"];
}
- (IBAction)didPressOrangeColorButton:(UIButton *)sender {
    [self.selectedButton setBackgroundColor:[UIColor orangeColor]];
    [self.faceColors replaceObjectAtIndex:self.currentSquareIndexInCube withObject:@"O"];
}
- (IBAction)didPressGreenColorButton:(UIButton *)sender {
    [self.selectedButton setBackgroundColor:[UIColor greenColor]];
    [self.faceColors replaceObjectAtIndex:self.currentSquareIndexInCube withObject:@"G"];
}
- (IBAction)didPressBlueColorButton:(UIButton *)sender {
    [self.selectedButton setBackgroundColor:[UIColor blueColor]];
    [self.faceColors replaceObjectAtIndex:self.currentSquareIndexInCube withObject:@"B"];
}
- (IBAction)didPressYellowColorButton:(UIButton *)sender {
    [self.selectedButton setBackgroundColor:[UIColor yellowColor]];
    [self.faceColors replaceObjectAtIndex:self.currentSquareIndexInCube withObject:@"Y"];
}
- (IBAction)didPressWhiteColorButton:(UIButton *)sender {
    [self.selectedButton setBackgroundColor:[UIColor whiteColor]];
    [self.faceColors replaceObjectAtIndex:self.currentSquareIndexInCube withObject:@"W"];
}

- (IBAction)didPressNextFaceButton:(id)sender {
    
    if([[self.nextFaceButton titleForState:UIControlStateNormal] isEqualToString:@"DONE"])
    {
        [self saveColorPatchImages];
        [self performSegueWithIdentifier:@"correctionToSolveSegue" sender:self];
        return;
    }
    
    if(self.currentFaceIndex < 5)
    {
        self.currentFaceIndex += 1;
        [self setColorsFromArray:self.currentFaceIndex];
        self.faceImageView.image = [self.faceImages objectAtIndex:self.currentFaceIndex];
        
    }
    self.faceIndexLabel.text = [NSString stringWithFormat:@"Face %d/6", (int)self.currentFaceIndex + 1];
    
    if(self.currentFaceIndex == 5)
    {
        [self.nextFaceButton setTitle:@"DONE" forState:UIControlStateNormal];
        [self.nextFaceButton setTitle:@"DONE" forState:UIControlStateHighlighted];
    }
}

- (IBAction)didPressPreviousFaceButton:(id)sender {
    if(self.currentFaceIndex > 0) {
        self.currentFaceIndex -= 1;
        [self setColorsFromArray:self.currentFaceIndex];
        self.faceImageView.image = [self.faceImages objectAtIndex:self.currentFaceIndex];
    }
    
    self.faceIndexLabel.text = [NSString stringWithFormat:@"Face %d/6", (int)self.currentFaceIndex + 1];
    
    if(self.currentFaceIndex < 5) {
        [self.nextFaceButton setTitle:@"Next" forState:UIControlStateNormal];
        [self.nextFaceButton setTitle:@"Next" forState:UIControlStateHighlighted];
    }
}

#pragma mark - Instance Methods -

- (void)removeAllBorders {
    [self.firstPatchButton removeBorders];
    [self.secondPatchButton removeBorders];
    [self.thirdPatchButton removeBorders];

    [self.fourthPatchButton removeBorders];
    [self.fifthPatchButton removeBorders];
    [self.sixtPatchButton removeBorders];

    [self.seventhPatchButton removeBorders];
    [self.eightPatchButton removeBorders];
    [self.ninethPatchButton removeBorders];
}

- (void)setColorsFromArray:(NSInteger)faceIndex {

    NSInteger startIndex = faceIndex * 9;

    [self.firstPatchButton setCubieColor:self.faceColors[startIndex + 0]];
    [self.secondPatchButton setCubieColor:self.faceColors[startIndex + 1]];
    [self.thirdPatchButton setCubieColor:self.faceColors[startIndex + + 2]];
    [self.fourthPatchButton setCubieColor:self.faceColors[startIndex + + 3]];
    [self.fifthPatchButton setCubieColor:self.faceColors[startIndex + + 4]];
    [self.sixtPatchButton setCubieColor:self.faceColors[startIndex + 5]];
    [self.seventhPatchButton setCubieColor:self.faceColors[startIndex + 6]];
    [self.eightPatchButton setCubieColor:self.faceColors[startIndex + 7]];
    [self.ninethPatchButton setCubieColor:self.faceColors[startIndex + 8]];
}

- (NSString*)getFaceColors:(NSInteger)faceIndex {
    NSInteger startIndex = faceIndex * 9;
    NSArray *colorsArray = [self.faceColors subarrayWithRange:NSMakeRange(startIndex, 9)];
    NSString *stringRepresentation = [colorsArray componentsJoinedByString:@""];
    return stringRepresentation.length == 9 ? stringRepresentation : nil;
}

- (void)saveColorPatchImages {
    for (NSUInteger faceIndex = 0; faceIndex < self.faceImages.count; faceIndex++) {
        UIImage *faceImage = [self.faceImages objectAtIndex:faceIndex];
        NSString *colorString = [self getFaceColors:faceIndex];
        NSString *faceImageName = [NSString stringWithFormat:@"cubeface_%@_%@", colorString, [NSUUID UUID]];
        [faceImage saveToDocumentsFolderWithName:faceImageName];
    }
}

@end
