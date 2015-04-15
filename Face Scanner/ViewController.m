//
//  ViewController.m
//  Face Scanner
//
//  Created by Georges Kanaan on 3/23/15.
//  Copyright (c) 2015 Georges Kanaan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIImageView *selectedFaceImageView;
@property (strong, nonatomic) IBOutlet UIImageView *recognizedFaceImageView;

@end

@implementation ViewController

static NSString * const galleryIdentifier = @"studentGallery";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //update status bar appearance
    [self setNeedsStatusBarAppearanceUpdate];
    
    //authenticate with Kairos
    [KairosSDK initWithAppId:@"77ccfe89" appKey:@"03eed3cb0d74e95dc34e6e14cd1a2fbc"];
    
    //enroll all students
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"enrolledStudents"]) [self enrollEntireStudentDatabase];
    
    //init the UIImagePickerController
    imagePicker = [UIImagePickerController new];
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
}

- (BOOL)prefersStatusBarHidden {return NO;}
- (UIStatusBarStyle)preferredStatusBarStyle{return UIStatusBarStyleLightContent;}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //recognize the selected face if necessary
    if (self.shouldDetectFace) {
        //set the BOOL
        self.shouldDetectFace = NO;
        
        //update UI
        [self.statusLabel setText:@"Uploading face to server for recognition..."];
        [self.selectedFaceImageView setImage:self.selectedFace];
        
        //upload image to kairos for recognition
        [KairosSDK recognizeWithImage:self.selectedFace threshold:@".80" galleryName:galleryIdentifier maxResults:@"1" success:^(NSDictionary *response) {
            NSLog(@"response: %@",response);
            
            [self.statusLabel setText:@"Processing results..."];

            NSString *status = [[[[response objectForKey:@"images"] objectAtIndex:0] objectForKey:@"transaction"] objectForKey:@"status"];
            if ([status isEqualToString:@"failure"]) {
                [self.statusLabel setText:@"No match found"];
            }
            
        } failure:^(NSDictionary *response) {
            [self.statusLabel setText:@"Failed to recognize face"];
        }];
    }
}

#pragma mark - Enrolling Student Database
- (NSArray*)studentNames {
    NSMutableArray *studentNames = [NSMutableArray new];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"StudentDatabase" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:htmlPath encoding:NSASCIIStringEncoding error:nil];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:nil];
    
    HTMLNode *bodyNode = [parser body];
    
    NSArray *studentNodes = [bodyNode findChildTags:@"strong"];

    for (HTMLNode *studentNode in studentNodes) {
        NSString *name = [self stringBetweenString:@"\">" andString:@"</a" originalString:[studentNode rawContents]];
        [studentNames addObject:name];
    }

    return studentNames;
}

- (NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end originalString:(NSString*)origString {
    NSRange startRange = [origString rangeOfString:start];
    if (startRange.location != NSNotFound) {
        NSRange targetRange;
        targetRange.location = startRange.location + startRange.length;
        targetRange.length = [origString length] - targetRange.location;
        NSRange endRange = [origString rangeOfString:end options:0 range:targetRange];
        if (endRange.location != NSNotFound) {
            targetRange.length = endRange.location - targetRange.location;
            return [origString substringWithRange:targetRange];
        }
    }
    return nil;
}

- (NSArray*)studentProfileImagesLinks {
    NSMutableArray *studentProfileImageLinks = [NSMutableArray new];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"StudentDatabase" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:htmlPath encoding:NSASCIIStringEncoding error:nil];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:nil];
    
    HTMLNode *bodyNode = [parser body];
    
    NSArray *imageNodes = [bodyNode findChildrenOfClass:@"userpicture"];
    
    for (HTMLNode *imageNode in imageNodes) {
        NSString *url = [NSString stringWithFormat:@"http://moodle.ic.edu.lb/%@",[imageNode getAttributeNamed:@"src"]];
        [studentProfileImageLinks addObject:url];
    }
    
    return studentProfileImageLinks;
}


- (void)enrollEntireStudentDatabase {
    __strong NSDictionary *studentsDict = [NSDictionary dictionaryWithObjects:[self studentProfileImagesLinks] forKeys:[self studentNames]];
    
    __block int enrolledUsers = 0;
    for (NSString *studentName in studentsDict) {
        NSString *imageURL = [studentsDict objectForKey:studentName];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [KairosSDK enrollWithImageURL:imageURL subjectId:studentName galleryName:galleryIdentifier success:^(NSDictionary *response) {
                enrolledUsers++;
                NSLog(@"enrolled user succesfully %i", enrolledUsers);
                if (enrolledUsers >= 1800) [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"enrolledStudents"];
            } failure:^(NSDictionary *response) {
                NSLog(@"failed to enroll user");
            }];
        });
    }
}

#pragma mark - Picking an image
- (IBAction)scanNewFace {
    [self.statusLabel setText:@"User is selecting picture to send..."];

    //present the action sheet for picking a image
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Select Image Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Library", nil];
    as.tag = 1;
    [as showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {//tag 1 is image picker action sheet
        if (buttonIndex == actionSheet.cancelButtonIndex) return;
        
        //set the source of the image picker to camera and present it
        imagePicker.sourceType = (buttonIndex == 0) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
        if (imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];//just dismiss the picker
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.statusLabel setText:@"Preparing faces for selection..."];

    //get edited image
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.selectedFace = image;
    self.shouldDetectFace = YES;
    [self viewDidAppear:NO];
    
    /*present the colelction VC so the user can choose which faec he wants to recognize
    FaceSelectionCollectionViewController *collectionVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"faceSelectionVC"];
    collectionVC.faces = [image allFacesImagesWithAccuracy:CIDetectorAccuracyHigh];
    collectionVC.viewController = self;
    
    //dismiss the picker
    [picker dismissViewControllerAnimated:NO completion:^{
        [self presentViewController:collectionVC animated:YES completion:nil];
    }];
     */
    [picker dismissViewControllerAnimated:NO completion:nil];
}

@end
