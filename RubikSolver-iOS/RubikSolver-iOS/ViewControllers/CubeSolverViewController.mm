//
//  CubeSolverViewController.m
//  RubikSolver-iOS
//
//  Created by rhcpfan on 15/01/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#ifdef __cplusplus
#include "search.hpp"
#endif

#import "CubeSolverViewController.h"

@interface CubeSolverViewController ()

@end

@implementation CubeSolverViewController

#pragma mark - Application Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rotationIndex = 0;
    self.scene3D = [[SCNScene alloc] init];
    
    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [self.scene3D.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 0, 8);
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    ambientLightNode.position = SCNVector3Make(0, 0, 8);
    [self.scene3D.rootNode addChildNode:ambientLightNode];
    
    // Add the rubik cubelets to the scene
    [self addRubiksCubeNodeToScene];
    
    // Set scene properties
    SCNView *scnView = self.sceneKitView;
    // set the scene to the view
    scnView.scene = self.scene3D;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
    
    // show statistics such as fps and timing information
    scnView.showsStatistics = NO;
    
    // configure the view
    UIColor *backgroundColor = [UIColor colorWithRed:30/255.0 green:163/255.0 blue:215/255.0 alpha:1];
    scnView.backgroundColor = backgroundColor;
    
    // Add the reflective floor under the cube
    SCNFloor *floor = [[SCNFloor alloc] init];
    NSMutableArray *floorMaterials = [[NSMutableArray alloc] init];
    [floorMaterials addObject:[self getMaterialWithColor:backgroundColor]];
    floor.materials = floorMaterials;
    
    SCNNode *floorNode = [[SCNNode alloc] init];
    floorNode.geometry = floor;
    floorNode.position = SCNVector3Make(0, -4, 0);
    floorNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:nil];
    
    [self.scene3D.rootNode addChildNode:floorNode];
    
    // Solve the cube and extract the rotation sequence
    const char * canonicalForm = [self prepareDataForSolver];
    NSString *solvingSolution = [self solveCubeWithConfiguration:canonicalForm];
    if (solvingSolution != nil) {
        NSArray<NSString*>* solvingRotations = [solvingSolution componentsSeparatedByString:@" "];
        self.rotationSequence = [[NSMutableArray alloc] initWithArray:solvingRotations];
    }

    if (solvingSolution == nil) {
        self.solutionLabel.text = @"Invalid configuration.";
        [self.nextButton setTitle:@"RETRY" forState:UIControlStateNormal];
    }
}

#pragma mark - 3D Cube Creation
#pragma mark -

- (SCNMaterial*)getMaterialWithColor:(UIColor*) materialColor {
    SCNMaterial *coloredMaterial = [[SCNMaterial alloc] init];
    coloredMaterial.diffuse.contents = materialColor;
    coloredMaterial.specular.contents = [UIColor whiteColor];
    return coloredMaterial;
}

- (SCNMaterial*)getMaterialFromStringRepresentation:(NSString*) stringColor {
    
    SCNMaterial *coloredMaterial = [[SCNMaterial alloc] init];
    
    if([stringColor isEqualToString:@"B"]) { coloredMaterial.diffuse.contents = [UIColor blueColor]; }
    else if([stringColor isEqualToString:@"W"]) { coloredMaterial.diffuse.contents = [UIColor whiteColor]; }
    else if([stringColor isEqualToString:@"O"]) { coloredMaterial.diffuse.contents = [UIColor orangeColor]; }
    else if([stringColor isEqualToString:@"G"]) { coloredMaterial.diffuse.contents = [UIColor greenColor]; }
    else if([stringColor isEqualToString:@"Y"]) { coloredMaterial.diffuse.contents = [UIColor yellowColor]; }
    else if([stringColor isEqualToString:@"R"]) { coloredMaterial.diffuse.contents = [UIColor redColor]; }
    else coloredMaterial.diffuse.contents = [UIColor blackColor];
    
    coloredMaterial.specular.contents = [UIColor whiteColor];
    return coloredMaterial;
}

- (void)separateCollorArrayIntoFaces {
    
    // Separate the large array into 6 smaller arrays and look at the center color
    for (int index = 0; index < [self.allColorsArray count]; index += 9) {
        
        NSRange subArrayRange = NSMakeRange(index, 9);
        NSArray<NSString*> *subArray = [self.allColorsArray subarrayWithRange:subArrayRange];
        
        NSString *centerColor = [subArray objectAtIndex:4];
        
        if ([centerColor isEqualToString:@"Y"]) { self.upFaceColors = [NSArray arrayWithArray: subArray]; }
        else if ([centerColor isEqualToString:@"G"]) { self.leftFaceColors = [NSArray arrayWithArray:subArray]; }
        else if ([centerColor isEqualToString:@"O"]) { self.frontFaceColors = [NSArray arrayWithArray:subArray]; }
        else if ([centerColor isEqualToString:@"W"]) { self.downFaceColors = [NSArray arrayWithArray:subArray]; }
        else if ([centerColor isEqualToString:@"R"]) { self.backFaceColors = [NSArray arrayWithArray:subArray]; }
        else if ([centerColor isEqualToString:@"B"]) { self.rightFaceColors = [NSArray arrayWithArray:subArray]; }
    }
}

- (void)addRubiksCubeNodeToScene {
    
    NSMutableArray *cubeMaterials = [[NSMutableArray alloc] init];
    [cubeMaterials addObject: [self getMaterialWithColor:[UIColor blackColor]]];
    [cubeMaterials addObject: [self getMaterialWithColor:[UIColor blackColor]]];
    [cubeMaterials addObject: [self getMaterialWithColor:[UIColor blackColor]]];
    [cubeMaterials addObject: [self getMaterialWithColor:[UIColor blackColor]]];
    [cubeMaterials addObject: [self getMaterialWithColor:[UIColor blackColor]]];
    [cubeMaterials addObject: [self getMaterialWithColor:[UIColor blackColor]]];
    
    [self separateCollorArrayIntoFaces];
    
    for (int x = -1; x <= 1 ; x++) {
        for (int y = -1; y <= 1; y++) {
            for (int z = -1; z <= 1; z++) {
                
                // Build the cube geometry
                SCNBox *cubeGeometry = [[SCNBox alloc] init];
                cubeGeometry.chamferRadius = 0.1;
                
                //TOP FACE
                if (y == 1) {
                    int faceIndex = (abs(z + 1) * 3 + x + 1);
                    SCNMaterial *faceMaterial = [self getMaterialFromStringRepresentation: [self.upFaceColors objectAtIndex:faceIndex]];
                    [cubeMaterials replaceObjectAtIndex:4 withObject: faceMaterial];
                }
                
                //BOTTOM FACE
                if (y == -1) {
                    int faceIndex = (abs(z - 1) * 3 + x + 1);
                    SCNMaterial *faceMaterial = [self getMaterialFromStringRepresentation: [self.downFaceColors objectAtIndex:faceIndex]];
                    [cubeMaterials replaceObjectAtIndex:5 withObject: faceMaterial];
                }
                
                // FRONT FACE
                if(z == 1) {
                    int faceIndex = (abs(y - 1) * 3 + x + 1);
                    SCNMaterial *faceMaterial = [self getMaterialFromStringRepresentation: [self.frontFaceColors objectAtIndex:faceIndex]];
                    [cubeMaterials replaceObjectAtIndex:0 withObject: faceMaterial];
                }
                
                // BACK FACE
                if(z == -1) {
                    int faceIndex = (abs(y - 1) * 3 + abs(x - 1));
                    SCNMaterial *faceMaterial = [self getMaterialFromStringRepresentation: [self.backFaceColors objectAtIndex:faceIndex]];
                    [cubeMaterials replaceObjectAtIndex:2 withObject: faceMaterial];
                }
                
                // LEFT FACE
                if (x == - 1)
                {
                    int faceIndex = (abs(y - 1) * 3 + z + 1);
                    SCNMaterial *faceMaterial = [self getMaterialFromStringRepresentation: [self.leftFaceColors objectAtIndex:faceIndex]];
                    [cubeMaterials replaceObjectAtIndex:3 withObject: faceMaterial];
                }
                
                // RIGHT FACE
                if (x == 1)
                {
                    int faceIndex = (abs(y - 1) * 3 + abs(z - 1));
                    SCNMaterial *faceMaterial = [self getMaterialFromStringRepresentation: [self.rightFaceColors objectAtIndex:faceIndex]];
                    [cubeMaterials replaceObjectAtIndex:1 withObject: faceMaterial];
                }
                
                cubeGeometry.materials = cubeMaterials;
                
                // Build the cube node
                SCNNode *cubeNode = [[SCNNode alloc] init];
                cubeNode.geometry = cubeGeometry;
                cubeNode.position = SCNVector3Make(x, y, z);
                cubeNode.name = [NSString stringWithFormat:@"cubelet %d %d %d", x, y, z];
                
                [self.scene3D.rootNode addChildNode:cubeNode];
            }
        }
    }
    
}

#pragma mark - Cube Rotation
#pragma mark -

- (SCNNode*)getRotationNodeFromMove:(NSString*)moveString {
    // Add all the cubes into a node that represents the face
    SCNNode *rotateNode = [[SCNNode alloc] init];
    rotateNode.name = @"RotateNode";
    
    // Get all the cubes in the scene
    NSArray<SCNNode *> *cubelets = [self.scene3D.rootNode childNodesPassingTest:^BOOL(SCNNode * _Nonnull child, BOOL * _Nonnull stop) {
        return [child.name containsString:@"cubelet"];
    }];
    
    // Categorize them by position (create the rotation node)
    if ([moveString containsString:@"L"]) {
        // Take all the nodes with x ~= -1 (left side)
        for (SCNNode *cubelet in cubelets) {
            if (cubelet.position.x < -0.9) {
                [rotateNode addChildNode:cubelet];
            }
        }
    }
    else if ([moveString containsString:@"R"]) {
        // Take all the nodes with x ~= 1 (right side)
        for (SCNNode *cubelet in cubelets) {
            if (cubelet.position.x > 0.9) {
                [rotateNode addChildNode:cubelet];
            }
        }
    } else if ([moveString containsString:@"U"]) {
        // Take all the nodes with y ~= 1 (up side)
        for (SCNNode *cubelet in cubelets) {
            if (cubelet.position.y > 0.9) {
                [rotateNode addChildNode:cubelet];
            }
        }
        
    } else if ([moveString containsString:@"D"]) {
        // Take all the nodes with y ~= -1 (down side)
        for (SCNNode *cubelet in cubelets) {
            if (cubelet.position.y < -0.9) {
                [rotateNode addChildNode:cubelet];
            }
        }
    } else if ([moveString containsString:@"F"]) {
        // Take all the nodes with z ~= 1 (front side)
        for (SCNNode *cubelet in cubelets) {
            if (cubelet.position.z > 0.9) {
                [rotateNode addChildNode:cubelet];
            }
        }
    } else if ([moveString containsString:@"B"]) {
        // Take all the nodes with y ~= 1 (back side)
        for (SCNNode *cubelet in cubelets) {
            if (cubelet.position.z < -0.9) {
                [rotateNode addChildNode:cubelet];
            }
        }
    }
    
    return rotateNode;
}

- (SCNAction*)getAnimationFromMove:(NSString*)moveString {
    
    // Number and direction of rotation
    int nrOfRotations = 1;
    int clockWise = 1;
    
    if ([moveString containsString:@"2"]) { nrOfRotations = 2; }
    if ([moveString containsString:@"'"]) { clockWise = -1; }
    
    // Categorize them by position (create the rotation node)
    if ([moveString containsString:@"L"]) {
        return [SCNAction rotateByX:M_PI_2 * nrOfRotations * clockWise y:0 z:0 duration:2];
    }
    else if ([moveString containsString:@"R"]) {
        return [SCNAction rotateByX:M_PI_2 * nrOfRotations * -clockWise y:0 z:0 duration:2];
        
    } else if ([moveString containsString:@"U"]) {
        return [SCNAction rotateByX:0 y:M_PI_2 * nrOfRotations * -clockWise z:0 duration:2];
        
    } else if ([moveString containsString:@"D"]) {
        return [SCNAction rotateByX:0 y:M_PI_2 * nrOfRotations * clockWise z:0 duration:2];
        
    } else if ([moveString containsString:@"F"]) {
        return [SCNAction rotateByX:0 y:0 z:M_PI_2 * nrOfRotations * -clockWise duration:2];
        
    } else if ([moveString containsString:@"B"]) {
        return [SCNAction rotateByX:0 y:0 z:M_PI_2 * nrOfRotations * clockWise duration:2];
    }
    
    return nil;
}

#pragma mark - Cube Solving
#pragma mark -
- (const char*)prepareDataForSolver {
    
    NSString *configuration = @"";
    NSMutableArray* allColors = [NSMutableArray arrayWithArray:self.upFaceColors];
    [allColors addObjectsFromArray:self.rightFaceColors];
    [allColors addObjectsFromArray:self.frontFaceColors];
    [allColors addObjectsFromArray:self.downFaceColors];
    [allColors addObjectsFromArray:self.leftFaceColors];
    [allColors addObjectsFromArray:self.backFaceColors];
    
    for (NSString* color in allColors) {
        if ([color isEqualToString:@"Y"]) {
            configuration = [configuration stringByAppendingString:@"U"];
        }
        else if ([color isEqualToString:@"G"]) {
            configuration = [configuration stringByAppendingString:@"L"];
        }
        else if ([color isEqualToString:@"O"]) {
            configuration = [configuration stringByAppendingString:@"F"];
        }
        else if ([color isEqualToString:@"B"]) {
            configuration = [configuration stringByAppendingString:@"R"];
        }
        else if ([color isEqualToString:@"W"]) {
            configuration = [configuration stringByAppendingString:@"D"];
        }
        else if ([color isEqualToString:@"R"]) {
            configuration = [configuration stringByAppendingString:@"B"];
        }
    }
    return [configuration UTF8String];
}

- (NSString*)solveCubeWithConfiguration:(const char*)cubeConfiguration {
    
    char* solutionArray = ApplyKociembaAlgorithm(strdup(cubeConfiguration), 24, 1000, 0, "cache");
    if(solutionArray == NULL) {
        return nil;
    }
    
    NSString *solutionString = [NSString stringWithUTF8String:solutionArray];
    solutionString = [solutionString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return solutionString;
}

#pragma mark - Application Lifecycle
#pragma mark -

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)didPressNextButton:(UIButton *)sender {

    if(self.rotationIndex >= [self.rotationSequence count] && ![sender.currentTitle isEqualToString:@"RESTART"]) {
        [self.nextButton setTitle:@"RESTART" forState:UIControlStateNormal];
        [self animateEnding];
        return;
    } else if ([sender.currentTitle isEqualToString:@"RESTART"] || [sender.currentTitle isEqualToString:@"RETRY"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    self.solutionLabel.text = self.rotationSequence[self.rotationIndex];
    
    SCNNode *rotationNode = [self getRotationNodeFromMove:self.rotationSequence[self.rotationIndex]];
    SCNAction *rotationSCNAction = [self getAnimationFromMove:self.rotationSequence[self.rotationIndex]];
    
    [self.scene3D.rootNode addChildNode:rotationNode];
    
    self.nextButton.enabled = NO;
    self.previousButton.enabled = NO;
    
    [rotationNode runAction:rotationSCNAction completionHandler:^{
        
        [rotationNode enumerateChildNodesUsingBlock:^(SCNNode * _Nonnull child, BOOL * _Nonnull stop) {
            child.transform = child.worldTransform;
            [child removeFromParentNode];
            [self.scene3D.rootNode addChildNode:child];
        }];
        
        [rotationNode removeFromParentNode];
        self.rotationIndex += 1;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.nextButton.enabled = YES;
            self.previousButton.enabled = YES;
        });
    }];
}

- (IBAction)didPressPreviousButton:(UIButton *)sender {
    
    self.rotationIndex -= 1;
    
    NSLog(@"Rotation index: %d", self.rotationIndex);
    
    if(self.rotationIndex < 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    self.solutionLabel.text = self.rotationSequence[self.rotationIndex];
    
    SCNNode *rotationNode = [self getRotationNodeFromMove:self.rotationSequence[self.rotationIndex]];
    SCNAction *rotationSCNAction = [self getAnimationFromMove:self.rotationSequence[self.rotationIndex]];
    
    [self.scene3D.rootNode addChildNode:rotationNode];
    
    self.nextButton.enabled = NO;
    self.previousButton.enabled = NO;

	if (!rotationSCNAction) {
		return;
	}
	
	[rotationNode runAction:[rotationSCNAction reversedAction] completionHandler:^{
		
		[rotationNode enumerateChildNodesUsingBlock:^(SCNNode * _Nonnull child, BOOL * _Nonnull stop) {
			child.transform = child.worldTransform;
			[child removeFromParentNode];
			[self.scene3D.rootNode addChildNode:child];
		}];
		
		[rotationNode removeFromParentNode];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.nextButton.enabled = YES;
            self.previousButton.enabled = YES;
        });
	}];
}

- (void)animateEnding {
    
    // Get all the cubes in the scene
    NSArray<SCNNode *> *cubelets = [self.scene3D.rootNode childNodesPassingTest:^BOOL(SCNNode * _Nonnull child, BOOL * _Nonnull stop) {
        return [child.name containsString:@"cubelet"];
    }];
    
    for (SCNNode* cube in cubelets) {
        cube.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:nil];
    }
}

@end
