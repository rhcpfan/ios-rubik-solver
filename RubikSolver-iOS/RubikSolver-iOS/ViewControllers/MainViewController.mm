//
//  ViewController.m
//  RubikSolver-iOS
//
//  Created by rhcpfan on 15/01/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#import "MainViewController.h"
#import "search.hpp"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Solve an example of a cube configuration at startup in order to create (and cache)
    // the necessary pruning tables for the solver
    char* solutionArray = ApplyKociembaAlgorithm(strdup("ULURURRLDLDLBRUDBUUUFDFLDBRBUFBDDDRFLUBDLFBRLFFBFBLRFR"), 24, 1000, 0, "cache");
    NSLog(@"Solution: %@", [NSString stringWithUTF8String:solutionArray]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
