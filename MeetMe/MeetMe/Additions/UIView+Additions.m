//
//  UIView+Additions.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 24/12/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

+ (UIView*)viewWithMultipleImages:(NSArray<UIImage*>*)images andSize:(CGSize)size
{
    NSUInteger IMAGE_COUNT = images.count;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    view.clipsToBounds = YES;
    
    // No image
    if (IMAGE_COUNT == 0) {
        return view;
    }
    
    // 1 image
    if (IMAGE_COUNT == 1) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:view.bounds];
        imgView.image = [images objectAtIndex:0];
        [view addSubview:imgView];
        return view;
    }
    
    // 2 images
    if (IMAGE_COUNT == 2) {
        UIImageView *left  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width/2.0, size.height)];
        left.image         = [images objectAtIndex:0];
        left.clipsToBounds = YES;
        
        UIImageView *right = [[UIImageView alloc] initWithFrame:CGRectMake(size.width/2.0, 0, size.width/2.0, size.height)];
        right.image        = [images objectAtIndex:1];
        right.clipsToBounds = YES;
        
        [view addSubview:left];
        [view addSubview:right];
        
        return view;
    }
    
    // Need to better support case with more than 2 images
    if (IMAGE_COUNT > 2) {
        UIImageView *first       = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width/2.0, size.height)];
        first.image              = [images objectAtIndex:0];
        first.clipsToBounds      = YES;
        first.layer.borderColor  = [UIColor whiteColor].CGColor;
        first.layer.borderWidth  = 1.0;

        UIImageView *second      = [[UIImageView alloc] initWithFrame:CGRectMake(size.width/2.0, 0, size.width/2.0, size.height/2.0)];
        second.image             = [images objectAtIndex:1];
        second.clipsToBounds     = YES;
        second.layer.borderColor = [UIColor whiteColor].CGColor;
        second.layer.borderWidth = 1.0;

        UIImageView *third       = [[UIImageView alloc] initWithFrame:CGRectMake(size.width/2.0, size.height/2.0, size.width/2.0, size.height/2.0)];
        third.image              = [images objectAtIndex:2];
        third.clipsToBounds      = YES;
        third.layer.borderColor  = [UIColor whiteColor].CGColor;
        third.layer.borderWidth  = 1.0;
        
        [view addSubview:first];
        [view addSubview:second];
        [view addSubview:third];
        
        return view;
    }
    
    return nil;
}

@end
