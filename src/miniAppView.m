//
//  miniAppView.m
//  Paductivity
//
//  Created by William Alexander on 15/10/2010.
//  Copyright 2010 Framestore-CFC. All rights reserved.
//


#import "miniAppView.h"



@implementation miniAppView

@synthesize rootPanelView;
@synthesize expectingToReceiveEvents;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
    
		
		[self setContentMode: UIViewContentModeRedraw];
		[self setMultipleTouchEnabled: 1];
		[self setExclusiveTouch: 1];
		
		[self setBackgroundColor: [UIColor blackColor]];
		
		
		/*rounded corners of 'MINI_APP_CORNER_RADIUS' radius and clipped boundaryies are common to all mini apps:*/
		[self setClipsToBounds: YES];
		[[self layer] setCornerRadius: MINI_APP_CORNER_RADIUS];
		[[self layer] setMasksToBounds: YES];
		
		/*create a black layer to fit above all others, initially hidden, but made visible if the mini app becomes 'disabled':*/
		darkenTopLayer = [CALayer layer];
		[darkenTopLayer setFrame: [self bounds]];
		[darkenTopLayer setBackgroundColor: [[UIColor blackColor] CGColor]];
		[darkenTopLayer setOpacity: MINI_APP_DISABLED_OPACITY];
		[darkenTopLayer setHidden: YES];
		
		[[self layer] addSublayer: darkenTopLayer];
		[darkenTopLayer setZPosition: 10.0];
		
		darkenTopLayerAnim_pos = [CABasicAnimation animationWithKeyPath: @"position"];
		[darkenTopLayerAnim_pos setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[darkenTopLayerAnim_pos retain];
		darkenTopLayerAnim_bounds = [CABasicAnimation animationWithKeyPath: @"bounds"];
		[darkenTopLayerAnim_bounds setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[darkenTopLayerAnim_bounds retain];
		
		
		/*by default, mini app is not disabled:*/
		miniAppIsDisabled = 0;
		
		/*by default, mini app is not exempted:*/
		viewIsCurrentlyExempted = 0;
		
		/*no touch town yet (!)*/
		touchAlreadyDown = 0;
	}
    return self;
}


- (CALayer *)returnDarkenTopLayer
{
	return darkenTopLayer;
}

/*
	Whenever the view's bounds change, make sure the 'darkenTopLayer' fills the bounds. If the view has got to a shape at which it should be disabled, then make this so:
 */

- (void)layoutSubviews
{
	/*First of all move the darkenTopLayer to fill this view's frame: (go over the edges to provide us with some slack in case layer animation shows through)*/
	CGRect viewBounds = [self bounds];
	[darkenTopLayer setFrame: CGRectMake(-100, -100, viewBounds.size.width + 200, viewBounds.size.height + 200)];
	[darkenTopLayer removeAllAnimations];
	
	
	/*If this mini app is currently running as normal, this new frame may require it to be disabled. if so then make the darken top layer visible:*/
	if(miniAppIsDisabled == 0) 
	{
		if([self shouldMiniAppBeDisabledGivenBounds: [self bounds]] == YES) 
		{
			[darkenTopLayer setHidden: NO];
			miniAppIsDisabled = 1;
		}
	}
	
	/*similarly, if the app is currently disabled this new frame might mean it should be enabled:*/
	else 
	{
		if([self shouldMiniAppBeDisabledGivenBounds: [self bounds]] == NO) 
		{
			[darkenTopLayer setHidden: YES];
			miniAppIsDisabled = 0;
		}
	}
}


/*
	shouldMiniAppBeDisabledGivenBounds - given a rectangular bounds, this method simply returns true or false to whether the bounds size means the mini app should be disabled (subclasses can override this method to provide their own criteria)
 */
- (BOOL)shouldMiniAppBeDisabledGivenBounds: (CGRect)bounds_in
{
	if( (bounds_in.size.width < MINI_APP_MINIMUM_ENABLED_WIDTH_HEIGHT) || (bounds_in.size.height < MINI_APP_MINIMUM_ENABLED_WIDTH_HEIGHT) ) return YES;
	return NO;
}

/*getter function - allows a caller to query whether this mini app is currently disabled:*/
- (NSValue *)isMiniAppDisabled
{
	if(miniAppIsDisabled == 0) return [NSNumber numberWithBool: NO];
	else return [NSNumber numberWithBool: YES];
}


- (int)hitTestOverride:(CGPoint)point
{
	return 0;
}

- (int)getPanelTreeDescNodePointer
{
	return panelTreeDescNodePointer;
}

-(void)setPanelTreeDescNodePointer:(int)pointerIn
{
	panelTreeDescNodePointer = pointerIn;
	panelTreeDesc thePanelTreeDescNode = *( (panelTreeDesc *)(pointerIn) );
}


/*
	stubs - subclasses can implement these method if they choose
 */
- (void)shiftEventBegins
{
}

- (void)shiftEventEnded
{
	[self redrawContentInSettledFrame];
}

- (void)redrawContentInSettledFrame
{
	[rootPanelView miniAppViewDidFinishRedrawingInSettledFrame: self];
}

- (void)expand:(float)duration toFrame:(CGRect)newFrame
{
}

- (void)contract: (float)duration
{
	CGRect contractedFrame = CGRectMake((int)(self.frame.origin.x + 0.5 * self.frame.size.width), (int)(self.frame.origin.y + 0.5 * self.frame.size.height), 0, 0);
	[UIView animateWithDuration: duration animations: ^{ [self setFrame: contractedFrame]; } ];
}


/*
	touch event handling
*/
/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(touchAlreadyDown == 0) touchAlreadyDown = 1;
	else if(touchAlreadyDown == 1)
	{
		touchAlreadyDown++;
	}
	else
	{
		touchAlreadyDown++;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	touchAlreadyDown--;
}*/


/*
	truncate - called when a new mini app menu is opened. This view must animate itself from its current frame to the new frame provided, in the time indicated by 'duration'
*/
- (void)truncate: (float)duration toFrame:(CGRect)newFrame
{
	[UIView animateWithDuration: duration animations: ^{ [self setFrame: newFrame]; } ];
}

- (void)animateChangeOfBoundsAndCenter: (float)duration toBounds: (CGRect)newBounds andCenter: (CGPoint)newCenter
{
	[UIView animateWithDuration: duration animations: ^{ [self setBounds: newBounds]; [self setCenter: newCenter]; } ];
}


/*
	METHODS FOR DEALING WITH MINI APP VIEW EXEPMTION
 */

/*
	miniAppViewExemptionWillStart - this method will be called when the mini app is about to be animated to its exemption position. This is the chance to make any other desired changes to the mini app view's state hen exempted:
 */
- (void)miniAppViewExemptionWillStart
{
}

/*
 miniAppViewExemptionWillEnd - this method will be called when the mini app is about to be animated back away from its exemption position. This is the chance to make any internal changes to the mini app view's state after exemption:
 */
- (void)miniAppViewExemptionWillEnd;
{
}

/*
	shouldBeExemptedInNewHypotheticalOrientation - this method will be called when the parent panel view is about to rotate all mini apps as a result of device reorientation. It will be passed information about its position/state in that new orientation (hence 'hypothetical'). If it decides that it should be exempted in that orientation, then it returns YES here. 
													By default, any miniAppView returns no to this:
 */
- (BOOL)shouldViewBeExemptedInHypotheticalOrientation: (int)hypoOrientation center: (CGPoint)hypoCenter bounds: (CGRect)hypoBounds withNewCenter: (CGPoint *)newCenter_out;
{
	return NO;
}

/*
	quit - default does nothing, but subclasses can override if they need to
 */
- (void)quit
{
}

- (void)dealloc 
{
	/*release animation objects:*/
	[darkenTopLayerAnim_pos release];
	[darkenTopLayerAnim_bounds release];
	
    [super dealloc];
}

@end
