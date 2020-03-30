//
//  utilities.m
//  Paductivity
//
//  Created by William Alexander on 11/06/2011.
//  Copyright 2011 Framestore-CFC. All rights reserved.
//

#import "utilities.h"


@implementation utilities

/*
	openCGResourceImage: - returns a CGIMageRef pointer to the image resource requested. N.B. it is the *caller's* responsibility to release the CGImage
 */
+ (CGImageRef)openCGResourceImage: (NSString *)pathForResource ofType: (NSString *)type
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource: pathForResource ofType: type];
	CFStringRef pathString = CFStringCreateWithCString(NULL, [filePath UTF8String], kCFStringEncodingUTF8);
	CFURLRef URLRef = CFURLCreateWithFileSystemPath(NULL, pathString, kCFURLPOSIXPathStyle, NO);
	CGDataProviderRef provider = CGDataProviderCreateWithURL(URLRef);
	CGImageRef outImage = CGImageCreateWithPNGDataProvider(provider, NULL, YES, kCGRenderingIntentDefault);
	
	//[filePath release];
	CFRelease(pathString);
	CFRelease(URLRef);
	CFRelease(provider);
	
	return outImage;
}


+ (void)drawRoundedRect:(CGContextRef)drawingCGContextRef rect:(CGRect)rect radius:(float)rad
{
	/*move to top left corner - and start to the right of the rounded edge:*/
	CGContextMoveToPoint(drawingCGContextRef, rect.origin.x + rad, rect.origin.y);
	
	/*draw the rectangle from here:*/
	CGContextAddLineToPoint(drawingCGContextRef, rect.origin.x + rect.size.width - rad, rect.origin.y);
	CGContextAddArcToPoint(drawingCGContextRef, rect.origin.x + rect.size.width, rect.origin.y, rect.origin.x + rect.size.width, rect.origin.y + rad, rad);
	CGContextAddLineToPoint(drawingCGContextRef, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - rad);
	CGContextAddArcToPoint(drawingCGContextRef, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, rect.origin.x + rect.size.width - rad, rect.origin.y + rect.size.height, rad);
	CGContextAddLineToPoint(drawingCGContextRef, rect.origin.x + rad, rect.origin.y + rect.size.height);
	CGContextAddArcToPoint(drawingCGContextRef, rect.origin.x, rect.origin.y + rect.size.height, rect.origin.x, rect.origin.y + rect.size.height - rad, rad);
	CGContextAddLineToPoint(drawingCGContextRef, rect.origin.x, rect.origin.y + rad);
	CGContextAddArcToPoint(drawingCGContextRef, rect.origin.x, rect.origin.y, rect.origin.x + rad, rect.origin.y, rad);
}

@end
