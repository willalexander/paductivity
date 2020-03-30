//
//  calculatorMiniAppView.m
//  Paductivity
//
//  Created by William Alexander on 20/10/2010.
//  Copyright 2010 Framestore-CFC. All rights reserved.
//

#import "calculatorMiniAppView.h"

#import <QuartzCore/CALayer.h>


@implementation calculatorButtonView

- (id)initWithFrame:(CGRect)frame andId:(int)buttonId_in
{
	if(self = [super initWithFrame: frame])
	{
		buttonId = buttonId_in;
		
		if(buttonId == 0) buttonSymbol[0] = '0';
		if(buttonId == 1) buttonSymbol[0] = '1';
		if(buttonId == 2) buttonSymbol[0] = '2';
		if(buttonId == 3) buttonSymbol[0] = '3';
		if(buttonId == 4) buttonSymbol[0] = '4';
		if(buttonId == 5) buttonSymbol[0] = '5';
		if(buttonId == 6) buttonSymbol[0] = '6';
		if(buttonId == 7) buttonSymbol[0] = '7';
		if(buttonId == 8) buttonSymbol[0] = '8';
		if(buttonId == 9) buttonSymbol[0] = '9';
		if(buttonId == 10) buttonSymbol[0] = '+';
		if(buttonId == 11) buttonSymbol[0] = '-';
		if(buttonId == 12) buttonSymbol[0] = 'x';
		if(buttonId == 13) buttonSymbol[0] = '/';
		if(buttonId == 14) buttonSymbol[0] = 'c';
		if(buttonId == 15) buttonSymbol[0] = '.';
		if(buttonId == 16) buttonSymbol[0] = '=';

		buttonSymbol[1] = '\0';
		
		textShiftToCentre[0][0] = -0.25; textShiftToCentre[0][1] = 0.34;
		textShiftToCentre[1][0] = -0.25; textShiftToCentre[1][1] = 0.34;
		textShiftToCentre[2][0] = -0.25; textShiftToCentre[2][1] = 0.34;
		textShiftToCentre[3][0] = -0.25; textShiftToCentre[3][1] = 0.34;
		textShiftToCentre[4][0] = -0.25; textShiftToCentre[4][1] = 0.34;
		textShiftToCentre[5][0] = -0.25; textShiftToCentre[5][1] = 0.34;
		textShiftToCentre[6][0] = -0.25; textShiftToCentre[6][1] = 0.34;
		textShiftToCentre[7][0] = -0.25; textShiftToCentre[7][1] = 0.34;
		textShiftToCentre[8][0] = -0.25; textShiftToCentre[8][1] = 0.34;
		textShiftToCentre[9][0] = -0.25; textShiftToCentre[9][1] = 0.34;
		textShiftToCentre[10][0] = -0.29; textShiftToCentre[10][1] = 0.26;
		textShiftToCentre[11][0] = -0.17; textShiftToCentre[11][1] = 0.28;
		textShiftToCentre[12][0] = -0.23; textShiftToCentre[12][1] = 0.27;
		textShiftToCentre[13][0] = -0.14; textShiftToCentre[13][1] = 0.35;
		textShiftToCentre[14][0] = -0.25; textShiftToCentre[14][1] = 0.27;
		textShiftToCentre[15][0] = -0.12; textShiftToCentre[15][1] = 0.07;
		textShiftToCentre[16][0] = -0.25; textShiftToCentre[16][1] = 0.28;
		
		/*clear background - all content will be explicitly drawn:*/
		self.backgroundColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.0];
	
		/*unless directly instructed otherwise, any change of frame will result in crude resizing of current content:*/
		[self setContentMode: UIViewContentModeScaleToFill];
		
		/*obviously, to start with, buttons are 'unpressed off':*/
		pressedOn = 0;
		
		/*this variable is used to record double tap events. It starts with a value of zero:*/
		doubleTap_oneTapDown = 0;
	}
	
	return self;
}


/*
	buttonId returns the id of this button view
 */
- (int)buttonId
{
	return buttonId;
}


/*
	draws the contents of this button, which is basically the graphic provided by the parent view, which should fit the bounds perfectly, and text for the button's symbol
 */
- (void)drawRect:(CGRect)rect
{
	/*First of all retrieve the graphics context:*/
	CGContextRef drawingCGContext = UIGraphicsGetCurrentContext();
	
	[self drawToContext: drawingCGContext inParentSpace: NO];
}


/*
	drawToContext: the guts of drawing for this view type - draws into the context provided. Draws the contents of this button, which is basically the graphic provided by the parent view, which should fit the bounds perfectly, and text for the button's symbol
*/
- (void)drawToContext: (CGContextRef)theContext inParentSpace: (BOOL)ifInParentSpace
{
	/*if we are drawing into our own screen space, we'll be drawing from the origin as usual. But we may be need to draw at a particular point in a larger context, so set the origin of drawing here:*/
	CGPoint drawingOrigin = CGPointMake(0, 0);
	if(ifInParentSpace == YES) drawingOrigin = self.frame.origin;
	

	int basicDimension = self.bounds.size.width;
	if(self.bounds.size.height < basicDimension) basicDimension = self.bounds.size.height;

	/*Get the latest graphics from the parent, 'main' view:*/
	CGImageRef backgroundGraphicsImage = [[self superview] returnButtonGraphicsForType: (buttonId < 10)? (0 + pressedOn) : (2 + pressedOn)];

	/*if this button is non-square (only happens in the case of the 'equals' button), then this is slighly more complicated - the square graphics need to be stretched:*/
	CGContextRef tileSectionContext;
	CGImageRef tileSectionImage;

	if(self.bounds.size.width > self.bounds.size.height)
	{
		tileSectionContext = CGBitmapContextCreate(NULL, CGImageGetWidth(backgroundGraphicsImage) - (int)(2.0 * CALCULATOR_BUTTON_CORNER_RADIUS * CGImageGetWidth(backgroundGraphicsImage)), CGImageGetHeight(backgroundGraphicsImage), 8, 4 * (CGImageGetWidth(backgroundGraphicsImage) - (int)(2.0 * CALCULATOR_BUTTON_CORNER_RADIUS * CGImageGetWidth(backgroundGraphicsImage))), CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);

		CGContextDrawImage(tileSectionContext, CGRectMake((int)(-1.0 * CALCULATOR_BUTTON_CORNER_RADIUS * CGImageGetWidth(backgroundGraphicsImage)), 0, CGImageGetWidth(backgroundGraphicsImage), CGImageGetHeight(backgroundGraphicsImage)), backgroundGraphicsImage);
		tileSectionImage = CGBitmapContextCreateImage(tileSectionContext);
	
		CGContextDrawImage(theContext, CGRectMake(drawingOrigin.x + 0, drawingOrigin.y, CGImageGetWidth(backgroundGraphicsImage), CGImageGetHeight(backgroundGraphicsImage)), backgroundGraphicsImage);
		CGContextDrawImage(theContext, CGRectMake(drawingOrigin.x + self.bounds.size.width - CGImageGetWidth(backgroundGraphicsImage), drawingOrigin.y, CGImageGetWidth(backgroundGraphicsImage), CGImageGetHeight(backgroundGraphicsImage)), backgroundGraphicsImage);
		CGContextDrawImage(theContext, CGRectMake(drawingOrigin.x + CALCULATOR_BUTTON_CORNER_RADIUS * CGImageGetWidth(backgroundGraphicsImage), drawingOrigin.y, self.bounds.size.width - 2 * (int)(CALCULATOR_BUTTON_CORNER_RADIUS * CGImageGetWidth(backgroundGraphicsImage)), CGImageGetHeight(tileSectionImage)), tileSectionImage);
												   
		CGGradientRelease(tileSectionContext);
		CGImageRelease(tileSectionImage);
	}

	else if(self.bounds.size.height > self.bounds.size.width)
	{
		tileSectionContext = CGBitmapContextCreate(NULL, CGImageGetWidth(backgroundGraphicsImage), CGImageGetHeight(backgroundGraphicsImage) - 2 * (int)(CALCULATOR_BUTTON_CORNER_RADIUS * CGImageGetHeight(backgroundGraphicsImage)), 8, 4 * CGImageGetWidth(backgroundGraphicsImage), CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
		
		CGContextDrawImage(tileSectionContext, CGRectMake(0, -1 * (int)(CALCULATOR_BUTTON_CORNER_RADIUS * CGImageGetHeight(backgroundGraphicsImage)), CGImageGetWidth(backgroundGraphicsImage), CGImageGetHeight(backgroundGraphicsImage)), backgroundGraphicsImage);
		tileSectionImage = CGBitmapContextCreateImage(tileSectionContext);
	
		CGContextDrawImage(theContext, CGRectMake(drawingOrigin.x, drawingOrigin.y, CGImageGetWidth(backgroundGraphicsImage), CGImageGetHeight(backgroundGraphicsImage)), backgroundGraphicsImage);
		CGContextDrawImage(theContext, CGRectMake(drawingOrigin.x, drawingOrigin.y + self.bounds.size.height - CGImageGetHeight(backgroundGraphicsImage), CGImageGetWidth(backgroundGraphicsImage), CGImageGetHeight(backgroundGraphicsImage)), backgroundGraphicsImage);
		CGContextDrawImage(theContext, CGRectMake(drawingOrigin.x, drawingOrigin.y + CALCULATOR_BUTTON_CORNER_RADIUS * CGImageGetHeight(backgroundGraphicsImage), CGImageGetWidth(tileSectionImage), self.bounds.size.height - 2 * (int)(CALCULATOR_BUTTON_CORNER_RADIUS * CGImageGetHeight(backgroundGraphicsImage))), tileSectionImage);
		
		CGGradientRelease(tileSectionContext);
		CGImageRelease(tileSectionImage);
	}

	else CGContextDrawImage(theContext, CGRectMake(drawingOrigin.x, drawingOrigin.y, self.bounds.size.width, self.bounds.size.height), backgroundGraphicsImage);
	

	CGContextSaveGState(theContext);
	CGContextSetTextMatrix(theContext, CGAffineTransformMake(1, 0, 0, -1, 0, 0));

	CGContextSelectFont(theContext, "Helvetica", (int)(0.3 * basicDimension), kCGEncodingMacRoman);
	CGContextSetRGBFillColor(theContext, 0.15, 0.15, 0.15, 1.0);
	CGContextShowTextAtPoint(theContext, drawingOrigin.x + (int)(0.5*self.bounds.size.width + 0.3 * basicDimension * textShiftToCentre[buttonId][0]), drawingOrigin.y + (int)(0.5*self.bounds.size.height + 0.3 * basicDimension * textShiftToCentre[buttonId][1]), buttonSymbol, 1);

	CGContextRestoreGState(theContext);
}


/*
	setPressed - external caller uses this to tell this button that it has been pressed down and hence to change its graphics
 */
- (void)setPressed: (BOOL)pressed
{
	if(pressed == YES) pressedOn = 1;
	else pressedOn = 0;
	
	[self setNeedsDisplay];
}


- (void)dealloc
{
	[super dealloc];
}

@end





@implementation calculatorDigitsView : UIView


- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame: frame])
	{
		/*this view itself draws nothing, and clips all its content to its frame rect:*/
		[self setBackgroundColor: [UIColor clearColor]];
		[self setClipsToBounds: YES];
			
		
		/*create a sublayer of constant size that will contain the digits:*/
		contentSublayer = [CALayer layer];
		[[self layer] addSublayer: contentSublayer];
		
		[contentSublayer setFrame: CGRectMake(frame.size.width - 708, 0, 708, 90)];
		[contentSublayer removeAllAnimations];

		
		/*we start with one digit. (0)*/
		numDigitsCurrentlyDisplayed = 1;
		
		/*draw all content:*/
		[self generateDigitGraphics];
		[self setNeedsDisplay];
		
		/*by default, the layoutSubviews: method has a special custom technique to keep the calculator and its screen at the optimum size:*/
		layoutStyle = 0;
	}
	
	return self;
}


/*
	the most efficient way to draw 'classic' digital digits which are going to be drawn, redrawn and stored in memory, is to create graphics for each of the segments, then create the digits from these later. This method creates these segment graphics:
 */
- (void)generateDigitGraphics
{
	CGContextRef drawingContext;
	
	float shadowColorComponents[] = {0.0, 0.08, 0.0, 0.5};
	CGColorRef shadowCGColorRef = CGColorCreate(CGColorSpaceCreateDeviceRGB(), shadowColorComponents);
	
	/*allocate a block of bytes to draw the segments to:*/
	char *bytes = (char *)malloc(3600);
	

	/*0*/
	drawingContext = CGBitmapContextCreate(bytes, 50, 18, 8, 200, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	for(int i = 0; i < 3600; i++) bytes[i] = 0;
	
	CGContextSetShadowWithColor(drawingContext, CGSizeMake(3.0, -5.0), 4.0, shadowCGColorRef);
	CGContextSetRGBFillColor(drawingContext, 0.0, 0.0, 0.0, 0.7);
	
	
	CGContextBeginPath(drawingContext);
	CGContextMoveToPoint(drawingContext, 0, 18);
	CGContextAddLineToPoint(drawingContext, 40, 18);
	CGContextAddLineToPoint(drawingContext, 32, 10);
	CGContextAddLineToPoint(drawingContext, 8, 10);
	CGContextClosePath(drawingContext);
	CGContextFillPath(drawingContext);
	
	digitGraphics[0] = CGBitmapContextCreateImage(drawingContext);
	CGContextRelease(drawingContext);
	
	
	/*1*/
	drawingContext = CGBitmapContextCreate(bytes, 18, 48, 8, 72, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	for(int i = 0; i < 3600; i++) bytes[i] = 0;
	
	CGContextSetShadowWithColor(drawingContext, CGSizeMake(3.0, -5.0), 4.0, shadowCGColorRef);
	CGContextSetRGBFillColor(drawingContext, 0.0, 0.0, 0.0, 1.0);
	
	CGContextBeginPath(drawingContext);
	CGContextMoveToPoint(drawingContext, 0, 10);
	CGContextAddLineToPoint(drawingContext, 0, 48);
	CGContextAddLineToPoint(drawingContext, 8, 40);
	CGContextAddLineToPoint(drawingContext, 8, 14);
	CGContextClosePath(drawingContext);
	CGContextFillPath(drawingContext);
	digitGraphics[1] = CGBitmapContextCreateImage(drawingContext);
	CGContextRelease(drawingContext);
	
	/*2*/
	drawingContext = CGBitmapContextCreate(bytes, 18, 48, 8, 72, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	for(int i = 0; i < 3600; i++) bytes[i] = 0;
	
	CGContextSetShadowWithColor(drawingContext, CGSizeMake(3.0, -5.0), 4.0, shadowCGColorRef);
	CGContextSetRGBFillColor(drawingContext, 0.0, 0.0, 0.0, 0.7);
	
	CGContextBeginPath(drawingContext);
	CGContextMoveToPoint(drawingContext, 8, 10);
	CGContextAddLineToPoint(drawingContext, 8, 48);
	CGContextAddLineToPoint(drawingContext, 0, 40);
	CGContextAddLineToPoint(drawingContext, 0, 14);
	CGContextClosePath(drawingContext);
	CGContextFillPath(drawingContext);
	digitGraphics[2] = CGBitmapContextCreateImage(drawingContext);
	CGContextRelease(drawingContext);
	
	/*3*/
	drawingContext = CGBitmapContextCreate(bytes, 48, 18, 8, 196, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	for(int i = 0; i < 3600; i++) bytes[i] = 0;
	
	CGContextSetShadowWithColor(drawingContext, CGSizeMake(3.0, -5.0), 4.0, shadowCGColorRef);
	CGContextSetRGBFillColor(drawingContext, 0.0, 0.0, 0.0, 0.7);
	
	CGContextBeginPath(drawingContext);
	CGContextMoveToPoint(drawingContext, 0, 14);
	CGContextAddLineToPoint(drawingContext, 8, 18);
	CGContextAddLineToPoint(drawingContext, 30, 18);
	CGContextAddLineToPoint(drawingContext, 38, 14);
	CGContextAddLineToPoint(drawingContext, 30, 10);
	CGContextAddLineToPoint(drawingContext, 8, 10);
	CGContextClosePath(drawingContext);
	CGContextFillPath(drawingContext);
	digitGraphics[3] = CGBitmapContextCreateImage(drawingContext);
	CGContextRelease(drawingContext);
	
	/*4*/
	drawingContext = CGBitmapContextCreate(bytes, 18, 48, 8, 72, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	for(int i = 0; i < 3600; i++) bytes[i] = 0;
	
	CGContextSetShadowWithColor(drawingContext, CGSizeMake(3.0, -5.0), 4.0, shadowCGColorRef);
	CGContextSetRGBFillColor(drawingContext, 0.0, 0.0, 0.0, 0.7);
	
	CGContextBeginPath(drawingContext);
	CGContextMoveToPoint(drawingContext, 0, 10);
	CGContextAddLineToPoint(drawingContext, 0, 48);
	CGContextAddLineToPoint(drawingContext, 8, 44);
	CGContextAddLineToPoint(drawingContext, 8, 18);
	CGContextClosePath(drawingContext);
	CGContextFillPath(drawingContext);
	digitGraphics[4] = CGBitmapContextCreateImage(drawingContext);
	CGContextRelease(drawingContext);
	
	/*5*/
	drawingContext = CGBitmapContextCreate(bytes, 18, 48, 8, 72, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	for(int i = 0; i < 3600; i++) bytes[i] = 0;
	
	CGContextSetShadowWithColor(drawingContext, CGSizeMake(3.0, -5.0), 4.0, shadowCGColorRef);
	CGContextSetRGBFillColor(drawingContext, 0.0, 0.0, 0.0, 0.7);
	
	CGContextBeginPath(drawingContext);
	CGContextMoveToPoint(drawingContext, 8, 10);
	CGContextAddLineToPoint(drawingContext, 8, 48);
	CGContextAddLineToPoint(drawingContext, 0, 44);
	CGContextAddLineToPoint(drawingContext, 0, 18);
	CGContextClosePath(drawingContext);
	CGContextFillPath(drawingContext);
	digitGraphics[5] = CGBitmapContextCreateImage(drawingContext);
	CGContextRelease(drawingContext);
	
	/*6*/
	drawingContext = CGBitmapContextCreate(bytes, 50, 18, 8, 200, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	for(int i = 0; i < 3600; i++) bytes[i] = 0;
	
	CGContextSetShadowWithColor(drawingContext, CGSizeMake(3.0, -5.0), 4.0, shadowCGColorRef);
	CGContextSetRGBFillColor(drawingContext, 0.0, 0.0, 0.0, 0.7);
	
	CGContextBeginPath(drawingContext);
	CGContextMoveToPoint(drawingContext, 0, 10);
	CGContextAddLineToPoint(drawingContext, 40, 10);
	CGContextAddLineToPoint(drawingContext, 32, 18);
	CGContextAddLineToPoint(drawingContext, 8, 18);
	CGContextClosePath(drawingContext);
	CGContextFillPath(drawingContext);
	digitGraphics[6] = CGBitmapContextCreateImage(drawingContext);
	CGContextRelease(drawingContext);
	
	/*7*/
	drawingContext = CGBitmapContextCreate(bytes, 16, 16, 8, 64, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	for(int i = 0; i < 3600; i++) bytes[i] = 0;
	
	CGContextSetShadowWithColor(drawingContext, CGSizeMake(3.0, -5.0), 4.0, shadowCGColorRef);
	CGContextSetRGBFillColor(drawingContext, 0.0, 0.0, 0.0, 0.7);
	
	CGContextBeginPath(drawingContext);
	CGContextMoveToPoint(drawingContext, 0, 16);
	CGContextAddLineToPoint(drawingContext, 6, 16);
	CGContextAddLineToPoint(drawingContext, 6, 10);
	CGContextAddLineToPoint(drawingContext, 0, 10);
	CGContextClosePath(drawingContext);
	CGContextFillPath(drawingContext);
	digitGraphics[7] = CGBitmapContextCreateImage(drawingContext);
	CGContextRelease(drawingContext);
	
	
	
	/*constant data about where each segment gets positioned to form the classic '8' digit:*/
	digitGraphicsRectOffsets[0][0] = 1; digitGraphicsRectOffsets[0][1] = 62; digitGraphicsRectOffsets[0][2] = 50; digitGraphicsRectOffsets[0][3] = 18;
	digitGraphicsRectOffsets[1][0] = 0; digitGraphicsRectOffsets[1][1] = 31; digitGraphicsRectOffsets[1][2] = 18; digitGraphicsRectOffsets[1][3] = 48;
	digitGraphicsRectOffsets[2][0] = 34; digitGraphicsRectOffsets[2][1] = 31; digitGraphicsRectOffsets[2][2] = 18; digitGraphicsRectOffsets[2][3] = 48;
	digitGraphicsRectOffsets[3][0] = 2; digitGraphicsRectOffsets[3][1] = 26; digitGraphicsRectOffsets[3][2] = 48; digitGraphicsRectOffsets[3][3] = 18;
	digitGraphicsRectOffsets[4][0] = 0; digitGraphicsRectOffsets[4][1] = -9; digitGraphicsRectOffsets[4][2] = 18; digitGraphicsRectOffsets[4][3] = 48;
	digitGraphicsRectOffsets[5][0] = 34; digitGraphicsRectOffsets[5][1] = -9; digitGraphicsRectOffsets[5][2] = 18; digitGraphicsRectOffsets[5][3] = 48;
	digitGraphicsRectOffsets[6][0] = 1; digitGraphicsRectOffsets[6][1] = -10; digitGraphicsRectOffsets[6][2] = 50; digitGraphicsRectOffsets[6][3] = 18;
	digitGraphicsRectOffsets[7][0] = 45; digitGraphicsRectOffsets[7][1] = -13; digitGraphicsRectOffsets[7][2] = 16; digitGraphicsRectOffsets[7][3] = 16;
	
	/*simple set if masks to define which segments are necessary to define each digit, 1-9:*/
	digitGraphicsVisibilities[0][0] = 1; digitGraphicsVisibilities[0][1] = 1; digitGraphicsVisibilities[0][2] = 1; digitGraphicsVisibilities[0][3] = 0; digitGraphicsVisibilities[0][4] = 1; digitGraphicsVisibilities[0][5] = 1; digitGraphicsVisibilities[0][6] = 1; 
	digitGraphicsVisibilities[1][0] = 0; digitGraphicsVisibilities[1][0] = 0; digitGraphicsVisibilities[1][2] = 1; digitGraphicsVisibilities[1][3] = 0; digitGraphicsVisibilities[1][4] = 0; digitGraphicsVisibilities[1][5] = 1; digitGraphicsVisibilities[1][6] = 0;
	digitGraphicsVisibilities[2][0] = 1; digitGraphicsVisibilities[2][1] = 0; digitGraphicsVisibilities[2][2] = 1; digitGraphicsVisibilities[2][3] = 1; digitGraphicsVisibilities[2][4] = 1; digitGraphicsVisibilities[2][5] = 0; digitGraphicsVisibilities[2][6] = 1;
	digitGraphicsVisibilities[3][0] = 1; digitGraphicsVisibilities[3][1] = 0; digitGraphicsVisibilities[3][2] = 1; digitGraphicsVisibilities[3][3] = 1; digitGraphicsVisibilities[3][4] = 0; digitGraphicsVisibilities[3][5] = 1; digitGraphicsVisibilities[3][6] = 1;
	digitGraphicsVisibilities[4][0] = 0; digitGraphicsVisibilities[4][1] = 1; digitGraphicsVisibilities[4][2] = 1; digitGraphicsVisibilities[4][3] = 1; digitGraphicsVisibilities[4][4] = 0; digitGraphicsVisibilities[4][5] = 1; digitGraphicsVisibilities[4][6] = 0;
	digitGraphicsVisibilities[5][0] = 1; digitGraphicsVisibilities[5][1] = 1; digitGraphicsVisibilities[5][2] = 0; digitGraphicsVisibilities[5][3] = 1; digitGraphicsVisibilities[5][4] = 0; digitGraphicsVisibilities[5][5] = 1; digitGraphicsVisibilities[5][6] = 1;
	digitGraphicsVisibilities[6][0] = 1; digitGraphicsVisibilities[6][1] = 1; digitGraphicsVisibilities[6][2] = 0; digitGraphicsVisibilities[6][3] = 1; digitGraphicsVisibilities[6][4] = 1; digitGraphicsVisibilities[6][5] = 1; digitGraphicsVisibilities[6][6] = 1;
	digitGraphicsVisibilities[7][0] = 1; digitGraphicsVisibilities[7][1] = 0; digitGraphicsVisibilities[7][2] = 1; digitGraphicsVisibilities[7][3] = 0; digitGraphicsVisibilities[7][4] = 0; digitGraphicsVisibilities[7][5] = 1; digitGraphicsVisibilities[7][6] = 0;
	digitGraphicsVisibilities[8][0] = 1; digitGraphicsVisibilities[8][1] = 1; digitGraphicsVisibilities[8][2] = 1; digitGraphicsVisibilities[8][3] = 1; digitGraphicsVisibilities[8][4] = 1; digitGraphicsVisibilities[8][5] = 1; digitGraphicsVisibilities[8][6] = 1;
	digitGraphicsVisibilities[9][0] = 1; digitGraphicsVisibilities[9][1] = 1; digitGraphicsVisibilities[9][2] = 1; digitGraphicsVisibilities[9][3] = 1; digitGraphicsVisibilities[9][4] = 0; digitGraphicsVisibilities[9][5] = 1; digitGraphicsVisibilities[9][6] = 1;


	/*clean up*/
	free(bytes);
	CGColorRelease(shadowCGColorRef);
}


/*
	given a number made up of several digits, this method constructs each of these digits out of our segment graphics and draws them to the content layer of this view:
 */
- (void)drawDigitsForNumber:(int *)intStr ofLength: (int)strLength andDecimalPointPos: (int)decimalPointPos isNegative: (int)isNegative
{
	/*create a whole new bitmap context to draw the number into:*/
	CGContextRef theContext = CGBitmapContextCreate(NULL, 708, 90, 8, 708 * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast) ;
	
	CGPoint basePoint;
	int digitChar;
	
	/*draw the digits, from left to right:*/
	for(int i = 0; i < strLength; i++)
	{
		basePoint = CGPointMake(708 + ((i - strLength) * 54) - 2, 0);
		digitChar = intStr[i];
		
		/*for each element of the classic '8' digit, draw it for this number if valid:*/
		for(int d = 0; d < 7; d++)
		{
			if(digitGraphicsVisibilities[digitChar][d] == 1) CGContextDrawImage(theContext, CGRectMake(basePoint.x + digitGraphicsRectOffsets[d][0], basePoint.y + digitGraphicsRectOffsets[d][1] + 10, digitGraphicsRectOffsets[d][2], digitGraphicsRectOffsets[d][3]), digitGraphics[d]);
		}
		
		/*if the decimal point should appear after this digit, then draw it:*/
		if(i == decimalPointPos) CGContextDrawImage(theContext, CGRectMake(basePoint.x + digitGraphicsRectOffsets[7][0], basePoint.y + digitGraphicsRectOffsets[7][1] + 10, digitGraphicsRectOffsets[7][2], digitGraphicsRectOffsets[7][3]), digitGraphics[7]);
	}
	
	/*if the number is negative, then draw a negative sign before the first digit:*/
	if(isNegative == 1)
	{
		basePoint = CGPointMake(708 - (strLength + 1) * 54 - 2, 0);
		CGContextDrawImage(theContext, CGRectMake(basePoint.x + digitGraphicsRectOffsets[3][0], basePoint.y + digitGraphicsRectOffsets[3][1] + 10, digitGraphicsRectOffsets[3][2], digitGraphicsRectOffsets[3][3]), digitGraphics[3]);
	}
	
	/*now draw this context out to a CGImage and assign it to our sublayer which always contains the drawn digits:*/
	CGImageRef drawingImage = CGBitmapContextCreateImage(theContext);
	[contentSublayer setContents: (id)drawingImage];
	[contentSublayer removeAllAnimations];
	
	/*clean up:*/
	CGContextRelease(theContext);
	CGImageRelease(drawingImage);

	/*record the number of digits being displayed (+1 for the +/- sign is appropriate):*/
	numDigitsCurrentlyDisplayed = strLength + isNegative;
	[self layoutSubviews];
}



/*
	roundedDiscreteFrame.	When the superview lays out its subview, it will call this method, passing as a parameter the maximum frame that this digit view has to occupy.  
							Because this view displays a discrete number of whole digits, it must truncate, or 'round down', this rectangle to the exact shape that will accommodate the maximum possible number of whole digits:
*/
- (CGRect)roundedDiscreteFrame: (CGRect)allowedFrame;
{
	int remainder = (int)(allowedFrame.size.width - 2) % 54;
	
	return CGRectMake(allowedFrame.origin.x + remainder, allowedFrame.origin.y, allowedFrame.size.width - remainder, allowedFrame.size.height);
}


- (void)layoutSubviews
{
	if(layoutStyle == 0)
	{
		int requiredWidth = numDigitsCurrentlyDisplayed * 54 + 10;
		if(requiredWidth > self.frame.size.width)
		{
			CGRect scaledFrame = CGRectMake(self.frame.size.width - 708.0 * (self.frame.size.width / requiredWidth), (int)(45.0 * (1.0 - (self.frame.size.width / requiredWidth))),  708.0 * (self.frame.size.width / requiredWidth), (int)(90.0 * (self.frame.size.width / requiredWidth)));
			[contentSublayer setFrame: scaledFrame];
		}
	
		else [contentSublayer setFrame: CGRectMake(self.frame.size.width - 708, 0, 708, 90)];
	
		[contentSublayer removeAllAnimations];
	}
}

- (void)setLayoutStyle: (int)layoutStyle_in;
{
	layoutStyle = layoutStyle_in;
}


- (CALayer *)contentSublayer
{
	return contentSublayer;
}
 

/*
	caller uses this method to notify this view that its frame is about to change. If this results in a different scale of the digits, then we animate that here. If not, we can do nothing:
 */
- (void)animateDigitsIfNecessaryForNewFrame: (CGRect)newFrame withDuration: (float)duration
{
	/*get the contentSublayer's current frame:*/
	CGRect contentSublayerFrame = [contentSublayer frame];
	
	/*calculate what the content sublayer's frame will need to be in this view's new frame:*/
	CGRect contentSublayerFrameWithThisNewFrame = CGRectMake(newFrame.size.width - 708, 0, 708, 90);
	int requiredWidth = numDigitsCurrentlyDisplayed * 54 + 10;
	if(requiredWidth > newFrame.size.width)
	{
		contentSublayerFrameWithThisNewFrame = CGRectMake(newFrame.size.width - 708.0 * (newFrame.size.width / requiredWidth), (int)(45.0 * (1.0 - (newFrame.size.width / requiredWidth))),  708.0 * (newFrame.size.width / requiredWidth), (int)(90.0 * (newFrame.size.width / requiredWidth)));
	}
	
	/*If the prospective frame does not match the current one, then animate from current to new:*/
	if(contentSublayerFrameWithThisNewFrame.size.width != contentSublayerFrame.size.width)	[UIView animateWithDuration: duration animations: ^{ [contentSublayer setFrame: contentSublayerFrameWithThisNewFrame]; }];
}

- (void)dealloc
{
	/*release the 8 digit segment CGImages:*/
	for(int i = 0; i < 8; i++) CGImageRelease(digitGraphics[i]);
	
	[super dealloc];
}


@end






@implementation calculatorMiniAppView

- (id)initWithFrame:(CGRect)frame 
{
	if ((self = [super initWithFrame:frame])) 
	{
		[self setBackgroundColor: [[UIColor redColor] autorelease]];


		/*set this view's content mode to redraw itself whenever its bounds are changed:*/
		[self setContentMode: UIViewContentModeScaleToFill];

		/*by default, don't draw view content to an offscreen buffer:*/
		drawOffScreenContentToScreen = 0;
		
		/*allocate the variables that will b eused to contain the digits that appear on the calculator screen. To start with, there is no operation in progress, we start with a '0' on the screen and in mode '3' (see header file for details on modes)*/
		digitDisplayArray = (int *)(malloc(CALCULATOR_MAX_DIGITS * sizeof(int)));
		digitDisplayArray[0] = 0;
		numDigits = 1;
		decimalPointPos = -1;
		screenNumberIsPositive = 1;
		
		widthSpaceRequired = CALCULATOR_DIGIT_WIDTH * (numDigits + 1);
		
		/*to start with, there is */
		operationInProgress = 0;
		actionMode = 3;
		
		
		/*Create and setup the CALayers and digitsView that comprise the calculator screen. There are three layers: A base CALayer for the green LCD background, a custom view for displaying and controlling the digits, and a CALayer on top to give a nice sheen*/
		screenBase = [CALayer layer];
		
		[[self layer] addSublayer: screenBase];
		[screenBase setFrame: CGRectMake(20, 20, frame.size.width - 40, 100)];
		[screenBase setAnchorPoint: CGPointMake(0.0, 0.0)];
		[screenBase setCornerRadius: 10.0];
		[screenBase setMasksToBounds: YES];
		[screenBase setContentsCenter: CGRectMake( (10.0/(frame.size.width - 40)), 0.0, (1.0 - (20.0/(frame.size.width - 40) )), 1.0)];
		[screenBase setZPosition: 1.0];
		

		
		/*when making the digits view, always first create it at the maximum width it can possibly be on screen: (i.e. 768 - 60 = 708 pixels wide), then truncate it later:*/
		screenDigits = [[calculatorDigitsView alloc] initWithFrame: CGRectMake(30, 30, frame.size.width - 60, 90)];
		
		[self addSubview: screenDigits];
		[[screenDigits layer] setZPosition: 2.0];

		
		/*draw the initial current number, 0, to the screen:*/
		[self setScreenDigits];
		
		
		screenSheen = [CALayer layer];
		
		[[self layer] addSublayer: screenSheen];
		[screenSheen setFrame: CGRectMake(25, 25, frame.size.width - 50, 90)];
		[screenSheen setAnchorPoint: CGPointMake(0.0, 0.0)];
		[screenSheen setCornerRadius: 7.0];
		[screenSheen setMasksToBounds: YES];
		[screenSheen setContentsCenter: CGRectMake( (7.0/(frame.size.width - 50)), 0.0, (1.0 - (14.0/(frame.size.width - 50) )), 1.0)];
		[screenSheen setZPosition: 3.0];
		
		
		/*generate the graphics for the screen (this will only have to be done once)*/
		[self generateScreenLayersGraphics];
		
		
		/*Create the calculator buttons - each button will be a 'calculatorButtonView' and have a CALayer behind it to create an appealing shadow effect:*/
		buttonSubviews = [NSMutableArray arrayWithCapacity: 17];
		buttonShadowLayers = [NSMutableArray arrayWithCapacity: 17];
		
		calculatorButtonView *aCalculatorButtonView;
		CALayer *aCalculatorButtonShadowLayer;
		
		for(int i = 0; i < 17; i++)
		{
			/*button:*/
			aCalculatorButtonView = [[calculatorButtonView alloc] initWithFrame: CGRectMake(0.0, 0.0, 50.0, 50.0) andId: i];
			[aCalculatorButtonView setNeedsDisplay];
			
			[self addSubview: aCalculatorButtonView];
			[[aCalculatorButtonView layer] setZPosition: 5.0];
			
			[buttonSubviews addObject: aCalculatorButtonView];
			[aCalculatorButtonView release];
			
			/*button shadow:*/
			aCalculatorButtonShadowLayer = [CALayer layer];
			[aCalculatorButtonShadowLayer setBackgroundColor: [[UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.0] CGColor]];
			[aCalculatorButtonShadowLayer setOpacity: 1.0];
			[aCalculatorButtonShadowLayer setContentsGravity: kCAGravityResize];
			
			/*if this is the equals button, set its scalable area to be just the centre so that its curved corners don't get distorted when it changes shape:*/
			if(i == 16) [aCalculatorButtonShadowLayer setContentsCenter: CGRectMake(0.45, 0.45, 0.1, 0.1)];
			
			[[self layer] addSublayer: aCalculatorButtonShadowLayer];
			[aCalculatorButtonShadowLayer setZPosition: 4.0];
			
			[buttonShadowLayers addObject: aCalculatorButtonShadowLayer];
			//[aCalculatorButtonShadowLayer release];
		}
		[buttonSubviews retain];
		[buttonShadowLayers retain];
		
		
		/*depending on the size and shape of this view, the buttons will be laid out in different positions. this method declares a massive fixed brute-force array or numbers defining all their configurations:*/
		[self defineButtonLayouts];
		
		/*now call our function for arranging these button views:*/
		[self layoutButtons];
		
		/*now, given the buttons' new size an layout, generate the graphics for them to use, and apply the resulting graphics:*/
		[self generateButtonGraphicsForCurrentLayout];
		
		for(int i = 0; i < 17; i++)
		{
			[[buttonSubviews objectAtIndex: i] setNeedsDisplay];
			[[buttonShadowLayers objectAtIndex: i] setContents: (id)buttonGraphics_shadow];
		}
	
		
		
		/*by default, manual layout subviews method is used:*/
		disableManualLayout = 0;
	
		/*when the layoutSubviews method needs to redraw the graphics because of a new view frame, this variable will indicate this:*/
		redrawContentInSettledFrame_ready = 0;
	
		/*set up animation objects to be used later on during truncation:*/
		buttonShadowLayersAnims = [NSMutableArray arrayWithCapacity: 34];
		
		CAMediaTimingFunction *easeInEaseOutTimingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
	
		for(int b = 0; b < 17; b++)
		{
			/*create the animation objects for this button shadow:*/
			CABasicAnimation *boundsAnim = [CABasicAnimation animationWithKeyPath: @"bounds"];
			CABasicAnimation *positionAnim = [CABasicAnimation animationWithKeyPath: @"position"];
	
			/*set the blending function to ease in ease out:*/
			[boundsAnim setTimingFunction: easeInEaseOutTimingFunction];
			[positionAnim setTimingFunction: easeInEaseOutTimingFunction];
		
			/*add to array:*/
			[buttonShadowLayersAnims addObject: boundsAnim];
			[buttonShadowLayersAnims addObject: positionAnim];
		}
		[buttonShadowLayersAnims retain];
	
		screenBaseAnim = [CABasicAnimation animationWithKeyPath: @"bounds"];
		[screenBaseAnim setTimingFunction: easeInEaseOutTimingFunction];
		[screenBaseAnim retain];
	
		screenDigitsSublayerAnim = [CABasicAnimation animationWithKeyPath: @"position"];
		[screenDigitsSublayerAnim setTimingFunction: easeInEaseOutTimingFunction];
		[screenDigitsSublayerAnim retain];
	
		screenSheenAnim = [CABasicAnimation animationWithKeyPath: @"bounds"];
		[screenSheenAnim setTimingFunction: easeInEaseOutTimingFunction];
		[screenSheenAnim retain];
	
		/*we'll also need some for the screen animation during contraction:*/
		screenComponentLayersAnims = [NSMutableArray arrayWithCapacity: 9];
	
		for(int b = 0; b < 3; b++)
		{
			/*create the animation objects for this button shadow:*/
			CABasicAnimation *boundsAnim = [CABasicAnimation animationWithKeyPath: @"bounds"];
			CABasicAnimation *positionAnim = [CABasicAnimation animationWithKeyPath: @"position"];
			CABasicAnimation *cornerRadiusAnim = [CABasicAnimation animationWithKeyPath: @"cornerRadius"];
			
			/*set the blending function to ease in ease out:*/
			[boundsAnim setTimingFunction: easeInEaseOutTimingFunction];
			[positionAnim setTimingFunction: easeInEaseOutTimingFunction];
			[cornerRadiusAnim setTimingFunction: easeInEaseOutTimingFunction];
		
			/*add to array:*/
			[screenComponentLayersAnims addObject: boundsAnim];
			[screenComponentLayersAnims addObject: positionAnim];
			[screenComponentLayersAnims addObject: cornerRadiusAnim];
		}
		[screenComponentLayersAnims retain];
	
	
		/*create nice embossed logo layer:*/
		CGImageRef imageImageRef = [utilities openCGResourceImage: @"embossedP" ofType: @"png"];
	
		niceEmbossedLogoLayer = [CALayer layer];
		[niceEmbossedLogoLayer setFrame: CGRectMake(0, 0, 400, 400)];
		[niceEmbossedLogoLayer setContents: (id)imageImageRef];
		[niceEmbossedLogoLayer setOpacity: 0.5];
		[niceEmbossedLogoLayer setHidden: YES];	
		
		[[self layer] addSublayer: niceEmbossedLogoLayer];
		CGImageRelease(imageImageRef);
	}
	
	return self;
}


/*Always forward events to this, the parent view:*/
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	return self;
}

-(void)layoutSubviews
{
	if(disableManualLayout == 0)
	{
		/*set screen layers' positions:*/
		[screenBase setFrame: CGRectMake(20, 20, self.bounds.size.width - 40, 100)];
		[screenBase removeAllAnimations];
	
		[screenDigits setFrame: CGRectMake(30, 30, self.bounds.size.width - 60, 90)];
	
	
		[screenSheen setFrame: CGRectMake(25, 25, self.bounds.size.width - 50, 90)];
		[screenSheen removeAllAnimations];
	
		/*configure the buttons:*/
		[self layoutButtons];
		
		
		/*we may have been signalled to regenerate the graphics for the current button size following change of bounds. If this is the case, then here is the place to do so, after we've calculated the size and layout of the buttons above:*/
		if(redrawContentInSettledFrame_ready == 1)
		{
			redrawContentInSettledFrame_ready = 0;
			
			/*regenerate button graphics:*/
			[self generateButtonGraphicsForCurrentLayout];
			
			/*with these new graphics generated, tell all the buttons to redraw themselves:*/
			for(int i = 0; i < 17; i++) [[buttonSubviews objectAtIndex: i] setNeedsDisplay];
			
			/*...and give the layers their latest rendered shadow:*/
			for(int i = 0; i < 17; i++) [[buttonShadowLayers objectAtIndex: i] setContents: (id)buttonGraphics_shadow];
			
			/*notify the parent view that we have finished all this heavy drawing:*/
			[rootPanelView miniAppViewDidFinishRedrawingInSettledFrame: self];
		}
	}
	
	/*call super view layout method to provide default behaviour for the 'top darken layer:*/
	[super layoutSubviews];
}


/*
	shouldMiniAppBeDisabledGivenBounds - the calculator's implementation of this method is based purely on the size of the buttons for the current layout:
 */
- (BOOL)shouldMiniAppBeDisabledGivenBounds: (CGRect)bounds_in
{
	/*if the buttons' dimension is less than 'CALCULATOR_MINI_APP_MINIMUM_BUTTON_DIMEMSION', we disable the mini app:*/
	if(buttonDimension < CALCULATOR_MINI_APP_MINIMUM_BUTTON_DIMEMSION) return YES;
	
	return NO;
}


/*
	depending on the size and shape of this view, the buttons will be laid out in different positions. this method declares a massive fixed brute-force array of numbers defining all their configurations:
*/
- (void)defineButtonLayouts
{
	/*'0' button:*/
	buttonLayouts[0][0][0] = 3;
	buttonLayouts[0][0][1] = 0;
	
	for(int i = 1; i < 4; i++){
		buttonLayouts[i][0][0] = 0;
		buttonLayouts[i][0][1] = 3;
	}
	
	buttonLayouts[4][0][0] = 0;
	buttonLayouts[4][0][1] = 1;
	
	
	/*'1'-'9' buttons:*/
	for(int i = 0; i < 5; i++){
		for(int j = 1; j < 10; j++){
			if(i <= 3){
				buttonLayouts[i][j][0] = (j - 1) % 3;
				buttonLayouts[i][j][1] = 2 - (int)((j - 1) / 3);
			}
			else{
				buttonLayouts[i][j][0] = j - 1;
				buttonLayouts[i][j][1] = 0;
			}
		}
	}
	
	
	/*operator buttons:*/
	for(int j = 10; j < 14; j++){
		buttonLayouts[0][j][0] = 3 + (j - 10) % 2;
		buttonLayouts[0][j][1] = 1 + (int)((j - 10) / 2);
	}
	
	for(int j = 10; j < 14; j++){
		buttonLayouts[1][j][0] = 3 + (j - 10) % 2;
		buttonLayouts[1][j][1] = (int)((j - 10) / 2);
	}
		
	for(int j = 10; j < 14; j++){
		buttonLayouts[2][j][0] = 3;
		buttonLayouts[2][j][1] = j - 10;
	}

	for(int j = 10; j < 14; j++){
		buttonLayouts[3][j][0] = 1 + (j - 10) % 2;
		buttonLayouts[3][j][1] = 3 + (int)((j - 10)/2);
	}
	
	for(int j = 10; j < 14; j++){
		buttonLayouts[4][j][0] = (j - 10) + 2;
		buttonLayouts[4][j][1] = 1;
	}
	
	
	/*'clear' point button:*/
	buttonLayouts[0][14][0] = 5;
	buttonLayouts[0][14][1] = 0;
	
	buttonLayouts[1][14][0] = buttonLayouts[2][14][0] = 2;
	buttonLayouts[1][14][1] = buttonLayouts[2][14][1] = 3;
		
	buttonLayouts[3][14][0] = 0;
	buttonLayouts[3][14][1] = 5;
	
	buttonLayouts[4][14][0] = 6;
	buttonLayouts[4][14][1] = 1;
	
	
	/*decimal point button:*/
	buttonLayouts[0][15][0] = 4;
	buttonLayouts[0][15][1] = 0;
	
	buttonLayouts[1][15][0] = buttonLayouts[2][15][0] = 1;
	buttonLayouts[1][15][1] = buttonLayouts[2][15][1] = 3;
	
	buttonLayouts[3][15][0] = 0;
	buttonLayouts[3][15][1] = 4;
	
	buttonLayouts[4][15][0] = 1;
	buttonLayouts[4][15][1] = 1;
	
	
	/*'equals' button:*/
	buttonLayouts[0][16][0] = 5;
	buttonLayouts[0][16][1] = 1;

	buttonLayouts[1][16][0] = 3;
	buttonLayouts[1][16][1] = 3;

	buttonLayouts[2][16][0] = 0;
	buttonLayouts[2][16][1] = 4;

	buttonLayouts[3][16][0] = 1;
	buttonLayouts[3][16][1] = 5;
	
	buttonLayouts[4][16][0] = 7;
	buttonLayouts[4][16][1] = 1;
}


/*
 this method simply creates and applies the graphics for the various screen layers (it's a greenish LCD background topped with a white sheen)
 */
- (void)generateScreenLayersGraphics;
{
	CGRect screenRect = CGRectMake(0, 0, self.bounds.size.width - 40, 100);
	
	/*create bitmap graphics context and byte buffer for it:*/
	char *bytes = (char *)malloc((self.bounds.size.width - 40) * 4 * 100);
	CGContextRef graphicsContext = CGBitmapContextCreate(NULL, self.bounds.size.width - 40, 100, 8, (self.bounds.size.width - 40)*4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	

	CGContextSaveGState(graphicsContext);
	CGContextScaleCTM(graphicsContext, 1.0, -1.0);
	CGContextTranslateCTM(graphicsContext, 0.0, -100);
	
	/*base background green:*/
	CGContextSetRGBFillColor(graphicsContext, 0.0, 0.25, 0.0, 1.0);
	CGContextFillRect(graphicsContext, screenRect);
	
	/*light falls on lower half of screen*/
	CGGradientRef scrnGradient;
	CGFloat scrnGradLocs[] = {0.0, 1.0};
	CGFloat scrnGradComps[] = {0.35, 0.45, 0.35, 1.0, 0.6, 0.65, 0.525, 1.0};
	
	scrnGradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), scrnGradComps, scrnGradLocs, 2);
	CGContextDrawLinearGradient(graphicsContext, scrnGradient, CGPointMake(0, 0), CGPointMake(0, screenRect.size.height), kCGGradientDrawsAfterEndLocation);
	
	/*cast shadow from calculator framework on to screen:*/
	CGRect screenShadCastRect = CGRectMake(screenRect.origin.x - 2, screenRect.origin.y, screenRect.size.width + 4, screenRect.size.height + 5);
	CGContextSaveGState(graphicsContext);
	float shadowColorComponents[] = {0.0, 0.0, 0.0, 1.0};
	CGColorRef shadowCGColorRef = CGColorCreate(CGColorSpaceCreateDeviceRGB(), shadowColorComponents);
	
	CGContextSetShadowWithColor(graphicsContext, CGSizeMake(0.0,0.0), 10.0, shadowCGColorRef);
	
	CGContextSetRGBFillColor(graphicsContext, 0.0, 0.0, 0.0, 0.7);
	
	CGContextBeginPath(graphicsContext);
	CGContextMoveToPoint(graphicsContext, screenShadCastRect.origin.x + 10, -10);
	CGContextAddLineToPoint(graphicsContext, screenShadCastRect.origin.x + 10, screenRect.origin.y);
	[utilities drawRoundedRect: graphicsContext rect: screenShadCastRect radius: 10];
	CGContextAddLineToPoint(graphicsContext, screenShadCastRect.origin.x + 10, -10);
	CGContextAddLineToPoint(graphicsContext, -10, -10);
	CGContextAddLineToPoint(graphicsContext, -10, -10 + 120);
	CGContextAddLineToPoint(graphicsContext, -10 + screenRect.size.width + 20, -10 + 120);
	CGContextAddLineToPoint(graphicsContext, -10 + screenRect.size.width + 20, -10);
	CGContextAddLineToPoint(graphicsContext, screenShadCastRect.origin.x + 10, -10);
	CGContextClosePath(graphicsContext);
	CGContextSetRGBFillColor(graphicsContext, 0.0, 0.0, 0.0, 2.0);
	CGContextFillPath(graphicsContext);
	
	CGContextRestoreGState(graphicsContext);
	
	CGContextRestoreGState(graphicsContext);
	

	CGImageRef graphicsImage = CGBitmapContextCreateImage(graphicsContext);
	[screenBase setContents: (id)graphicsImage];
	
	/*Clean up:*/
	free(bytes);
	CGGradientRelease(scrnGradient);
	CGContextRelease(graphicsContext);
	CGImageRelease(graphicsImage);
	
	
	/*now draw the sheen graphics:*/
	screenRect = CGRectMake(0, 0, self.bounds.size.width - 50, 90);
	
	bytes = (char *)malloc((self.bounds.size.width - 50) * 4 * 90);
	for(int i = 0; i < ((self.bounds.size.width - 50) * 4 * 90); i++) bytes[i] = 0;
	graphicsContext = CGBitmapContextCreate(NULL, self.bounds.size.width - 50, 90, 8, (self.bounds.size.width - 50)*4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	
	CGContextSaveGState(graphicsContext);
	CGContextScaleCTM(graphicsContext, 1.0, -1.0);
	CGContextTranslateCTM(graphicsContext, 0.0, -90);
	
	CGGradientRef sheenGradient;
	CGFloat sheenGradLocs[] = {0.0, 1.0};
	CGFloat sheenGradComps[] = {1.0, 1.0, 1.0, 0.7, 1.0, 1.0, 1.0, 0.1};
	
	sheenGradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), sheenGradComps, sheenGradLocs, 2);
	CGContextDrawLinearGradient(graphicsContext, sheenGradient, CGPointMake(0, 0), CGPointMake(0, 20), 0);
	
	
	CGContextRestoreGState(graphicsContext);
	
	graphicsImage = CGBitmapContextCreateImage(graphicsContext);
	[screenSheen setContents: (id)graphicsImage];
	
	/*Clean up:*/
	free(bytes);
	CGGradientRelease(sheenGradient);
	CGContextRelease(graphicsContext);
	CGImageRelease(graphicsImage);
}


/*
	setupOffScreenContentLayer - will be called whenever the view changes bounds. Simply creates an offscreen buffer of the exact correct size for new bounds, ready to be used if necessary:
 */
- (void)setupOffScreenContentLayer: (CGContextRef)contextRef withSize: (CGSize)sizeForContext
{
	/*create the CGLayer: (free it up first if we're recreating it here:)*/
	if(offScreenContent != nil) 
	{
		CGLayerRelease(offScreenContent);
		CGContextRelease(offScreenContentContext);
	}
		
	offScreenContent = CGLayerCreateWithContext(contextRef, sizeForContext, NULL);
	
	/*give it its own graphics context:*/
	offScreenContentContext = CGLayerGetContext(offScreenContent);

	CGContextRetain(offScreenContentContext);
}


/*
	determineButtonLayoutInfoForFrame - given a new CGRect bounds available, this method determines the optimum layout for buttons inside that rect, and outputs information about said layout
 */
- (void)determineButtonLayoutInfoForFrame: (CGRect)frameToFit drawableSpace: (CGRect *)drawableSpace_out buttonsLayoutConfig: (int *)buttonsLayoutConfig_out numButtonsI: (int *)numButtonsI_out numButtonsJ: (int *)numButtonsJ_out buttonDimension: (int *)buttonDimension_out keyLayoutBound: (int *)keyLayoutBound_out 
{
	/*first of all - determine the rectangle space that is available for the buttons to sit in:*/
	CGRect drawableSpace = CGRectMake(20, 140, frameToFit.size.width - 40, frameToFit.size.height - 160);
	*drawableSpace_out = drawableSpace;
	
	if(drawableSpace.size.width > drawableSpace.size.height) /*landscape:*/
	{
		if((drawableSpace.size.width / 9.0) > (drawableSpace.size.height / 3.0))		/*ultra extreme lanscape*/
		{
			*buttonsLayoutConfig_out = 4;
			
			*numButtonsI_out = 9;
			*numButtonsJ_out = 2;
			
			/*bound by width?*/
			if((drawableSpace.size.width / drawableSpace.size.height) < 4.5){
				*buttonDimension_out = (int)(drawableSpace.size.width/9.0) - 2;
				*keyLayoutBound_out = 1; } 
			/*or height?*/
			else {
				*buttonDimension_out = (int)(drawableSpace.size.height/2.0) - 2;
				*keyLayoutBound_out = 0; }
			
			/*N.B. if the shape of the view is so extreme that the buttons are below the minimum acceptable size, then stop at said acceptable size, and allow the buttons to be covered over by the decreasing bounds. (looks ugly but doesn't matter as the mini app will be disabled in this situation anyway)*/
			if(((*buttonDimension_out) < CALCULATOR_MINI_APP_MINIMUM_BUTTON_DIMEMSION) || (drawableSpace.size.height < 0))
			{
				*buttonDimension_out = CALCULATOR_MINI_APP_MINIMUM_BUTTON_DIMEMSION - 1;
				*drawableSpace_out = CGRectMake(20, 140, frameToFit.size.width - 40, 2 * (CALCULATOR_MINI_APP_MINIMUM_BUTTON_DIMEMSION - 1 + 2));
				
				*keyLayoutBound_out = 0;
			}
		}
		
		else if(((drawableSpace.size.width/6.0) - 2) > ((drawableSpace.size.height/4.0) - 2)) /*extreme landscape*/
		{
			*buttonsLayoutConfig_out = 0;
			
			*numButtonsI_out = 6;
			*numButtonsJ_out = 3;
			
			/*bound by width?*/
			if((drawableSpace.size.width / drawableSpace.size.height) < 2.0){
				*buttonDimension_out = (int)(drawableSpace.size.width/6.0) - 2;
				*keyLayoutBound_out = 1; } 
			/*or height?*/
			else {
				*buttonDimension_out = (int)(drawableSpace.size.height/3.0) - 2;
				*keyLayoutBound_out = 0; }
		}
		
		else /*moderate lanscape:*/
		{
			*buttonsLayoutConfig_out = 1;
			
			*numButtonsI_out = 5;
			*numButtonsJ_out = 4;
			
			/*bound by width?*/
			if((drawableSpace.size.width / drawableSpace.size.height) < 1.25) {
				*buttonDimension_out = (int)(drawableSpace.size.width/5.0) - 2;
				*keyLayoutBound_out = 1; }
			/*or height?*/
			else {
				*buttonDimension_out = (int)(drawableSpace.size.height/4.0) - 2;
				*keyLayoutBound_out = 0; }
		}
	}
	
	else /*portrait*/ 
	{
		if(((drawableSpace.size.height/6.0) - 10) > ((drawableSpace.size.width/4.0) - 6)) /*extreme portrait*/
		{
			*buttonsLayoutConfig_out = 3;
			
			*numButtonsI_out = 3;
			*numButtonsJ_out = 6;
			
			/*bound by width?*/
			if((drawableSpace.size.width / drawableSpace.size.height) < 0.5) {
				*buttonDimension_out = (int)(drawableSpace.size.width/3.0) - 2;
				*keyLayoutBound_out = 1; }
			
			/*or height?*/
			else {
				*buttonDimension_out = (int)(drawableSpace.size.height/6.0) - 2;
				*keyLayoutBound_out = 0; }
		}
		
		else /*moderate portrait:*/
		{
			*buttonsLayoutConfig_out = 2;
			
			*numButtonsI_out = 4;
			*numButtonsJ_out = 5;
			
			/*bound by width?*/
			if((drawableSpace.size.width / drawableSpace.size.height) < 0.8) {
				*buttonDimension_out = (int)(drawableSpace.size.width/4.0) - 2;
				*keyLayoutBound_out = 1; }
			
			/*or height?*/
			else {
				*buttonDimension_out = (int)(drawableSpace.size.height/5.0) - 2;
				*keyLayoutBound_out = 0; }
		}
	}
}


/*
	determineButtonFrameGivenIndex - given a button index (0 - 17), this method uses known information about the buttons layout to return the frame that that button should occupy in thie view's coordinate space:
 */
- (void)determineButtonFrameGivenIndex: (int)b drawableSpace: (CGRect)drawableSpace_in buttonsLayoutConfig: (int)buttonsLayoutConfig_in numButtonsI: (int)numButtonsI_in numButtonsJ: (int)numButtonsJ_in buttonDimension: (int)buttonDimension_in keyLayoutBound: (int)keyLayoutBound_in frame: (CGRect *)frame_out
{
	/*We know the layout of the buttons and their size. Determine how much space they take up:*/
	int discreteButtonLayoutWidth = numButtonsI_in *buttonDimension_in + (numButtonsI_in - 1) * 2;
	int discreteButtonLayoutHeight = numButtonsJ_in *buttonDimension_in + (numButtonsJ_in - 1) * 2;
	
	int i = buttonLayouts[buttonsLayoutConfig_in][b][0];
	int j = buttonLayouts[buttonsLayoutConfig_in][b][1];
	
	int stickOffset_i = 0, stickOffset_j = 0;
	
	int stickOffsetThresholds[4][2] = {{5, -1}, {3, 3}, {3, 4}, {-1, 6}};
	
	
	/*if we are in 'ultra extreme landscape' button layout mode, then there is no spreading out of buttons. they are central-aligned:*/
	if(buttonsLayoutConfig_in == 4) 
	{
		if(keyLayoutBound_in == 0) stickOffset_i = (int)(0.5 * (drawableSpace_in.size.width - discreteButtonLayoutWidth));
		if(keyLayoutBound_in == 1) stickOffset_j = (int)(0.5 * (drawableSpace_in.size.height - discreteButtonLayoutHeight));
	}
		
	/*if any other layout mode, allow buttons to spread out to fill any surplus space:*/
	else
	{
		/*if we're height bound, allow certain defined buttons to spread out over the width of the space available to fill the space nicely:*/
		if(keyLayoutBound_in == 0)
		{
			if(stickOffsetThresholds[buttonsLayoutConfig_in][0] == -1) stickOffset_i = (int)(0.5 * (drawableSpace_in.size.width - discreteButtonLayoutWidth));
			else if(i >= stickOffsetThresholds[buttonsLayoutConfig_in][0]) stickOffset_i = drawableSpace_in.size.width - discreteButtonLayoutWidth;
		}	
	
		/*if we're width bound, allow certain defined buttons to spread out over the width of the space available to fill the space nicely:*/
		if(keyLayoutBound_in == 1)
		{
			if(stickOffsetThresholds[buttonsLayoutConfig_in][1] == -1) stickOffset_j = (int)(0.5 * (drawableSpace_in.size.height - discreteButtonLayoutHeight));
			else if(j >= stickOffsetThresholds[buttonsLayoutConfig_in][1]) stickOffset_j = drawableSpace_in.size.height - discreteButtonLayoutHeight;
		}
	}
	
	*frame_out = CGRectMake(drawableSpace_in.origin.x + i*(buttonDimension_in + 2) + stickOffset_i, drawableSpace_in.origin.y + j*(buttonDimension_in + 2) + stickOffset_j, buttonDimension_in, buttonDimension_in);
	
	/*special treatment for the 'equals' button - as its an oblong:*/
	if(b == 16)
	{
		if(buttonsLayoutConfig_in == 0) *frame_out = CGRectMake(drawableSpace_in.origin.x + i*(buttonDimension_in + 2) + stickOffset_i, drawableSpace_in.origin.y + j*(buttonDimension_in + 2) + stickOffset_j, buttonDimension_in, 2 * buttonDimension_in + 2);
		
		else *frame_out = CGRectMake(drawableSpace_in.origin.x + i*(buttonDimension_in + 2) + stickOffset_i, drawableSpace_in.origin.y + j*(buttonDimension_in + 2) + stickOffset_j, 2 * buttonDimension_in + 2, buttonDimension_in);
	}
}


/*
	whenever called, this method lays out the buttons, determining their configuration and size based on the space available:
*/
- (void)layoutButtons
{
	CGRect drawableSpace;
	
	/*what will the button configuration be?:*/
	int numButtonsI, numButtonsJ;
	int discreteButtonLayoutWidth, discreteButtonLayoutHeight;
	int buttonsLayoutConfig;
	int keyLayoutBound;
	int buttonDimensionValue;
	
	[self determineButtonLayoutInfoForFrame: self.bounds drawableSpace: &drawableSpace buttonsLayoutConfig: &buttonsLayoutConfig numButtonsI: &numButtonsI numButtonsJ: &numButtonsJ buttonDimension: &buttonDimensionValue keyLayoutBound: &keyLayoutBound];
	buttonDimension = buttonDimensionValue;
	
	/*now that we know the layout of the buttons and their size, determine how much space they take up:*/
	discreteButtonLayoutWidth = numButtonsI *buttonDimension + (numButtonsI - 1) * 2;
	discreteButtonLayoutHeight = numButtonsJ *buttonDimension + (numButtonsJ - 1) * 2;

	
	
	/*now fit the buttons into this space:*/
	CGRect buttonFrame;
	
	for(int b = 0; b < 17; b++)
	{
		[self determineButtonFrameGivenIndex: b drawableSpace: drawableSpace buttonsLayoutConfig: buttonsLayoutConfig numButtonsI: numButtonsI numButtonsJ: numButtonsJ buttonDimension: buttonDimension keyLayoutBound: keyLayoutBound frame: &buttonFrame];
		
		/*position the button and a shadow layer behind it:*/
		if(b < 16)
		{
			[[buttonSubviews objectAtIndex: b] setFrame: buttonFrame];
			[[buttonShadowLayers objectAtIndex: b] setFrame: CGRectMake(buttonFrame.origin.x - 10, buttonFrame.origin.y - 10, buttonFrame.size.width + 20, buttonFrame.size.height + 20)];
		}
		
		/*special treatment for the 'equals' button - as its an oblong:*/
		else 
		{
			[[buttonSubviews objectAtIndex: b] setFrame: buttonFrame];
			[[buttonShadowLayers objectAtIndex: b] setFrame: CGRectMake(buttonFrame.origin.x - 10, buttonFrame.origin.y - 10, buttonFrame.size.width + 20, buttonFrame.size.height + 20)];
		}
		
		[[buttonShadowLayers objectAtIndex: b] removeAllAnimations];
	}
	
	/*in just one configuration, the extreme portrait mode ('3'), there can sometimes be empty space below the buttons. If this is the case, fill it with a nice embossed effect Paductivity logo:*/
	if(buttonsLayoutConfig == 3)
	{
		CGRect buttonsArea = CGRectMake(drawableSpace.origin.x, drawableSpace.origin.y, numButtonsI * buttonDimension + (numButtonsI * 2), numButtonsJ * buttonDimension + (numButtonsJ * 2));
		
		if([niceEmbossedLogoLayer isHidden] == YES) [niceEmbossedLogoLayer setHidden: NO];
		
		/*if there is not much space available for it, then draw the embossed logo as if it is scrolling. If there is more space than needed, then centre it in the space available:*/
		if( (self.bounds.size.height - (buttonsArea.origin.y + buttonsArea.size.height)) < (buttonDimension + buttonsArea.size.width) )
		{
			[niceEmbossedLogoLayer setFrame: CGRectMake(buttonsArea.origin.x, buttonsArea.origin.y + buttonsArea.size.height + (int)(0.5 * buttonDimension), buttonsArea.size.width, buttonsArea.size.width)];	
		}
		else [niceEmbossedLogoLayer setFrame: CGRectMake(buttonsArea.origin.x, buttonsArea.origin.y + buttonsArea.size.height + (int)(0.5 * (self.bounds.size.height - (buttonsArea.origin.y + buttonsArea.size.height + buttonsArea.size.width))), buttonsArea.size.width, buttonsArea.size.width)];
		
		[niceEmbossedLogoLayer removeAllAnimations];
	}
	
	else if([niceEmbossedLogoLayer isHidden] == NO) [niceEmbossedLogoLayer setHidden: YES];
}



/*
	given the current constant dimensions of the buttons, this method generates the graphics as CGImageRef's, which they will all use:
*/
- (void)generateButtonGraphicsForCurrentLayout
{
	CGContextRef bitmapContext = CGBitmapContextCreate(NULL, buttonDimension, buttonDimension, 8, buttonDimension*4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	CGContextRef largerShadowBitmapContext = CGBitmapContextCreate(NULL, buttonDimension + 20, buttonDimension + 20, 8, (buttonDimension + 20)*4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	
	
	/*First, draw the light-colored 'off' mode button:*/
	CGContextSetRGBFillColor(bitmapContext, 0.0, 0.0, 0.0, 1.0);
	CGContextBeginPath(bitmapContext);
	[utilities drawRoundedRect: bitmapContext rect: CGRectMake(0.0, 0.0, buttonDimension, buttonDimension) radius: (int)(0.13 * buttonDimension)];
	CGContextFillPath(bitmapContext);
	
	CGContextSetRGBFillColor(bitmapContext, 1.0, 1.0, 1.0, 1.0);
	CGContextBeginPath(bitmapContext);
	[utilities drawRoundedRect: bitmapContext rect: CGRectMake(1, 1, buttonDimension - 2, (int)(0.5*(buttonDimension - 2))) radius: (int)(0.13 * buttonDimension)];
	CGContextFillPath(bitmapContext);
	
	CGContextSetRGBFillColor(bitmapContext, 0.4, 0.4, 0.43, 1.0);
	CGContextBeginPath(bitmapContext);
	[utilities drawRoundedRect: bitmapContext rect: CGRectMake(1, buttonDimension - 1 - (int)(0.5*(buttonDimension - 2)), buttonDimension - 2, (int)(0.5*(buttonDimension - 2))) radius: (int)(0.13 * buttonDimension)];
	CGContextFillPath(bitmapContext);
	
	CGGradientRef buttonGradient;
	CGFloat buttonGradLocs[] = {0.0, 1.0};
	CGFloat buttonGradComps[] = {0.9, 0.9, 0.9, 1.0, 0.7, 0.7, 0.75, 1.0};
	
	CGContextSaveGState(bitmapContext);
	CGContextBeginPath(bitmapContext);
	
	[utilities drawRoundedRect:bitmapContext rect: CGRectMake(1, 3, buttonDimension - 2, buttonDimension - 6) radius: (int)(0.13 * buttonDimension)];
	
	CGContextClosePath(bitmapContext);
	CGContextClip(bitmapContext);
	
	buttonGradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), buttonGradComps, buttonGradLocs, 2);
	CGContextDrawLinearGradient(bitmapContext, buttonGradient, CGPointMake(1, 2), CGPointMake(1, buttonDimension - 4), kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(buttonGradient);
	
	
	CGContextRestoreGState(bitmapContext);
	
	/*fix this as a CGImage:*/
	buttonGraphics_light_off = CGBitmapContextCreateImage(bitmapContext);
	
	
	/*next draw the light-colored 'on' mode button:*/
	CGContextClearRect(bitmapContext, CGRectMake(0, 0, buttonDimension, buttonDimension));
	
	CGContextSetRGBFillColor(bitmapContext, 0.0, 0.0, 0.0, 1.0);
	CGContextBeginPath(bitmapContext);
	[utilities drawRoundedRect: bitmapContext rect: CGRectMake(0.0, 0.0, buttonDimension, buttonDimension) radius: (int)(0.13 * buttonDimension)];
	CGContextFillPath(bitmapContext);
	
	CGContextSetRGBFillColor(bitmapContext, 0.4, 0.4, 0.43, 1.0);
	CGContextBeginPath(bitmapContext);
	[utilities drawRoundedRect: bitmapContext rect: CGRectMake(1, 1, buttonDimension - 2, (int)(0.5*(buttonDimension - 2))) radius: (int)(0.13 * buttonDimension)];
	CGContextFillPath(bitmapContext);
	
	CGContextSetRGBFillColor(bitmapContext, 0.8, 0.8, 0.8, 1.0);
	CGContextBeginPath(bitmapContext);
	[utilities drawRoundedRect: bitmapContext rect: CGRectMake(1, buttonDimension - 1 - (int)(0.5*(buttonDimension - 2)), buttonDimension - 2, (int)(0.5*(buttonDimension - 2))) radius: (int)(0.13 * buttonDimension)];
	CGContextFillPath(bitmapContext);
	
	
	buttonGradComps[0] = 0.6;
	buttonGradComps[1] = 0.6;
	buttonGradComps[2] = 0.65;
	buttonGradComps[4] = 0.7;
	buttonGradComps[5] = 0.7;
	buttonGradComps[6] = 0.7;
	
	CGContextSaveGState(bitmapContext);
	CGContextBeginPath(bitmapContext);
	
	[utilities drawRoundedRect:bitmapContext rect: CGRectMake(1, 3, buttonDimension - 2, buttonDimension - 6) radius: (int)(0.13 * buttonDimension)];
	
	CGContextClosePath(bitmapContext);
	CGContextClip(bitmapContext);
	
	buttonGradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), buttonGradComps, buttonGradLocs, 2);
	CGContextDrawLinearGradient(bitmapContext, buttonGradient, CGPointMake(1, 2), CGPointMake(1, buttonDimension - 4), kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(buttonGradient);
	
	CGContextRestoreGState(bitmapContext);
	
	/*fix this as a CGImage:*/
	buttonGraphics_light_on = CGBitmapContextCreateImage(bitmapContext);
	
	
	/*Now draw the dark-colored 'off' mode button:*/
	CGContextClearRect(bitmapContext, CGRectMake(0, 0, buttonDimension, buttonDimension));
	
	CGContextSetRGBFillColor(bitmapContext, 0.0, 0.0, 0.0, 1.0);
	CGContextBeginPath(bitmapContext);
	[utilities drawRoundedRect: bitmapContext rect: CGRectMake(0.0, 0.0, buttonDimension, buttonDimension) radius: (int)(0.13 * buttonDimension)];
	CGContextFillPath(bitmapContext);
	
	CGContextSetRGBFillColor(bitmapContext, 0.8, 0.8, 0.8, 1.0);
	CGContextBeginPath(bitmapContext);
	[utilities drawRoundedRect: bitmapContext rect: CGRectMake(1, 1, buttonDimension - 2, (int)(0.5*(buttonDimension - 2))) radius: (int)(0.13 * buttonDimension)];
	CGContextFillPath(bitmapContext);
	
	CGContextSetRGBFillColor(bitmapContext, 0.2, 0.2, 0.23, 1.0);
	CGContextBeginPath(bitmapContext);
	[utilities drawRoundedRect: bitmapContext rect: CGRectMake(1, buttonDimension - 1 - (int)(0.5*(buttonDimension - 2)), buttonDimension - 2, (int)(0.5*(buttonDimension - 2))) radius: (int)(0.13 * buttonDimension)];
	CGContextFillPath(bitmapContext);
	
	
	buttonGradComps[0] = 0.6;
	buttonGradComps[1] = 0.6;
	buttonGradComps[2] = 0.6;
	buttonGradComps[4] = 0.4;
	buttonGradComps[5] = 0.4;
	buttonGradComps[6] = 0.45;
	
	CGContextSaveGState(bitmapContext);
	CGContextBeginPath(bitmapContext);
	
	[utilities drawRoundedRect:bitmapContext rect: CGRectMake(1, 3, buttonDimension - 2, buttonDimension - 6) radius: (int)(0.13 * buttonDimension)];
	
	CGContextClosePath(bitmapContext);
	CGContextClip(bitmapContext);
	
	buttonGradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), buttonGradComps, buttonGradLocs, 2);
	CGContextDrawLinearGradient(bitmapContext, buttonGradient, CGPointMake(1, 2), CGPointMake(1, buttonDimension - 4), kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(buttonGradient);
	
	CGContextRestoreGState(bitmapContext);
	
	/*fix this as a CGImage:*/
	buttonGraphics_dark_off = CGBitmapContextCreateImage(bitmapContext);
	
	
	/*First, draw the dark-colored 'on' mode button:*/
	CGContextClearRect(bitmapContext, CGRectMake(0, 0, buttonDimension, buttonDimension));
	
	CGContextSetRGBFillColor(bitmapContext, 0.0, 0.0, 0.0, 1.0);
	CGContextBeginPath(bitmapContext);
	[utilities drawRoundedRect: bitmapContext rect: CGRectMake(0.0, 0.0, buttonDimension, buttonDimension) radius: (int)(0.13 * buttonDimension)];
	CGContextFillPath(bitmapContext);
	
	CGContextSetRGBFillColor(bitmapContext, 0.2, 0.2, 0.23, 1.0);
	CGContextBeginPath(bitmapContext);
	[utilities drawRoundedRect: bitmapContext rect: CGRectMake(1, 1, buttonDimension - 2, (int)(0.5*(buttonDimension - 2))) radius: (int)(0.13 * buttonDimension)];
	CGContextFillPath(bitmapContext);
	
	CGContextSetRGBFillColor(bitmapContext, 0.6, 0.6, 0.6, 1.0);
	CGContextBeginPath(bitmapContext);
	[utilities drawRoundedRect: bitmapContext rect: CGRectMake(1, buttonDimension - 1 - (int)(0.5*(buttonDimension - 2)), buttonDimension - 2, (int)(0.5*(buttonDimension - 2))) radius: (int)(0.13 * buttonDimension)];
	CGContextFillPath(bitmapContext);
	
	
	buttonGradComps[0] = 0.4;
	buttonGradComps[1] = 0.4;
	buttonGradComps[2] = 0.45;
	buttonGradComps[4] = 0.5;
	buttonGradComps[5] = 0.5;
	buttonGradComps[6] = 0.5;
	
	CGContextSaveGState(bitmapContext);
	CGContextBeginPath(bitmapContext);
	
	[utilities drawRoundedRect:bitmapContext rect: CGRectMake(1, 3, buttonDimension - 2, buttonDimension - 6) radius: (int)(0.13 * buttonDimension)];
	
	CGContextClosePath(bitmapContext);
	CGContextClip(bitmapContext);
	
	buttonGradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), buttonGradComps, buttonGradLocs, 2);
	CGContextDrawLinearGradient(bitmapContext, buttonGradient, CGPointMake(1, 2), CGPointMake(1, buttonDimension - 4), kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(buttonGradient);
	
	CGContextRestoreGState(bitmapContext);
	
	/*fix this as a CGImage:*/
	buttonGraphics_dark_on = CGBitmapContextCreateImage(bitmapContext);
	
	
	/*now generate the shadow image that will slip beneath each button:*/
	CGContextClearRect(bitmapContext, CGRectMake(0, 0, buttonDimension + 10, buttonDimension + 10));
	
	
	
	CGContextSaveGState(largerShadowBitmapContext);
	float shadowColorComponents[] = {0.0, 0.0, 0.0, 0.7};
	CGColorRef shadowCGColorRef = CGColorCreate(CGColorSpaceCreateDeviceRGB(), shadowColorComponents);
	
	CGContextSetShadowWithColor(largerShadowBitmapContext, CGSizeMake(0, -0.75 * (int)(0.04 * buttonDimension)), (int)(0.04 * buttonDimension), shadowCGColorRef);
	
	CGContextSetRGBFillColor(largerShadowBitmapContext, 0.0, 0.0, 0.0, 1.0);
	
	CGContextBeginPath(largerShadowBitmapContext);
	[utilities drawRoundedRect: largerShadowBitmapContext rect: CGRectMake(10, 10, buttonDimension, buttonDimension) radius: (int)(0.13 * buttonDimension)];
	CGContextFillPath(largerShadowBitmapContext);
	
	CGContextRestoreGState(largerShadowBitmapContext);
	
	buttonGraphics_shadow = CGBitmapContextCreateImage(largerShadowBitmapContext);
	

	/*Clean up:*/
	CGColorRelease(shadowCGColorRef);
	CGContextRelease(bitmapContext);
	CGContextRelease(largerShadowBitmapContext);
}


/*	
	This will be called by the button subviews - to request the CGImage that they need to draw their UIs
*/
- (CGImageRef)returnButtonGraphicsForType:(int)typeToReturn;
{
	if(typeToReturn == 0) return buttonGraphics_light_off;
	if(typeToReturn == 1) return buttonGraphics_light_on;
	if(typeToReturn == 2) return buttonGraphics_dark_off;
	if(typeToReturn == 3) return buttonGraphics_dark_on;
}


/*
	setScreenDigits - this method takes the currentNumber, and does everything necessary to draw it as digits to the screen:
*/
- (void)setScreenDigits
{
	[screenDigits drawDigitsForNumber: digitDisplayArray ofLength: numDigits andDecimalPointPos: decimalPointPos isNegative: 1 - screenNumberIsPositive];
}


/*
	drawRect - Here the mini app view draws itself
 */
- (void)drawRect:(CGRect)rect
{
	CGContextRef theContext = UIGraphicsGetCurrentContext();
	
	/*if in normal mode, then just draw background gradient as usual: (and update the size of the offscreen buffer to reflect the current size of this view)*/
	if(drawOffScreenContentToScreen == 0) 
	{
		[self setupOffScreenContentLayer: theContext withSize: self.bounds.size];
		[self drawToContext: theContext];
	}
	
	/*when this view contracts, is simply draws a layer which has a flat, all inclusive,  version of the UI:*/
	else 
	{
		CGContextSetRGBFillColor(theContext, 0.0, 0.0, 0.0, 1.0);
		CGContextFillRect(theContext, [self bounds]);
		CGContextDrawLayerInRect(theContext, [self bounds], offScreenContent);
	}
}


/*
	drawToContext - this method does all the drawing for the view - it simply draws everything to the context provided:
 */
- (void)drawToContext: (CGContextRef)theContext
{
	/*draw nice gradient for background:*/
	CGGradientRef bkgdGradient;
	CGColorSpaceRef bkgdGradientColorSpace;
	CGFloat bkgdGradLocs[] = {0.0, 1.0};
	CGFloat bkgdGradComps[] = {0.65, 0.7, 0.65, 1.0, 0.4, 0.4, 0.45, 1.0};
	
	bkgdGradientColorSpace = CGColorSpaceCreateDeviceRGB();
	bkgdGradient = CGGradientCreateWithColorComponents(bkgdGradientColorSpace, bkgdGradComps, bkgdGradLocs, 2);
	
	/*draw it to the context provided:*/
	CGContextDrawLinearGradient(theContext, bkgdGradient, CGPointMake(0.0, 0.0), CGPointMake(0.0, self.bounds.size.height), kCGGradientDrawsAfterEndLocation);
	
	/*clean up:*/
	CGColorRelease(bkgdGradientColorSpace);
	CGGradientRelease(bkgdGradient);
}


/*******************************************************************************************************************
 
 METHODS RELATING TO THE THE ACTUAL CALCULATOR FUNCTIONALITY
 
 ********************************************************************************************************************/
/*
	this method will be called by a button subview if it gets pressed. the button in will pass its id as a parameter. Based on the current state of input, operations in progress etc, this method will process the button's function appropriately:
*/
- (void)buttonEvent: (int)buttonId
{
	/*If this button was a number, and we're in either integer or fraction entry mode, then add this number to change the current number appropriately, then draw the digits to the view. If we're in 'result' mode, then clear the current result number and start from scratch:*/
	if(buttonId <= 9)
	{
		if(actionMode == 0)
		{
			/*no more than 6 integer and 6 fractional components:*/
			if(numDigits <= 8)
			{
				digitDisplayArray[numDigits++] = buttonId;
				[self setScreenDigits];
			}
		}
		
		else if(actionMode == 1)
		{
			if((numDigits) <= 8)
			{
				digitDisplayArray[numDigits ++] = buttonId;
				[self setScreenDigits];
			}
		}
		
		else if(actionMode == 2)
		{
			/*you can't start a number with a zero:*/
			if(buttonId != 0)
			{
				screenNumberIsPositive = 1;
				digitDisplayArray[0] = buttonId;
				numDigits = 1;
				decimalPointPos = -1;
			
				actionMode = 0;
			
				[self setScreenDigits];
			}
		}
		
		if(actionMode == 3)
		{
			/*you can't start a number with a zero:*/
			if(buttonId != 0)
			{
				screenNumberIsPositive = 1;
				digitDisplayArray[0] = buttonId;
				numDigits = 1;
				decimalPointPos = -1;
			
				actionMode = 0;
			
				[self setScreenDigits];
			}
		}
	}
	
	/*if any of the plus/minus/multiply/divide buttons are pressed, then we are now in an operation mode. If there is an operation in progress, then carry it out and record its result just like as if the equals button has been pressed. Either way, record the operation, record the current number as the primary operand, and set the current number back to 0 to await user input:*/
	if((buttonId >= 10) && (buttonId <= 13))
	{
		/*if this hasbeen pressed just after a previous operation, then do nothing:*/
		if(actionMode != 2)
		{
			/*If an operation is in progress then this will be the start of another, so carry out the previous operation as though the equals button was pressed, display the result and use as the primary operand to this new operation*/
			if(operationInProgress != -1)
			{
				double currentNumber = [self convertNumberToDouble];
				double operationResult;
			
				/* calculate the result of the current operation:*/
				if(operationInProgress == 0) operationResult = primaryOperand + currentNumber;
				if(operationInProgress == 1) operationResult = primaryOperand - currentNumber;
				if(operationInProgress == 2) operationResult = primaryOperand * currentNumber;
				if(operationInProgress == 3) operationResult = primaryOperand / currentNumber;
			
				/*now display this result on screen:*/
				[self convertDoubleToScreenDigits: operationResult];
			
				[self setScreenDigits];
			}
		
			primaryOperand = [self convertNumberToDouble];
		
			operationInProgress = buttonId - 10;
		
			actionMode = 2;
		}
	}
	
	/*if the user has hit the clear button, then set everything back to the start:*/
	if(buttonId == 14)
	{
		screenNumberIsPositive = 1;
		digitDisplayArray[0] = 0;
		numDigits = 1;
		decimalPointPos = -1;
		
		actionMode = 3;
		
		
		operationInProgress = -1;
		
		[self setScreenDigits];
	}
	
	/*if the decimal point button was pressed, and we are currently in integer entry mode, or 'left-over' mode, then switch to fractional entry mode:*/
	if(buttonId == 15)
	{
		if(actionMode == 0)
		{
			actionMode = 1;
			decimalPlaces = 0;
			decimalPointPos = numDigits - 1;
		
			[self setScreenDigits];
		}
		
		if(actionMode == 2)
		{
			screenNumberIsPositive = 1;
			digitDisplayArray[0] = 0;
			numDigits = 1;
			decimalPlaces = 0;
			decimalPointPos = numDigits - 1;
			
			actionMode = 1;
			
			[self setScreenDigits];
		}
		
		if(actionMode == 3)
		{
			if(decimalPointPos == -1)
			{
				actionMode = 1;
				decimalPlaces = 0;
				decimalPointPos = numDigits - 1;
				
				[self setScreenDigits];
			}
		}
	}
	
	/*if the user hits the equals button, then *if* we are in an operation mode, then we carry out the operation in progress using the primary operand and the current number, then display the result to the user:*/
	if(buttonId == 16)
	{
		if(operationInProgress != -1)
		{
			double currentNumber = [self convertNumberToDouble];
			double operationResult;
			
			/*if the user has hit the '=' button without entering a second operand, then just return the first operand as the result:*/
			if(actionMode == 2)
			{
				operationResult = primaryOperand;
			}
			
			/*otherwise (more likely), calculate the result of the current operation:*/
			else 
			{
				if(operationInProgress == 0) operationResult = primaryOperand + currentNumber;
				if(operationInProgress == 1) operationResult = primaryOperand - currentNumber;
				if(operationInProgress == 2) operationResult = primaryOperand * currentNumber;
				if(operationInProgress == 3) operationResult = primaryOperand / currentNumber;
			}
			
			/*now display this result on screen:*/
			[self convertDoubleToScreenDigits: operationResult];
		}
		
		operationInProgress = -1;
		actionMode = 3;
		
		[self setScreenDigits];
	}
}


/*
	convertNumberToDouble - takes our internal array-representation of the current number and converts it into a normal double data type:
 */
-(double)convertNumberToDouble
{
	int highestOrderOfMagnitude;
	double convertedNumber = 0.0;
	
	if(decimalPointPos == -1) highestOrderOfMagnitude = numDigits - 1;
	else highestOrderOfMagnitude = decimalPointPos;
	
	for(int i = 0; i < numDigits; i++)
	{
		convertedNumber += (double)(digitDisplayArray[i]) * (double)(pow(10, highestOrderOfMagnitude - i));
	}
	
	if(screenNumberIsPositive == 0) convertedNumber *= -1.0;
	
	
	return convertedNumber;
}


/*
	convertDoubleToScreenDigits - simply takes a double-precision float, converts it into a sequence if digits and copies these digits into our screen digits member variable:
 */
-(void)convertDoubleToScreenDigits: (double)in_double
{
	int doubleOrderOfMagnitude;
	int doubleDecimalPlaces;
	
	/*get the abolute value of the current number, ignoring minus sign:*/
	double in_double_abs = in_double;
	if(in_double_abs < 0) in_double_abs *= -1.0;
	
	/*get the double in sequential string form:*/
	char numberStr[50];
	sprintf(numberStr, "%f", in_double_abs);
	
	
	/*determine the order of magnitude of the number (number of digits to the left of the decimal point)*/
	for(int i = 0; i < 7; i++)
	{
		if(numberStr[i] == '.') 
		{
			doubleOrderOfMagnitude = i;
		}
	}
	
	/*determine how many decimal places:*/
	doubleDecimalPlaces = 0;
	decimalPointPos = -1;
	for(int i = 6; i > 0; i--)
	{
		if(numberStr[doubleOrderOfMagnitude + i] != '0')
		{
			doubleDecimalPlaces = i;
			break;
		}
	}
	if(doubleDecimalPlaces > 0) decimalPointPos = doubleOrderOfMagnitude - 1;
	
	/*put the digits into the array for drawing:*/
	for(int i = 0; i < doubleOrderOfMagnitude; i++) digitDisplayArray[i] = numberStr[i] - 48;
	for(int i = 0; i < doubleDecimalPlaces; i++)	digitDisplayArray[doubleOrderOfMagnitude + i] = numberStr[doubleOrderOfMagnitude + 1 + i] - 48;
	
	numDigits = doubleOrderOfMagnitude + doubleDecimalPlaces;
	screenNumberIsPositive = (in_double >= 0)? 1:0;
	
}



/*******************************************************************************************************************
 
 STANDARD TOUCH EVENT HANDLING METHODS
 
 ********************************************************************************************************************/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	/*handle touch functionality. ignore if this mini app is disabled:*/
	if(miniAppIsDisabled == 0)
	{
		if([[event touchesForView: self] count] == 1)
		{
			CGPoint touchPos = [[[touches allObjects] objectAtIndex: 0] locationInView: self];
			calculatorButtonView *buttonView;
		
			/*did the touch fall inside any of the buttons?*/
			for(int i = 0; i < [buttonSubviews count]; i++)
			{
				buttonView = [buttonSubviews objectAtIndex: i];
				
				if( (touchPos.x > buttonView.frame.origin.x)&&(touchPos.x < (buttonView.frame.origin.x + buttonView.frame.size.width))&&(touchPos.y > buttonView.frame.origin.y)&&(touchPos.y < (buttonView.frame.origin.y + buttonView.frame.size.height)) )
				{
					/*press button graphics in:*/
					[buttonView setPressed: YES];
					[[buttonShadowLayers objectAtIndex: i] setHidden: YES];
					[[buttonShadowLayers objectAtIndex: i] removeAllAnimations];
				
					/*record that this exact touch that pressed this button:*/
					pressedButtonTouch = [[touches allObjects] objectAtIndex: 0];
					pressedButton = i;
				
					/*carry out the actual function of the button:*/
					[self buttonEvent: i];
					
					break;
				}
			}
		}
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	/*handle touch functionality. ignore if this mini app is disabled:*/
	if(miniAppIsDisabled == 0)
	{
		/*check to see if this touch up means the end of a single touch event that was pressing button:*/
		if(pressedButtonTouch != nil)
		{
			for(int i = 0; i < [[touches allObjects] count]; i++)
			{
				if([[touches allObjects] objectAtIndex: i] == pressedButtonTouch)
				{
					[[buttonSubviews objectAtIndex: pressedButton] setPressed: NO];
					[[buttonShadowLayers objectAtIndex: pressedButton] setHidden: NO];
					[[buttonShadowLayers objectAtIndex: pressedButton] removeAllAnimations];
				
					pressedButtonTouch = nil;
					break;
				}
			}
		}
	}
}


/*******************************************************************************************************************
 
 VARIOUS MINI APP - SPECIFIC IMPLEMENTATIONS OF STANDARD TRANSFORMATION METHODS PLUS EXTRA RELATED METHODS
 
********************************************************************************************************************/

/*
	redrawContentInSettledFrame - this will be called by any of our event handling functions when the mini app's frame has stopped changing frequently enough that it is worth redrawing the mini app content in full
 */
- (void)redrawContentInSettledFrame
{
	/*let the layoutSubviews method know that next time it is called it should regenerate and apply the button graphics: (this must happen *after* the latest layout has been applied)*/
	redrawContentInSettledFrame_ready = 1;
	
	/*make sure the system knows to carry out layout as soon as it can!*/
	[self setNeedsLayout];
	[self setNeedsDisplay];
}




/*
	this view's implementation of the method to change the bounds and center
 */
- (void)animateChangeOfBoundsAndCenter: (float)duration toBounds: (CGRect)newBounds andCenter: (CGPoint)newCenter
{
	CGRect drawableSpace;
	int buttonsLayoutConfig;
	int numButtonsI, numButtonsJ;	
	int buttonDimensionValue;
	int keyLayoutBound;
	
	/*first of all, for each button determine where it will appear in the new frame for this view:*/
	[self determineButtonLayoutInfoForFrame: newBounds drawableSpace: &drawableSpace buttonsLayoutConfig: &buttonsLayoutConfig numButtonsI: &numButtonsI numButtonsJ: &numButtonsJ buttonDimension: &buttonDimensionValue keyLayoutBound: &keyLayoutBound]; 
	buttonDimension = buttonDimensionValue;
	
	CGRect buttonNewFrame;
	
	CGRect shadowCurrentBounds = [[buttonShadowLayers objectAtIndex: 0] bounds];
	CGPoint shadowCurrentPos;
	
	CGRect shadowNewBounds = CGRectMake(0, 0, buttonDimension + 20, buttonDimension + 20);
	CGPoint shadowNewPos;
	
	for(int b = 0; b < 17; b++)
	{
		[self determineButtonFrameGivenIndex: b drawableSpace: drawableSpace buttonsLayoutConfig: buttonsLayoutConfig numButtonsI: numButtonsI numButtonsJ: numButtonsJ buttonDimension: buttonDimension keyLayoutBound: keyLayoutBound frame: &buttonNewFrame];
		
		/*set the view of the button to animate to its new position:*/
		[UIView animateWithDuration: duration animations: ^{ [[buttonSubviews objectAtIndex: b] setFrame: buttonNewFrame]; } ];
		
		/*now apply animation to the shadows:*/
		shadowCurrentPos = [[buttonShadowLayers objectAtIndex: b] position];
		shadowNewPos = CGPointMake(buttonNewFrame.origin.x + (int)(0.5 * buttonNewFrame.size.width), buttonNewFrame.origin.y + (int)(0.5 * buttonNewFrame.size.height));
		
		[[buttonShadowLayersAnims objectAtIndex: b*2 + 0] setDuration: duration];
		[[buttonShadowLayersAnims objectAtIndex: b*2 + 0] setFromValue: [NSValue value:&shadowCurrentBounds withObjCType:@encode(CGRect)]];
		[[buttonShadowLayersAnims objectAtIndex: b*2 + 0] setToValue: [NSValue value:&shadowNewBounds withObjCType:@encode(CGRect)]];
		[[buttonShadowLayersAnims objectAtIndex: b*2 + 1] setDuration: duration];
		[[buttonShadowLayersAnims objectAtIndex: b*2 + 1] setFromValue: [NSValue value:&shadowCurrentPos withObjCType:@encode(CGPoint)]];
		[[buttonShadowLayersAnims objectAtIndex: b*2 + 1] setToValue: [NSValue value:&shadowNewPos withObjCType:@encode(CGPoint)]];
		
		[[buttonShadowLayers objectAtIndex: b] setFrame: shadowNewBounds];
		[[buttonShadowLayers objectAtIndex: b] setPosition: shadowNewPos];
		[[buttonShadowLayers objectAtIndex: b] addAnimation: [buttonShadowLayersAnims objectAtIndex: b*2 + 0] forKey:@"bounds"];
		[[buttonShadowLayers objectAtIndex: b] addAnimation: [buttonShadowLayersAnims objectAtIndex: b*2 + 1] forKey:@"position"];
	}
	
	/*animate the screen elements as well (if neccessary):*/
	if(newBounds.size.width != self.bounds.size.width)
	{
		/*Screen Base*/
		CGRect screenBaseCurrentBounds = [screenBase bounds];
		CGRect screenBaseNewBounds = CGRectMake(0, 0, newBounds.size.width - 40, 100);
		
		[screenBaseAnim setDuration: duration];
		[screenBaseAnim setFromValue: [NSValue value: &screenBaseCurrentBounds withObjCType: @encode(CGRect)]];
		[screenBaseAnim setToValue: [NSValue value: &screenBaseNewBounds withObjCType: @encode(CGRect)]];
		
		[screenBase setBounds: screenBaseNewBounds];
		[screenBase addAnimation: screenBaseAnim forKey: @"bounds"];
		
		/*Screen digits view:*/
		CGRect screenDigitsViewNewFrame = CGRectMake(30, 30, newBounds.size.width - 60, 90);
		
		CGPoint screenDigitsSublayerOldPos = [[screenDigits contentSublayer] position];
		CGPoint screenDigitsSublayerNewPos = CGPointMake(screenDigitsSublayerOldPos.x + screenDigitsViewNewFrame.size.width - [screenDigits frame].size.width, screenDigitsSublayerOldPos.y);
		[screenDigitsSublayerAnim setDuration: duration];
		[screenDigitsSublayerAnim setFromValue: [NSValue value: &screenDigitsSublayerOldPos withObjCType: @encode(CGPoint)]];
		[screenDigitsSublayerAnim setToValue: [NSValue value: &screenDigitsSublayerNewPos withObjCType: @encode(CGPoint)]];
		[[screenDigits contentSublayer] setPosition: screenDigitsSublayerNewPos];
		[[screenDigits contentSublayer] addAnimation: screenDigitsSublayerAnim forKey: @"position"];
		
		[screenDigits setLayoutStyle: 1];
		[UIView animateWithDuration: duration animations: ^{ [screenDigits setFrame: screenDigitsViewNewFrame]; } completion: ^(BOOL finished) { [screenDigits setLayoutStyle: 0]; }];
		
		/*it is possible that the new size for the screen digits view will require different size digits. Notify the screenDigits view so that *if necessary* it can animate this change:*/
		[screenDigits animateDigitsIfNecessaryForNewFrame: screenDigitsViewNewFrame withDuration: duration];
		
		/*Screen Sheen:*/
		CGRect screenSheenCurrentBounds = [screenSheen bounds];
		CGRect screenSheenNewBounds = CGRectMake(0, 0, newBounds.size.width - 50, 90);
		
		[screenSheenAnim setDuration: duration];
		[screenSheenAnim setFromValue: [NSValue value: &screenSheenCurrentBounds withObjCType: @encode(CGRect)]];
		[screenSheenAnim setToValue: [NSValue value: &screenSheenNewBounds withObjCType: @encode(CGRect)]];
		
		[screenSheen setBounds: screenSheenNewBounds];
		[screenSheen addAnimation: screenSheenAnim forKey: @"bounds"];
	}
		
	/*ensure no complex layoutSubviews code is run:*/
	disableManualLayout = 1;
	
	/*finally set off the animation for this, the main view itself. Ensure that when the animation completes, everything is redrawn at the new resolution and set back to rights:*/
	[UIView animateWithDuration: duration animations: ^{ [self setBounds: newBounds]; [self setCenter: newCenter]; } completion: ^(BOOL finished) {disableManualLayout = 0; [self redrawContentInSettledFrame]; } ];
}


/*
	contract - this method will be called by the parent when this app needs to quit and close itself:
*/
- (void)contract:(float)duration
{
	/*instruct the main view layer to draw our flat offscreen image of the UI:*/
	[self drawFullUIIntoOffScreenLayer];
	
	
	drawOffScreenContentToScreen = 1;
	[self setNeedsDisplay];
		

	/*and switch off all our sub layers (except the darkenTopLayer if this miniApp is currently disabled) and views so that we are purely displaying this flat image now:*/
	for(int i = 0; i < [[self subviews] count]; i++) [[[self subviews] objectAtIndex: i] setHidden: YES];
	for(int i = 0; i < [[[self layer] sublayers] count]; i++)
	{
		if((miniAppIsDisabled == 1)&&([[[self layer] sublayers] objectAtIndex: i] == darkenTopLayer)) continue;
		
		[[[[self layer] sublayers] objectAtIndex: i] setHidden: YES];
		[[[[self layer] sublayers] objectAtIndex: i] removeAllAnimations];
	}
	
	/*set off final anim - (there is a delay of 0 seconds simply to force the system to process our animation *after* updating layout/display)*/
	[NSTimer scheduledTimerWithTimeInterval: 0.0 target: self selector: @selector(contractAnimation:) userInfo: [NSNumber numberWithFloat: duration] repeats: NO ];
}


/*
	just a wrapper that allows me to set the view anim call off after a small timer delay, which allows control over the order in which certain anim and draw events occur
 */
- (void)contractAnimation: (NSTimer *)theTimer
{
	[UIView animateWithDuration: [[theTimer userInfo] floatValue] animations: ^{[self setFrame: CGRectMake(self.frame.origin.x + (int)(0.5 * self.frame.size.width), self.frame.origin.y + (int)(0.5 * self.frame.size.height), 0, 0)]; } ];
}


/*
	takes the current state of the UI with all its subviews and layers and flattens them down to one bitmap image, contained in a CGLayer
*/
- (void)drawFullUIIntoOffScreenLayer
{
	/*start by drawing this, the background of the view:*/
	[self drawToContext: offScreenContentContext];
	
	
	CGContextRef CALayerContentsContext;
	CGImageRef CALayerContentsImage;
	
	/*draw the screen background:*/
	CALayerContentsContext = CGBitmapContextCreate(NULL, [screenBase bounds].size.width, [screenBase bounds].size.height, 8, [screenBase bounds].size.width*4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	[screenBase renderInContext: CALayerContentsContext];
	CALayerContentsImage = CGBitmapContextCreateImage(CALayerContentsContext);
	CGContextDrawImage(offScreenContentContext, [screenBase frame], CALayerContentsImage);
	
	CGContextRelease(CALayerContentsContext);
	CGImageRelease(CALayerContentsImage);
	
	/*draw the screen digits:*/
	CALayerContentsContext = CGBitmapContextCreate(NULL, [[screenDigits contentSublayer] bounds].size.width, [[screenDigits contentSublayer] bounds].size.height, 8, [[screenDigits contentSublayer] bounds].size.width*4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast); 
	[[screenDigits contentSublayer] renderInContext: CALayerContentsContext];
	CALayerContentsImage = CGBitmapContextCreateImage(CALayerContentsContext);
	CGContextDrawImage(offScreenContentContext, CGRectMake([screenDigits frame].origin.x + [[screenDigits contentSublayer] frame].origin.x, [screenDigits frame].origin.y, [[screenDigits contentSublayer] bounds].size.width, [[screenDigits contentSublayer] bounds].size.height), CALayerContentsImage);
	CGContextRelease(CALayerContentsContext);
	CGImageRelease(CALayerContentsImage);
	
	/*draw the screen sheen:*/
	CALayerContentsContext = CGBitmapContextCreate(NULL, [screenSheen bounds].size.width, [screenSheen bounds].size.height, 8, [screenSheen bounds].size.width*4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	[screenSheen renderInContext: CALayerContentsContext];
	CALayerContentsImage = CGBitmapContextCreateImage(CALayerContentsContext);
	CGContextDrawImage(offScreenContentContext, [screenSheen frame], CALayerContentsImage);
	
	CGContextRelease(CALayerContentsContext);
	CGImageRelease(CALayerContentsImage);
	
	/*draw the buttons shadows:*/
	CGContextSaveGState(offScreenContentContext);
	CGContextScaleCTM(offScreenContentContext, 1.0, -1.0);
	CGContextTranslateCTM(offScreenContentContext, 0.0, -1.0 * self.bounds.size.height);
	
	for(int i = 0; i < [buttonShadowLayers count]; i++) 
	{
		CGRect shadowLayerFrame = [[buttonShadowLayers objectAtIndex: i] frame];
		CGContextDrawImage(offScreenContentContext, CGRectMake(shadowLayerFrame.origin.x, self.bounds.size.height - shadowLayerFrame.origin.y - shadowLayerFrame.size.height, shadowLayerFrame.size.width, shadowLayerFrame.size.height), buttonGraphics_shadow);
		
	}
	CGContextRestoreGState(offScreenContentContext);
		
	/*instruct each of the buttons to draw themselves to the view in their locations:*/
	for(int i = 0; i < [buttonSubviews count]; i++) [[buttonSubviews objectAtIndex: i] drawToContext: offScreenContentContext inParentSpace: YES];
	
	
	/*if the embossed logo is visible, draw it as well:*/
	if([niceEmbossedLogoLayer isHidden] == NO)
	{
		CALayerContentsContext = CGBitmapContextCreate(NULL, [niceEmbossedLogoLayer bounds].size.width, [niceEmbossedLogoLayer bounds].size.height, 8, [niceEmbossedLogoLayer bounds].size.width*4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
		[niceEmbossedLogoLayer renderInContext: CALayerContentsContext];
		CALayerContentsImage = CGBitmapContextCreateImage(CALayerContentsContext);
		CGContextDrawImage(offScreenContentContext, [niceEmbossedLogoLayer frame], CALayerContentsImage);
		
		CGContextRelease(CALayerContentsContext);
		CGImageRelease(CALayerContentsImage);
	
		[niceEmbossedLogoLayer setHidden: YES];
	}
	
	/*finally, if this mini app is currently disabled and therefore has a dark filter over the top, then draw this in:*/
	if(miniAppIsDisabled == 1)
	{
		CGContextSetRGBFillColor(offScreenContentContext, 0.0, 0.0, 0.0, MINI_APP_DISABLED_OPACITY);
		CGContextFillRect(offScreenContentContext, [self bounds]);
	}
	
	/*Either way, hide the darken layer (a little hack here - set its opacity to 0 so that even if the superclass tries to make it visible, it will not be seen:*/
	[[self returnDarkenTopLayer] setHidden: YES];
	[[self returnDarkenTopLayer] setOpacity: 0.0];
	[[self returnDarkenTopLayer] removeAllAnimations];
}



- (void)dealloc 
{
	/*free the array of digits:*/
	free(digitDisplayArray);
	
	/*free the screen digits view:*/
	[screenDigits release];
	
	/*release all of the buttons and their sublayers:*/
	[buttonSubviews removeAllObjects];
	[buttonSubviews release];
	[buttonShadowLayers removeAllObjects];
	[buttonShadowLayers release];
	
	/*remove button graphics images:*/
	CGImageRelease(buttonGraphics_light_off);
	CGImageRelease(buttonGraphics_light_on);
	CGImageRelease(buttonGraphics_dark_off);
	CGImageRelease(buttonGraphics_dark_on);
	CGImageRelease(buttonGraphics_shadow);
	
	/*release various animation objects:*/
	[screenBaseAnim release];
	[screenDigitsSublayerAnim release];
	[screenSheenAnim release];
	
	[buttonShadowLayersAnims removeAllObjects];
	[buttonShadowLayersAnims release];
	[screenComponentLayersAnims removeAllObjects];
	[screenComponentLayersAnims release];
	
	
	/*remove the offscreen layer and context:*/
	CGLayerRelease(offScreenContent);
	CGContextRelease(offScreenContentContext);

	
    [super dealloc];
}


@end