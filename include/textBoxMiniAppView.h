//
//  textBoxMiniAppView.h
//  Paductivity
//
//  Created by William Alexander on 15/10/2010.
//  Copyright 2010 Framestore-CFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CAMediaTimingFunction.h>
#import <QuartzCore/CADisplayLink.h>

#import "utilities.h"

#import "miniAppView.h"


#define TEXTBOXMINIAPP_SHADEDSTRIPWIDTH 305
#define TEXTBOXMINIAPP_SHADEDSTRIPHEIGHT 5

#define TEXTBOXMINIAPP_RULEDLINESGAP 25

#define TEXTBOXMINIAPP_MINIMUM_ENABLED_WIDTH 154


@interface UITextView_subclass : UITextView
{
	int switchedOff;
}

- (void)setSwitchedOff: (int)switchedOffValue;

@end


@interface textBoxMiniAppView : miniAppView
{
	/*CALayer and associated animations for the shaded graphic strip:*/
	CALayer *shadedStripLayer;
	CABasicAnimation *shadedStripLayerAnim_position;
	CABasicAnimation *shadedStripLayerAnim_bounds;
	
	/*CALayer and associated animations for the ruled lines graphic*/
	CALayer *ruledLinesLayer;
	CABasicAnimation *ruledLinesLayerAnim_position;
	CABasicAnimation *ruledLinesLayerAnim_bounds;
	int ruledLinesOffset;
	
	/*UITextView that handles the text:*/
	UITextView_subclass *textView;
	
	
	/*for switching off the 'layoutSubviews()' method*/
	int disableManualLayout;

	
	/*We need a display link to allow the background paper graphic to match the UITextView's movement everytime the display is drawn:*/
	CADisplayLink *textMovementDisplayLink;
	
	/*we keep a record of whether we're in text entry mode (if the textView is the first responder) or not*/
	int textViewIsFirstResponder;
	
	/*variables for dealing with exemption:*/
	int textViewHeightDuringExemption;
	
	/*for collecting touch hits to distinguish between single and double touches:*/
	CGPoint *collectedTouches;
	int numTouchesCollected;
}

- (void)updateScrolling;

- (void)collectAndAnalizeHitTestTouches;
- (void)keyboardWillShow:(NSNotification *)theNotification;
- (void)keyboardWillHide;

- (CGPoint)determineWhetherViewNeedsToBeExemptedInHypotheticalSituation: (int)hypoOrientation center:(CGPoint) hypoCenter bounds: (CGRect)hypoBounds;


@end
