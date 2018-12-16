//
//  CubeSolverViewController.h
//  RubikSolver-iOS
//
//  Created by rhcpfan on 15/01/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>

@interface CubeSolverViewController : UIViewController

- (void)addRubiksCubeNodeToScene;
- (void)separateCollorArrayIntoFaces;



- (const char*)prepareDataForSolver;

- (NSString*)solveCubeWithConfiguration:(const char*)cubeConfiguration;
- (SCNAction*)getAnimationFromMove:(NSString*)moveString;

@property NSMutableArray* rotationSequence;
@property int rotationIndex;

- (void)animateEnding;

@property SCNScene *scene3D;
@property SCNNode *rotationNode;

@property (weak, nonatomic) IBOutlet SCNView *sceneKitView;



@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;

- (IBAction)didPressNextButton:(UIButton *)sender;
- (IBAction)didPressPreviousButton:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UILabel *solutionLabel;

@property NSMutableArray* allColorsArray;

@property NSArray<NSString*> *upFaceColors;
@property NSArray<NSString*> *downFaceColors;
@property NSArray<NSString*> *frontFaceColors;
@property NSArray<NSString*> *backFaceColors;
@property NSArray<NSString*> *leftFaceColors;
@property NSArray<NSString*> *rightFaceColors;

@end
