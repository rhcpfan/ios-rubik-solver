//
//  ColorCorrectionViewController.m
//  RubikSolver-iOS
//
//  Created by rhcpfan on 15/01/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#import "ColorCorrectionViewController.h"
#import "CubeSolverViewController.h"

@interface ColorCorrectionViewController ()

@end

@implementation ColorCorrectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];    // Do any additional setup after loading the view.
    
    self.currentFaceIndex = 0;
    [self setColorsFromArray:self.currentFaceIndex];
    self.faceImageView.image = [self.faceImages objectAtIndex:self.currentFaceIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"correctionToSolveSegue"]) {
        CubeSolverViewController *solverViewController = [segue destinationViewController];
        solverViewController.allColorsArray = self.faceColors;
    }
}

- (UIColor*) getUIColorFromString: (NSString*) stringRepresentation {
    
    if ([stringRepresentation isEqualToString:@"R"]) return [UIColor redColor];
    if ([stringRepresentation isEqualToString:@"G"]) return [UIColor greenColor];
    if ([stringRepresentation isEqualToString:@"B"]) return [UIColor blueColor];
    if ([stringRepresentation isEqualToString:@"O"]) return [UIColor orangeColor];
    if ([stringRepresentation isEqualToString:@"W"]) return [UIColor whiteColor];
    if ([stringRepresentation isEqualToString:@"Y"]) return [UIColor yellowColor];
    
    return [UIColor blackColor];
}

- (void) setColorsFromArray: (NSInteger) faceIndex {
    
    NSInteger startIndex = faceIndex * 9;
    
    [self.firstPatchButton setBackgroundColor: [self getUIColorFromString:self.faceColors[startIndex + 0]]];
    [self.secondPatchButton setBackgroundColor: [self getUIColorFromString:self.faceColors[startIndex + 1]]];
    [self.thirdPatchButton setBackgroundColor: [self getUIColorFromString:self.faceColors[startIndex + 2]]];
    [self.fourthPatchButton setBackgroundColor: [self getUIColorFromString:self.faceColors[startIndex + 3]]];
    [self.fifthPatchButton setBackgroundColor: [self getUIColorFromString:self.faceColors[startIndex + 4]]];
    [self.sixtPatchButton setBackgroundColor: [self getUIColorFromString:self.faceColors[startIndex + 5]]];
    [self.seventhPatchButton setBackgroundColor: [self getUIColorFromString:self.faceColors[startIndex + 6]]];
    [self.eightPatchButton setBackgroundColor: [self getUIColorFromString:self.faceColors[startIndex + 7]]];
    [self.ninethPatchButton setBackgroundColor: [self getUIColorFromString:self.faceColors[startIndex + 8]]];
}

- (void) removeAllBorders {
    self.firstPatchButton.layer.borderWidth = 0;
    self.secondPatchButton.layer.borderWidth = 0;
    self.thirdPatchButton.layer.borderWidth = 0;
    
    self.fourthPatchButton.layer.borderWidth = 0;
    self.fifthPatchButton.layer.borderWidth = 0;
    self.sixtPatchButton.layer.borderWidth = 0;
    
    self.seventhPatchButton.layer.borderWidth = 0;
    self.eightPatchButton.layer.borderWidth = 0;
    self.ninethPatchButton.layer.borderWidth = 0;
}

- (void) addBorderToButton:(UIButton *)button {
    button.layer.borderWidth = 5;
    button.layer.borderColor = [UIColor blackColor].CGColor;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)didPressFirstPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9;
    [self addBorderToButton:self.selectedButton];
}
- (IBAction)didPressSecondPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 1;
    [self addBorderToButton:self.selectedButton];
}
- (IBAction)didPressThirdPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 2;
    [self addBorderToButton:self.selectedButton];
}
- (IBAction)didPressFourthPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 3;
    [self addBorderToButton:self.selectedButton];
}
- (IBAction)didPressFifthPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 4;
    [self addBorderToButton:self.selectedButton];
    
}
- (IBAction)didPressSixthPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 5;
    [self addBorderToButton:self.selectedButton];
}
- (IBAction)didPressSeventhPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 6;
    [self addBorderToButton:self.selectedButton];
}
- (IBAction)didPressEightPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 7;
    [self addBorderToButton:self.selectedButton];
}
- (IBAction)didPressNinethPatchButton:(UIButton *)sender {
    [self removeAllBorders];
    self.selectedButton = sender;
    self.currentSquareIndexInCube = self.currentFaceIndex * 9 + 8;
    [self addBorderToButton:self.selectedButton];
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
        for (NSString* color in self.faceColors) {
            NSLog(@"%@", color);
        }
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
    if(self.currentFaceIndex > 0)
    {
        self.currentFaceIndex -= 1;
        [self setColorsFromArray:self.currentFaceIndex];
        self.faceImageView.image = [self.faceImages objectAtIndex:self.currentFaceIndex];
    }
    self.faceIndexLabel.text = [NSString stringWithFormat:@"Face %d/6", (int)self.currentFaceIndex + 1];
    
    if(self.currentFaceIndex < 5)
    {
        [self.nextFaceButton setTitle:@"Next" forState:UIControlStateNormal];
        [self.nextFaceButton setTitle:@"Next" forState:UIControlStateHighlighted];
    }
}

@end
