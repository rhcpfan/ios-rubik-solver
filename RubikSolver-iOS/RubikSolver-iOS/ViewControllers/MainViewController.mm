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
    // Do any additional setup after loading the view, typically from a nib.
    
    char* solutionArray = ApplyKociembaAlgorithm(strdup("ULURURRLDLDLBRUDBUUUFDFLDBRBUFBDDDRFLUBDLFBRLFFBFBLRFR"), 24, 1000, 0, "cache");
    NSLog(@"Solution: %@", [NSString stringWithUTF8String:solutionArray]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
