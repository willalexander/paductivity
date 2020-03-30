//
//  calculatorMiniAppView.h
//  Paductivity
//
//  Created by William Alexander on 20/10/2010.
//  Copyright 2010 Framestore-CFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CAMediaTimingFunction.h>

#import "utilities.h"

#import "miniAppView.h"


#define CALCULATORMINIAPPVIEW_MIN_VIEW_ACTIVE_SIZE 200 
#define CALCULATOR_BUTTON_CORNER_RADIUS 0.13
#define CALCULATOR_DIGIT_WIDTH 54
#define CALCULATOR_MAX_DIGITS 12
#define CALCULATOR_MINI_APP_MINIMUM_BUTTON_DIMEMSION 40


/*
	this view subclass will be used for each of the calculator buttons. Each view has an id that tells it which button it is('1', '2', '=' etc)
*/
@interface calculatorButtonView: UIView
{
	int buttonId;
	char buttonSymbol[2];
	
	int pressedOn;

	float textShiftToCentre[17][2];
	
	/*for dectecting double taps:*/
	int doubleTap_oneTapDown;
	CGPoint touchStartLocation;
	CGPoint touchEndLocation;
}

- (id)initWithFrame:(CGRect)frame andId:(int)buttonId_in;
- (void)drawToContext: (CGContextRef)theContext inParentSpace: (BOOL)ifInParentSpace;
- (void)setPressed: (BOOL)pressed;

@end



/*
	this view contains the digits on the screen
*/
@interface calculatorDigitsView : UIView
{
	CALayer *contentSublayer;
	
	CGImageRef digitGraphics[8];
	int digitGraphicsRectOffsets[8][4];
	int digitGraphicsVisibilities[10][7];
	
	int numDigitsCurrentlyDisplayed;
	
	int layoutStyle;
}

- (void)generateDigitGraphics;
- (void)drawDigitsForNumber: (int *)intStr ofLength: (int)strLength andDecimalPointPos: (int)decimalPointPos isNegative: (int)isNegative;
- (CGRect)roundedDiscreteFrame: (CGRect)allowedFrame;
- (void)setLayoutStyle: (int)layoutStyle_in;
- (void)animateDigitsIfNecessaryForNewFrame: (CGRect) screenDigitsViewNewFrame withDuration: (float)duration;

- (CALayer *)contentSublayer;
@end



@interface calculatorMiniAppView : miniAppView 
{	
	/*the actual current number in memory and to be displayed:*/
	int currentNumberOom;
	int currentNumberSignOverride;
	double storedNumber;
	
	/*variables relating to the actual core calculations:*/
	double primaryOperand;
	int decimalPlaces;
	
	

	/*event state info:*/
	int touchWentDownOnKey_i, touchWentDownOnKey_j;
	
	
	/*variables for keeping track of the number currently on screen:*/
	int *digitDisplayArray;
	int numDigits;
	int decimalPointPos;
	int screenNumberIsPositive;
	int widthSpaceRequired;
	
	
	/*variables for keeping track of what operation (if any) is currently in progress, and what 'action'/input mode we are in:*/
	int operationInProgress;
	int actionMode;
	/* 'actionMode' keeps track of what stage the current number being input is at. The values mean as follows:
	 
	 0: Number is being input. Specifically the integer part of the number.
	 1: Number is being unput. Specifically the fractional part of the number.
	 2: User has just pressed an operation button. The screen continues to show the last entered number. The minute another digit button is pressed, this screen number is cleared and a new  number is started with the digit in question
	 3: User has just pressed the equals button. The screen continues to show the resultant number. If they choose to then use an operation, then this resultant number becomes an operand to a new operation. If the user presses a digit button, all is cleared and a new number started
	 
	 There is a number on screen left over from a previous calculation. If an operation button is pressed next, this number will be used as an operand. If a digit button is pressed, this number will be cleared and the user's new digit will start a new number
	 */
	
	
	/*The calculator screen is made up of two CALayers and a view stacked on top of each other:*/
	CALayer *screenBase;
	calculatorDigitsView *screenDigits;
	CALayer *screenSheen;
	
	/*animation objects for the screen elements:*/
	CABasicAnimation *screenBaseAnim;
	CABasicAnimation *screenDigitsSublayerAnim;
	CABasicAnimation *screenSheenAnim;
	
	
	/*geometric info about current screen layout and button layout:*/
	int buttonLayouts[5][17][2];
	int keypadLayout;
	int keypadDimensions[2];
	int keySquareSize;
	int buttonDimension;
	
	/*We keep an array of the subviews that form the calculator buttons and an array of CALayers for the shadows beneath:*/
	NSMutableArray *buttonSubviews;
	NSMutableArray *buttonShadowLayers;
	
	/*animation objects that will be used to move these buttons elegantly when need be:*/
	NSMutableArray *buttonShadowLayersAnims;
	NSMutableArray *screenComponentLayersAnims;
	
	
	/*a set on CGImages are kept for the button graphics, so that all buttons can efficiently re-use the same base graphics:*/
	CGImageRef buttonGraphics_light_off;
	CGImageRef buttonGraphics_light_on;
	CGImageRef buttonGraphics_dark_off;
	CGImageRef buttonGraphics_dark_on;
	CGImageRef buttonGraphics_shadow;
	
	
	UITouch *pressedButtonTouch;
	int pressedButton;
	
	
	CGPoint touchStartLocation;
	CGPoint touchEndLocation;
	
	/*as well as drawing its interface to the screen, this view will maintain an offscreen version of its content in a CGLayer:*/
	CGLayerRef offScreenContent;
	CGContextRef offScreenContentContext;
	
	int drawOffScreenContentToScreen;
	
	
	/*nice embossed logo to show in any empty spaces:*/
	CALayer *niceEmbossedLogoLayer;
	
	
	/*a switch to determine whether the view goes throught the long process of laying out subviews/layers (switch made available so that this can be avoided if necessary):*/
	int disableManualLayout;
	int redrawContentInSettledFrame_ready;
	
	
	UIView *testSubview;
}


- (void)defineButtonLayouts;
- (void)generateScreenLayersGraphics;
- (void)setupOffScreenContentLayer: (CGContextRef)contextRef withSize: (CGSize)sizeForContext;
- (void)determineButtonLayoutInfoForFrame: (CGRect)frameToFit drawableSpace: (CGRect *)drawableSpace_out buttonsLayoutConfig: (int *)buttonsLayoutConfig_out numButtonsI: (int *)numButtonsI_out numButtonsJ: (int *)numButtonsJ_out buttonDimension: (int *)buttonDimension_out keyLayoutBound: (int *)keyLayoutBound_out; 
- (void)determineButtonFrameGivenIndex: (int)b drawableSpace: (CGRect)drawableSpace_in buttonsLayoutConfig: (int)buttonsLayoutConfig_in numButtonsI: (int)numButtonsI_in numButtonsJ: (int)numButtonsJ_in buttonDimension: (int)buttonDimension_in keyLayoutBound: (int)keyLayoutBound_in frame: (CGRect *)frame_out;
- (void)layoutButtons;
- (void)generateButtonGraphicsForCurrentLayout;
- (CGImageRef)returnButtonGraphicsForType:(int)typeToReturn;

- (void)setScreenDigits;
- (void)drawToContext: (CGContextRef)theContext;

- (void)buttonEvent: (int)buttonId;
- (double)convertNumberToDouble;
- (void)convertDoubleToScreenDigits: (double)in_double;

- (void)contractAnimation: (NSTimer *)theTimer;
- (void)drawFullUIIntoOffScreenLayer;

@end
