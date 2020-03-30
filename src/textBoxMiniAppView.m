//
//  textBoxMiniAppView.m
//  Paductivity
//
//  Created by William Alexander on 15/10/2010.
//  Copyright 2010 Framestore-CFC. All rights reserved.
//


#import "textBoxMiniAppView.h"


@implementation UITextView_subclass

- (id)initWithFrame:(CGRect)frame
{
	if(self == [super initWithFrame: frame])
	{
		switchedOff = 0;
	}
	
	return self;
}

- (void)setSwitchedOff: (int)switchedOffValue
{
	switchedOff = switchedOffValue;
}

- (BOOL)canBecomeFirstResponder
{
	if(switchedOff == 1) return NO;
	return YES;
}

- (BOOL)becomeFirstResponder
{
	if (switchedOff == 1) return NO;
	
	[self.superview keyboardWillShow: nil];
	return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
	[self.superview keyboardWillHide];
	return [super resignFirstResponder];
}


@end



@implementation textBoxMiniAppView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) 
	{
		/*we don't need multi touch for this mini app:*/
		self.multipleTouchEnabled = 0;
		
		/*the base of the background graphics is always white:*/
		self.backgroundColor = [UIColor whiteColor];
		
		/*over the top of this will be a nice shaded 'strip' graphic that gives the impression of a folded page. This is stetchable and will be drawn in a separate layer. Create this here:*/
		CGImageRef shadedStripImage = [utilities openCGResourceImage: @"shadedStrip" ofType: @"png"];
		
		shadedStripLayer = [CALayer layer];
		[shadedStripLayer setBackgroundColor: [[UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.0] CGColor]];
		[shadedStripLayer setFrame: CGRectMake(0, 0, TEXTBOXMINIAPP_SHADEDSTRIPWIDTH, TEXTBOXMINIAPP_SHADEDSTRIPHEIGHT)];
		[shadedStripLayer setContents: (id)shadedStripImage];
		[[self layer] addSublayer: shadedStripLayer];
		
		shadedStripLayerAnim_position = [CABasicAnimation animationWithKeyPath: @"position"];
		[shadedStripLayerAnim_position setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[shadedStripLayerAnim_position retain];
		
		shadedStripLayerAnim_bounds = [CABasicAnimation animationWithKeyPath: @"bounds"];
		[shadedStripLayerAnim_bounds setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[shadedStripLayerAnim_bounds retain]; 
			
		/*On top of the paper color, draw a the paper's ruled lines will be drawn as a separate layer:*/
		CGImageRef ruledLinesImage = [utilities openCGResourceImage: @"ruledLines" ofType: @"png"];
		
		ruledLinesLayer = [CALayer layer];
		[ruledLinesLayer setBackgroundColor: [[UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.0] CGColor]];
		[ruledLinesLayer setFrame: CGRectMake(0, 0, 70, 1054)];
		[ruledLinesLayer setContents: (id)ruledLinesImage];
		[ruledLinesLayer setContentsCenter: CGRectMake(0.95, 0.0, 0.05, 1.0)];
		[[self layer] addSublayer: ruledLinesLayer];
		
		ruledLinesLayerAnim_position = [CABasicAnimation animationWithKeyPath: @"position"];
		[ruledLinesLayerAnim_position setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[ruledLinesLayerAnim_position retain];
		
		ruledLinesLayerAnim_bounds = [CABasicAnimation animationWithKeyPath: @"bounds"];
		[ruledLinesLayerAnim_bounds setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[ruledLinesLayerAnim_bounds retain]; 
		
		/*the lines begin at their set position, with an 'offset' of zero which will change if the user moves the text up or down:*/
		ruledLinesOffset = 0;
		
		
		/*The actual text content will be handled by a UITextView:*/
		textView = [[UITextView_subclass alloc] initWithFrame: CGRectMake(65, 0, frame.size.width - 70, frame.size.height)];
		[textView setBackgroundColor: [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.0]];
		[textView setFont: [UIFont fontWithName: [[UIFont familyNames] objectAtIndex: 6] size: 21] ];
		[textView setSwitchedOff: 1];
		
		[self addSubview: textView];
		
		
		/*Make sure that as the view frame changes, the text view is autoresized to maintain its position relative to this view's edges:*/
		[self setAutoresizesSubviews: YES];
		[textView setAutoresizingMask: (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	
		
		/*Set up a CADisplayLink to give us a callback method in the run loop that's in sync with the display updating:*/
		textMovementDisplayLink = [CADisplayLink displayLinkWithTarget: self selector: @selector(updateScrolling)];
		[textMovementDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode: NSRunLoopCommonModes];
	
		
		/*for certain fast animations of this view's frame changing, we'll want to suspend the manual laying out of subviews. for now though, all ow it to happen:*/
		disableManualLayout = 0;

		
		/*clean up the CGImages we've just created and applied:*/
		CGImageRelease(shadedStripImage);
		CGImageRelease(ruledLinesImage);
		
		
		/*the hit test method will need to collect touches in order to distinguish between single and double taps:*/
		collectedTouches = (CGPoint *)malloc(50 * sizeof(CGPoint));
		numTouchesCollected = 0;
		
		/*we keep a record of whether we're in text entry mode (if the textView is the first responder) or not*/
		textViewIsFirstResponder = 0;
		
		/*we want to be notified if the keyboard is launched and dismissed by the user, as this represents us leaving text entry mode*/
		//[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object: nil];
		//[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object: nil];
		//[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyboardDidHide:) name: UIKeyboardDidHideNotification object: nil];
    }
    return self;
	
}



/*
	layoutSubviews - called whenever this view's bounds/frame changes. This method ensures that the new bounds/rect info is passed on to top level 'polish' view
 */
-(void)layoutSubviews
{
	if(disableManualLayout == 1) return;
	
	[super layoutSubviews];
	
	/*force the shaded page fold graphic to stretch all the way down the length of the view:*/
	[shadedStripLayer setFrame: CGRectMake(0, 0, TEXTBOXMINIAPP_SHADEDSTRIPWIDTH, self.bounds.size.height)];
	[shadedStripLayer removeAllAnimations];
	
	/*force the ruled lines graphic to maintain its height, but stretch its width to fill the frame:*/
	ruledLinesOffset = ((int)([textView contentOffset].y)) % TEXTBOXMINIAPP_RULEDLINESGAP;
	[ruledLinesLayer setFrame: CGRectMake(0, -25 - ruledLinesOffset, self.bounds.size.width, 1054)];
	[ruledLinesLayer removeAllAnimations];
}


/*
	updateScrolling - setup to be called at every iteration of the global run loop, in sync with the display being refreshed. It forces our underlaying paper graphics to be positioned:
*/
- (void)updateScrolling
{
	[self setNeedsLayout];
	
//	if([theStubbornView isFirstResponder] == YES) NSLog(@"     *****Text View *IS* first responder");
//	else NSLog(@"     *****Text View is *NOT* first responder");
}


/*
	hitTest -	If the text view is the first responder, then all events follow system default behaviour by flowing straight to it and its subviews
				However, if we are not in text entry mode (text view is not first responder), when receiving a touch, wait for a split second to check its not a double touch (if it is, then we do nothing, otherwise the parent view's double tap detection is interfered with). If not, then this is a normal touch and we go into text entry mode:
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	/*While this event is passed on to the text view, see whether this touch is part of a double touch. (we do this by collecting an array of all hits this method is called with, which will then by analysed by 'collectAndAnalizeHitTestTouches'
			By default, the text view is not allowed to become firstResponder, i.e. not allowed to bring up the keyboard. *if* we verify that this was a single, not a double touch, then the text view will be allowed to become first responder*/
	if([textView isFirstResponder] == NO)
	{
		collectedTouches[numTouchesCollected++] = point;
		[NSObject cancelPreviousPerformRequestsWithTarget: self];
		[self performSelector: @selector(collectAndAnalizeHitTestTouches) withObject: nil afterDelay: DOUBLE_TAP_TIME_THRESHOLD];
	}
	
	/*always pass the event on to the text view!*/
	return [super hitTest: point withEvent: event];

}


/*
	collectAndAnalizeHitTestTouches - this will be called if we're out of text entry mode and a certain delay has passed after the above hitTest method has started receiving hits.
*/
- (void)collectAndAnalizeHitTestTouches
{
	int foundDoubleTouch = 0;
	
	/*loop over all collected touches to see whether they are identical:*/
	for(int i = 1; i < numTouchesCollected; i++)
	{
		if((collectedTouches[i].x != collectedTouches[0].x)||(collectedTouches[i].y != collectedTouches[0].y))
		{
			foundDoubleTouch = 1;
			break;
		}
	}
	
	/*we're done, so return collection to start point:*/
	numTouchesCollected = 0;
	
	/*if all collected touches are identical, then they merely represent a single touch, and we can proceed as a single touch should, by launching text input mode:*/
	if(foundDoubleTouch == 0)
	{
		[textView setSwitchedOff: 0];
	}
	
	/*if these collected touches were not identical, then there was a double touch, for which no action is taken.*/
}


/*
	keyboard callback for when keyboard is launched - when the text view is in entry mode, this method gets called. If the keyboard's appearance obscures this view too much, this method moves this view upwards so that it can be seen by the user:
 */
- (void)keyboardWillShow:(NSNotification *)theNotification;
{
	/*If the text view has just become first responder here, and therefore the keyboard has appeared, then checl to see whether we need to move this view and exempt it. If we're already in text entry mode and this call is spurious, then do nothing:*/
	if(viewIsCurrentlyExempted == 0)
	{
		/*Find out from the parent panel view what orientation the app is currently in:*/
		int currentAppOrientation = [self.superview getCurrentAppOrientation];
	
		CGPoint newCenter = [self determineWhetherViewNeedsToBeExemptedInHypotheticalSituation: [self.superview getCurrentAppOrientation] center: self.center bounds: self.bounds];
	
		if(newCenter.x != -1)
		{
			/*request this view be given a special position (after 0.3 seconds to allow the keyboard to appear first):*/
			NSMutableArray *paramArray = [[NSMutableArray alloc] initWithCapacity: 2];
			[paramArray addObject: self];
			[paramArray addObject: [NSNumber numberWithFloat: newCenter.x]];
			[paramArray addObject: [NSNumber numberWithFloat: newCenter.y]];
		
			textViewHeightDuringExemption = (int)(TEXTBOXMINIAPP_RULEDLINESGAP * 5.5);
			[NSTimer scheduledTimerWithTimeInterval: 0.3 target: rootPanelView selector: @selector(requestMiniAppViewExemption:) userInfo: paramArray repeats: NO];
		}
	}
}

	
- (CGPoint)determineWhetherViewNeedsToBeExemptedInHypotheticalSituation: (int)hypoOrientation center: (CGPoint)hypoCenter bounds: (CGRect)hypoBounds
{	
	
	CGSize appRect, keyboardRect, freeSpaceRect;
	CGPoint viewCenter;
	
	/*given the orientation, we can know what the app's total screen space us, the space the keyboard takes up and the space left over:*/
	if((hypoOrientation == 0)||(hypoOrientation == 2))
	{
		appRect = CGSizeMake(768, 1004);
		keyboardRect = CGSizeMake(768, 264);
		freeSpaceRect = CGSizeMake(768, 760);
		
		if(hypoOrientation == 0) viewCenter = hypoCenter;
		else viewCenter = CGPointMake(768 - hypoCenter.x, 1024 - hypoCenter.y);
	}
		
	else
	{
		appRect = CGSizeMake(1024, 748);
		keyboardRect = CGSizeMake(1024, 352);
		freeSpaceRect = CGSizeMake(1024, 416);
		
		if(hypoOrientation == 1) viewCenter = CGPointMake(hypoCenter.y, 768 - hypoCenter.x);
		else viewCenter = CGPointMake(1024 - hypoCenter.y, hypoCenter.x);
	}
	
	float pixelDistOfViewAboveKeyboard = freeSpaceRect.height - (viewCenter.y - 0.5 * hypoBounds.size.height);
	
	/*As a rule, if there are less than 5 and a half lines exposed above the keyboard, we will shift this view upwards to allow 5 and a half lines to be seen so that the user can actually input text practically:*/
	if((pixelDistOfViewAboveKeyboard / (float)(TEXTBOXMINIAPP_RULEDLINESGAP)) < 5.5)
	{
		/*One exception to this. If the bottom of the view is *also* above the keyboard, then moving it up ain't going to expose any more space, so ony carry on if this is not the case:*/
		if((viewCenter.y + 0.5 * hypoBounds.size.height) > freeSpaceRect.height) 
		{
			float amountToShiftBy = (int)(TEXTBOXMINIAPP_RULEDLINESGAP * 5.5) - pixelDistOfViewAboveKeyboard;
		
			/*If the view's height is less than the 5-and-a-half lines, then only move it up the the extent that it will show its entire height, no point moving it up any higher:*/
			if(hypoBounds.size.height < (int)(TEXTBOXMINIAPP_RULEDLINESGAP * 5.5))
			{
				amountToShiftBy -= ((int)(TEXTBOXMINIAPP_RULEDLINESGAP * 5.5) - hypoBounds.size.height);
			}
			
			
			CGPoint newCenter;
			if(hypoOrientation == 0) newCenter = CGPointMake(hypoCenter.x, hypoCenter.y - amountToShiftBy);
			if(hypoOrientation == 1) newCenter = CGPointMake(hypoCenter.x + amountToShiftBy, hypoCenter.y);
			if(hypoOrientation == 2) newCenter = CGPointMake(hypoCenter.x, hypoCenter.y + amountToShiftBy);
			if(hypoOrientation == 3) newCenter = CGPointMake(hypoCenter.x - amountToShiftBy, hypoCenter.y);
	
			return newCenter;
		}
	}
	
	return CGPointMake(-1, -1);
}	


/*
	keyboard callback for when keyboard is dismissed
 */
- (void)keyboardWillHide
{
	[textView setSwitchedOff: 1];
	if(viewIsCurrentlyExempted == 1) [rootPanelView endMiniAppViewExemption];
}


/*
	miniAppViewExemptionWillStart - at this point, we'll shift the text view so that it only fills the visible area above the keyboard:
 */
- (void)miniAppViewExemptionWillStart
{
	viewIsCurrentlyExempted = 1;
	[textView setFrame: CGRectMake([textView frame].origin.x, [textView frame].origin.y, [textView frame].size.width, textViewHeightDuringExemption)];
}

/*
	miniAppViewExemptionWillEnd - at this point, we'll return the text view so that it fills the whole area of the view:
 */
- (void)miniAppViewExemptionWillEnd
{
	viewIsCurrentlyExempted = 0;
	[textView setFrame: CGRectMake([textView frame].origin.x, [textView frame].origin.y, [textView frame].size.width, [self bounds].size.height)];
}

/*
	if this view is about to be reoriented, it is possible that, if currently the first responder, it might still need to be exempted in the new orientation:
 */
- (BOOL)shouldViewBeExemptedInHypotheticalOrientation: (int)hypoOrientation center: (CGPoint)hypoCenter bounds: (CGRect)hypoBounds withNewCenter: (CGPoint *)newCenter_out
{
	if([textView isFirstResponder])
	{
		*newCenter_out = [self determineWhetherViewNeedsToBeExemptedInHypotheticalSituation: hypoOrientation center: hypoCenter bounds: hypoBounds];
		
		if(newCenter_out->x != -1) 
		{
			textViewHeightDuringExemption = (int)(TEXTBOXMINIAPP_RULEDLINESGAP * 5.5);
			return YES;
		}
	}
	
	return NO;
}

/*******************************************************************************************************************
 
 VARIOUS MINI APP - SPECIFIC IMPLEMENTATIONS OF STANDARD TRANSFORMATION METHODS PLUS EXTRA RELATED METHODS
 
 ********************************************************************************************************************/


- (void)animateChangeOfBoundsAndCenter: (float)duration toBounds: (CGRect)newBounds andCenter: (CGPoint)newCenter
{
	/*we don't want any manual layout to interfere with the animation:*/
	disableManualLayout = 1;

	/*first of all, consider the shaded strip layer. if the new view bounds are shorter than before, then leave it alone as it will look fine as the view bounds change. If the new bounds are taller, then increase the size of the shaded strip layer *now* so that it looks fine as the animated increasing bounds reveal it:*/
	if(newBounds.size.height > self.bounds.size.height)
	{
		[shadedStripLayer setFrame: CGRectMake(0, 0, TEXTBOXMINIAPP_SHADEDSTRIPWIDTH, newBounds.size.height)];
		[shadedStripLayer removeAllAnimations];
	}
	
	/*Next, the ruled lines layer. If the new view bounds are narrower than before, then leave it alone as it will look fine as the view bounds change. If the new bounds are wider, then increase the size of the ruled lines layer *now* so that it looks fine as the animated increasing bounds reveal it*/
	if(newBounds.size.width > self.bounds.size.width) 
	{
		CGRect ruledLinesLayerFrame = [ruledLinesLayer frame];
		
		[ruledLinesLayer setFrame: CGRectMake(0, ruledLinesLayerFrame.origin.y, newBounds.size.width, 1054)];
		[ruledLinesLayer removeAllAnimations];
	}
	
	/*If the change of bounds is purely in the height direction, then let the UIView text class handle the resizing. If however the width is affected, stop the text view from updating its frame until *after* the change animation:*/
	if(newBounds.size.width == self.bounds.size.width)
	{
		/*animate the whole view:*/
		[UIView animateWithDuration: duration animations: ^{ [self setBounds: newBounds]; [self setCenter: newCenter]; } completion: ^(BOOL finished) { disableManualLayout = 0; [self setNeedsLayout]; [rootPanelView miniAppViewDidFinishRedrawingInSettledFrame: self]; } ];
	}
	
	else 
	{
		/*stop the view here from automatically resizing the text view:*/
		[self setAutoresizesSubviews: NO];
		
		/*now due to paragraph formatting, the new view bounds are going to rearrange the text to the extent that the user's place will probably be lost. Here we crudely calculate how the offset from top-of-page should be changed to keep the position roughly the same:*/
		int areaOfTextLostOrGained = (newBounds.size.width - self.bounds.size.width) * (int)([textView contentOffset].y);
		int textOffsetRequiredToCompensate = (int)((float)areaOfTextLostOrGained / newBounds.size.width);
		
		CGPoint newTextViewOffset = [textView contentOffset];
		newTextViewOffset.y -= textOffsetRequiredToCompensate;
 		
		/*animate the whole view:*/
		[UIView animateWithDuration: duration animations: ^{ [self setBounds: newBounds]; [self setCenter: newCenter]; } completion: ^(BOOL finished) { disableManualLayout = 0; [self setAutoresizesSubviews: YES]; [textView setFrame: CGRectMake(65, 0, self.bounds.size.width - 70, self.bounds.size.height)]; [textView setContentOffset:newTextViewOffset]; [self setNeedsLayout]; [rootPanelView miniAppViewDidFinishRedrawingInSettledFrame: self]; } ];
	}
}	


/*
	contract - For this mini app, we'll copy the text view's content into a new static layer, then animate this the view and all the content layers together:
 */
- (void)contract:(float)duration
{
	disableManualLayout = 1;
	
	/*copy the text view and ruled lines layer current content to a new created layer and hide them:*/
	CALayer *linesAndTextLayer = [CALayer layer];
	[linesAndTextLayer setBackgroundColor: [[UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.0] CGColor]];
	[[self layer] addSublayer: linesAndTextLayer];
	[linesAndTextLayer setZPosition: 4.0];
	[linesAndTextLayer setFrame: [ruledLinesLayer frame]];

	
	/*get the graphical content out of the ruled lines layer and the text view and copy it into this new layer:*/
	CGContextRef linesAndTextLayerBitmapContext = CGBitmapContextCreate(NULL, [linesAndTextLayer bounds].size.width, [linesAndTextLayer bounds].size.height, 8, [linesAndTextLayer bounds].size.width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	CGContextScaleCTM(linesAndTextLayerBitmapContext, 1.0, -1.0);
	CGContextTranslateCTM(linesAndTextLayerBitmapContext, 0.0, -1.0 * [linesAndTextLayer bounds].size.height);
	[ruledLinesLayer renderInContext: linesAndTextLayerBitmapContext];

	CGContextRef textContentBitmapContext = CGBitmapContextCreate(NULL, [textView contentSize].width, [textView contentSize].height, 8, [textView contentSize].width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	[[textView layer] renderInContext: textContentBitmapContext];
	CGImageRef textContentBitmapImage = CGBitmapContextCreateImage(textContentBitmapContext);
	CGContextDrawImage(linesAndTextLayerBitmapContext, CGRectMake(65 - [linesAndTextLayer frame].origin.x, -1.0 * [textView contentOffset].y - [linesAndTextLayer frame].origin.y, [textView contentSize].width, [textView contentSize].height), textContentBitmapImage);


	CGImageRef linesAndTextLayerContents = CGBitmapContextCreateImage(linesAndTextLayerBitmapContext);
	[linesAndTextLayer setContents: (id)linesAndTextLayerContents];
	
	/*release the various context and intermediate images created above:*/
	CGContextRelease(textContentBitmapContext);
	CGImageRelease(textContentBitmapImage);
	CGContextRelease(linesAndTextLayerBitmapContext);
	CGImageRelease(linesAndTextLayerContents);
	
	
	/*we won't need these now that they've been copied, so hide them:*/
	[textView setHidden: YES];
	[ruledLinesLayer setHidden: YES];
	[ruledLinesLayer removeAllAnimations];

	
	/*set up the shadedStrip layer and the bitmap layer to animate:*/
	CGPoint ssLayer_oldPos = [shadedStripLayer position];
	CGRect ssLayer_oldBounds = [shadedStripLayer bounds];
	CGPoint bitmapLayer_oldPos = [linesAndTextLayer position];
	CGRect bitmapLayer_oldBounds = [linesAndTextLayer bounds];
	CGRect zeroBounds = CGRectMake(0, 0, 0, 0);
	CGPoint zeroPoint = CGPointMake(0, 0);

	
	[shadedStripLayerAnim_position setDuration: duration];
	[shadedStripLayerAnim_position setFromValue: [NSValue value: &ssLayer_oldPos withObjCType: @encode(CGPoint)]];
	[shadedStripLayerAnim_position setToValue: [NSValue value: &zeroPoint withObjCType: @encode(CGPoint)]];
	[shadedStripLayerAnim_bounds setDuration: duration];
	[shadedStripLayerAnim_bounds setFromValue: [NSValue value: &ssLayer_oldBounds withObjCType: @encode(CGRect)]];
	[shadedStripLayerAnim_bounds setToValue: [NSValue value: &zeroBounds withObjCType: @encode(CGRect)]];

	[shadedStripLayer setPosition: zeroPoint];
	[shadedStripLayer setBounds: zeroBounds];
	[shadedStripLayer addAnimation: shadedStripLayerAnim_position forKey: @"position"];
	[shadedStripLayer addAnimation: shadedStripLayerAnim_bounds forKey: @"bounds"];

	
	CABasicAnimation *linesAndTextLayerAnim_pos = [CABasicAnimation animationWithKeyPath: @"position"];
	[linesAndTextLayerAnim_pos setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
	CABasicAnimation *linesAndTextLayerAnim_bounds = [CABasicAnimation animationWithKeyPath: @"bounds"];
	[linesAndTextLayerAnim_bounds setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];

	[linesAndTextLayerAnim_pos setDuration: duration];
	[linesAndTextLayerAnim_pos setFromValue: [NSValue value: &bitmapLayer_oldPos withObjCType: @encode(CGPoint)]];
	[linesAndTextLayerAnim_pos setToValue: [NSValue value: &zeroPoint withObjCType: @encode(CGPoint)]];
	[linesAndTextLayerAnim_bounds setDuration: duration];
	[linesAndTextLayerAnim_bounds setFromValue: [NSValue value: &bitmapLayer_oldBounds withObjCType: @encode(CGRect)]];
	[linesAndTextLayerAnim_bounds setToValue: [NSValue value: &zeroBounds withObjCType: @encode(CGRect)]];

	[linesAndTextLayer setPosition: zeroPoint];
	[linesAndTextLayer setBounds: zeroBounds];
	[linesAndTextLayer addAnimation: linesAndTextLayerAnim_pos forKey: @"position"];
	[linesAndTextLayer addAnimation: linesAndTextLayerAnim_bounds forKey: @"bounds"];
	
	
	/*IF KEYBOARD IS ACTIVE REMOVE IT!!!*/
	if([textView isFirstResponder] == YES) [textView resignFirstResponder];

	/*if contracting while disabled, the darken top layer will look fine automatically when scaled down. But hide it if this view is not disabled, otherwise it might appear suddenly:*/
	if(miniAppIsDisabled == 0) [darkenTopLayer setHidden: YES];

	
	/*animate the view to scale down. Disable manual layout to freeze content as it is right now*/
	disableManualLayout = 1;
	[UIView animateWithDuration: duration animations: ^{[self setFrame: CGRectMake(self.frame.origin.x + (int)(0.5 * self.frame.size.width), self.frame.origin.y + (int)(0.5 * self.frame.size.height), 0, 0)]; } ];
}


/*
	shouldMiniAppBeDisabledGivenBounds - given a rectangular bounds, this method simply returns true or false to whether the bounds size means the mini app should be disabled (subclasses can override this method to provide their own criteria)
 */
- (BOOL)shouldMiniAppBeDisabledGivenBounds: (CGRect)bounds_in
{
	if( (bounds_in.size.width < TEXTBOXMINIAPP_MINIMUM_ENABLED_WIDTH) || (bounds_in.size.height < TEXTBOXMINIAPP_RULEDLINESGAP) ) return YES;
	return NO;
}


/*
	quit - this will be called by the parent view just before it removes this view, triggering dealloc(). Safe in the knowledge that this app's useful life is now over, use this method to remove any retain cycles, e.g. shared ownership by a display link:
 */
- (void)quit
{
	[textMovementDisplayLink invalidate];
}


- (void)dealloc 
{
	/*release the text view:*/
	[textView removeFromSuperview];
	[textView release];
	
	/*release animation objects:*/
	[shadedStripLayerAnim_position release];
	[shadedStripLayerAnim_bounds release];
	[ruledLinesLayerAnim_position release];
	[ruledLinesLayerAnim_bounds release];
	
    /*release the collected touches array:*/
	free(collectedTouches);
	
	/*this object is about to cease to exist, so remove it as an observer of keyboard hiding:*/
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[super dealloc];
}

@end

