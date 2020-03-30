//
//  webBrowserMiniAppView.h
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


/*
	we create a simple subclass of the UITextField class which will be used for the web mini app's URL entry field. The sublass is just to overrride a couple of methods related to first responder status
 */
@interface UITextField_subclass : UITextField
{
}

@end


@interface webBrowserMiniAppView : miniAppView <UITextFieldDelegate, UIWebViewDelegate> {

	UIWebView *webView;
	
	CALayer *webViewProxy;
	CABasicAnimation *webViewProxyAnim_pos;
	CABasicAnimation *webViewProxyAnim_bounds;
	
	CALayer *webLoadingCover;
	CABasicAnimation *webLoadingCoverAnim_pos;
	CABasicAnimation *webLoadingCoverAnim_bounds;
	
	UIActivityIndicatorView *webLoadingIndicator;
	UITextField_subclass *URLEntryView;
	
	CALayer *backButton;
	CALayer *forwardButton;
	CALayer *stopButton;
	CALayer *reloadButton;
	
	CABasicAnimation *backButtonAnim_pos;
	CABasicAnimation *backButtonAnim_bounds;
	CABasicAnimation *forwardButtonAnim_pos;
	CABasicAnimation *forwardButtonAnim_bounds;
	CABasicAnimation *stopButtonAnim_pos;
	CABasicAnimation *stopButtonAnim_bounds;
	CABasicAnimation *reloadButtonAnim_pos;
	CABasicAnimation *reloadButtonAnim_bounds;
	
	int buttonDown;
	
	int shiftEventInProgress;
	CGSize webViewSizeAtStartOfShiftEvent;
	
	int webLoadingInProgress;
	
	CGImageRef buttonGraphics_back_off;
	CGImageRef buttonGraphics_back_on;
	CGImageRef buttonGraphics_forward_off;
	CGImageRef buttonGraphics_forward_on;
	CGImageRef buttonGraphics_stop_off;
	CGImageRef buttonGraphics_stop_on;
	CGImageRef buttonGraphics_reload_off;
	CGImageRef buttonGraphics_reload_on;
	
	int disableManualLayout;
}

- (void)generateBackgroundContent;

- (void)createButtonGraphics;
- (void)drawWebLoadingCoverGradient;
- (void)carbonCopyWebViewContents;
- (void)setButtonStates;

- (void)urlEntryViewDidBecomeFirstResponder;
- (CGPoint)determineWhetherViewNeedsToBeExemptedInHypotheticalSituation: (int)hypoOrientation center: (CGPoint)hypoCenter bounds: (CGRect)hypoBounds;
- (void)urlEntryViewDidResignFirstResponder;


@end
