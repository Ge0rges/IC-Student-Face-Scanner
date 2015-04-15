//
//  FaceSelectionCollectionViewController.m
//  Face Scanner
//
//  Created by Georges Kanaan on 3/24/15.
//  Copyright (c) 2015 Georges Kanaan. All rights reserved.
//

#import "FaceSelectionCollectionViewController.h"

@interface FaceSelectionCollectionViewController ()

@end

@implementation FaceSelectionCollectionViewController

static NSString * const reuseIdentifier = @"faceCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    //update status bar appearance
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden {return NO;}
- (UIStatusBarStyle)preferredStatusBarStyle{return UIStatusBarStyleLightContent;}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.faces count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    //configure the cell
    NSLog(@"cell image is: %@",[self.faces objectAtIndex:indexPath.row]);
    [(UIImageView*)[cell viewWithTag:1] setImage:[self.faces objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.viewController.selectedFace = [self.faces objectAtIndex:indexPath.row];
    self.viewController.shouldDetectFace = YES;
    
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
