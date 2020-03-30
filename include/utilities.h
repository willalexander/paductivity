//
//  utilities.h
//  Paductivity
//
//  Created by William Alexander on 11/06/2011.
//  Copyright 2011 Framestore-CFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>

@interface utilities : NSObject {
}


+ (CGImageRef)openCGResourceImage: (NSString *)pathForResource ofType: (NSString *)type;
+ (void)drawRoundedRect: (CGContextRef)drawingCGContextRef rect: (CGRect)rect radius: (float)rad;

@end
