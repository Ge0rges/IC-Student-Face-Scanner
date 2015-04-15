#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface UIImage (FaceDetection)

- (NSArray *)facesWithAccuracy:(NSString * const)detectorAccuracy;
- (CIFaceFeature *)largestFaceWithAccuracy:(NSString * const)detectorAccuracy;
- (UIImage *)croppedAroundLargestFaceWithAccuracy:(NSString * const)detectorAccuracy;
- (UIImage*)croppedImageToRect:(CGRect)rect;
- (UIImage*)croppedImageToFaceFeature:(CIFaceFeature* const)face;
- (NSArray*)allFacesImagesWithAccuracy:(NSString * const)detectorAccuracy;

@end
