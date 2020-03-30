//
//  calendarMiniAppView.m
//  Paductivity
//
//  Created by William Alexander on 20/10/2010.
//  Copyright 2010 Framestore-CFC. All rights reserved.
//

#import "calendarMiniAppView.h"
#import <QuartzCore/CALayer.h>


@implementation calendarMonthView

- (id)initWithFrame:(CGRect)frame andYear:(int)year_in andMonth:(int)month_in andBaseImage:(CGImageRef)baseImage_in
{
	self = [super initWithFrame:frame];
	
	/*record year and month:*/
	year = year_in;
	month = month_in;
	
	[self setYear:year_in andMonth:month_in];

	self.backgroundColor = [UIColor lightGrayColor];
	
	/*record the base image ref:*/
	baseImage = baseImage_in;
	
	/*for efficiency, this view will not redraw itself when its bounds are changed, only when explicitly told:*/
	self.contentMode = UIViewContentModeScaleToFill;
	
	return self;
}

- (void)setBaseImage:(CGImageRef)baseImage_in;
{
	baseImage = baseImage_in;
}

- (void)setYear:(int)year_in andMonth:(int)month_in
{
	/*record year and month:*/
	year = year_in;
	month = month_in;
	
	/*record year and months as strings for ease or drawing later on:*/
	for(int i = 0; i < 4; i ++) year_str[i] = (int)((float)(year) * pow(10,(i - 3))) - 10*((int)((float)(year) * pow(10,(i - 4)))) + 48;
	year_str[4] = '\0';
	
	if(month == 1) {month_str[0] = 'j'; month_str[1] = 'a'; month_str[2] = 'n'; month_str[3] = 'u'; month_str[4] = 'a'; month_str[5] = 'r'; month_str[6] = 'y'; month_str_len = 7;}
	if(month == 2) {month_str[0] = 'f'; month_str[1] = 'e'; month_str[2] = 'b'; month_str[3] = 'r'; month_str[4] = 'u'; month_str[5] = 'a'; month_str[6] = 'r'; month_str[7] = 'y'; month_str_len = 8;} 
	if(month == 3) {month_str[0] = 'm'; month_str[1] = 'a'; month_str[2] = 'r'; month_str[3] = 'c'; month_str[4] = 'h'; month_str_len = 5;} 
	if(month == 4) {month_str[0] = 'a'; month_str[1] = 'p'; month_str[2] = 'r'; month_str[3] = 'i'; month_str[4] = 'l'; month_str_len = 5;} 
	if(month == 5) {month_str[0] = 'm'; month_str[1] = 'a'; month_str[2] = 'y'; month_str_len = 3;} 
	if(month == 6) {month_str[0] = 'j'; month_str[1] = 'u'; month_str[2] = 'n'; month_str[3] = 'e'; month_str_len = 4;} 
	if(month == 7) {month_str[0] = 'j'; month_str[1] = 'u'; month_str[2] = 'l'; month_str[3] = 'y'; month_str_len = 4;} 
	if(month == 8) {month_str[0] = 'a'; month_str[1] = 'u'; month_str[2] = 'g'; month_str[3] = 'u'; month_str[4] = 's'; month_str[5] = 't'; month_str_len = 6;} 
	if(month == 9) {month_str[0] = 's'; month_str[1] = 'e'; month_str[2] = 'p'; month_str[3] = 't'; month_str[4] = 'e'; month_str[5] = 'm'; month_str[6] = 'b'; month_str[7] = 'e'; month_str[8] = 'r'; month_str_len = 9;} 
	if(month == 10) {month_str[0] = 'o'; month_str[1] = 'c'; month_str[2] = 't'; month_str[3] = 'o'; month_str[4] = 'b'; month_str[5] = 'e'; month_str[6] = 'r'; month_str_len = 7;} 
	if(month == 11) {month_str[0] = 'n'; month_str[1] = 'o'; month_str[2] = 'v'; month_str[3] = 'e'; month_str[4] = 'm'; month_str[5] = 'b'; month_str[6] = 'e'; month_str[7] = 'r'; month_str_len = 8;} 
	if(month == 12) {month_str[0] = 'd'; month_str[1] = 'e'; month_str[2] = 'c'; month_str[3] = 'e'; month_str[4] = 'm'; month_str[5] = 'b'; month_str[6] = 'e'; month_str[7] = 'r'; month_str_len = 8;} 
	
	/*we also now need to know the start day for this month, and how many days it has:*/
	/*To calculate the day on which the first of this month falls, first of all compute how many days it is since 1st January 2001: (or do the same backwards of this month is before that)*/
	int numDaysSince01Jan01 = 0;
	
	if(year >= 2001)
	{
		for(int i = 2001; i < year; i++)
		{
			if([self isLeapYear: i] == 0) numDaysSince01Jan01 += 365;
			else numDaysSince01Jan01 += 366;
		}
		for(int i = 1; i < month; i++)
		{
			if((i == 1) || (i == 3) || (i == 5) || (i == 7) || (i == 8) || (i == 10) || (i == 12)) numDaysSince01Jan01 += 31;
			else if(i != 2) numDaysSince01Jan01 += 30;
			else
			{
				if([self isLeapYear: year]) numDaysSince01Jan01 += 29;
				else numDaysSince01Jan01 += 28;
			}
		}
		month_startDay = numDaysSince01Jan01 % 7;
	}
	
	else 
	{
		for(int i = 2000; i > year; i--)
		{
			if([self isLeapYear: i] == 0) numDaysSince01Jan01 += 365;
			else numDaysSince01Jan01 += 366;
		}
		for(int i = 12; i >= month; i--)
		{
			if((i == 1) || (i == 3) || (i == 5) || (i == 7) || (i == 8) || (i == 10) || (i == 12)) numDaysSince01Jan01 += 31;
			else if(i != 2) numDaysSince01Jan01 += 30;
			else
			{
				if([self isLeapYear: year]) numDaysSince01Jan01 += 29;
				else numDaysSince01Jan01 += 28;
			}
		}
		month_startDay = (7 - (numDaysSince01Jan01 % 7)) % 7;
	}
	
	if((month == 1) || (month == 3) || (month == 5) || (month == 7) || (month == 8) || (month == 10) || (month == 12)) month_length = 31;
	else if(month != 2) month_length = 30;
	else 
	{
		if([self isLeapYear: year] == 1) month_length = 29;
		else month_length = 28;
	}
}

- (int)year
{
	return year;
}

- (int)month
{
	return month;
}

- (int)isLeapYear:(int)year_in
{
	if((year_in % 4) == 0)
	{
		if((year_in % 100) == 0)
		{
			if((year_in % 400) == 0) return 1;
			else return 0;
		}
		else return 1;
	}
	else return 0;
}



- (void)drawRect:(CGRect)rect
{

	/*first of all obtain the graphics context:*/
	CGContextRef drawingCGContext = UIGraphicsGetCurrentContext();
	
	/*first draw the base image to the background:*/
	CGContextDrawImage(drawingCGContext, rect, baseImage);			  
	
	
	CGContextSetTextMatrix(drawingCGContext, CGAffineTransformMake(1, 0, 0, -1, 0, 0));
	
	
	CGContextSelectFont(drawingCGContext, "Helvetica-Bold", (int)(rect.size.height*0.2), kCGEncodingMacRoman);
	CGContextSetRGBFillColor(drawingCGContext, 0.9, 0.9, 0.9, 1.0);
	CGContextShowTextAtPoint(drawingCGContext, (int)(rect.size.height*0.49), (int)(rect.size.height*0.24), year_str, 4);
	
	CGContextSelectFont(drawingCGContext, "Helvetica-Light", (int)(rect.size.height*0.1), kCGEncodingMacRoman);
	CGContextSetRGBFillColor(drawingCGContext, 0.6, 0.6, 0.6, 1.0);
	CGContextShowTextAtPoint(drawingCGContext, (int)(rect.size.height*0.08), (int)(rect.size.height*0.17), month_str, month_str_len);

	/*a bit of polish - if we're drawing the month that we're currently in, then highlight today's date:*/
	CFGregorianDate currentDate_gregorian = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), NULL);
	int i,j;
	
	if((currentDate_gregorian.year == year) && (currentDate_gregorian.month == month))
	{
		i = month_startDay + (currentDate_gregorian.day - 1);
		j = (int)(i / 7.0);
		i = i % 7;
		
		int centreX = rect.size.height * (-0.03 + 0.105 + i*0.125 + 0.055);
		int centreY = rect.size.height * (0.43 + j*0.1 - 0.031);
		
		CGContextSetRGBFillColor(drawingCGContext, 1.0, 0.0, 0.0, 0.5);
		CGContextMoveToPoint(drawingCGContext, (int)(centreX), (int)(centreY - rect.size.height*0.065));
		CGContextAddArcToPoint(drawingCGContext, (int)(centreX + rect.size.height*0.065), (int)(centreY - rect.size.height*0.065), (int)(centreX + rect.size.height*0.065), (int)(centreY), (int)(rect.size.height*0.065));
		CGContextAddArcToPoint(drawingCGContext, (int)(centreX + rect.size.height*0.065), (int)(centreY + rect.size.height*0.065), (int)(centreX), (int)(centreY + rect.size.height*0.065), (int)(rect.size.height*0.065));
		CGContextAddArcToPoint(drawingCGContext, (int)(centreX - rect.size.height*0.065), (int)(centreY + rect.size.height*0.065), (int)(centreX - rect.size.height*0.065), (int)(centreY), (int)(rect.size.height*0.065));
		CGContextAddArcToPoint(drawingCGContext, (int)(centreX - rect.size.height*0.065), (int)(centreY - rect.size.height*0.065), (int)(centreX ), (int)(centreY - rect.size.height*0.065), (int)(rect.size.height*0.065));
		CGContextFillPath(drawingCGContext);
		
		CGContextSetRGBFillColor(drawingCGContext, 1.0, 1.0, 1.0, 1.0);
		CGContextMoveToPoint(drawingCGContext, (int)(centreX), (int)(centreY - rect.size.height*0.055));
		CGContextAddArcToPoint(drawingCGContext, (int)(centreX + rect.size.height*0.055), (int)(centreY - rect.size.height*0.055), (int)(centreX + rect.size.height*0.055), (int)(centreY), (int)(rect.size.height*0.055));
		CGContextAddArcToPoint(drawingCGContext, (int)(centreX + rect.size.height*0.055), (int)(centreY + rect.size.height*0.055), (int)(centreX), (int)(centreY + rect.size.height*0.055), (int)(rect.size.height*0.055));
		CGContextAddArcToPoint(drawingCGContext, (int)(centreX - rect.size.height*0.055), (int)(centreY + rect.size.height*0.055), (int)(centreX - rect.size.height*0.055), (int)(centreY), (int)(rect.size.height*0.055));
		CGContextAddArcToPoint(drawingCGContext, (int)(centreX - rect.size.height*0.055), (int)(centreY - rect.size.height*0.055), (int)(centreX ), (int)(centreY - rect.size.height*0.055), (int)(rect.size.height*0.055));
		CGContextFillPath(drawingCGContext);
	}
	
	
	/*now draw dates:*/
	char dateStr[3];
	int centralisingOffset;
	
	CGContextSelectFont(drawingCGContext, "Helvetica-Bold", (int)(rect.size.height*0.09), kCGEncodingMacRoman);
	CGContextSetRGBFillColor(drawingCGContext, 0.0, 0.0, 0.0, 1.0);
	for(int d = 1; d <= month_length; d++)
	{
		/*work out which coordinates on the grid this date should appear:*/
		i = month_startDay + (d - 1);
		j = (int)(i / 7.0);
		i = i % 7;
		
		/*create date as string:*/
		sprintf(dateStr, "%d", d);
		
		/*now draw to said grid point:*/
		centralisingOffset = 0;
		if(d > 9) centralisingOffset = rect.size.height * -0.03;
		CGContextShowTextAtPoint(drawingCGContext, (int)(rect.size.height * (0.105 + i*0.125)) + centralisingOffset, (int)(rect.size.height * (0.43 + j*0.1)), dateStr, (d > 9)? 2:1);
	}
}


- (void)dealloc
{
	[super dealloc];
}


@end



@implementation calendarMiniAppView


- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
	{
		/*brown background:*/
		[self setBackgroundColor: [UIColor colorWithRed: 0.33 green: 0.154 blue: 0.0 alpha: 1.0]];
		
		
		
		/*always clip all contents to these bounds:*/
		self.clipsToBounds = YES;
		
		/*to give the view nice rounded corners, access underlying CALayer, and set it to have rounded corners:*/
		[[self layer] setCornerRadius: 5.0];
		[[self layer] setMasksToBounds: YES];
		
		/*always keep an internal record of this view's dimensions:*/
		currentBounds = [self bounds];
		
		
		/*ths size and layout of months in the roster depends upon how big the view is and whether the roster should be oriented horiontally or vertically (simply dependent on whether the view is wider than it is tall or vice versa)*/
		if(frame.size.width > frame.size.height)
		{
			rosterDirection = 0;
			monthViewDimension = frame.size.height;
			
			/*There need to be enough month views to allow for there to be at least 1 clear view off screen at the edges at any one time:*/
			numberOfMonthViews = (int)(frame.size.width / frame.size.height) + 2;
		}
		else 
		{
			rosterDirection = 1;
			monthViewDimension = frame.size.width;
			
			/*There need to be enough month views to allow for there to be at least 1 clear view off screen at the edges at any one time:*/
			numberOfMonthViews = (int)(frame.size.height / frame.size.width) + 2;
		}

		
		/*Now determine the current date:*/
		currentDate_gregorian = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), NULL);
		
		
		
		/*Create the month views, with the current month displayed in the middle:*/
		
		/*First of all, load the base image that all month views will use as their background. Create it as a bitmap context scaled down to */
		monthBaseImage_raw = [utilities openCGResourceImage: @"monthPageBase" ofType: @"png"];
		
		int centralMonth = (int)(numberOfMonthViews / 2.0);
		monthViews = [NSMutableArray arrayWithCapacity: numberOfMonthViews];
		
		/*keep a record of exactly where, geometrically, the first month on the roster is*/
		firstMonthPosition = -1 * centralMonth * monthViewDimension;
		
		calendarMonthView *newMonthView;	
		int newMonthViewYear;
		int newMonthViewMonth;
	
		for(int i = 0; i < numberOfMonthViews; i++)
		{
			newMonthViewYear = currentDate_gregorian.year;
			newMonthViewMonth = currentDate_gregorian.month - (centralMonth - i);
			if(newMonthViewMonth > 12)
			{
				newMonthViewYear++;
				newMonthViewMonth -= 12;
			}
			if(newMonthViewMonth < 1)
			{
				newMonthViewYear--;
				newMonthViewMonth += 12;
			}
		
			newMonthView = [[calendarMonthView alloc] initWithFrame:CGRectMake(0.0, 0.0, monthViewDimension, monthViewDimension) andYear:newMonthViewYear andMonth:newMonthViewMonth andBaseImage: monthBaseImage];

			[self addSubview: newMonthView];
			[monthViews addObject: newMonthView];
			[newMonthView release];
		}
	
		[monthViews retain];
		
		
		/*we start with the current month centered in the view. This is considered to be the neutral position, an offset of zero:*/
		rosterOffset = 0;
		
		/*the roster is aligned horizontally:*/
		rosterDirection = 0;
		
		/*keep a running record of by how many months today's month is offset from the start month of our roster:*/
		firstMonthMonthOffset = centralMonth;
	
	
		/*Add a layer above everything for polish - it'll have a gradient that tapers off to black at the edges to give a nice darkening effect on the mini-app:*/
		gradientOverlayLayer = [CALayer layer];
		[gradientOverlayLayer setBackgroundColor: [[UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.0] CGColor]];
		gradientOverlayLayer.anchorPoint = CGPointMake(0.0, 0.0);
		gradientOverlayLayer.bounds = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
		gradientOverlayLayer.position = CGPointMake(0.0, 0.0);
		gradientOverlayLayer.zPosition = 1.0;
		[[self layer] addSublayer: gradientOverlayLayer];
		
		gradientOverlayLayerAnim = [CABasicAnimation animationWithKeyPath: @"bounds"];
		[gradientOverlayLayerAnim setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[gradientOverlayLayerAnim retain];
	
		gradientOverlayLayerContentAnim = [CABasicAnimation animationWithKeyPath: @"contents"];
		[gradientOverlayLayerContentAnim setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[gradientOverlayLayerContentAnim retain];
		
		
		[self initialiseAssetsForGraphicsRescaling];
		[self sizeMonthBaseImageToMonthViewDimensions: self.bounds];
		[self reBuildUIElementsAtCurrentSizeAndResolution];
		
		

		/*add a button in the bottom left corner to allow the user to return to the current month:*/
		returnToTodayLayer = [CALayer layer];
		returnToTodayLayer.anchorPoint = CGPointMake(0.5, 0.5);
		returnToTodayLayer.bounds = CGRectMake(0.0, 0.0, 50.0, 50.0);
		returnToTodayLayer.backgroundColor = [[UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.0] CGColor];
		returnToTodayLayer.opacity = RETURN_TO_TODAY_LAYER_OPACITY;
		returnToTodayLayer.position = CGPointMake(60.0, frame.size.height - 60.0);
		returnToTodayLayer.zPosition = 2.0;
		returnToTodayLayer.hidden = YES;
		[[self layer] addSublayer: returnToTodayLayer];
		
		/*load the 'returnToToday' icon for the button layer to display as its contents:*/
		returnToTodayImage = [utilities openCGResourceImage: @"returnToTodayIcon" ofType: @"png"];
		[returnToTodayLayer setContents: (id)returnToTodayImage];
		CATransform3D myCATransform = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
		returnToTodayLayer.transform = myCATransform;
		
		/*it starts 'off', of course:*/
		returnToTodayLayerTouchDown = 0;
		
		/*create Anim objects to use in animating it:*/
		returnToTodayLayerAnim_position = [CABasicAnimation animationWithKeyPath: @"position"];
		[returnToTodayLayerAnim_position setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[returnToTodayLayerAnim_position retain];
		
		returnToTodayLayerAnim_bounds = [CABasicAnimation animationWithKeyPath: @"bounds"];
		[returnToTodayLayerAnim_bounds setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[returnToTodayLayerAnim_bounds retain];
		
		returnToTodayLayerAnim_transform = [CABasicAnimation animationWithKeyPath: @"transform"];
		[returnToTodayLayerAnim_transform setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[returnToTodayLayerAnim_transform retain];
		
		returnToTodayLayerAnim_opacity = [CABasicAnimation animationWithKeyPath: @"opacity"];
		[returnToTodayLayerAnim_opacity setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[returnToTodayLayerAnim_opacity retain];
		
		
		
		/*Set up a CADisplayLink to give us a callback method in the run loop that's in sync with the display updating:*/
		rosterMovementDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(monthViewsShiftCallback:)];
		[rosterMovementDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		rosterMotionInProgress = 0;
	
		/*layout, by default, behaves as normal*/
		disableManualLayout = 0;
	}

	return self;
}



/*
	a simple procedure for defining a very particular gradient function for the 'gradient overlay'
 */
static void myCalculateShadingValues(void *info, const float *in, float *out)
{
	float v;
	size_t k, components;
	
	components = (size_t)info;
	
	v = 1.0 - 2.0*fabs(*in - 0.5);
	v = sqrt(sqrt(sqrt(v)));
	for(k = 0; k < components - 1; k++) *out++ = 0;
	*out++ = 1.0 - v;
}


/*
	used just once when setting up the mini app, this creates all the assets that will be re-used every time graphics need to be redrawn:
 */
- (void)initialiseAssetsForGraphicsRescaling
{
	/*Create the CGFunction object that will point to our gradient shading function:*/
	size_t components = 1 + CGColorSpaceGetNumberOfComponents(CGColorSpaceCreateDeviceRGB());
	static const float input_value_range[2] = {0, 1};
	static const float output_value_ranges[8] = {0, 1, 0, 1, 0, 1, 0, 1};
	static const CGFunctionCallbacks callbacks = {0, &myCalculateShadingValues, NULL};
	
	gradientShadingFunction = CGFunctionCreate((void *)components, 1, input_value_range, components, output_value_ranges, &callbacks);
}


/*
	if the size/shape of the view changes, we will need to assign new values to miniApp attributes that control how the months fit inside thw view:
 */
- (void)setUpRosterGeometryForChangedBounds: (CGRect)newBounds
{
	float scaleFactor;
	int newMonthViewDimension;
	
	/*First, are the new bounds landscape or portrait?*/
	if(newBounds.size.width > newBounds.size.height)
	{
		rosterDirection = 0;
		newMonthViewDimension = (int)(newBounds.size.height);
	}
	else
	{
		rosterDirection = 1;
		newMonthViewDimension = (int)(newBounds.size.width);
	}
	
	
	/*if the new roster size is different to the old size, then the month views are going to have to be scaled, as are the extra drawing layers above:*/
	if(newMonthViewDimension != monthViewDimension)
	{
		scaleFactor = (float)(newMonthViewDimension) / (float)(monthViewDimension);
		
		/*the first month position needs to be scaled so that the months stay in the same position relative to the centre of the view:*/
		firstMonthPosition = (int)(scaleFactor * (float)(firstMonthPosition));
		
		/*update other geometric values:*/
		rosterOffset = (int)(scaleFactor * (float)(rosterOffset));
		monthViewDimension = newMonthViewDimension;
	}
}


/*
	given a new bounds rectangle for the view, regenerate the various graphics that depend on this:
 */
- (void)sizeMonthBaseImageToMonthViewDimensions: (CGRect)targetRect
{
	/*the dimension of the month views is whichever of horizontal/vertical of the targetRect is smaller:*/
	int dimensions;
	int rosterOrientation;
	
	if(targetRect.size.width < targetRect.size.height)	
	{
		dimensions = (int)(targetRect.size.width);
		rosterOrientation = 1;
	}
	else
	{
		dimensions = (int)(targetRect.size.height);
		rosterOrientation = 0;
	}

	/*redraw the month page graphic by creating a bitmap of the precise size required and drawing the graphic CGImage into it:*/
	CGContextRef monthBaseImageBitmapContext = CGBitmapContextCreate(NULL, dimensions, dimensions, 8, dimensions*4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipLast);
	
	CGContextSaveGState(monthBaseImageBitmapContext);
	CGContextScaleCTM(monthBaseImageBitmapContext, 1.0, -1.0);
	CGContextTranslateCTM(monthBaseImageBitmapContext, 0, -1*dimensions);
	
	CGContextDrawImage(monthBaseImageBitmapContext, CGRectMake(0.0, 0.0, dimensions, dimensions), monthBaseImage_raw);
	
	CGContextRestoreGState(monthBaseImageBitmapContext);	
	
	if(monthBaseImage != nil) CGImageRelease(monthBaseImage);
	monthBaseImage = CGBitmapContextCreateImage(monthBaseImageBitmapContext);
	
	/*clean up:*/
	CGContextRelease(monthBaseImageBitmapContext);
	
	/*redraw the gradient graphic: */
	[self sizeGradientImageToNewBounds: targetRect withOrientation: rosterOrientation];
}


/*
	regenerates the gradient graphic that is layered over the top of the view:
 */
- (void)sizeGradientImageToNewBounds: (CGRect)targetRect withOrientation: (int)rosterOrientation
{
	/*redraw the overlay gradient by drawing it fresh into a bitmap then a CGImage of the correct size:*/
	CGPoint startPoint, endPoint;
	
	startPoint = CGPointMake(rosterOrientation * 0.5*targetRect.size.width, (1 - rosterOrientation) * 0.5*targetRect.size.height);
	endPoint = CGPointMake((1 - rosterOrientation) * targetRect.size.width + rosterOrientation * 0.5*targetRect.size.width, (1 - rosterOrientation) * 0.5*targetRect.size.height + rosterOrientation * targetRect.size.height);
	
	if(horizontalGradientShading != nil) CGShadingRelease(horizontalGradientShading);
	if(gradientOverlayGradientImage != nil) CGImageRelease(gradientOverlayGradientImage);
	
	horizontalGradientShading = CGShadingCreateAxial(CGColorSpaceCreateDeviceRGB(), startPoint, endPoint, gradientShadingFunction, false, false);
	
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, targetRect.size.width, targetRect.size.height, 8, targetRect.size.width*4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	CGContextDrawShading(gradientBitmapContext, horizontalGradientShading);
	
	gradientOverlayGradientImage = CGBitmapContextCreateImage(gradientBitmapContext);
	
	
	CGContextRelease(gradientBitmapContext);
}


/*
	after view shape/size changes, graphics will havve been regenerated for the months or other graphics. this method actually applies these newly generated graphics:
 */
- (void)reBuildUIElementsAtCurrentSizeAndResolution
{
	/*loop through and redraw all the month views:*/
	for(int i = 0; i < [monthViews count]; i++)
	{
		[[monthViews objectAtIndex: i] setBaseImage: monthBaseImage];
		[[monthViews objectAtIndex: i] setNeedsDisplay];
	}

	/*apply the latest graphic to the gradient layer:*/
	[gradientOverlayLayer setContents: (id)gradientOverlayGradientImage];

	/*make sure that the roster offset record, which will inevitably have suffered from rounding errors, is set back to its exact correct value:*/
	rosterOffset = firstMonthPosition + firstMonthMonthOffset * monthViewDimension;
	
	/*notify the parent view that we have finished all this heavy drawing:*/
	[rootPanelView miniAppViewDidFinishRedrawingInSettledFrame: self];
}


/*
	returnToTodayStateForBoundsRect - for a given view bounds rectangle, returns where and how (and whether) the returnToToday appears. 0 for invisible, 1/2/3/4 for visible + oriented left/right/up/down
 */
- (int)returnToTodayStateForBoundsRect: (CGRect)rect isHypothetical: (int)isHypo 
{
	/*if this is being asked about the current view state, then we can use all current state settings (rosterOffset etc) If however this question is being asked about a potential/hypothetical setup, we need to calculate what values rosterOffset etc would take in that situation:*/
	int rosterDirectionForRect = rosterDirection;
	int monthViewDimensionForRect = monthViewDimension;
	int rosterOffsetForRect = rosterOffset;
	
	if(isHypo == 1)
	{
		/*what would the roster direction and month view dimension be for this bounds rect?*/
		if(rect.size.width > rect.size.height)	
		{
			rosterDirectionForRect = 0;
			monthViewDimensionForRect = rect.size.height;
		}
		else
		{
			rosterDirectionForRect = 1;
			monthViewDimensionForRect = rect.size.width;
		}
		
		float scaleFactor = (float)(monthViewDimensionForRect) / (float)(monthViewDimension);
		rosterOffsetForRect = (int)(scaleFactor * (float)(rosterOffset));
	}
	
	
	/*first of all, the returnToTodayButton only appears if the current month view is completely off screen. If not, then return zero:*/
	if((rosterDirectionForRect == 0) && (abs(rosterOffsetForRect) < (int)(0.5*rect.size.width + 0.5*monthViewDimensionForRect))) return 0;
	if((rosterDirectionForRect == 1) && (abs(rosterOffsetForRect) < (int)(0.5*rect.size.height + 0.5*monthViewDimensionForRect))) return 0;
	
	/*now that its definitely visible, determine which way the button should face:*/
	if(rosterDirectionForRect == 0) 
	{
		if(rosterOffsetForRect < 0) return 1;
		else return 2;
	}
	else 
	{
		if(rosterOffsetForRect < 0) return 3;
		else return 4;
	}
}


/*
	getReturnToTodayLayerTransformForOrientation - this method returns the 'returnToToday' transform rotation needed, based on the roster's current direction and offset
 */
- (CATransform3D)getReturnToTodayLayerTransformForOrientation: (int)orientation
{
	CATransform3D returnButtonLayerXform = returnToTodayLayer.transform;
	
	if(orientation == 1)
	{
		returnButtonLayerXform.m11 = 1;
		returnButtonLayerXform.m12 = 0;
		returnButtonLayerXform.m21 = 0;
		returnButtonLayerXform.m22 = 1;
	}
		
	if(orientation == 2)
	{
		returnButtonLayerXform.m11 = -1;
		returnButtonLayerXform.m12 = 0;
		returnButtonLayerXform.m21 = 0;
		returnButtonLayerXform.m22 = 1;
	}
	
	if(orientation == 3)
	{
		returnButtonLayerXform.m11 = 0;
		returnButtonLayerXform.m12 = 1;
		returnButtonLayerXform.m21 = -1;
		returnButtonLayerXform.m22 = 0;
	}
		
	if(orientation == 4)
	{
		returnButtonLayerXform.m11 = 0;
		returnButtonLayerXform.m12 = -1;
		returnButtonLayerXform.m21 = -1;
		returnButtonLayerXform.m22 = 0;
	}
	
	return returnButtonLayerXform;
}


/*
	shiftMonthsRoster - called when the set of month views is to be shifted along horizontally. This is called when a user's touch motion requires the roster of said month views to be shifted
 */
- (void)shiftMonthsRoster:(int)shiftAmount;
{
	/*move all of our month views along horizontally, accordingly:*/
	calendarMonthView *currentMonthView;
	CGPoint currentMonthViewCenter;
	int currentMonthViewMonth;
	
	/*continue to keep track of the position, in view space, of the first month's position:*/
	firstMonthPosition += shiftAmount;
	
	for(int i = 0; i < numberOfMonthViews; i++)
	{
		currentMonthView = [monthViews objectAtIndex: i];
		
		currentMonthViewCenter = [currentMonthView center];
		
		if(rosterDirection == 0)	[currentMonthView setCenter: CGPointMake(currentMonthViewCenter.x + shiftAmount, currentMonthViewCenter.y)];
		else						[currentMonthView setCenter: CGPointMake(currentMonthViewCenter.x, currentMonthViewCenter.y + shiftAmount)];
	}
	
	/*now, if this resulted in either of the views on the ends moving out of the this parent view bounds by more than its own width, then it needs to be 'recycled' and put at the other end of the 'queue':*/
	currentMonthView = [monthViews objectAtIndex: (numberOfMonthViews - 1)];
	currentMonthViewCenter = [currentMonthView center];
	if(
			((rosterDirection == 0) && ((shiftAmount > 0)&&(currentMonthViewCenter.x > (self.bounds.size.width + 0.5*monthViewDimension)))) ||
			((rosterDirection == 1) && ((shiftAmount > 0)&&(currentMonthViewCenter.y > (self.bounds.size.height + 0.5*monthViewDimension))))
	   )
	{
		if(rosterDirection == 0)	[currentMonthView setCenter: CGPointMake(currentMonthViewCenter.x - (numberOfMonthViews * monthViewDimension), currentMonthViewCenter.y)];
		else						[currentMonthView setCenter: CGPointMake(currentMonthViewCenter.x, currentMonthViewCenter.y - (numberOfMonthViews * monthViewDimension))];
		
		currentMonthViewMonth = [currentMonthView month] - numberOfMonthViews;
		if(currentMonthViewMonth < 1) [currentMonthView setYear: ([currentMonthView year] - 1) andMonth: (currentMonthViewMonth + 12)];
		else [currentMonthView setYear: ([currentMonthView year]) andMonth: currentMonthViewMonth];
		
		firstMonthPosition -= monthViewDimension;
		
		[currentMonthView setNeedsDisplay];
		
		/*shift the view from last place to first in the array:*/
		[monthViews removeObjectAtIndex: (numberOfMonthViews - 1)];
		[monthViews insertObject: currentMonthView atIndex: 0];
		
		/*the roster takes one step 'back' in time:*/
		firstMonthMonthOffset += 1;
	}
	
	currentMonthView = [monthViews objectAtIndex: 0];
	currentMonthViewCenter = [currentMonthView center];
	if(
			((rosterDirection == 0) && ((shiftAmount < 0)&&(currentMonthViewCenter.x < (-0.5*monthViewDimension)))) ||
			((rosterDirection == 1) && ((shiftAmount < 0)&&(currentMonthViewCenter.y < (-0.5*monthViewDimension))))
		)
	{
		if(rosterDirection == 0)	[currentMonthView setCenter: CGPointMake(currentMonthViewCenter.x + (numberOfMonthViews * monthViewDimension), currentMonthViewCenter.y)];
		else						[currentMonthView setCenter: CGPointMake(currentMonthViewCenter.x, currentMonthViewCenter.y + (numberOfMonthViews * monthViewDimension))];
		
		currentMonthViewMonth = [currentMonthView month] + numberOfMonthViews;
		if(currentMonthViewMonth > 12) [currentMonthView setYear: ([currentMonthView year] + 1) andMonth: (currentMonthViewMonth - 12)];
		else [currentMonthView setYear: ([currentMonthView year]) andMonth: currentMonthViewMonth];
		
		firstMonthPosition += monthViewDimension;
		
		[currentMonthView setNeedsDisplay];
		
		/*shift the view from first place to last in the array:*/
		[monthViews removeObjectAtIndex: 0];
		[monthViews insertObject: currentMonthView atIndex: (numberOfMonthViews - 1)];
		
		/*the roster takes one step 'forward' in time:*/
		firstMonthMonthOffset -= 1;
	}
	
	
	
	/*keep record of how much the roster is offset by relative to its neutral position:*/
	rosterOffset += shiftAmount;
	
	
	
	/*ensure that the returnToToday layer is in the correct state:*/
	int returnToTodayLayerState = [self returnToTodayStateForBoundsRect: self.bounds isHypothetical: 0];
	if(returnToTodayLayerState > 0)
	{
		[returnToTodayLayer setPosition: CGPointMake(60.0, self.bounds.size.height - 60.0)];
		[returnToTodayLayer setTransform:  [self getReturnToTodayLayerTransformForOrientation: returnToTodayLayerState]];
		[returnToTodayLayer setHidden: NO];
	}
	else [returnToTodayLayer setHidden: YES];
	
	[returnToTodayLayer removeAllAnimations];
}


/*
	this call back is synchronised with the display refresh, and *if and when* the months roster needs to be animated, this method will handle it:
 */
- (void)monthViewsShiftCallback:(CADisplayLink*)displayLink
{
	int newRosterOffset;
	
	if(rosterMotionInProgress == 1)
	{
		/*update time elapsed:*/
		rosterMotion_timeElapsed += displayLink.duration;
		
		newRosterOffset = rosterMotion_startOffset + rosterMotion_startSpeed * rosterMotion_timeElapsed + 0.5 * (rosterMotion_acceleration * rosterMotion_timeElapsed * rosterMotion_timeElapsed);
		[self shiftMonthsRoster: (newRosterOffset - rosterOffset)];
		
		if(rosterOffset == rosterMotion_endOffset) rosterMotionInProgress = 0;
	}
}






/*******************************************************************************************************************
 
 HERE WE OVERRIDE, WHERE NECESSARY, SYSTEM UIVIEW METHODS
 
 ********************************************************************************************************************/


/*
	hitTest - always return any hits to this, the main mini app view. We don't want the section views actually receiving touch events, we want to handle them here:
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	return self;
}


/* 
	layoutSubviews - will be called when this view's frame/bounds has been changed
 */
- (void)layoutSubviews
{
	/*do not run if manual layout is disabled:*/
	if(disableManualLayout == 1) return;
	
	[super layoutSubviews];
	
	float scaleFactor;
	int newMonthViewDimension;
	
	
	/*First and foremost, is the view landscape or portrait?*/
	if(self.bounds.size.width > self.bounds.size.height)
	{
		/*landscape*/
		if(rosterDirection == 1)	/*specifically, if we are changing from portrait, then deal with that here:*/
		{
			/*switch the orientation of the overlay gradient:*/
			[self sizeGradientImageToNewBounds: self.bounds withOrientation: 0];
			[gradientOverlayLayer setContents: (id)gradientOverlayGradientImage];
			
			rosterDirection = 0;
			
			//[self orientReturnToTodayLayer];
		}
		
		else rosterDirection = 0;
		
		newMonthViewDimension = (int)(self.bounds.size.height);
	}
	
	else
	{
		/*portrait*/
		if(rosterDirection == 0)	/*specifically, if we are changing from lanscape, then deal with that here:*/
		{
			/*switch the orientation of the overlay gradient:*/
			[self sizeGradientImageToNewBounds: self.bounds withOrientation: 1];
			[gradientOverlayLayer setContents: (id)gradientOverlayGradientImage];
			
			rosterDirection = 1;
		}
		
		else rosterDirection = 1;
		
		newMonthViewDimension = (int)(self.bounds.size.width);
	}
	
	
	/*if the month size is different to the old size, then the month views are going to have to be scaled, as are the extra drawing layers above:*/
	if(newMonthViewDimension != monthViewDimension)
	{
		scaleFactor = (float)(newMonthViewDimension) / (float)(monthViewDimension);
		
		/*the first month position needs to be scaled so that the months stay in the same position relative to the centre of the view:*/
		firstMonthPosition = (int)(scaleFactor * (float)(firstMonthPosition));
		
		/*update other geometric values:*/
		rosterOffset = (int)(scaleFactor * (float)(rosterOffset));
		monthViewDimension = newMonthViewDimension;
	}
	
	/*to lay out the month views, start by putting the first in position, then place the the others after it, one by one:*/
	for(int i = 0; i < [monthViews count]; i++)
	{
		if(rosterDirection == 0)
			[[monthViews objectAtIndex: i] setCenter: CGPointMake(0.5*self.bounds.size.width + firstMonthPosition + i * monthViewDimension, 0.5 * monthViewDimension)];
		
		else
			[[monthViews objectAtIndex: i] setCenter: CGPointMake(0.5 * monthViewDimension, 0.5*self.bounds.size.height + firstMonthPosition + i * monthViewDimension)];
			
		
		[[monthViews objectAtIndex: i] setBounds: CGRectMake(0.0, 0.0, monthViewDimension, monthViewDimension)];
	}
	
	/*with the main view changing size, there may be the need to add or remove month views that we need or don't need anymore:*/
	calendarMonthView *newMonthView;
	calendarMonthView *monthViewToRemove;
	
	int newYear, newMonth;
	
	/*if our view now doesn't cover enough area for the roster, then we need to add another month:*/
	if(
			((rosterDirection == 0) && (((int)(self.bounds.size.width / (float)(monthViewDimension)) + 2) > numberOfMonthViews)) ||
			((rosterDirection == 1) && (((int)(self.bounds.size.height / (float)(monthViewDimension)) + 2) > numberOfMonthViews))	
		)
	{
		/*We'll need to add another month view. To determine whether we add a month to the start or end of the roster, just see end is closert to the centre and therefore more in need of the addition*/
		if(abs(firstMonthPosition) < (0.5 * (numberOfMonthViews - 1) * monthViewDimension))
		{
			/*we'll add the new month view at the beginning of the roster*/
			newYear = [[monthViews objectAtIndex: 0] year];
			newMonth = [[monthViews objectAtIndex: 0] month] - 1;
			if(newMonth == 0)
			{
				newMonth = 12;
				newYear--;
			}
			
			newMonthView = [[calendarMonthView alloc] initWithFrame:CGRectMake(0.0, 0.0, monthViewDimension, monthViewDimension) andYear: newYear andMonth: newMonth andBaseImage: monthBaseImage];
			
			if(rosterDirection == 0)	[newMonthView setCenter: CGPointMake(0.5 * self.bounds.size.width + firstMonthPosition - monthViewDimension, 0.5 * monthViewDimension)];
			else						[newMonthView setCenter: CGPointMake(0.5 * monthViewDimension, 0.5 * self.bounds.size.height + firstMonthPosition - monthViewDimension)];
			
			[self addSubview: newMonthView];
			[monthViews insertObject: newMonthView atIndex: 0];
			[newMonthView release];
			
			numberOfMonthViews++;
			firstMonthPosition -= monthViewDimension;
			firstMonthMonthOffset +=1;
		}
		
		else 
		{
			/*we'll add the new month view at the end of the roster*/
			newYear = [[monthViews objectAtIndex: (numberOfMonthViews - 1)] year];
			newMonth = [[monthViews objectAtIndex: (numberOfMonthViews - 1)] month] + 1;
			if(newMonth == 13)
			{
				newMonth = 1;
				newYear++;
			}
			
			newMonthView = [[calendarMonthView alloc] initWithFrame:CGRectMake(0.0, 0.0, monthViewDimension, monthViewDimension) andYear: newYear andMonth: newMonth andBaseImage: monthBaseImage];
			
			if(rosterDirection == 0)	[newMonthView setCenter: CGPointMake(0.5 * self.bounds.size.width + firstMonthPosition + numberOfMonthViews * monthViewDimension , 0.5 * monthViewDimension)];
			else						[newMonthView setCenter: CGPointMake(0.5 * monthViewDimension, 0.5 * self.bounds.size.height + firstMonthPosition + numberOfMonthViews * monthViewDimension)];
			
			[self addSubview: newMonthView];
			[monthViews addObject: newMonthView];
			[newMonthView release];
			
			numberOfMonthViews++;
		}
	}

	/*if our roster now covers more area than we need for the view, then remove as many months as necessary:*/
	int numberOfViewsNeeded;
	
	if(rosterDirection == 0)	numberOfViewsNeeded = (int)(self.bounds.size.width / (float)(monthViewDimension)) + 2;
	else						numberOfViewsNeeded = (int)(self.bounds.size.height / (float)(monthViewDimension)) + 2;
	
	if(numberOfMonthViews > numberOfViewsNeeded)
	{
		int numberOfMonthViewsToRemove = numberOfMonthViews - numberOfViewsNeeded;
		int numberOfMonthViewsToRemoveFromStart;
		int numberOfMonthViewsToRemoveFromEnd;
		
		
		/*if the number of month views to be removed is even, then remove half the number from each end:*/
		if((numberOfMonthViewsToRemove % 2) == 0) numberOfMonthViewsToRemoveFromStart = numberOfMonthViewsToRemoveFromEnd = 0.5 * numberOfMonthViewsToRemove;
		
		/*if an odd number, then remove 1 less month view from the end that is closer from the centre than from the other end:*/
		else 
		{
			/*if 'start end' is closer:*/
			if(abs(firstMonthPosition) < (int)(0.5 * (numberOfMonthViews - 1) * monthViewDimension))
			{
				numberOfMonthViewsToRemoveFromStart = (int)(0.5 * numberOfMonthViewsToRemove);
				numberOfMonthViewsToRemoveFromEnd = numberOfMonthViewsToRemove - numberOfMonthViewsToRemoveFromStart; 
			}
			/*if the 'end end' is closer:*/
			else
			{
				numberOfMonthViewsToRemoveFromEnd = (int)(0.5 * numberOfMonthViewsToRemove);
				numberOfMonthViewsToRemoveFromStart = numberOfMonthViewsToRemove - numberOfMonthViewsToRemoveFromEnd; 
			}
		}
		
		/*now actually remove the month views:*/
		for(int i = 0; i < numberOfMonthViewsToRemoveFromStart; i++)
		{
			[[monthViews objectAtIndex: 0] removeFromSuperview];
			[monthViews removeObjectAtIndex: 0];
			
			numberOfMonthViews--;
			firstMonthPosition += monthViewDimension;
			firstMonthMonthOffset -= 1;
		}
		
		for(int i = 0; i < numberOfMonthViewsToRemoveFromEnd; i++)
		{
			[[monthViews objectAtIndex: (numberOfMonthViews -1)] removeFromSuperview];
			[monthViews removeObjectAtIndex: (numberOfMonthViews -1)];
			
			numberOfMonthViews--;
		}
	}
	

	/*update the gradient-polish layer above:*/
	gradientOverlayLayer.bounds = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
	[gradientOverlayLayer removeAllAnimations];
	
	
	
	
	/*The returnToToday layer is always in the bottom-left corner, 60px from each edge. Also set its state:*/
	int returnToTodayLayerState = [self returnToTodayStateForBoundsRect: self.bounds isHypothetical: 0];
	
	
	[returnToTodayLayer setPosition: CGPointMake(60.0, self.bounds.size.height - 60.0)];
	[returnToTodayLayer setTransform:  [self getReturnToTodayLayerTransformForOrientation: returnToTodayLayerState]];
	
	
	if(returnToTodayLayerState > 0) [returnToTodayLayer setHidden: NO];
	else							[returnToTodayLayer setHidden: YES];
	
	
	/*After an animation, it is possible that the layer will be invisible with hidden=NO but opacity=0.0, this needs to be correct here if it is the case:*/
	[returnToTodayLayer setOpacity: RETURN_TO_TODAY_LAYER_OPACITY];
	
	
	[returnToTodayLayer removeAllAnimations];

	
	
	currentBounds = [self bounds];
}


/*
 These are the methods for handling touch events:
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	/*N.B. multi touch is only enabled so that double-tap detection works, for all other events for this view, we ignore all touches except the first one:*/
	UITouch *theTouch = [[touches allObjects] objectAtIndex: 0];
	if(theTouch == [[[event touchesForView: self] allObjects] objectAtIndex: 0])
	{
		/*did the touch fall within our 'returnToToday' button?*/
		if([returnToTodayLayer hitTest:[theTouch locationInView: self] ] == returnToTodayLayer)
		{
			returnToTodayLayer.opacity = 0.6;
			[returnToTodayLayer removeAllAnimations];
		
			returnToTodayLayerTouchDown = 1;
		}
	
		/*automatically stop any roster motion*/
		rosterMotionInProgress = 0;
			
		/*reset measurements of how fast the user's touch is moving*/
		currentTouchHorizontalSpeedRecord = 0;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	/*N.B. multi touch is only enabled so that double-tap detection works, for all other events for this view, we ignore all touches except the first one:*/
	UITouch *theTouch = [[touches allObjects] objectAtIndex: 0];
	if(theTouch == [[[event touchesForView: self] allObjects] objectAtIndex: 0])
	{
		if(returnToTodayLayerTouchDown == 1) return;
	
		CGPoint currentTouchPoint = [theTouch locationInView: self];
		CGPoint previousTouchPoint = [theTouch previousLocationInView: self];
	
		float touchMovementInRosterDirection;
	
		if(rosterDirection == 0)	touchMovementInRosterDirection = currentTouchPoint.x - previousTouchPoint.x;
		else						touchMovementInRosterDirection = currentTouchPoint.y - previousTouchPoint.y;
	
	
		[self shiftMonthsRoster: touchMovementInRosterDirection];
	
		/*keep track of how fast the user's touch is moving across the screen:*/
		currentTouchHorizontalSpeedRecord = touchMovementInRosterDirection / (CACurrentMediaTime() - currentTouchTimeRecord);
		currentTouchTimeRecord = CACurrentMediaTime();
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	/*N.B. multi touch is only enabled so that double-tap detection works, for all other events for this view, we ignore all touches except the first one:*/
	UITouch *theTouch = [[touches allObjects] objectAtIndex: 0];
	if(theTouch == [[[event touchesForView: self] allObjects] objectAtIndex: 0])
	{
		float returnRoster_timeTaken;
	
		/*if this is the end of a press of the return button, trigger the animation that returns the roster to today:*/
		if(returnToTodayLayerTouchDown == 1)
		{
			/*calculate the roster return animation. First of all, how long will it take? this is linearly dependent on the distance it has to travel:*/
			returnRoster_timeTaken = ROSTER_RETURN_TIME_PER_PIXEL * (float)(abs(rosterOffset));
			
			/*if this time is more than the acceptable time, then force the return to take the acceptable time by increasing its initial velocity:*/
			if(returnRoster_timeTaken > ROSTER_RETURN_MAX_ACCEPTABLE_TIME) returnRoster_timeTaken = ROSTER_RETURN_MAX_ACCEPTABLE_TIME;
		
			/*now we know how long it will take, use simple 'SUVAT' equations to calculate the start velocity needed to meet this time:*/
			rosterMotion_startSpeed = -2.0 * rosterOffset / returnRoster_timeTaken;
		
			/*now, if this start speed exceeds the maximum 'comfortable' speed we want to see from the roster, then we need to limit it, which means fixing both the startSpeed *and* the time taken. The only way to do this is to reduce the distance, so to do that we cheat by 'cutting out' some months between the current position and today's month (the destination). The roster will move so fast that the user won't notice the jump:*/
			if(fabs(rosterMotion_startSpeed) > ROSTER_MAXIMUM_SPEED)
			{
				/*what must the distance be to allow the motion to complete with the fixed start velocity and the fixed duration?*/
				int rosterMotion_idealDistance = 0.5 * ROSTER_MAXIMUM_SPEED * ROSTER_RETURN_MAX_ACCEPTABLE_TIME;
				
				if(rosterOffset < 0) rosterMotion_idealDistance *= -1.0;
				
				/*so we need to 'pretend' that the rosterOffset is this value rather than the larger distance it actually is. Now the current position of the months in the view will not be exactly the same as they would be if we *were* at this theoretical offset, so add on to this theoretical offset the amount required to line it up with the where our months are in the view:*/
				int idealDistanceMonthPhase = abs(rosterMotion_idealDistance) % monthViewDimension;
				int rosterTruePhase = abs(rosterOffset) % monthViewDimension;
				
				int rosterMotion_idealDistance_surplus;
				if(rosterTruePhase > idealDistanceMonthPhase)	rosterMotion_idealDistance_surplus = rosterTruePhase - idealDistanceMonthPhase;
				else											rosterMotion_idealDistance_surplus = monthViewDimension - (idealDistanceMonthPhase - rosterTruePhase);
				
				if(rosterOffset > 0)	rosterMotion_idealDistance = rosterMotion_idealDistance + rosterMotion_idealDistance_surplus;
				else					rosterMotion_idealDistance = rosterMotion_idealDistance - rosterMotion_idealDistance_surplus;
				
				
				/*given this 'pretend' setup, set all months to have the date value it *would* have if the pretend space were true rather than their actual date that they're currently displaying. This means that from this month onwards, as the roster animates back to the origin, all months will be given their month value in the pretend space thus leading back to the origin/'todayMonth'*/
				int monthDifferenceRetweenRealAndPretendOffset = rint((float)(rosterOffset - rosterMotion_idealDistance) / monthViewDimension);

				
				calendarMonthView *monthToChange;
				int monthToChange_monthValue;
				int monthToChange_yearValue;
				
				for(int i = 0; i < numberOfMonthViews; i++)
				{
					monthToChange = [monthViews objectAtIndex: i];
					
					monthToChange_monthValue = [monthToChange month] + monthDifferenceRetweenRealAndPretendOffset;
					
					if(monthToChange_monthValue > 0)
					{
						monthToChange_yearValue = [monthToChange year] + (int)((float)(monthToChange_monthValue - 1) / 12.0);
						monthToChange_monthValue = ((monthToChange_monthValue - 1) % 12) + 1;
					}
						
					else
					{
						monthToChange_yearValue = [monthToChange year] + (int)(((float)(monthToChange_monthValue + 1) / 12.0) - 1.0);
						monthToChange_monthValue = ((monthToChange_monthValue + 1) % 12) + 11;
					}
					
					[monthToChange setYear: monthToChange_yearValue andMonth: monthToChange_monthValue];
				}
				
				rosterOffset = rosterMotion_idealDistance;
				firstMonthMonthOffset -= monthDifferenceRetweenRealAndPretendOffset;
				
				
				/*now we've adjusted the roster to return quicly enough, set up time and speed variables based on this, so that animation can begin:*/
				returnRoster_timeTaken = ROSTER_RETURN_TIME_PER_PIXEL * (float)(abs(rosterOffset));
				rosterMotion_startSpeed = -2.0 * rosterOffset / returnRoster_timeTaken;
			}
			
			/*finally compute the rate of constant acceleration that will be required for this to work:*/
			rosterMotion_acceleration = -1.0 * rosterMotion_startSpeed / returnRoster_timeTaken;
			
			/*for the motion callback system, record where we are starting from, set the time counter to zero and determine offset at which the roster should stop moving (0 obviously)*/
			rosterMotion_startOffset = rosterOffset;
			rosterMotion_timeElapsed = 0;
			rosterMotion_endOffset = 0;
			
			/*finally, record in the system that the roster motion has begun:*/
			rosterMotionInProgress = 1;
		
			/*end of touch event, so record this fact and set the button back to normal:*/
			returnToTodayLayerTouchDown = 0;
			returnToTodayLayer.opacity = 0.3;
			[returnToTodayLayer removeAllAnimations];
		}
	
		/*otherwise, analyse the user's motion before they lifted the touch, and keep the roster moving at the same rate for a while:*/
		else 
		{
			/*now that the user has lifted their finger, let the roster keep on moving beneath, at the speed the user left off:*/
			if(currentTouchHorizontalSpeedRecord != 0)
			{
				/*don't allow anything above our constant-defined top speed:*/
				if(fabs(currentTouchHorizontalSpeedRecord) > (float)(ROSTER_MAXIMUM_SPEED))
				{
					if(currentTouchHorizontalSpeedRecord < 0) rosterMotion_startSpeed = -1.0 * (float)(ROSTER_MAXIMUM_SPEED);
					else rosterMotion_startSpeed = (float)(ROSTER_MAXIMUM_SPEED);
				}
				else rosterMotion_startSpeed = currentTouchHorizontalSpeedRecord;
			
				/*acceleration will be the standard rate of deceleration for the roster:*/
				if(rosterMotion_startSpeed > 0) rosterMotion_acceleration = ROSTER_DECELERATION;
				else rosterMotion_acceleration = -1.0 * ROSTER_DECELERATION;
			
				/*for the motion callback system record where we are starting from, determine offset at which the roster should stop moving and set the time counter to zero:*/
				rosterMotion_startOffset = rosterOffset;
				rosterMotion_endOffset = rosterOffset - (rosterMotion_startSpeed * rosterMotion_startSpeed) / (2.0 * rosterMotion_acceleration);
				rosterMotion_timeElapsed = 0;
			
				/*record that roster motion is now in progress:*/
				rosterMotionInProgress = 1;
			}
		}
	}
}


/*******************************************************************************************************************
 
 VARIOUS MINI APP - SPECIFIC IMPLEMENTATIONS OF STANDARD TRANSFORMATION METHODS PLUS EXTRA RELATED METHODS
 
 ********************************************************************************************************************/


- (void)shiftEventBegins
{
	/*if a shift event begins, then immediately put a stop to any roster movement:*/
	rosterMotionInProgress = 0;
}


/*
	shiftEventEnded -	for efficiency, as the user is rapidly and unpredictably dragging views around as part of a shift event, the month subviews are very crudely rescaled. 
						..This method will be called when the user's touch has lifted, signalling that the new position is fairly fixed and so those month subviews can be redrawn correctly:
 */
- (void)shiftEventEnded
{
	/*size the month view base image to the correct current month view size:*/
	[self sizeMonthBaseImageToMonthViewDimensions: self.bounds];
	
	/*now loop through and redraw all the month views:*/
	[self reBuildUIElementsAtCurrentSizeAndResolution];
}


/*
	slightly complicated dut to having to fit in with the roster system
 */
- (void)animateChangeOfBoundsAndCenter:(float)duration toBounds:(CGRect)newBounds andCenter:(CGPoint)newCenter
{
	/*immediately cancel any roster motion:*/
	rosterMotionInProgress = 0;
	
	/*for animation purposes, there we need to record cetain settings now before anything changes:*/
	int currentRTTLayerState = [self returnToTodayStateForBoundsRect: self.bounds isHypothetical: 0];
	
	/*If there will need to be new month views for the new bounds, create these now:*/
	
	/*how many month views will be required for this new rect? */
	int newNumberOfMonthViews;
	
	if(newBounds.size.width > newBounds.size.height)	newNumberOfMonthViews = (int)(newBounds.size.width / newBounds.size.height) + 2;
	else												newNumberOfMonthViews = (int)(newBounds.size.height / newBounds.size.width) + 2;

	
	/*if there are more than we currently have, then new views need to be created to meet this number:*/
	if(newNumberOfMonthViews > numberOfMonthViews)
	{
		/*Now, if we need to add an even number of views, then its half to the beginning, half to the end of the roster, simple. However, if its an odd number, then there will be 1 more view at whichever end of the roster is closer to the middle:*/
		int numberOfMonthViewsToAdd = newNumberOfMonthViews - numberOfMonthViews;
		int numberOfMonthViewsToAddToStart;
		int numberOfMonthViewsToAddToEnd;
		
		if((numberOfMonthViewsToAdd % 2) == 0) numberOfMonthViewsToAddToStart = numberOfMonthViewsToAddToEnd = numberOfMonthViewsToAdd / 2;
		else
		{
			if(abs(firstMonthPosition) < (int)(0.5 * (numberOfMonthViews - 1) * monthViewDimension))
			{
				/*start end is closer to middle:*/
				numberOfMonthViewsToAddToStart = (int)(0.5 * (newNumberOfMonthViews - numberOfMonthViews)) + 1;
				numberOfMonthViewsToAddToEnd = newNumberOfMonthViews - numberOfMonthViews - numberOfMonthViewsToAddToStart;
			}
			else 
			{
				/*end end is closer to middle:*/
				numberOfMonthViewsToAddToStart = (int)(0.5 * (newNumberOfMonthViews - numberOfMonthViews));
				numberOfMonthViewsToAddToEnd = newNumberOfMonthViews - numberOfMonthViews - numberOfMonthViewsToAddToStart;
			}
		}
		
		/*now that we've worked out how many to add to each end, create them and add them! - starting with the ones at the start end, then the ones at the end end:*/
		int neighbourMonthView_year;
		int neighbourMonthView_month;
		calendarMonthView *newMonthView;
		int newMonthView_month, newMonthView_year;
		
		for(int i = 0; i < numberOfMonthViewsToAddToStart; i++)
		{
			/*for each new month view, work out which month and year it is:*/
			neighbourMonthView_year = [[monthViews objectAtIndex: 0] year];
			neighbourMonthView_month = [[monthViews objectAtIndex: 0] month];
			
			newMonthView_month = neighbourMonthView_month - 1;
			newMonthView_year = neighbourMonthView_year;
			
			if(newMonthView_month == 0)
			{
				newMonthView_month = 12;
				newMonthView_year--;
			} 
			
			/*create the month view and add it to the array of subviews:*/
			newMonthView = [[calendarMonthView alloc] initWithFrame:CGRectMake(0.0, 0.0, monthViewDimension, monthViewDimension) andYear: newMonthView_year andMonth: newMonthView_month andBaseImage: monthBaseImage];
			[monthViews insertObject: newMonthView atIndex: 0];
			[self addSubview: newMonthView];
			
			/*position it:*/
			if(rosterDirection == 0)	[newMonthView setCenter: CGPointMake([[monthViews objectAtIndex: 1] center].x - monthViewDimension, 0.5 * monthViewDimension)];
			else						[newMonthView setCenter: CGPointMake(0.5 * monthViewDimension, [[monthViews objectAtIndex: 1] center].y - monthViewDimension)];
		}
		
		for(int i = 0; i < numberOfMonthViewsToAddToEnd; i++)
		{
			/*for each new month view, work out which month and year it is:*/
			neighbourMonthView_year = [[monthViews objectAtIndex: ([monthViews count] - 1)] year];
			neighbourMonthView_month = [[monthViews objectAtIndex: ([monthViews count] - 1)] month];
			
			newMonthView_month = neighbourMonthView_month + 1;
			newMonthView_year = neighbourMonthView_year;
			
			if(newMonthView_month == 13)
			{
				newMonthView_month = 1;
				newMonthView_year++;
			} 
			
			/*create the month view and add it to the array of subviews:*/
			newMonthView = [[calendarMonthView alloc] initWithFrame: CGRectMake(0.0, 0.0, monthViewDimension, monthViewDimension) andYear: newMonthView_year andMonth: newMonthView_month andBaseImage: monthBaseImage];
			[monthViews insertObject: newMonthView atIndex: [monthViews count]];
			[self addSubview: newMonthView];
			
			/*position it:*/
			if(rosterDirection == 0)	[newMonthView setCenter: CGPointMake([[monthViews objectAtIndex: ([monthViews count] - 2)] center].x + monthViewDimension, 0.5 * monthViewDimension)];
			else						[newMonthView setCenter: CGPointMake(0.5 * monthViewDimension, [[monthViews objectAtIndex: ([monthViews count] - 2)] center].y + monthViewDimension)];
		}
		
		
		/*these are now fully fledged views, so make sure the system takes them into account:*/
		numberOfMonthViews = numberOfMonthViews + numberOfMonthViewsToAdd;
		firstMonthPosition += (int)(-1.0 * numberOfMonthViewsToAddToStart * monthViewDimension);
		firstMonthMonthOffset += numberOfMonthViewsToAddToStart;
		
		
	}
	
	
	/*now, record what the current attribues are of the calendar geometry, before then determining what they'll be in the new bounds:*/
	int oldMonthViewDimension = monthViewDimension;
	int oldRosterDirection = rosterDirection;
	int oldRosterOffset = rosterOffset;
	
	[self setUpRosterGeometryForChangedBounds: newBounds];
	
	
	/*if there are fewer months than we currently have, we should schedule the current surplus view to be deleted once they are no longer needed:*/
	
	/*modify the size of the various graphics based on this new view size:*/
	[self sizeMonthBaseImageToMonthViewDimensions: newBounds];
	
	
	/*animate each view to the position it'll take in the new bounds:*/
	for(int i = 0; i < [monthViews count]; i++)
	{
		if(rosterDirection == 0)
			[UIView animateWithDuration: duration animations: 
							^{  [[monthViews objectAtIndex: i] setCenter: CGPointMake(0.5*newBounds.size.width + firstMonthPosition + i * monthViewDimension, 0.5 * monthViewDimension)];
								[[monthViews objectAtIndex: i] setBounds: CGRectMake(0.0, 0.0, monthViewDimension, monthViewDimension)];
							}
			 ];
		
		else
			[UIView animateWithDuration: duration animations: 
							^{  [[monthViews objectAtIndex: i] setCenter: CGPointMake(0.5 * monthViewDimension, 0.5*newBounds.size.height + firstMonthPosition + i * monthViewDimension)];
								[[monthViews objectAtIndex: i] setBounds: CGRectMake(0.0, 0.0, monthViewDimension, monthViewDimension)];
							}
			 ];
	}
	

	/*animate the returnToToday button to its new position and state:*/
	int newRTTLayerState = [self returnToTodayStateForBoundsRect: newBounds isHypothetical: 0];
	
	CGPoint oldPosition, newPosition;
	CATransform3D oldTransform, newTransform;
	
	/*So. If the RTT layer is hidden and will still be hidden at the end of this change of bounds, then don't change it at all.*/
	if( (currentRTTLayerState > 0) || (newRTTLayerState > 0) )
	{
		//NSLog(@"animating from state %d to %d", currentRTTLayerState, newRTTLayerState);
		
		/*If it does go from hidden to visible, or vice-versa, or is visible through out, then animate its position:*/
		oldPosition = [returnToTodayLayer position];
		newPosition = CGPointMake(60.0, newBounds.size.height - 60.0);
		
		[returnToTodayLayerAnim_position setDuration: duration];
		[returnToTodayLayerAnim_position setFromValue: [NSValue value: &oldPosition withObjCType: @encode(CGPoint)]];
		[returnToTodayLayerAnim_position setToValue: [NSValue value: &newPosition withObjCType: @encode(CGPoint)]];
		[returnToTodayLayer setPosition: newPosition];
		[returnToTodayLayer addAnimation: returnToTodayLayerAnim_position forKey: @"position"];
		
		/*Only need to animate its transform if a) its transform changes, and b) its going from visible to still visible:*/
		if( (currentRTTLayerState != newRTTLayerState) && (currentRTTLayerState > 0) && (newRTTLayerState > 0) )
		{
			oldTransform = [returnToTodayLayer transform];
			newTransform = [self getReturnToTodayLayerTransformForOrientation: newRTTLayerState];
			[returnToTodayLayerAnim_transform setDuration: duration];
			[returnToTodayLayerAnim_transform setFromValue: [NSValue value: &oldTransform withObjCType: @encode(CATransform3D)]];
			[returnToTodayLayerAnim_transform setToValue: [NSValue value: &newTransform withObjCType: @encode(CATransform3D)]];
			[returnToTodayLayer setTransform: newTransform];
			[returnToTodayLayer addAnimation: returnToTodayLayerAnim_transform forKey: @"transform"];
		}
		
		/*finally if we're going from hidden->visible or vice-versa, the animate this:*/
		if( (currentRTTLayerState == 0) && (newRTTLayerState > 0) )
		{
			[returnToTodayLayer setOpacity: 0.0];
			[returnToTodayLayer setHidden: NO];
			
			[returnToTodayLayerAnim_opacity setDuration: duration];
			[returnToTodayLayerAnim_opacity setFromValue: [NSNumber numberWithFloat: 0.0]];
			[returnToTodayLayerAnim_opacity setToValue: [NSNumber numberWithFloat: RETURN_TO_TODAY_LAYER_OPACITY]];
			[returnToTodayLayer setOpacity: RETURN_TO_TODAY_LAYER_OPACITY];
			[returnToTodayLayer addAnimation: returnToTodayLayerAnim_opacity forKey: @"opacity"];
		}
		
		if( (currentRTTLayerState > 0) && (newRTTLayerState == 0) )
		{
			[returnToTodayLayerAnim_opacity setDuration: duration];
			[returnToTodayLayerAnim_opacity setFromValue: [NSNumber numberWithFloat: RETURN_TO_TODAY_LAYER_OPACITY]];
			[returnToTodayLayerAnim_opacity setToValue: [NSNumber numberWithFloat: 0.0]];
			[returnToTodayLayer setOpacity: 0.0];
			[returnToTodayLayer addAnimation: returnToTodayLayerAnim_opacity forKey: @"opacity"];
		}
	}

	
	
	
	/*animate the gradient overlay layer towards its new content:*/
	CGRect gradLayerOldBounds = self.bounds;
	CGRect gradLayerNewBounds = newBounds;
	
	[gradientOverlayLayerAnim setDuration: duration];
	[gradientOverlayLayerAnim setFromValue: [NSValue value: &gradLayerOldBounds withObjCType: @encode(CGRect)]];
	[gradientOverlayLayerAnim setToValue: [NSValue value: &gradLayerNewBounds withObjCType: @encode(CGRect)]];
	[gradientOverlayLayer setBounds: newBounds];
	[gradientOverlayLayer addAnimation: gradientOverlayLayerAnim forKey: @"bounds"];
	
	[gradientOverlayLayerContentAnim setDuration: duration];
	[gradientOverlayLayerContentAnim setToValue: [NSValue value: &gradientOverlayGradientImage withObjCType: @encode(CGImageRef)]];
	[gradientOverlayLayer setContents: (id)gradientOverlayGradientImage];
	[gradientOverlayLayer addAnimation: gradientOverlayLayerContentAnim forKey: @"contents"];
	
	
	
	/*ensure no complex layoutSubviews code is run, as it can interfere with the smooth running of the animation:*/
	disableManualLayout = 1;
	
	/*now animate the whole view, and set all functionality back to rights when finished:*/
	[UIView animateWithDuration: duration animations: ^{ [self setBounds: newBounds]; [self setCenter: newCenter]; } completion: ^(BOOL finished) { [self setNeedsLayout]; [self reBuildUIElementsAtCurrentSizeAndResolution]; disableManualLayout = 0; } ];
}


/*
	For this calendar mini app, contraction simply involves scaling down the view, month views and RTT layer all together:
*/
- (void)contract: (float)duration;
{
	/*disable any layout during animation:*/
	disableManualLayout = 1;
	
	/*immediately halt any roster motion:*/
	rosterMotionInProgress = 0;
	
	/*scale all month views down to nothing at the same time as this, the parent, scales down:*/
	for(int i = 0; i < [monthViews count]; i++)
	{
		CGRect testBounds = [[monthViews objectAtIndex: i] bounds];
		
		[UIView animateWithDuration: duration animations: ^{ [[monthViews objectAtIndex: i] setFrame: CGRectMake(0, 0, 0, 0)]; } ];
	}
	
	/*also animate the RTT layer scaling down:*/
	CGPoint oldPosition = [returnToTodayLayer position];
	CGPoint newPosition = CGPointMake(0, 0);
	CGRect oldBounds = [returnToTodayLayer bounds];
	CGRect newBounds = CGRectMake(0, 0, 0, 0);
	
	[returnToTodayLayerAnim_position setDuration: duration];
	[returnToTodayLayerAnim_position setFromValue: [NSValue value: &oldPosition withObjCType: @encode(CGPoint)]];
	[returnToTodayLayerAnim_position setToValue: [NSValue value: &newPosition withObjCType: @encode(CGPoint)]];
	
	[returnToTodayLayerAnim_bounds setDuration: duration];
	[returnToTodayLayerAnim_bounds setFromValue: [NSValue value: &oldBounds withObjCType: @encode(CGRect)]];
	[returnToTodayLayerAnim_bounds setToValue: [NSValue value: &newBounds withObjCType: @encode(CGRect)]];
	
	
	[returnToTodayLayer setPosition: newPosition];
	
	
	[returnToTodayLayer setBounds: newBounds];
	
	[returnToTodayLayer addAnimation: returnToTodayLayerAnim_position forKey: @"position"];
	[returnToTodayLayer addAnimation: returnToTodayLayerAnim_bounds forKey: @"bounds"];
	
	
	/*if contracting while disabled, the darken top layer will look fine automatically when scaled down. But hide it if this view is not disabled, otherwise it might appear suddenly:*/
	if(miniAppIsDisabled == 0) [darkenTopLayer setHidden: YES];
	

	/*now simply scale down the view to nothing:*/
	[UIView animateWithDuration: duration animations: ^{[self setFrame: CGRectMake(self.frame.origin.x + (int)(0.5 * self.frame.size.width), self.frame.origin.y + (int)(0.5 * self.frame.size.height), 0, 0)]; } ];
}


/*
 shouldMiniAppBeDisabledGivenBounds - given a rectangular bounds, this method simply returns true or false to whether the bounds size means the mini app should be disabled (subclasses can override this method to provide their own criteria)
 */
- (BOOL)shouldMiniAppBeDisabledGivenBounds: (CGRect)bounds_in
{
	if( (bounds_in.size.width < CALENDARMINIAPP_MINIMUM_ENABLED_WIDTH_HEIGHT) || (bounds_in.size.height < CALENDARMINIAPP_MINIMUM_ENABLED_WIDTH_HEIGHT) ) return YES;
	return NO;
}


/*
 quit - this will be called by the parent view just before it removes this view, triggering dealloc(). Safe in the knowledge that this app's useful life is now over, use this method to remove any retain cycles, e.g. shared ownership by a display link:
 */
- (void)quit
{	
	disableManualLayout = 1;
	[rosterMovementDisplayLink invalidate];
}


- (void)dealloc 
{
	/*remove base images (both raw and current):*/
	CGImageRelease(monthBaseImage_raw);
	CGImageRelease(monthBaseImage);
	CGImageRelease(returnToTodayImage);
	
	/*release animation objects:*/
	[gradientOverlayLayerAnim release];
	[gradientOverlayLayerContentAnim release];
	
	[returnToTodayLayerAnim_position release];
	[returnToTodayLayerAnim_bounds release];
	[returnToTodayLayerAnim_transform release];
	[returnToTodayLayerAnim_opacity release];
	
	/*release gradient related objects:*/
	CGFunctionRelease(gradientShadingFunction);
	CGShadingRelease(horizontalGradientShading);
	CGImageRelease(gradientOverlayGradientImage);
	
	/*remove all the month views:*/
	[monthViews removeAllObjects];
	[monthViews release];
	
	[super dealloc];
}


@end
