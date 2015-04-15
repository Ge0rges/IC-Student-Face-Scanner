//
//  FaceSelectionCollectionViewController.h
//  Face Scanner
//
//  Created by Georges Kanaan on 3/24/15.
//  Copyright (c) 2015 Georges Kanaan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@class ViewController;

@interface FaceSelectionCollectionViewController : UICollectionViewController

@property (strong, nonatomic) NSArray *faces;
@property (strong, nonatomic) ViewController *viewController;

@end
