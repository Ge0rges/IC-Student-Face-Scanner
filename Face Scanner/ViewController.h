//
//  ViewController.h
//  Face Scanner
//
//  Created by Georges Kanaan on 3/23/15.
//  Copyright (c) 2015 Georges Kanaan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import "KairosSDK.h"
#import "UIImage+FaceDetection.h"
#import "FaceSelectionCollectionViewController.h"
#import "HTMLParser.h"

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
    UIImagePickerController *imagePicker;
}

@property (strong, nonatomic) UIImage *selectedFace;
@property (nonatomic) BOOL shouldDetectFace;
@end

