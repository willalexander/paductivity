//
//  miniAppView.h
//  Paductivity
//
//  Created by William Alexander on 15/10/2010.
//  Copyright 2010 Framestore-CFC. All rights reserved.
//

#define DOUBLE_TAP_TIME_THRESHOLD 0.1
#define DOUBLE_TAP_SPACE_THRESHOLD 25
#define MINI_APP_MINIMUM_ENABLED_WIDTH_HEIGHT 200
#define MINI_APP_DISABLED_OPACITY 0.7
#define MINI_APP_CORNER_RADIUS 5.0


#import <UIKit/UIKit.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CAMediaTimingFunction.h>

#import "panelTreeDesc.h"


@interface miniAppView : UIView {

	int panelTreeDescNodePointer;
	
	UIView *rootPanelView;
	int expectingToReceiveEvents;
	
	int touchAlreadyDown;
	
	CALayer *darkenTopLayer;
	int miniAppIsDisabled;
	
	CABasicAnimation *darkenTopLayerAnim_pos;
	CABasicAnimation *darkenTopLayerAnim_bounds;
	
	int viewIsCurrentlyExempted;
}

- (CALayer *)returnDarkenTopLayer;


- (int)hitTestOverride:(CGPoint)point;
- (int)getPanelTreeDescNodePointer;
- (void)setPanelTreeDescNodePointer: (int)pointerIn;

- (NSValue *)isMiniAppDisabled;
- (BOOL)shouldMiniAppBeDisabledGivenBounds: (CGRect)bounds_in;

/*These are the standard transformation methods that any mini app *must* implement in order to work within the panel system. They are all the various transformations of bounds/center that can happen to the mini app:*/
- (void)shiftEventBegins;
- (void)shiftEventEnded;
- (void)redrawContentInSettledFrame; // - ACTUALLY NEEDED??
- (void)animateChangeOfBoundsAndCenter: (float)duration toBounds: (CGRect)newBounds andCenter: (CGPoint)newCenter;
- (void)contract: (float)duration;

- (void)miniAppViewExemptionWillStart;
- (void)miniAppViewExemptionWillEnd;
- (BOOL)shouldViewBeExemptedInHypotheticalOrientation: (int)hypoOrientation center: (CGPoint)hypoCenter bounds: (CGRect)hypoBounds withNewCenter: (CGPoint *)newCenter_out;

- (void)quit;


@property (nonatomic, retain) UIView *rootPanelView;
@property int expectingToReceiveEvents;

@end
