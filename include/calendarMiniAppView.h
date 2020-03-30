//
//  calendarMiniAppView.h
//  Paductivity
//
//  Created by William Alexander on 20/10/2010.
//  Copyright 2010 Framestore-CFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/CADisplayLink.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CAMediaTimingFunction.h>

#import "utilities.h"

#import "miniAppView.h"


#define ROSTER_DECELERATION -1000.0
#define ROSTER_MAXIMUM_SPEED 3500
#define ROSTER_RETURN_TIME_PER_PIXEL 0.0008
#define ROSTER_RETURN_MAX_ACCEPTABLE_TIME 3
#define RETURN_TO_TODAY_LAYER_OPACITY 0.3 

#define CALENDARMINIAPP_MINIMUM_ENABLED_WIDTH_HEIGHT 50


/*calendarMonthView - this view's job is to display one single calendar month:*/
@interface calendarMonthView : UIView
{
	int year;
	int month;
	
	unsigned char year_str[5];
	unsigned char month_str[8];
	int month_str_len;
	
	int month_startDay;
	int month_length;
	
	CGImageRef baseImage;
}

- (id)initWithFrame:(CGRect)frame andYear:(int)year_in andMonth:(int)month_in andBaseImage:(CGImageRef)baseImage_in;
- (void)setBaseImage:(CGImageRef)baseImage_in;
- (void)setYear:(int)year_in andMonth:(int)month_in;
- (int)month;
- (int)year;
- (int)isLeapYear:(int)year_in;

@end



@interface calendarMiniAppView : miniAppView 
{
	CGRect currentBounds;
	
	int monthViewDimension;
	int numberOfMonthViews;
	
	CFGregorianDate currentDate_gregorian;
	
	NSMutableArray *monthViews;
	
	CGImageRef monthBaseImage_raw;
	CGImageRef monthBaseImage;
	CGImageRef returnToTodayImage;
	
	/*layer that site on top of the view to give it some nice vignette, Also create a CAAnimation object to animate it with when necessary:*/
	CALayer *gradientOverlayLayer;
	CABasicAnimation *gradientOverlayLayerAnim;
	CABasicAnimation *gradientOverlayLayerContentAnim;
	
	CGFunctionRef gradientShadingFunction;
	CGShadingRef horizontalGradientShading;
	CGImageRef gradientOverlayGradientImage;
	
	
	CALayer *returnToTodayLayer;
	int returnToTodayLayerTouchDown;
	CABasicAnimation *returnToTodayLayerAnim_position;
	CABasicAnimation *returnToTodayLayerAnim_bounds;
	CABasicAnimation *returnToTodayLayerAnim_transform;
	CABasicAnimation *returnToTodayLayerAnim_opacity;
	
	float currentTouchTimeRecord;
	float currentTouchHorizontalSpeedRecord;
	
	int rosterDirection;
	int rosterOffset;
	int firstMonthPosition;
	int firstMonthMonthOffset;
	
	/*'suvat' values for when animating the months roster in motion:*/
	float rosterMotion_timeElapsed;
	int rosterMotion_startOffset;
	float rosterMotion_startSpeed;
	float rosterMotion_acceleration;
	int rosterMotion_endOffset;
	int rosterMotionInProgress;
	
	CADisplayLink *rosterMovementDisplayLink;
	
	/*switch for manual layout*/
	int disableManualLayout;
}

- (void)initialiseAssetsForGraphicsRescaling;

- (void)setUpRosterGeometryForChangedBounds: (CGRect)newBounds;
- (void)sizeMonthBaseImageToMonthViewDimensions: (CGRect)targetRect;
- (void)sizeGradientImageToNewBounds: (CGRect)targetRect withOrientation: (int)rosterOrientation;
- (void)reBuildUIElementsAtCurrentSizeAndResolution;

- (int)returnToTodayStateForBoundsRect: (CGRect)rect isHypothetical: (int)isHypo;
- (CATransform3D)getReturnToTodayLayerTransformForOrientation: (int)orientation;

- (void)shiftMonthsRoster:(int)shiftAmount;
- (void)monthViewsShiftCallback:(CADisplayLink *)displayLink;


@end
