#import "UIImage+FaceDetection.h"

@implementation UIImage (FaceDetection)

- (NSArray *)facesWithAccuracy:(NSString * const)detectorAccuracy {
    CIImage *coreImageRepresentation = [[CIImage alloc] initWithImage:self];

    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };      // 2
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];

    NSArray *features = [detector featuresInImage:coreImageRepresentation];

    return features;
}

- (CIFaceFeature *)largestFaceWithAccuracy:(NSString * const)detectorAccuracy {
    
    NSArray *faces = [self facesWithAccuracy:detectorAccuracy];
    
    float currentLargestWidth = 0;
    CIFaceFeature *largestFace;
    
    for (CIFaceFeature *face in faces) {
        if (face.bounds.size.width > currentLargestWidth) {
            largestFace = face;
            currentLargestWidth = face.bounds.size.width;
        }
    }
    
    return largestFace;
}

- (NSArray*)allFacesImagesWithAccuracy:(NSString * const)detectorAccuracy {
    NSMutableArray *faces = [NSMutableArray new];
    
    NSArray *facesFeatures = [self facesWithAccuracy:detectorAccuracy];
    
    for (CIFaceFeature *face in facesFeatures) [faces addObject:[self croppedImageToFaceFeature:face]];
    
    return faces;
}

- (UIImage *)croppedAroundLargestFaceWithAccuracy:(NSString * const)detectorAccuracy {
    CIFaceFeature *largestFace = [self largestFaceWithAccuracy:detectorAccuracy];

    CIImage *coreImage = [[CIImage alloc] initWithImage:self];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *faceImage = [coreImage imageByCroppingToRect:largestFace.bounds];
    UIImage *croppedImage = [UIImage imageWithCGImage:[context createCGImage:faceImage fromRect:faceImage.extent]];

    return croppedImage;
}

- (UIImage*)croppedImageToFaceFeature:(CIFaceFeature*)face {
    CIImage *coreImage = [[CIImage alloc] initWithImage:self];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *faceImage = [coreImage imageByCroppingToRect:face.bounds];
    UIImage *croppedImage = [UIImage imageWithCGImage:[context createCGImage:faceImage fromRect:faceImage.extent]];
    
    return croppedImage;
}

- (UIImage*)croppedImageToRect:(CGRect)rect {
    CIImage *coreImage = [[CIImage alloc] initWithImage:self];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *faceImage = [coreImage imageByCroppingToRect:rect];
    UIImage *croppedImage = [UIImage imageWithCGImage:[context createCGImage:faceImage fromRect:faceImage.extent]];
    
    return croppedImage;
}

@end