//
//  panelView.m
//  WorkPad
//
//  Created by William Alexander on 28/09/2010.
//  Copyright 2010 Framestore-CFC. All rights reserved.
//

#import "panelView.h"

#import "panelViewController.h"
#import "panelTreeDesc_objC.h"


@implementation  miniAppIconsView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame: frame];
	
	[self setBackgroundColor: [UIColor blackColor]];
	
	iconTouchDown = -1;
	
	return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint touchPoint = [[touches anyObject] locationInView:self];
	
	for(int i = 0; i < 5; i++)
	{
		CALayer *iconLayerToTest = [[[self layer] sublayers] objectAtIndex: i];
		
		if([iconLayerToTest hitTest:touchPoint] == iconLayerToTest)
		{
			[iconLayerToTest setOpacity: 0.5]; 
			[iconLayerToTest removeAllAnimations];
			iconTouchDown = i;
		}
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(iconTouchDown != -1)
	{
		CALayer *iconTouchedDown = [[[self layer] sublayers] objectAtIndex: iconTouchDown];
		
		[iconTouchedDown setOpacity: 1.0];
		[iconTouchedDown removeAllAnimations];
		
		/*if this was the help button rather than one of the mini app icons, then launch the instructions:*/
		if(iconTouchDown == 4)
		{
			[[self superview] openInstructions];
			iconTouchDown = -1;
			return;
		}
		
		/*the new mini app has now been chosen, so create it and display it:*/
		[[self superview] newMiniAppChosen: iconTouchDown];
		
		iconTouchDown = -1;
	}
}

- (void)setBottomRightCornerPos: (CGPoint)bottomRightCornerPos
{
	/*put the help button in the bottom right corner (offset by 6px):*/
	[[[[self layer] sublayers] objectAtIndex: 4] setPosition: CGPointMake(bottomRightCornerPos.x - 31, bottomRightCornerPos.y - 31)];
	[[[[self layer] sublayers] objectAtIndex: 4] removeAllAnimations];
}

- (void)setBottomRightCornerPosAndAnimateHelpButtonAppearance: (id)parameters;
{
	CGPoint bottomRightCorner;
	[[parameters objectAtIndex: 0] getValue: &bottomRightCorner];
	
	/*put the help button in the bottom right corner (offset by 6px):*/
	[[[[self layer] sublayers] objectAtIndex: 4] setPosition: CGPointMake(bottomRightCorner.x - 31, bottomRightCorner.y - 31)];
	[[[[self layer] sublayers] objectAtIndex: 4] removeAllAnimations];
	
	[[[[self layer] sublayers] objectAtIndex: 4] setHidden: NO];
}

- (void)animHelpButtonHide
{
	[[[[self layer] sublayers] objectAtIndex: 4] setHidden: YES];
}

@end



@implementation instructionsView

- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame: frame])
	{
		[self setBackgroundColor: [UIColor blackColor]];
		
		/*First of all, there's the scroll view that will contain the instuctions content image:*/
		theScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 50, frame.size.width, frame.size.height - 50)];
		[theScrollView setContentSize: CGSizeMake(768, 2048)];
		[theScrollView setIndicatorStyle: UIScrollViewIndicatorStyleWhite];
		
		CGImageRef instructionsImage = [utilities openCGResourceImage: @"instructions" ofType: @"png"];
		scrollViewContentView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 768, 2048)];
		[[scrollViewContentView layer] setContents: (id)(instructionsImage)]; 
		[theScrollView addSubview: scrollViewContentView];
		CGImageRelease(instructionsImage);
		
		[self addSubview: theScrollView];
		
		/*create the navigation bar:*/
		theNavBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, 50)];
		[theNavBar setBarStyle: UIBarStyleBlack];
		
		UIBarButtonItem *theButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style: UIBarButtonItemStyleDone target: self action: @selector(userDidQuit)];
		UINavigationItem *titleItem = [[UINavigationItem alloc] initWithTitle: @"How to use Paductivity"];
		[titleItem setRightBarButtonItem: theButton];
		
		NSMutableArray *theItemsArray = [[NSMutableArray alloc] initWithCapacity: 2];
		[theItemsArray addObject: titleItem];
		[theNavBar setItems: theItemsArray animated: NO];
		
		[self addSubview: theNavBar];
		
		
		[theButton release];
		[titleItem release];
	}
	
	return self;
}

- (void)userDidQuit
{
	[[self superview] closeInstructions];
}

- (void)layoutSubviewsInLatestBounds
{
	[theScrollView setFrame: CGRectMake(0, 50, self.bounds.size.width, self.bounds.size.height - 50)];
	if(self.bounds.size.width == 768)	[scrollViewContentView setFrame: CGRectMake(0, 0, 768, 2048)];
	else								[scrollViewContentView setFrame: CGRectMake(128, 0, 768, 2048)];
	
	[theNavBar setFrame: CGRectMake(0, 0, self.bounds.size.width, 50)];
}

- (void)animateToNewCenterAndBounds: (float)duration newCenter: (CGPoint)newCenter newBounds: (CGRect)newBounds
{
	[UIView animateWithDuration: duration animations: ^{ [theScrollView setFrame: CGRectMake(0, 50, self.bounds.size.width, self.bounds.size.height - 50)]; } ];
	if(self.bounds.size.width == 768)	[UIView animateWithDuration: duration animations: ^{ [scrollViewContentView setFrame: CGRectMake(0, 0, 768, 2048)]; } ];
	else								[UIView animateWithDuration: duration animations: ^{ [scrollViewContentView setFrame: CGRectMake(128, 0, 768, 2048)]; } ];
	
	[UIView animateWithDuration: duration animations: ^{ [theNavBar setFrame: CGRectMake(0, 0, self.bounds.size.width, 50)]; } ];
}


@end




@implementation panelView

@synthesize thisViewController;

/*
	Initialisation comprises setting the background color to black:
*/
- (id)initWithFrame:(CGRect)frame andRootPanelDescNodePointer:(int)rootPanelDescNodePointer {
    if ((self = [super initWithFrame:frame])) {
   
		/*Set background color to black:*/
		self.backgroundColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 1.0];
		
		/*Make this view receive multiple touches:*/
		self.multipleTouchEnabled = YES;
		
		/*No touch event or type of touch event is currently in progress:*/
		touchEventTypeInProgress = -1;
		
		/*this is an array of views that will keep track, during shift events, of the views that are affected by said events so that when the event ends, the views in question can be sent a message to notify them*/
		miniAppViewsAffectedByCurrentShiftEvent = [NSMutableArray arrayWithCapacity: 1];
		[miniAppViewsAffectedByCurrentShiftEvent retain];
		
		
		/*We want the interface to respond to device orientation changes - register to be notified if the device's orientation changes:*/
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
		
		/*keep track of orientation changes and layout method calls to force the interface to stay in portrait mode until after the user's first move from portrait to lanscape:*/
		firstDeviceOrientAwayFromPortraitHasOccurred = 0;
		layoutSubviewsHasBeenCalledForFirstTime = 0;
		lastRecordedOrientation = -1;
		previousDeviceOrientation = UIDeviceOrientationPortrait;
		previousDeviceOrientationAngle = 0;
		currentDeviceOrientation = UIDeviceOrientationPortrait;
		currentDeviceOrientationAngle = 0;
		
		
		
		/*set up necessary variables for double tap detection:*/
		doubleTapDetectionStage = 0;
		
		collectingTouches = 0;
		collectedTouches = (CGPoint *)malloc(10 * sizeof(CGPoint));
		
		numTouchesCollected = 0;
		
		
		/*by default, layoutSubviews() method acts as normal:*/
		suspendLayout = 0;
		
		
		/*To open new mini apps, the user will be presented with the mini app menu; Create, hidden to start with, icons for each mini app type, for the user when they are presented with a choice:*/
		[self setupMiniAppChoiceIcons];
		
		/*create a desc node pointer that represents the full frame of the screen, ready for the first app when it is chosen from the first menu and created:*/
		newPanelDescPointer = (panelTreeDesc *)rootPanelDescNodePointer;
		
		/*to start with, we are not in mini app choice mode:*/
		newMiniAppChoiceMode = 0;
		iconTouchDown = -1;
		
		/*an array is kept of pointers to the mini app views that exist:*/
		miniAppSubviews = [NSMutableArray arrayWithCapacity: 0];
		[miniAppSubviews retain];
		
		/*In some cases, we want to intervene to regulate the order of/delay heavy graphics-related calls. This variable keeps a record of any context we're in in which graphics calls should be delayed (none by default):*/
		graphicsDelayContext = -1;
		
		/*By default, there is no mini app view exemption:*/
		exemptedMiniAppView = nil;
		
		/*Create the CALayers that are needed to give the effect of a border around exempted views:*/
		exemptViewBorderLayer_a = [CALayer layer];
		[exemptViewBorderLayer_a setBackgroundColor: [[UIColor blackColor] CGColor]];
		[exemptViewBorderLayer_a setCornerRadius: MINI_APP_CORNER_RADIUS + 1];
		[exemptViewBorderLayer_a setHidden: YES];
		[[self layer] addSublayer: exemptViewBorderLayer_a];
		[exemptViewBorderLayer_a setZPosition: 5.0];
		
		exemptViewBorderLayer_b = [CALayer layer];
		[exemptViewBorderLayer_b setBackgroundColor: [[UIColor blackColor] CGColor]];
		[exemptViewBorderLayer_b setCornerRadius: MINI_APP_CORNER_RADIUS + 1];
		[exemptViewBorderLayer_b setHidden: YES];
		[[self layer] addSublayer: exemptViewBorderLayer_b];
		[exemptViewBorderLayer_b setZPosition: 5.0];
		
		exemptViewBorderLayer_a_anim = [CABasicAnimation animationWithKeyPath: @"position"];
		[exemptViewBorderLayer_a_anim setDuration: EXEMPTION_ANIM_DURATION];
		[exemptViewBorderLayer_a_anim setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[exemptViewBorderLayer_a_anim retain];
		
		exemptViewBorderLayer_b_anim = [CABasicAnimation animationWithKeyPath: @"position"];
		[exemptViewBorderLayer_b_anim setDuration: EXEMPTION_ANIM_DURATION];
		[exemptViewBorderLayer_b_anim setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[exemptViewBorderLayer_b_anim retain];
		
		exemptViewBorderLayer = exemptViewBorderLayer_b;
		exemptViewBorderLayer_anim = exemptViewBorderLayer_b_anim;
		
		/*First of all, we start off with the opening screen animation:*/
		appBehaviorStage = 0;
		[self startUpScreenAnimation_setup];
		
		/*create and set up the instructions view*/
		theInstructionsView = [[instructionsView alloc] initWithFrame: CGRectMake(0, 20, 768, 1004)];
		[theInstructionsView setHidden: YES];
		[self addSubview: theInstructionsView];
		instructionsMode = 0;
	}
	
    return self;
}


/*
	Simple setter method
 */
- (void)setTheAppDelegate: (WorkPadAppDelegate *)theDelegate_in
{
	theAppDelegate = theDelegate_in;
}


- (void)startUpScreenAnimation_setup
{
	/*load up the static image:*/
	appLaunchImage = [utilities openCGResourceImage: @"Default" ofType: @"png"];
	
	/*create the layer for this image that will sit on top of everything:*/
	appLaunchImageLayer = [[CALayer alloc] init];
	[appLaunchImageLayer setFrame: CGRectMake(0, 0, 768, 1024)];
	[appLaunchImageLayer setContents: (id)(appLaunchImage)];
	[[self layer] addSublayer: appLaunchImageLayer];
	[appLaunchImageLayer setZPosition: 2.0];
	[appLaunchImageLayer release];
	
	/*create little black squares to go over the Paductivity logo, which will appear bit by bit:*/
	logoCoverers = [[[NSMutableArray alloc] initWithCapacity: 19] retain];
	CALayer *newLayer;
	for(int i = 0; i < 19; i++)
	{
		newLayer = [[CALayer alloc] init];
		if(i == 0) [newLayer setFrame: CGRectMake(10, 50, 36, 36)];
		[newLayer setBackgroundColor: [[UIColor blackColor] CGColor]];
		[newLayer setCornerRadius: 6];
		[newLayer setOpacity: 0.0];
		
		if(i == 0) [newLayer setFrame: CGRectMake(193, 458, 36, 36)];
		if(i == 1) [newLayer setFrame: CGRectMake(193, 493, 36, 36)];
		if(i == 2) [newLayer setFrame: CGRectMake(228, 493, 36, 36)];
		if(i == 3) [newLayer setFrame: CGRectMake(228, 528, 36, 36)];
		if(i == 4) [newLayer setFrame: CGRectMake(263, 458, 36, 36)];
		if(i == 5) [newLayer setFrame: CGRectMake(263, 493, 36, 36)];
		if(i == 6) [newLayer setFrame: CGRectMake(298, 493, 36, 36)];
		if(i == 7) [newLayer setFrame: CGRectMake(333, 493, 36, 36)];
		if(i == 8) [newLayer setFrame: CGRectMake(368, 458, 36, 36)];
		if(i == 9) [newLayer setFrame: CGRectMake(368, 493, 36, 36)];
		if(i == 10) [newLayer setFrame: CGRectMake(420, 458, 19, 36)];
		if(i == 11) [newLayer setFrame: CGRectMake(420, 493, 19, 36)];
		if(i == 12) [newLayer setFrame: CGRectMake(438, 493, 36, 36)];
		if(i == 13) [newLayer setFrame: CGRectMake(490, 458, 19, 36)];
		if(i == 14) [newLayer setFrame: CGRectMake(490, 493, 19, 36)];
		if(i == 15) [newLayer setFrame: CGRectMake(508, 458, 36, 36)];
		if(i == 16) [newLayer setFrame: CGRectMake(508, 493, 36, 36)];
		if(i == 17) [newLayer setFrame: CGRectMake(543, 493, 36, 36)];
		if(i == 18) [newLayer setFrame: CGRectMake(543, 528, 36, 36)];
		
		[[self layer] addSublayer: newLayer];
		[newLayer setZPosition: 3.0];
		
		[logoCoverers addObject: newLayer];
		[newLayer release];
	}
	
	/*clean up:*/
	CGImageRelease(appLaunchImage);
	
	/*we wait for 'START_UP_SCREEN_DURATION' seconds before launching a nice animation to transition from this start up screen to the app ready for input:*/
	[NSTimer scheduledTimerWithTimeInterval: START_UP_SCREEN_DURATION target: self selector: @selector(startUpScreenAnimation_execute:) userInfo: nil repeats: NO];
}


/*
	executes various stages of the opening animation, based on the stage requested by the caller through 'theTimer':
 */
- (void)startUpScreenAnimation_execute: (NSTimer *)theTimer
{
	/*For each logoCoverer, create and set off a unique animation that gives it a unique delay, followed by a uniform fade to full opacity, to obscure its part of the logo:*/
	CAKeyframeAnimation *covererAnim;
	NSMutableArray *covererAnim_timings;
	float appearAnimDelay;
	
	NSMutableArray *covererAnim_values = [[NSMutableArray alloc] initWithCapacity: 3];
	[covererAnim_values addObject: [NSNumber numberWithFloat: 0.0]];
	[covererAnim_values addObject: [NSNumber numberWithFloat: 0.0]];
	[covererAnim_values addObject: [NSNumber numberWithFloat: 1.0]];
	
	for(int i = 0; i < 19; i++)
	{
		covererAnim = [[CAKeyframeAnimation alloc] init];
		[covererAnim setKeyPath: @"opacity"];
		
		appearAnimDelay = START_UP_LOGO_SEGMENT_DISAPPEAR_MAX_DELAY * (float)(rand()) / (float)(INT_MAX);
		
		covererAnim_timings = [[NSMutableArray alloc] initWithCapacity: 3];
		[covererAnim_timings addObject: [NSNumber numberWithFloat: 0.0]];
		[covererAnim_timings addObject: [NSNumber numberWithFloat: appearAnimDelay / (appearAnimDelay + START_UP_LOGO_SEGMENT_DISAPPEAR_DURATION)]];
		[covererAnim_timings addObject: [NSNumber numberWithFloat: 1.0]];
		
		[covererAnim setKeyTimes: covererAnim_timings];
		[covererAnim setDuration: (appearAnimDelay + START_UP_LOGO_SEGMENT_DISAPPEAR_DURATION)];
		[covererAnim setValues: covererAnim_values];
		
		[[logoCoverers objectAtIndex: i] setOpacity: 1.0];
		[[logoCoverers objectAtIndex: i] addAnimation: covererAnim forKey: @"opacity"];
		
		[covererAnim_timings removeAllObjects];
		[covererAnim_timings release];
		[covererAnim release];
	}
	
	[covererAnim_values removeAllObjects];
	[covererAnim_values release];
	
	/*set the final stage of this animation to be ready to go when these logo coverers have finished animation:*/
	[NSTimer scheduledTimerWithTimeInterval: (START_UP_LOGO_SEGMENT_DISAPPEAR_MAX_DELAY + START_UP_LOGO_SEGMENT_DISAPPEAR_DURATION) target: self selector: @selector(startUpScreenAnimation_transitionToReadyState:) userInfo: nil repeats: NO];
}

- (void)startUpScreenAnimation_transitionToReadyState: (NSTimer *)theTimer
{
	/*fade out launch image:*/
	[appLaunchImageLayer setHidden: YES];
	[appLaunchImageLayer removeAllAnimations];

	for(int i = 0; i < 19; i++) 
	{
		[[logoCoverers objectAtIndex: i] setHidden: YES];
		[[logoCoverers objectAtIndex: i] removeAllAnimations];
	}
	
	/*remove and destroy all CALayers:*/
	[appLaunchImageLayer removeFromSuperlayer];
	
	for(int i = 0; i < 19; i++)  [[logoCoverers objectAtIndex: i] removeFromSuperlayer];
	[logoCoverers removeAllObjects];
	[logoCoverers release];
	
	
	
	/*provide menu for user:*/
	newMiniAppChoiceMode = 1;
	[self setMultipleTouchEnabled:NO];
	
	newMiniAppFrame = CGRectMake(0, 0, 768, 1024);
	[NSTimer scheduledTimerWithTimeInterval: 0.5 target: self selector: @selector(prepareNewMiniAppUserChoiceMenuForLaunch) userInfo: nil repeats: NO];
}


/*
	deviceOrientationDidChange - this method will be called by the system if/when the device's orientation changes. We keep the portrait-oriented structure, but just rotate the mini apps:
*/
- (void)deviceOrientationDidChange:(NSNotification *)theNotification;
{
	int newDeviceOrientation = [[UIDevice currentDevice] orientation];
	int newDeviceOrientationAngle;
	
	if(
			((newDeviceOrientation == UIDeviceOrientationPortrait)||(newDeviceOrientation == UIDeviceOrientationLandscapeLeft)||(newDeviceOrientation == UIDeviceOrientationPortraitUpsideDown)||(newDeviceOrientation == UIDeviceOrientationLandscapeRight))&&
			(newDeviceOrientation != previousDeviceOrientation)
	   )
	{
		currentDeviceOrientation = newDeviceOrientation;
		
		/*determine what the device's orientation angle now is:*/
		if([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) newDeviceOrientationAngle = 0;
		else if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) newDeviceOrientationAngle = 90;
		else if([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) newDeviceOrientationAngle = 180;
		else if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) newDeviceOrientationAngle = 270;
		currentDeviceOrientationAngle = newDeviceOrientationAngle;
		
		/*now perform the rotation:*/
		miniAppView *viewToRotate;
		CGRect viewToRotate_bounds;
		CGRect viewToRotate_toBounds;
		CGAffineTransform rotationTransformToApply;
		
		if(newDeviceOrientation == UIDeviceOrientationPortrait) rotationTransformToApply = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
		if(newDeviceOrientation == UIDeviceOrientationLandscapeLeft) rotationTransformToApply = CGAffineTransformMake(0, 1, -1, 0, 0, 0);
		if(newDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) rotationTransformToApply = CGAffineTransformMake(-1, 0, 0, -1, 0, 0);
		if(newDeviceOrientation == UIDeviceOrientationLandscapeRight) rotationTransformToApply = CGAffineTransformMake(0, -1, 1, 0, 0, 0);
		
		/*we will suspend all layout behaviour while rotating these to their new orientation:*/
		suspendLayout = 1;
		
		for(int i = 0; i < [self.subviews count]; i++)
		{
			if([self.subviews objectAtIndex: i] == theMiniAppIconsView) continue;
			if([self.subviews objectAtIndex: i] == theInstructionsView) continue;
			
			viewToRotate = [self.subviews objectAtIndex: i];
			
			/*determine the new frame that this view will take in the new oriented window:*/
			panelTreeDesc *viewToRotate_panelTreeDesc = (panelTreeDesc *)[viewToRotate getPanelTreeDescNodePointer];
			CGRect viewToRotate_trueGeometricFrame = CGRectMake(viewToRotate_panelTreeDesc->originX, viewToRotate_panelTreeDesc->originY, viewToRotate_panelTreeDesc->width, viewToRotate_panelTreeDesc->height);
			CGRect newFrame = [self cropFrameRectToAccommodatePanelGapsAndIPadToolbar: viewToRotate_trueGeometricFrame];
			
			/*extract the bounds from this view:*/
			CGRect newBounds = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
			if((currentDeviceOrientationAngle == 90) || (currentDeviceOrientationAngle == 270)) newBounds = CGRectMake(0, 0, newBounds.size.height, newBounds.size.width);
			
			/*extract the center from this new view:*/
			CGPoint newCenter = CGPointMake(newFrame.origin.x + 0.5 * newFrame.size.width, newFrame.origin.y + 0.5 * newFrame.size.height);
			
			/*Before we rotate the views to their new size and shape, check to see whether any of them believe that they should be exempted in this new orientation:*/
			CGPoint exemptedCenter;
			
			
			/*now deal with exemptions coming in to or out of effect:*/
			int currentDeviceOrientation_userFriendly;
			if(currentDeviceOrientation == UIDeviceOrientationPortrait) currentDeviceOrientation_userFriendly = 0;
			if(currentDeviceOrientation == UIDeviceOrientationLandscapeLeft) currentDeviceOrientation_userFriendly = 1;
			if(currentDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) currentDeviceOrientation_userFriendly = 2;
			if(currentDeviceOrientation == UIDeviceOrientationLandscapeRight) currentDeviceOrientation_userFriendly = 3;
			if([viewToRotate shouldViewBeExemptedInHypotheticalOrientation: currentDeviceOrientation_userFriendly center: newCenter bounds: newBounds withNewCenter: &exemptedCenter] == YES)
			{
				/*if an exemption on a different mini app view is currently in effect, then this is no longer the case, so reset it to normality as usual but without any animation:*/
				if((exemptedMiniAppView != nil)&&(exemptedMiniAppView != viewToRotate)) 
				{
					[exemptedMiniAppView miniAppViewExemptionWillEnd];
					[exemptViewBorderLayer setHidden: YES]; 
					[exemptViewBorderLayer removeAllAnimations];
					[[exemptedMiniAppView layer] setZPosition: 0.0];
				}
				
				/*the theoretical non-exempted center of this view is the center it will need to go back to if the exemption is ever ended in this new orienatation, so record it:*/
				exemptedMiniAppViewOriginalCenter = newCenter;
				
				/*This view is now the exempted view, so set up as necessary:*/
				exemptedMiniAppView = viewToRotate;
				[[exemptedMiniAppView layer] setZPosition: 6.0];
				newCenter = exemptedCenter;
				
				/*position the border layer in the right place, but don't show it just yet:*/
				CATransform3D exemptViewBorderLayerTransform = {rotationTransformToApply.a, rotationTransformToApply.b, 0, rotationTransformToApply.tx, rotationTransformToApply.c, rotationTransformToApply.d, 0, rotationTransformToApply.ty, 0, 0, 0, 0, 0, 0, 0, 1};
				[exemptViewBorderLayer setPosition: newCenter];
				[exemptViewBorderLayer setBounds: CGRectMake(0, 0, newBounds.size.width + 2, newBounds.size.height + 2)];
				[exemptViewBorderLayer setTransform: exemptViewBorderLayerTransform];
				[exemptViewBorderLayer setHidden: YES];
				[exemptViewBorderLayer removeAllAnimations];
			}
			else
			{
				/*if this view just happens to be currently exempted, then the fact that we're in this block means that it won't be anymore, so reset it to normality as usual but without any animation:*/
				if(exemptedMiniAppView == viewToRotate) 
				{
					[exemptedMiniAppView miniAppViewExemptionWillEnd];
					[exemptViewBorderLayer setHidden: YES]; 
					[exemptViewBorderLayer removeAllAnimations];
					[[exemptedMiniAppView layer] setZPosition: 0.0];
					
					exemptedMiniAppView = nil;
				}
			}
			
			
			/*animate the view's rotation. (if it's going to be exempted in the new orientation, then reveal the black border layer around it at the end of the animation:*/
			if(exemptedMiniAppView != viewToRotate) [UIView animateWithDuration: REORIENTATION_DURATION animations: ^{ [viewToRotate setTransform: rotationTransformToApply]; } completion: ^(BOOL finished){ suspendLayout = 0; } ];
			else									[UIView animateWithDuration: REORIENTATION_DURATION animations: ^{ [viewToRotate setTransform: rotationTransformToApply]; } completion: ^(BOOL finished){ suspendLayout = 0; [exemptedMiniAppView miniAppViewExemptionWillStart]; [exemptViewBorderLayer setHidden: NO]; [exemptViewBorderLayer removeAllAnimations]; } ];
			
			/*and animate the view's change of bounds and center:*/
			[viewToRotate animateChangeOfBoundsAndCenter: REORIENTATION_DURATION toBounds: newBounds andCenter: newCenter];
		}
		
		/*If we happen to be in new mini app choice mode, then reposition/rotate the mini app menu as well:*/
		if(newMiniAppChoiceMode == 1)
		{
			/*Get the rectangle space available for the new mini app, in which the new mini app is set to appear:*/
			CGRect emptySpaceFrame = CGRectMake(newPanelDescPointer->originX, newPanelDescPointer->originY, newPanelDescPointer->width, newPanelDescPointer->height);
			emptySpaceFrame = [self cropFrameRectToAccommodatePanelGapsAndIPadToolbar: emptySpaceFrame];
		
			/*now we know the exact rectangle space in which to place the menu, calculate the centre of it:*/
			CGPoint newCenter = CGPointMake(emptySpaceFrame.origin.x + 0.5 * emptySpaceFrame.size.width, emptySpaceFrame.origin.y + 0.5 * emptySpaceFrame.size.height);
		
			/*we may need to offset this center if the current open menu is offset:*/
			if(miniAppIconsViewOffset == 1);
			{
				if(currentDeviceOrientationAngle == 0)
				{
					if(emptySpaceFrame.size.width > emptySpaceFrame.size.height)	newCenter.x -= 28;
					else															newCenter.y -= 28;
				}
				if(currentDeviceOrientationAngle == 90)
				{
					if(emptySpaceFrame.size.width > emptySpaceFrame.size.height)	newCenter.x += 28;
					else															newCenter.y -= 28;
				}
				if(currentDeviceOrientationAngle == 180)
				{
					if(emptySpaceFrame.size.width > emptySpaceFrame.size.height)	newCenter.x += 28;
					else															newCenter.y += 28;
				}
				if(currentDeviceOrientationAngle == 270)
				{
					if(emptySpaceFrame.size.width > emptySpaceFrame.size.height)	newCenter.x -= 28;
					else															newCenter.y += 28;
				}
			}
			
			/*now animate the menu view to its new center:*/
			[UIView animateWithDuration: REORIENTATION_DURATION animations: ^{ [theMiniAppIconsView setCenter: newCenter]; } ];
			
			/*..and animate it to its new orientation:*/
			[UIView animateWithDuration: REORIENTATION_DURATION animations: ^{ [theMiniAppIconsView setTransform: rotationTransformToApply]; } completion: ^(BOOL finished){ suspendLayout = 0; } ];
			
			/*..and give it its new bottom right corner so that it can animate the help button there:*/
			CGPoint newBottomRightCorner;
			if(currentDeviceOrientationAngle == 0)	newBottomRightCorner = CGPointMake(emptySpaceFrame.origin.x + emptySpaceFrame.size.width - (newCenter.x - 0.5 * [theMiniAppIconsView bounds].size.width), emptySpaceFrame.origin.y + emptySpaceFrame.size.height - (newCenter.y - 0.5 * [theMiniAppIconsView bounds].size.height));
			if(currentDeviceOrientationAngle == 90)	newBottomRightCorner = CGPointMake(emptySpaceFrame.origin.y + emptySpaceFrame.size.height - (newCenter.y - 0.5 * [theMiniAppIconsView bounds].size.width), 768 - emptySpaceFrame.origin.x - (768 - (newCenter.x + 0.5 * [theMiniAppIconsView bounds].size.height))); 
			if(currentDeviceOrientationAngle == 180)newBottomRightCorner = CGPointMake(768 - emptySpaceFrame.origin.x - (768 - (newCenter.x + 0.5 * [theMiniAppIconsView bounds].size.width)), 1024 - emptySpaceFrame.origin.y - (1024 - (newCenter.y + 0.5 * [theMiniAppIconsView bounds].size.height)));
			if(currentDeviceOrientationAngle == 270)newBottomRightCorner = CGPointMake(1024 - emptySpaceFrame.origin.y - (1024 - (newCenter.y + 0.5 * [theMiniAppIconsView bounds].size.width)), emptySpaceFrame.origin.x + emptySpaceFrame.size.width - (newCenter.x - 0.5 * [theMiniAppIconsView bounds].size.height));
			
			NSMutableArray *performSelectorArgs = [[NSMutableArray alloc] initWithCapacity: 1];
			[performSelectorArgs addObject: [NSValue value: &newBottomRightCorner withObjCType: @encode(CGPoint)]];
			[theMiniAppIconsView performSelector: @selector(setBottomRightCornerPosAndAnimateHelpButtonAppearance:) withObject: performSelectorArgs afterDelay: REORIENTATION_DURATION];
			[performSelectorArgs release];
			
			[theMiniAppIconsView animHelpButtonHide];
		}
		
		/*now reposition the instrucions view. If it is visible, then animate it nicely. If not, then just snap it into its new position:*/
		CGPoint instructionsView_newCenter = CGPointMake(384, 522);
		if(currentDeviceOrientationAngle == 90) instructionsView_newCenter = CGPointMake(374, 512);
		if(currentDeviceOrientationAngle == 180) instructionsView_newCenter = CGPointMake(384, 502);
		if(currentDeviceOrientationAngle == 270) instructionsView_newCenter = CGPointMake(394, 512);
		
		CGRect instructionsView_newBounds = CGRectMake(0, 0, 768, 1004);
		if((currentDeviceOrientationAngle == 90)||(currentDeviceOrientationAngle == 270)) instructionsView_newBounds = CGRectMake(0, 0, 1024, 748);
		
		if(instructionsMode == 1)
		{
			[UIView animateWithDuration: REORIENTATION_DURATION animations: ^{ [theInstructionsView setCenter: instructionsView_newCenter]; }];
			[UIView animateWithDuration: REORIENTATION_DURATION animations: ^{ [theInstructionsView setBounds: instructionsView_newBounds]; }];
			[UIView animateWithDuration: REORIENTATION_DURATION animations: ^{ [theInstructionsView setTransform: rotationTransformToApply]; }];
			
			[theInstructionsView animateToNewCenterAndBounds: REORIENTATION_DURATION newCenter: instructionsView_newCenter newBounds: instructionsView_newBounds];
		}
		
		else
		{
			[theInstructionsView setCenter: instructionsView_newCenter];
			[theInstructionsView setBounds: instructionsView_newBounds];
			[theInstructionsView setTransform: rotationTransformToApply];
			[theInstructionsView layoutSubviewsInLatestBounds];
		}
		
		previousDeviceOrientation = newDeviceOrientation;
		previousDeviceOrientationAngle = newDeviceOrientationAngle;
	}
}


/*
	setupMiniAppChoiceIcons - this method is called as part of the view's initialisation routine. It handles full creation and setup of the four layers, that will present themselves as miniApp choices for the user when he/she opens up a new miniApp:
*/
-(void)setupMiniAppChoiceIcons
{
	/*create emtpy array to hold the layers:*/
	miniAppIconLayers = [[NSMutableArray alloc] initWithCapacity: 5];
	
	/*create the subview that will hold the mini app icons, hide it and add it to this main view as a sub view:*/
	theMiniAppIconsView = [[miniAppIconsView alloc] initWithFrame: CGRectMake(0, 0, 206, 206)];
	[theMiniAppIconsView setBackgroundColor: [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.0]];
	[theMiniAppIconsView setHidden: YES];
	[self addSubview: theMiniAppIconsView];
	
	
	/*Create the four icon CALayers, each of size 100 X 100, in the right position inside the miniAppIconsView, and the one help button (50 X 50):*/
	CALayer *newLayer;
	for(int i = 0; i < 5; i++)
	{
		NSString *iconName;
		if(i == 0) iconName = @"textBox";
		if(i == 1) iconName = @"calculator"; 
		if(i == 2) iconName = @"webBrowser"; 
		if(i == 3) iconName = @"calendar";
		if(i == 4) iconName = @"help";
		
		CGImageRef iconImage = [utilities openCGResourceImage: iconName ofType: @"png"];
		
		
		/*main, black layer with curved corners and white border:*/
		newLayer = [CALayer layer];
		newLayer.anchorPoint = CGPointMake(0.5, 0.5);
		newLayer.bounds = CGRectMake(0.0, 0.0, 100.0, 100.0);
		if(i == 4) newLayer.bounds = CGRectMake(0.0, 0.0, 50.0, 50.0);
		newLayer.backgroundColor = [[UIColor blackColor] CGColor];
		newLayer.borderColor = [[UIColor whiteColor] CGColor];
		newLayer.borderWidth = 4;
		newLayer.cornerRadius = 11;
		newLayer.contents = (id)iconImage;
		
		/*add it as a sublayer to the miniAppIconsView:*/
		[[theMiniAppIconsView layer] addSublayer: newLayer];
		[newLayer setPosition: CGPointMake(((i % 3) == 0)? 50:156, (i < 2)? 50:156)];
		
		
		[miniAppIconLayers addObject: newLayer];
	}
	
	/*Now create an 'appear' animation for each, which will be applied when the icons need to appear, creating an expansion effect on each. This animation lasts 0.4 seconds, and each icon has a slighly different delay at the beginning, to create interest:*/
	/*hard code the starting rectangle - invisibly small square, and the finishing rectangle - 100x100 square:*/
	CGRect zeroSizeRect = CGRectMake(0.0, 0.0, 0.0, 0.0);
	CGRect fullSizeRect = CGRectMake(0.0, 0.0, 100.0, 100.0);
	
	/*hard code the expansion animation key values - the anim will start at zero size rect, hold at zero size for a while, then expand to full size:*/
	NSMutableArray *animValues = [NSMutableArray arrayWithCapacity:3];
	[animValues addObject: [NSValue value:&zeroSizeRect withObjCType:@encode(CGRect)]];
	[animValues addObject: [NSValue value:&zeroSizeRect withObjCType:@encode(CGRect)]];
	[animValues addObject: [NSValue value:&fullSizeRect withObjCType:@encode(CGRect)]];
	
	/*now create the four animations, one for each icon:*/
	miniAppIconLayerAppearAnims = [NSMutableArray arrayWithCapacity: 4];
	for(int i = 0; i < 4; i++)
	{
		/*each icon has a slightly longer delay than the last on the expansion, so each needs its own aniamtion timings for its keyframes:*/
		NSMutableArray *animTimings = [NSMutableArray arrayWithCapacity:3];
		[animTimings addObject: [NSNumber numberWithFloat:0.0]];
		[animTimings addObject: [NSNumber numberWithFloat: ((float)(i)*0.1) / ((float)(i)*0.1 + 0.2) ]];
		[animTimings addObject: [NSNumber numberWithFloat:1.0]];
		
		/*create the actual animation object and give it the information it needs about duration and keyframe*/
		CAKeyframeAnimation *layerExpandAnim = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
		layerExpandAnim.duration = 0.2 + i*0.1;
		layerExpandAnim.values = animValues;
		layerExpandAnim.keyTimes = animTimings;
		
		/*add it to our array:*/
		[miniAppIconLayerAppearAnims addObject:layerExpandAnim];
	}
	
	/*this array will be used later, so retain:*/
	[miniAppIconLayerAppearAnims retain];
	
	
	/*there is one further set of animations to create - the animation to expand the user-chosen icon from its default position to the full frame of the new app that has been created.
	 This involves 3 animations - one to change the layer bounds, one to change the corner radii, and one to change the layer position:*/
	newMiniAppAppearAnims = [NSMutableArray arrayWithCapacity: 3];
	
	CABasicAnimation *newMiniAppAppearAnims_mainBounds = [CABasicAnimation animationWithKeyPath: @"bounds"];
	newMiniAppAppearAnims_mainBounds.duration = 0.25;
	
	CABasicAnimation *newMiniAppAppearAnims_mainPosition = [CABasicAnimation animationWithKeyPath: @"position"];
	newMiniAppAppearAnims_mainBounds.duration = 0.25;
	
	CABasicAnimation *newMiniAppAppearAnims_cornerRadius = [CABasicAnimation animationWithKeyPath: @"cornerRadius"];
	newMiniAppAppearAnims_cornerRadius.duration = 0.25;
	newMiniAppAppearAnims_cornerRadius.toValue = [NSNumber numberWithInt: 5];
	
	
	[newMiniAppAppearAnims addObject: newMiniAppAppearAnims_mainBounds];
	[newMiniAppAppearAnims addObject: newMiniAppAppearAnims_mainPosition];
	[newMiniAppAppearAnims addObject: newMiniAppAppearAnims_cornerRadius];
	
	[newMiniAppAppearAnims retain];
}


/*
	opens the instructions view
 */
- (void)openInstructions
{
	/*Simply bring the instructions view to the front, and animate it into visibility:*/
	[self bringSubviewToFront: theInstructionsView];
	[theInstructionsView setAlpha: 0.0];
	[theInstructionsView setHidden: NO];
	[UIView animateWithDuration: INSTRUCTIONS_VIEW_VIS_ANIM_DURATION animations: ^{ [theInstructionsView setAlpha: 1.0]; }];
	
	instructionsMode = 1;
}

/*
	closes the instructions
 */
- (void)closeInstructions
{
	/*Simply and animate the instrucitons view into invisibility:*/
	[UIView animateWithDuration: INSTRUCTIONS_VIEW_VIS_ANIM_DURATION animations: ^{ [theInstructionsView setAlpha: 0.0]; } completion: ^(BOOL finished){ [theInstructionsView setHidden: YES]; } ];
	
	instructionsMode = 0;
}



/*
	cropFrameRectToAccommodatePanelGapsAndIPadToolbar - given a CGRect, this determines whether it needs to have its shape cropped in order to fit in the drawable space, e.g. rects aligned with the top edge of the screen will need 20px shaved off their top edge to leave space for the iPad toolbar:
 */
- (CGRect)cropFrameRectToAccommodatePanelGapsAndIPadToolbar: (CGRect)rect
{
	CGRect croppedRect;
	
	/*a 1-pixel thick gap should separate all panels/miniApps. Therefore by default, shave one pixel off the right and bottom edges of each panel, with the exception of any panels with borders on the very right or bottom of the screen (they don't need their edges sliced)*/
	croppedRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - 1, rect.size.height - 1);
	if((croppedRect.origin.x + croppedRect.size.width) == 767) croppedRect.size.width = croppedRect.size.width + 1;
	if((croppedRect.origin.y + croppedRect.size.height) == 1023) croppedRect.size.height = croppedRect.size.height + 1;
	
	/*A further shaving - the top 20 pixels must be shaved off any mini app that is aligned with the top of this view - in order to make space for the iPad toolbar:*/
	if((currentDeviceOrientation == UIDeviceOrientationPortrait)&&(croppedRect.origin.y == 0))
	{
		croppedRect = CGRectMake(croppedRect.origin.x, 20, croppedRect.size.width, croppedRect.size.height - 20);
	}
	
	if((currentDeviceOrientation == UIDeviceOrientationLandscapeLeft)&&((croppedRect.origin.x + croppedRect.size.width) == 768))
	{
		croppedRect = CGRectMake(croppedRect.origin.x, croppedRect.origin.y, croppedRect.size.width - 20, croppedRect.size.height);
	}
	
	if((currentDeviceOrientation == UIDeviceOrientationPortraitUpsideDown)&&((croppedRect.origin.y + croppedRect.size.height) == 1024))
	{
		croppedRect = CGRectMake(croppedRect.origin.x, croppedRect.origin.y, croppedRect.size.width, croppedRect.size.height - 20);
	}
	
	if((currentDeviceOrientation == UIDeviceOrientationLandscapeRight)&&(croppedRect.origin.x == 0))
	{
		croppedRect = CGRectMake(20, croppedRect.origin.y, croppedRect.size.width - 20, croppedRect.size.height);
	}
	
	return croppedRect;
}


/*
	layoutSubviews
 
	this method should be called whenever there has been a change to the underlying panel structure, it updates the mini app views to the latest frame bounds that they need, ready for drawing:
*/
-(void)layoutSubviews
{
	if(layoutSubviewsHasBeenCalledForFirstTime == 0) layoutSubviewsHasBeenCalledForFirstTime = 1;
	
	if(suspendLayout == 0)
	{
		miniAppView *miniAppViewToUpdate;
		panelTreeDesc *panelDescNodeForView;
	
		
		for(int i = 0; i < [self.subviews count]; i++)
		{
			if([self.subviews objectAtIndex: i] == theMiniAppIconsView) continue;
			if([self.subviews objectAtIndex: i] == theInstructionsView) continue;
			
			miniAppViewToUpdate = [self.subviews objectAtIndex:i];
			[miniAppViewToUpdate setNeedsDisplay];
		
			/*This mini app view may be temporarily exempted from being confined to the panel layout, in which case, do not adjust its position here:*/
			if(miniAppViewToUpdate == exemptedMiniAppView) continue;
			
			
			panelDescNodeForView = (panelTreeDesc *)([miniAppViewToUpdate getPanelTreeDescNodePointer]);
		
			if(miniAppViewToUpdate == miniAppToBeRemoved) continue;
		
			/*a 1-pixel thick gap should separate all panels/miniApps. Therefore by default, shave one pixel off the right and bottom edges of each panel, with the exception of any panels with borders on the very right or bottom of the screen (they don't need their edges sliced)*/
			CGRect miniAppViewFrameRect = CGRectMake(panelDescNodeForView->originX, panelDescNodeForView->originY, panelDescNodeForView->width - 1, panelDescNodeForView->height - 1);
			if((miniAppViewFrameRect.origin.x + miniAppViewFrameRect.size.width) == 767) miniAppViewFrameRect.size.width = panelDescNodeForView->width;
			if((miniAppViewFrameRect.origin.y + miniAppViewFrameRect.size.height) == 1023) miniAppViewFrameRect.size.height = panelDescNodeForView->height;

			/*A further shaving - the top 20 pixels must be shaved off any mini app that is aligned with the top of this view - in order to make space for the iPad toolbar:*/
			if((previousDeviceOrientation == UIDeviceOrientationPortrait)&&(miniAppViewFrameRect.origin.y == 0))
			{
				miniAppViewFrameRect = CGRectMake(miniAppViewFrameRect.origin.x, 20, miniAppViewFrameRect.size.width, miniAppViewFrameRect.size.height - 20);
			}
			
			if((previousDeviceOrientation == UIDeviceOrientationLandscapeLeft)&&((miniAppViewFrameRect.origin.x + miniAppViewFrameRect.size.width) == 768))
			{
				miniAppViewFrameRect = CGRectMake(miniAppViewFrameRect.origin.x, miniAppViewFrameRect.origin.y, miniAppViewFrameRect.size.width - 20, miniAppViewFrameRect.size.height);
			}
			
			if((previousDeviceOrientation == UIDeviceOrientationPortraitUpsideDown)&&((miniAppViewFrameRect.origin.y + miniAppViewFrameRect.size.height) == 1024))
			{
				miniAppViewFrameRect = CGRectMake(miniAppViewFrameRect.origin.x, miniAppViewFrameRect.origin.y, miniAppViewFrameRect.size.width, miniAppViewFrameRect.size.height - 20);
			}
			
			if((previousDeviceOrientation == UIDeviceOrientationLandscapeRight)&&(miniAppViewFrameRect.origin.x == 0))
			{
				miniAppViewFrameRect = CGRectMake(20, miniAppViewFrameRect.origin.y, miniAppViewFrameRect.size.width - 20, miniAppViewFrameRect.size.height);
			}
			
		
			/*if we are in the middle of a shift event and this view's frame is being affected by it, then keep a record of this view:*/
			//if(touchEventTypeInProgress == 1)
			//{
			//	if((miniAppViewFrameRect.origin.x != [miniAppViewToUpdate frame].origin.x)||(miniAppViewFrameRect.origin.y != [miniAppViewToUpdate frame].origin.y)||(miniAppViewFrameRect.size.width != [miniAppViewToUpdate frame].size.width)||(miniAppViewFrameRect.size.height != [miniAppViewToUpdate frame].size.height))
			//	{
				//	[miniAppViewsAffectedByCurrentShiftEvent removeObject: miniAppViewToUpdate];
				//	[miniAppViewsAffectedByCurrentShiftEvent addObject: miniAppViewToUpdate];
				//}
			//}
		
			[miniAppViewToUpdate setFrame:miniAppViewFrameRect];
			[miniAppViewToUpdate setNeedsLayout];
			[miniAppViewToUpdate setNeedsDisplay];
		}
	}
}


/*
	openNewMiniAppOfType - this method handles the creation of a new mini app, from start to finish:
*/
-(void)openNewMiniAppWithDescNodeAddress:(int)panelDescNodeAddress andPanelToTruncate:(miniAppView *)panelToTruncate
{
	/*retrieve geometric info about the frames of the new panel, and the panel that is being truncated to make space for it:*/
	newPanelDescPointer = (panelTreeDesc *)panelDescNodeAddress;
	panelTreeDesc *truncatePanelDescPointer = (panelTreeDesc *)([panelToTruncate getPanelTreeDescNodePointer]);
	
	
	
	/*make sure that there is clean black space beneath the truncated panel as it makes way:*/
	[self setNeedsDisplay];
	
	
	/*we are now in 'newMiniAppChoiceMode', so announce this state so that all normal event handling is suspended, also make sure multi-touch is disabled*/
	newMiniAppChoiceMode = 1;
	[self setMultipleTouchEnabled:NO];
	
	/*instruct the truncate panel to truncate itself over the duration specified for truncation*/
	/*compute the new bounds and center for this mini app after resizing (as ever, each view should actually be 1px narrower and shorter than its true bounds, unless its aligned with the right hand or bottom edge):*/
	//CGRect newBounds = CGRectMake(0, 0, truncatePanelDescPointer->width - 1, truncatePanelDescPointer->height - 1);
	//if((truncatePanelDescPointer->originX + truncatePanelDescPointer->width) == 768) newBounds.size.width = truncatePanelDescPointer->width;
	//if((truncatePanelDescPointer->originY + truncatePanelDescPointer->height) == 1024) newBounds.size.height = truncatePanelDescPointer->height;
	
	CGRect newFrame = CGRectMake(truncatePanelDescPointer->originX, truncatePanelDescPointer->originY, truncatePanelDescPointer->width - 1, truncatePanelDescPointer->height - 1);
	if((newFrame.origin.x + newFrame.size.width) == 767) newFrame.size.width = newFrame.size.width + 1;
	if((newFrame.origin.y + newFrame.size.height) == 1023) newFrame.size.height = newFrame.size.height + 1;
	
	/*A further shaving - the top 20 pixels must be shaved off any mini app that is aligned with the top of this view - in order to make space for the iPad toolbar:*/
	if((previousDeviceOrientation == UIDeviceOrientationPortrait)&&(newFrame.origin.y == 0))
	{
		newFrame = CGRectMake(newFrame.origin.x, 20, newFrame.size.width, newFrame.size.height - 20);
	}
	
	if((previousDeviceOrientation == UIDeviceOrientationLandscapeLeft)&&((newFrame.origin.x + newFrame.size.width) == 768))
	{
		newFrame = CGRectMake(newFrame.origin.x, newFrame.origin.y, newFrame.size.width - 20, newFrame.size.height);
	}
	
	if((previousDeviceOrientation == UIDeviceOrientationPortraitUpsideDown)&&((newFrame.origin.y + newFrame.size.height) == 1024))
	{
		newFrame = CGRectMake(newFrame.origin.x, newFrame.origin.y, newFrame.size.width, newFrame.size.height - 20);
	}
	
	if((previousDeviceOrientation == UIDeviceOrientationLandscapeRight)&&(newFrame.origin.x == 0))
	{
		newFrame = CGRectMake(20, newFrame.origin.y, newFrame.size.width - 20, newFrame.size.height);
	}
	
	/*calculate the center of this mini app view, given the corrected frame:*/
	//CGPoint newCenter = CGPointMake(truncatePanelDescPointer->originX + 0.5 * newBounds.size.width, truncatePanelDescPointer->originY + 0.5 *  newBounds.size.height);
	CGPoint newCenter = CGPointMake(newFrame.origin.x + 0.5 * newFrame.size.width, newFrame.origin.y + 0.5 *  newFrame.size.height);
	
	
	/*extract just the bounds from the new frame:*/
	CGRect newBounds = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
	
	/*Important: the new bounds depend upon the orientation of the interface (they're swapped if we're in landscape)*/
	if((currentDeviceOrientationAngle == 90)||(currentDeviceOrientationAngle == 270)) newBounds = CGRectMake(0, 0, newBounds.size.height, newBounds.size.width);
	
	/*now apply this new bounds and center:*/
	graphicsDelayContext = 0;
	[panelToTruncate animateChangeOfBoundsAndCenter: TRUNCATION_FOR_NEW_MINI_APP_DURATION toBounds: newBounds andCenter: newCenter];
	
	
	/*After this has finished, send a message to this view itself to draw the menu for the user in the space left over:*/
	newMiniAppFrame = CGRectMake(newPanelDescPointer->originX, newPanelDescPointer->originY, newPanelDescPointer->width, newPanelDescPointer->height);
	
	/*As with the truncated mini app, this new frame might need to be cropped:*/
	newMiniAppFrame = [self cropFrameRectToAccommodatePanelGapsAndIPadToolbar: newMiniAppFrame];
	
	//NSTimer *menuLaunchTimer = [NSTimer timerWithTimeInterval: TRUNCATION_FOR_NEW_MINI_APP_DURATION target: self selector: @selector(launchNewMiniAppUserChoiceMenu) userInfo: nil repeats: NO];
	//[[NSRunLoop currentRunLoop] addTimer: menuLaunchTimer forMode: NSRunLoopCommonModes];
}


/*
	prepareNewMiniAppUserChoiceMenuForLaunch - prepares the mini app menu, ready to appear:
 */
-(void)prepareNewMiniAppUserChoiceMenuForLaunch
{
	CGRect spaceForNewApp = newMiniAppFrame;
	
	int iconSmallerSize = -1;
	CGRect iconSmallerRect;
	int iconSmallerCornerRadius;
	int iconSmallerOffset;
	CGPoint iconsViewOffset = CGPointMake(0.0, 0.0);
	NSMutableArray *iconSmallerSizeAnimValuesArray;
	
	/*determine where the centre of the set of icons should be:*/
	CGPoint menuCentre = CGPointMake((int)(spaceForNewApp.origin.x + 0.5*spaceForNewApp.size.width), (int)(spaceForNewApp.origin.y + 0.5*spaceForNewApp.size.height));
	miniAppIconsViewOffset = 0;
	
	/*determine the correct orientation for the menu:*/
	CGAffineTransform rotationTransformForOrientation;
	
	if(currentDeviceOrientationAngle ==   0) rotationTransformForOrientation = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
	if(currentDeviceOrientationAngle ==  90) rotationTransformForOrientation = CGAffineTransformMake(0, 1, -1, 0, 0, 0);
	if(currentDeviceOrientationAngle == 180) rotationTransformForOrientation = CGAffineTransformMake(-1, 0, 0, -1, 0, 0);
	if(currentDeviceOrientationAngle == 270) rotationTransformForOrientation = CGAffineTransformMake(0, -1, 1, 0, 0, 0);
	
	
	/*It is possible that there is not room, at the default size of 100x100, to fit the icons and help button into the space available for the new miniApp. If so, change shape/position of icons to fit:*/
	if((spaceForNewApp.size.width < 330)&&(spaceForNewApp.size.height < 330))
	{
		/*cut 56px off the larger dimension of the space available, to be filled by the help button:*/
		CGRect croppedSpaceForMenu = spaceForNewApp;
		if(spaceForNewApp.size.width > spaceForNewApp.size.height) croppedSpaceForMenu.size.width -= 56.0;
		else croppedSpaceForMenu.size.height -= 56.0;
		
		/*due to the above, we will be offsetting the icons from their position at the exact centre of the new mini app space. Record this globally:*/
		miniAppIconsViewOffset = 1;
		
		/*...and so offset the posisition at which the icons will be drawn:*/
		if(currentDeviceOrientationAngle == 0)
		{
			if(spaceForNewApp.size.width > spaceForNewApp.size.height)	menuCentre.x -= 28;
			else														menuCentre.y -= 28;
		}
		if(currentDeviceOrientationAngle == 90)
		{
			if(spaceForNewApp.size.width > spaceForNewApp.size.height)	menuCentre.x += 28;
			else														menuCentre.y -= 28;
		}
		if(currentDeviceOrientationAngle == 180)
		{
			if(spaceForNewApp.size.width > spaceForNewApp.size.height)	menuCentre.x += 28;
			else														menuCentre.y += 28;
		}
		if(currentDeviceOrientationAngle == 270)
		{
			if(spaceForNewApp.size.width > spaceForNewApp.size.height)	menuCentre.x -= 28;
			else														menuCentre.y += 28;
		}
		
		/*even in this offset position, the icons may be too big for the space available. If so, reduce them to fit into whichever if the dimensions of the availble space is smaller:*/
		if((croppedSpaceForMenu.size.width < 218)||(croppedSpaceForMenu.size.height < 218))
		{
			float smallerCroppedDimension = croppedSpaceForMenu.size.width;
			if(croppedSpaceForMenu.size.height < croppedSpaceForMenu.size.width) smallerCroppedDimension = croppedSpaceForMenu.size.height;
			
			iconSmallerSize = (int)(0.5 * (smallerCroppedDimension - 18));
		}
	}
	
	/*alternatively it is possible that only one of width/height is too small, in which case simply scale the icons down to fit in:*/
	else if((spaceForNewApp.size.width < 218)||(spaceForNewApp.size.height < 218))
	{
		int smallerDimension = spaceForNewApp.size.width;
		if(spaceForNewApp.size.height < spaceForNewApp.size.width) smallerDimension = spaceForNewApp.size.height;
		
		/*determine the size the icons will have to be, the CGRect they will occupy, the corner radius they'll need and the offset they'll need to have from their parent view's origin as a result of being smaller than normal:*/
		iconSmallerSize = (int)((smallerDimension - 18) / 2.0);
	}
	
	if(iconSmallerSize != -1)
	{
		iconSmallerRect = CGRectMake(0.0, 0.0, iconSmallerSize, iconSmallerSize);
		iconSmallerCornerRadius = (int)(11.0 * (iconSmallerSize / 100.0));
		iconSmallerOffset = 100 - iconSmallerSize; 
		
		/*the icons' appear animations will have to be changed to include this modified size:*/
		iconSmallerSizeAnimValuesArray = [NSMutableArray arrayWithCapacity: 3];
		[iconSmallerSizeAnimValuesArray addObject: [[[miniAppIconLayerAppearAnims objectAtIndex: 0] values] objectAtIndex: 0]];
		[iconSmallerSizeAnimValuesArray addObject: [[[miniAppIconLayerAppearAnims objectAtIndex: 0] values] objectAtIndex: 1]];
		[iconSmallerSizeAnimValuesArray addObject: [NSValue value: &iconSmallerRect withObjCType:@encode(CGRect)]];
		
		for(int i = 0; i < 4; i++) [[miniAppIconLayerAppearAnims objectAtIndex: i] setValues: iconSmallerSizeAnimValuesArray];
	}
	
	
	/*Now that we're confident that the icons and help button all fit, position the new mini app menu in place:*/
	[theMiniAppIconsView setCenter: menuCentre];
	[theMiniAppIconsView setTransform: rotationTransformForOrientation];
	
	/*determine the bottom right corner of the newMiniAppFrame, so that the mini app icons view can position the help button there:*/
	CGPoint newMiniAppFrame_bottomRightCorner;
	if(currentDeviceOrientationAngle == 0)	newMiniAppFrame_bottomRightCorner = CGPointMake(newMiniAppFrame.origin.x + newMiniAppFrame.size.width - [theMiniAppIconsView frame].origin.x, newMiniAppFrame.origin.y + newMiniAppFrame.size.height - [theMiniAppIconsView frame].origin.y);
	if(currentDeviceOrientationAngle == 90)	newMiniAppFrame_bottomRightCorner = CGPointMake(newMiniAppFrame.origin.y + newMiniAppFrame.size.height - ([theMiniAppIconsView center].y - 0.5 * [theMiniAppIconsView bounds].size.width), 768 - newMiniAppFrame.origin.x - (768 - ([theMiniAppIconsView center].x + 0.5 * [theMiniAppIconsView bounds].size.height))); 
	if(currentDeviceOrientationAngle == 180)newMiniAppFrame_bottomRightCorner = CGPointMake(768 - newMiniAppFrame.origin.x - (768 - ([theMiniAppIconsView center].x + 0.5 * [theMiniAppIconsView bounds].size.width)), 1024 - newMiniAppFrame.origin.y - (1024 - ([theMiniAppIconsView center].y + 0.5 * [theMiniAppIconsView bounds].size.height)));
	if(currentDeviceOrientationAngle == 270)newMiniAppFrame_bottomRightCorner = CGPointMake(1024 - newMiniAppFrame.origin.y - (1024 - ([theMiniAppIconsView center].y + 0.5 * [theMiniAppIconsView bounds].size.width)), newMiniAppFrame.origin.x + newMiniAppFrame.size.width - ([theMiniAppIconsView center].x - 0.5 * [theMiniAppIconsView bounds].size.height));
	[theMiniAppIconsView setBottomRightCornerPos: newMiniAppFrame_bottomRightCorner];

	
	
	/*now set the icons' areas to zero, set their initial position, make them visible and kill off all animation, so that they just appear immediately without any motion:*/
	for(int i = 0; i < 4; i++)
	{
		[[miniAppIconLayers objectAtIndex: i] setBounds: CGRectMake(0.0, 0.0, 0.0, 0.0)];
		
		if(iconSmallerSize != -1)
		{
			[[miniAppIconLayers objectAtIndex: i] setPosition: CGPointMake(((i % 3) == 0)? (iconSmallerOffset + 0.5 * iconSmallerSize):(iconSmallerOffset + 6.0 + 1.5 * iconSmallerSize), (i < 2)? (iconSmallerOffset + 0.5 * iconSmallerSize):(iconSmallerOffset + 6.0 + 1.5 * iconSmallerSize))];
			[[miniAppIconLayers objectAtIndex: i] setCornerRadius: iconSmallerCornerRadius];
		}
			
		[[miniAppIconLayers objectAtIndex: i] removeAllAnimations];
	}
	
	/*set the help button to hidden, in preparation for its animated appearance:*/
	[[miniAppIconLayers objectAtIndex: 4] setHidden: YES];
	[[miniAppIconLayers objectAtIndex: 4] removeAllAnimations];
	
	/*launch the menu with a delay of 0 seconds (this forces the system to carry out all of the above before continuing:)*/
	NSMutableArray *launchMethodArguments = [[NSMutableArray alloc] initWithCapacity: 2];
	[launchMethodArguments addObject: [NSNumber numberWithInt: iconSmallerSize]];
	[launchMethodArguments addObject: [NSValue value: &iconSmallerRect withObjCType: @encode(CGRect)]];
	
	[self performSelector: @selector(launchNewMiniAppUserChoiceMenu:) withObject: launchMethodArguments afterDelay: 0];
	
	[launchMethodArguments release];
}

- (void)launchNewMiniAppUserChoiceMenu: (id)parameters
{
	int iconSmallerSize = [[parameters objectAtIndex: 0] intValue];
	CGRect iconSmallerRect;
	[[parameters objectAtIndex: 1] getValue: &iconSmallerRect];
	
	/*now that the icons are mere dots, make the container view visible:*/
	[theMiniAppIconsView setHidden: NO];
	
	/*now that they are ready as dots, simply apply the pre-made animations and go*/
	CGRect iconDestinationRect = CGRectMake(0.0, 0.0, 100.0, 100.0);
	if(iconSmallerSize != -1) iconDestinationRect = iconSmallerRect;
	
	for(int i = 0; i < 4; i++)
	{
		[[miniAppIconLayers objectAtIndex: i] setBounds: iconDestinationRect];
		[[miniAppIconLayers objectAtIndex: i] addAnimation: [miniAppIconLayerAppearAnims objectAtIndex: i] forKey:@"animateBounds"];
	}
	
	/*Animate the help button to simply fade in:*/
	[[miniAppIconLayers objectAtIndex: 4] setHidden: NO];
	
	[self setNeedsLayout];
	[self setNeedsDisplay];
}


/* 
	newMiniAppChosen - called when user has selected a mini app type to open. This method sets up the new app in the right space, and sets the state of this view back to normal operation:
 */
- (void)newMiniAppChosen:(int)typeChosen
{
	newMiniAppTypeChosen = typeChosen;
	
	/*First, create the new view:*/
	CGRect newMiniAppRect = CGRectMake(newPanelDescPointer->originX, newPanelDescPointer->originY, newPanelDescPointer->width, newPanelDescPointer->height);
	
	/*As usual, crop it if neccessary:*/
	newMiniAppRect = [self cropFrameRectToAccommodatePanelGapsAndIPadToolbar: newMiniAppRect];
	
	if(typeChosen == 0) newMiniAppView = [[textBoxMiniAppView alloc] initWithFrame: newMiniAppRect];
	if(typeChosen == 1) newMiniAppView = [[calculatorMiniAppView alloc] initWithFrame: newMiniAppRect];
	if(typeChosen == 2) newMiniAppView = [[webBrowserMiniAppView alloc] initWithFrame: newMiniAppRect];
	if(typeChosen == 3) newMiniAppView = [[calendarMiniAppView alloc] initWithFrame: newMiniAppRect];
	
	/*assign the new mini app its pointer to its panelDescNode, and send it the id of its parent (i.e. this view):*/
	[newMiniAppView setPanelTreeDescNodePointer: (int)(newPanelDescPointer)];
	[newMiniAppView setRootPanelView: self];
	
	
	/*The above is the 'official' frame of the mini app view in the permanent portrait layout. If we're in anything other than upwards portrait mode, this newly created mini app view needs its affine transform and bounds updating to fit:*/
	
	/*orient transform the new mini app appropriately given the device orientation:*/
	CGAffineTransform rotationTransformForOrientation;
	
	if(currentDeviceOrientationAngle ==   0) rotationTransformForOrientation = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
	
	if(currentDeviceOrientationAngle ==  90)
	{
		rotationTransformForOrientation = CGAffineTransformMake(0, 1, -1, 0, 0, 0);
		[newMiniAppView setBounds: CGRectMake(0, 0, newMiniAppRect.size.height, newMiniAppRect.size.width)];
	}
		
	if(currentDeviceOrientationAngle == 180) rotationTransformForOrientation = CGAffineTransformMake(-1, 0, 0, -1, 0, 0);
	
	if(currentDeviceOrientationAngle == 270)
	{
		rotationTransformForOrientation = CGAffineTransformMake(0, -1, 1, 0, 0, 0);
		[newMiniAppView setBounds: CGRectMake(0, 0, newMiniAppRect.size.height, newMiniAppRect.size.width)];
	}
	
	[newMiniAppView setTransform: rotationTransformForOrientation];
	
	/*It is possible that this orientation of the mini app will come after it has already drawn itself at the assumed, device portrait orientation. In case this has happened, tell the new view the redraw itself now:*/
	[newMiniAppView shiftEventEnded];
	
	
	
	/*add it to the array of mini app views and install it as a subview to this, the parent view:*/
	[newMiniAppView setHidden: YES];
	[self addSubview: newMiniAppView];
	[miniAppSubviews addObject: newMiniAppView];
	[newMiniAppView release];
	
	/*make sure that the mini app icons view is always on top of everything else:*/
	[self bringSubviewToFront: theMiniAppIconsView];
	

	
	/*now trigger the chosen icon to expand to the full frame rect of the new mini app (it is a sublayer of the miniAppIconsView, so its destination rect must be reverse transformed to meet the correct rect in this view) Also, make sure the correct bounds are set based upon the device orientation:*/
	[[miniAppIconLayers objectAtIndex: typeChosen] setZPosition: 1];
	
	
	CGRect bounds_fromValue = [[miniAppIconLayers objectAtIndex: typeChosen] bounds];
	CGRect bounds_toValue = CGRectMake(0, 0, newMiniAppRect.size.width, newMiniAppRect.size.height);
	if((currentDeviceOrientationAngle == 90)||(currentDeviceOrientationAngle == 270)) bounds_toValue = CGRectMake(0, 0, bounds_toValue.size.height, bounds_toValue.size.width);
	
	CGPoint position_fromValue = [[miniAppIconLayers objectAtIndex: typeChosen] position];
	
	/*Quite complicated - the position 'to' value is the centre of the new mini app, but must be expressed in the coordinate space of the iconsView, which may be rotated:*/
	CGPoint position_toValue = CGPointMake(newMiniAppRect.origin.x + 0.5 * newMiniAppRect.size.width, newMiniAppRect.origin.y + 0.5 * newMiniAppRect.size.height);
	CGPoint position_toValue_iconsViewSpace = CGPointMake(position_toValue.x - ([theMiniAppIconsView center].x - 0.5 * ([theMiniAppIconsView bounds].size.width)), position_toValue.y - ([theMiniAppIconsView center].y - 0.5 * ([theMiniAppIconsView bounds].size.height)));
	if(currentDeviceOrientationAngle == 90) position_toValue_iconsViewSpace = CGPointMake(position_toValue.y - ([theMiniAppIconsView center].y - 0.5*[theMiniAppIconsView bounds].size.height), 768 - position_toValue.x - (768 - [theMiniAppIconsView center].x - 0.5*[theMiniAppIconsView bounds].size.width));
	if(currentDeviceOrientationAngle == 180) position_toValue_iconsViewSpace = CGPointMake(768 - position_toValue.x - (768 - [theMiniAppIconsView center].x - 0.5*[theMiniAppIconsView bounds].size.width), 1024 - position_toValue.y - (1024 - [theMiniAppIconsView center].y - 0.5*[theMiniAppIconsView bounds].size.height));
	if(currentDeviceOrientationAngle == 270) position_toValue_iconsViewSpace = CGPointMake(1024 - position_toValue.y - (1024 - [theMiniAppIconsView center].y - 0.5*[theMiniAppIconsView bounds].size.height), position_toValue.x - ([theMiniAppIconsView center].x - 0.5*[theMiniAppIconsView bounds].size.width));
	float cornerRadius_fromValue = [[miniAppIconLayers objectAtIndex: typeChosen] cornerRadius];
	
	/*bounds animation:*/
	[[newMiniAppAppearAnims objectAtIndex: 0] setFromValue: [NSValue value:&bounds_fromValue withObjCType:@encode(CGRect)]];
	[[newMiniAppAppearAnims objectAtIndex: 0] setToValue: [NSValue value:&bounds_toValue withObjCType:@encode(CGRect)]];
	
	/*position animation:*/
	[[newMiniAppAppearAnims objectAtIndex: 1] setFromValue: [NSValue value:&position_fromValue withObjCType:@encode(CGPoint)]];
	[[newMiniAppAppearAnims objectAtIndex: 1] setToValue: [NSValue value:&position_toValue_iconsViewSpace withObjCType:@encode(CGPoint)]];
	
	/*cornerRadius animation:*/
	[[newMiniAppAppearAnims objectAtIndex: 2] setFromValue: [NSNumber numberWithFloat: cornerRadius_fromValue]];
	
	CAAnimationGroup *animGroup = [[CAAnimationGroup alloc] init];
	[animGroup setAnimations: newMiniAppAppearAnims];
	[animGroup setDuration: 0.25];
	[animGroup setDelegate: self];
	
	
	/*Due to the vagaries of the way in which the icons are created, layer/bitmap wise, if the icons are normal size (100x100) then set the contents to remain native size and stay in the centre. If not, set contents to keep its aspect ratio while filling the layer bonds as much as possible:*/
	if((newMiniAppRect.size.width < 218) || (newMiniAppRect.size.height < 218)) [[miniAppIconLayers objectAtIndex: typeChosen] setContentsGravity: kCAGravityResizeAspect];
	else [[miniAppIconLayers objectAtIndex: typeChosen] setContentsGravity: kCAGravityCenter];
	[[miniAppIconLayers objectAtIndex: typeChosen] setBounds: bounds_toValue];
	[[miniAppIconLayers objectAtIndex: typeChosen] setPosition: position_toValue_iconsViewSpace];
	[[miniAppIconLayers objectAtIndex: typeChosen] setCornerRadius: 5];
	[[miniAppIconLayers objectAtIndex: typeChosen] addAnimation: animGroup forKey:@"animGroup"];
	[animGroup release];

	/*we are at the first stage, '0' of the mini app creation process:*/
	newMiniAppChoiceModeStage = 0;
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	if(newMiniAppChoiceModeStage == 0) [self fadeIconToNewMiniApp];
	else if(newMiniAppChoiceModeStage == 1) [self fullyInstateNewMiniAppAndEndChoiceMode];
}


/*
	fadeIconToNewMiniApp - this method is called when the initial stage of icon expansion for a new mini app is complete. It sets up the final stage of animation - fading the expanding icon out to reveal the new mini app UI beneath:
 */

- (void)fadeIconToNewMiniApp
{
	/*make the new mini app visible:*/
	[newMiniAppView setHidden: NO];
	
	/*hide all details of the minAppIconsView *except for* the icon that has been expanded, and trigger animation to fade it all into the new miniApp below:*/
	for(int i = 0; i < 5; i++)
	{
		if(i == newMiniAppTypeChosen) continue;
		
		[[miniAppIconLayers objectAtIndex: i] setHidden: YES];
		[[miniAppIconLayers objectAtIndex: i] removeAllAnimations];
	}
	
	[UIView animateWithDuration: 0.25 animations: ^{ [theMiniAppIconsView setAlpha: 0.0]; } completion: ^(BOOL finished) { [self animationDidStop: nil finished: YES]; } ];
	
	newMiniAppChoiceModeStage = 1;
}



/*
	fullyInstateNewMiniAppAndEndChoiceMode - this method will be called once the mini app icon chosen has morphed itself into the new new mini app - at this point we just clean up the mini app icons view and set the whole system back to processing events as normal:
 */
- (void)fullyInstateNewMiniAppAndEndChoiceMode
{
	/*first of all hide the container view:*/
	[theMiniAppIconsView setHidden: YES];
	
	/*now set it back to normal:*/
	[theMiniAppIconsView setAlpha: 1.0];
	
	
	/*the icons may have had their size made smaller. If this is the case, set their appear anims back to normal as well:*/
	if((newMiniAppFrame.size.width < 218) || (newMiniAppFrame.size.height < 218))
	{
		CGRect iconStandardBoundsRect = CGRectMake(0.0, 0.0, 100.0, 100.0);
		NSMutableArray *iconStandardSizeAnimValuesArray = [NSMutableArray arrayWithCapacity: 3];
		[iconStandardSizeAnimValuesArray addObject: [[[miniAppIconLayerAppearAnims objectAtIndex: 0] values] objectAtIndex: 0]];
		[iconStandardSizeAnimValuesArray addObject: [[[miniAppIconLayerAppearAnims objectAtIndex: 0] values] objectAtIndex: 1]];
		[iconStandardSizeAnimValuesArray addObject: [NSValue value: &iconStandardBoundsRect withObjCType:@encode(CGRect)]];
		
		for(int i = 0; i < 4; i++) [[miniAppIconLayerAppearAnims objectAtIndex: i] setValues: iconStandardSizeAnimValuesArray];
	}
	
	/*set all icons' settings (opacity, content gravity, size, corner radius etc) back to how they were before we animated it to expand:*/	
	for(int i = 0; i < 4; i++)
	{
		[[miniAppIconLayers objectAtIndex: i] setOpacity: 1.0];
		[[miniAppIconLayers objectAtIndex: i] setBounds: CGRectMake(0, 0, 100, 100)];
		[[miniAppIconLayers objectAtIndex: i] setPosition: CGPointMake(((i % 3) == 0)? 50:156, (i < 2)? 50:156)];
		[[miniAppIconLayers objectAtIndex: i] setContentsGravity: kCAGravityResize];
		[[miniAppIconLayers objectAtIndex: i] setCornerRadius: 11.0];
		[[miniAppIconLayers objectAtIndex: i] setZPosition: 0.0];
	
		[[miniAppIconLayers objectAtIndex: i] setHidden: NO];
		[[miniAppIconLayers objectAtIndex: i] removeAllAnimations];
	}
		
		
	/*We are now no longer in 'mini app choice mode*/
	newMiniAppChoiceMode = 0;
	[self setMultipleTouchEnabled: YES];
}


/*
	miniAppDidDetectQuitGesture - when a mini app detects that the user has signalled it to quit, it will call this method to notify this, the main parent view, which will then carry out the process of quitting and removing this view:
*/
- (void)miniAppDidDetectQuitGesture: (miniAppView *)theMiniAppView;
{
	/*If an exempted view quit has been called for, deny it. It would be inelegant to quit exempted views:*/
	if(exemptedMiniAppView == theMiniAppView) return;
	
	suspendLayout = 1;
	
	miniAppToBeRemoved = theMiniAppView;
	
	int cancelMiniAppQuit = 0;
	
	/*notify the internal panel data structure that this app should be removed: (UNLESS this is the root mini app, in which keep the internal structure the same to avoid it deallocating itself, ready for the user to launch another root mini app:)*/
	if([[self subviews] count] > 3)
	{
		panelTreeDesc *miniAppToBeRemoved_panelTreeDescNode = (panelTreeDesc *)([theMiniAppView getPanelTreeDescNodePointer]);
	
		if(removalAffectedMiniApps != nil) [removalAffectedMiniApps release];
		removalAffectedMiniApps = [NSMutableArray arrayWithCapacity: 2];
		[removalAffectedMiniApps retain];
	
		
		/*Find out which miniApps would be affected by removal of this miniApp:*/
		[thisViewController queryRemovalOfPanel: miniAppToBeRemoved_panelTreeDescNode->panelId recordAffectedMiniApps: removalAffectedMiniApps];
		
		/*One final obstacle before going ahead: If removing this miniApp would affect any exempted view, then don't do it:*/
		if(exemptedMiniAppView != nil)
		{
			for(int i = 0; i < [removalAffectedMiniApps count]; i++) if([removalAffectedMiniApps objectAtIndex: i] == exemptedMiniAppView) cancelMiniAppQuit = 1;
		}

		/*If no further objections, go ahead and remove the mini app:*/
		if(cancelMiniAppQuit == 0)
		{
			[thisViewController requestRemovalOfPanel: miniAppToBeRemoved_panelTreeDescNode->panelId];
			[removalAffectedMiniApps addObject: miniAppToBeRemoved];
		}
	}
	
	else 
	{
		if(removalAffectedMiniApps != nil) [removalAffectedMiniApps release];
		removalAffectedMiniApps = [NSMutableArray arrayWithCapacity: 1];
		[removalAffectedMiniApps retain];
		
		[removalAffectedMiniApps addObject: miniAppToBeRemoved];
	}
	
	/*after this quit mini app has contracted, continue with the process:*/
	if(cancelMiniAppQuit == 0) 
	{
		/*instruct the mini app view to contract:*/
		[theMiniAppView quit];
		[theMiniAppView contract: CONTRACTION_FOR_NEW_MINI_APP_DURATION];
		
		/*deal with affected mini apps after the contraction:*/
		[NSTimer scheduledTimerWithTimeInterval: CONTRACTION_FOR_NEW_MINI_APP_DURATION target: self selector: @selector(setOffRemovalAffectedMiniAppsResize:) userInfo: nil repeats: NO];
	}
		
	/*If there's to be no removal, then set everything back to ready here:*/
	if(cancelMiniAppQuit == 1) 
	{
		suspendLayout = 0;
		[self setNeedsLayout];
	}
	
	/*remove any reference to this removed app now that it has been removed:*/
	miniAppToBeRemoved = nil;
}


- (void)setOffRemovalAffectedMiniAppsResize: (NSTimer *)theTimer
{
	/*retrieve the quit mini app's desc node pointer:*/
	panelTreeDesc *miniAppToQuit_descNodePointer = (panelTreeDesc *)([[removalAffectedMiniApps lastObject] getPanelTreeDescNodePointer]);
	
	/*completely remove the quit mini app view by releasing all of its references:*/
	miniAppView *miniAppToRemove = [removalAffectedMiniApps lastObject];
	[removalAffectedMiniApps removeLastObject];
	[miniAppToRemove removeFromSuperview];
	[miniAppSubviews removeObject: miniAppToRemove];
	
	/*If there are other mini apps left over, animate the affected remaining mini apps into the space left over by the quit miniApp*/
	if([removalAffectedMiniApps count] > 0)
	{
		miniAppView *miniAppToResize;
		panelTreeDesc *miniAppToResizePanelDescNode;
	
		/*simply loop through the mini apps and instruct them to resize themselves to their new frames:*/
		for(int i = 0; i < [removalAffectedMiniApps count]; i++)
		{
			panelTreeDesc *viewToAnimate_node = (panelTreeDesc *)([[removalAffectedMiniApps objectAtIndex: i] getPanelTreeDescNodePointer]);
		
			miniAppToResize = [removalAffectedMiniApps objectAtIndex: i];
			miniAppToResizePanelDescNode = (panelTreeDesc *)([miniAppToResize getPanelTreeDescNodePointer]);
			
			/*retrieve the new frame that this affected mini app must take:*/
			CGRect newFrame = CGRectMake(miniAppToResizePanelDescNode->originX, miniAppToResizePanelDescNode->originY, miniAppToResizePanelDescNode->width, miniAppToResizePanelDescNode->height);
			
			/*crop it if neccessary:*/
			newFrame = [self cropFrameRectToAccommodatePanelGapsAndIPadToolbar: newFrame];
			
			/*extract the bounds and center for this new frame:*/
			CGRect newBounds = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
			if((currentDeviceOrientationAngle == 90)||(currentDeviceOrientationAngle == 270)) newBounds = CGRectMake(0, 0, newBounds.size.height, newBounds.size.width);
			
			CGPoint newCenter = CGPointMake(newFrame.origin.x + 0.5 * newFrame.size.width, newFrame.origin.y + 0.5 * newFrame.size.height);

		
			/*Finally, animate the view to its new bounds and center:*/
			[miniAppToResize animateChangeOfBoundsAndCenter: CONTRACTION_FOR_NEW_MINI_APP_DURATION toBounds: newBounds andCenter: newCenter];
		}
	
		NSTimer *returnToNormalTimer = [NSTimer scheduledTimerWithTimeInterval: CONTRACTION_FOR_NEW_MINI_APP_DURATION target: self selector: @selector(returnSystemToNormalRunning) userInfo: nil repeats: NO];
	}
	
	else 
	{
		/*simply return to menu mode, the original state of the application:*/
		newPanelDescPointer = miniAppToQuit_descNodePointer;
		newMiniAppFrame = CGRectMake(0, 0, 768, 1024);							
		
		newMiniAppChoiceMode = 1;
		[self setMultipleTouchEnabled:NO];
	
		/*wait a moment for finesse, then launch the menu:*/
		[NSTimer scheduledTimerWithTimeInterval: 0.5 target: self selector: @selector(prepareNewMiniAppUserChoiceMenuForLaunch) userInfo: nil repeats: NO];
	
		/*back to normal:*/
		suspendLayout = 0;
	}
}

- (void)returnSystemToNormalRunning
{
	suspendLayout = 0;
	[self setNeedsLayout];
}


/*
	When mini apps are instructed to redraw themselves after a change of bounds which usually follows an event such as a shift event, they notify this view when they've finished, so that this view is aware of the amounf of drawing processing going on and can act accordingly:
 */
- (void)miniAppViewDidFinishRedrawingInSettledFrame: (miniAppView *)theMiniAppView
{
	/*if we're waiting for a mini app to shift out of the way and redraw itself before launching the mini app menu, then there can only be one possible mini app to wait for, so we we're in this method it msut have happened, so proceed with the menu:*/
	if(graphicsDelayContext == 0)
	{
		[self prepareNewMiniAppUserChoiceMenuForLaunch];
		
		/*no more graphics delaying required:*/
		graphicsDelayContext = -1;
	}
}


/*
	We override the panel view's hitTest: this method will decide that the touch event belongs to a miniAppView *if* its coords are within that view's borders. otherwise, the event belongs to thit, the root view:
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	/*if we're in instructions view mode, then forward all events to the instructions view:*/
	if(instructionsMode == 1) return [super hitTest: point withEvent: event];
	
	/*if we're in new mini app choice mode, then sub views should not be responding to events, send all events to this, mini app icons view:*/
	if(newMiniAppChoiceMode == 1) return theMiniAppIconsView;
	
	/*handle double tap detection by 'collecting' this event:*/
	if(collectingTouches == 0)
	{
		collectingTouches = 1;
		[NSObject cancelPreviousPerformRequestsWithTarget: self];
		[self performSelector: @selector(stopDoubleTapDetection) withObject: nil afterDelay: DOUBLE_TAP_TIME_THRESHOLD];
	}
	collectedTouches[numTouchesCollected++] = point;
	
	
	/*Now normal hitTest: behaviour. First of all, find out which view the touch event has hit:*/
	UIView *trueTouchHitView;
	int foundHitSubview = 0;
		
	/*if one mini app view is exempted, then this will overlap others, and should always take priority in the event of  overlap, Therefore, if this touch falls inside an exepmted view, we don't need to test any others:*/
	if(exemptedMiniAppView != nil)
	{
		CGRect viewFrame = [exemptedMiniAppView frame];
	
		if((point.x >= viewFrame.origin.x)&&(point.x < (viewFrame.origin.x + viewFrame.size.width))&&(point.y >= viewFrame.origin.y)&&(point.y < (viewFrame.origin.y + viewFrame.size.height)))
		{
			trueTouchHitView = exemptedMiniAppView;
			foundHitSubview = 1;
			
			/*mini apps are allowed to define any area within their bounds, within which touch events are *forced* to be sent to said view, overriding the borders round each view for which touch events within would normally be sent to this, the parent view, instead:*/
			if([trueTouchHitView hitTestOverride: CGPointMake(point.x - trueTouchHitView.frame.origin.x, point.y - trueTouchHitView.frame.origin.y) ]) return trueTouchHitView;
		}
	}
	
	/*if not, then simply loop through and test the views as usual:*/
	if(foundHitSubview == 0)
	{
		for(int i = 0; i < [[self subviews] count]; i++)
		{
			/*theMiniAppIconsView' is not a mini app view. Ignore it.*/
			if([self.subviews objectAtIndex: i] == theMiniAppIconsView) continue;
			if([self.subviews objectAtIndex: i] == theInstructionsView) continue;
			
			CGRect subviewFrame = [[[self subviews] objectAtIndex: i] frame];
		
			if((point.x >= subviewFrame.origin.x)&&(point.x < (subviewFrame.origin.x + subviewFrame.size.width))&&(point.y >= subviewFrame.origin.y)&&(point.y < (subviewFrame.origin.y + subviewFrame.size.height)))
			{
				trueTouchHitView = [[self subviews] objectAtIndex: i];
				foundHitSubview = 1;
				
				/*mini apps are allowed to define any area within their bounds, within which touch events are *forced* to be sent to said view, overriding the borders round each view for which touch events within would normally be sent to this, the parent view, instead:*/
				if([trueTouchHitView hitTestOverride: CGPointMake(point.x - trueTouchHitView.frame.origin.x, point.y - trueTouchHitView.frame.origin.y) ]) return trueTouchHitView;
				
				break;
			}
		}
	}
		
	/*if this event falls inside none of the subviews/miniApps, i.e. its in the gap between, then the event belongs to this, the main view:*/
	if(foundHitSubview == 0) return self;
	
	/*if the mini app in question is disabled, then don't pass the event to it at all. Destroy the event instead:*/
	if([[trueTouchHitView isMiniAppDisabled] boolValue] == YES) return nil;
	
	/*Now, for the touch event to be truly considered to be inside this 'true' view, it must fall not just inside it, but away from its border. Otherwise, this is a 'panel structure' event:*/
	CGRect trueTouchHitViewFrame = [trueTouchHitView frame];
	
	if(
			(point.x > (trueTouchHitViewFrame.origin.x + PANEL_STRUCTURE_PANEL_VIEW_BORDER_WIDTH))&&
			(point.x < (trueTouchHitViewFrame.origin.x + trueTouchHitViewFrame.size.width - PANEL_STRUCTURE_PANEL_VIEW_BORDER_WIDTH))&&
			(point.y > (trueTouchHitViewFrame.origin.y + PANEL_STRUCTURE_PANEL_VIEW_BORDER_WIDTH))&&
		(point.y < (trueTouchHitViewFrame.origin.y + trueTouchHitViewFrame.size.height - PANEL_STRUCTURE_PANEL_VIEW_BORDER_WIDTH))
				)
	{
		//if((point.x < (trueTouchHitViewFrame.origin.x + trueTouchHitViewFrame.size.width - 50))||(point.y > (trueTouchHitViewFrame.origin.y + 50)))
		//{
			return [trueTouchHitView hitTest: [trueTouchHitView convertPoint: point fromView: self] withEvent: event];
		//}
		
		//else return self;
	}	
	
	else return self;
}



/*
 stopDoubleTapDetection - this method will be called after various periods of the hitTest method 'collecting' touch info
 */
- (void)stopDoubleTapDetection
{
	CGPoint touch_p1 = CGPointMake(-1, -1);
	CGPoint touch_p2;
	CGPoint touchToCheck;
	int touchesFound = 0;
	
	
	/*if this method has been called, then we've timed out. Analise the collected touches to see whether they represent a double tap:*/
	
	/*if fewer than 4 touches then we can't possibly have a full double tap:*/
	if(numTouchesCollected >= 4)
	{
		/*in order to be recognised, the touch positions provided must match up with at least one other, so loop through to see if there are any matching pairs:*/
		for(int i = 0; i < numTouchesCollected; i++)
		{
			touchToCheck = collectedTouches[i];
			
			for(int j = i + 1; j < numTouchesCollected; j++)
			{
				if(( (collectedTouches[j].x == touchToCheck.x) && (collectedTouches[j].y == touchToCheck.y) ) && ( (collectedTouches[j].x != touch_p1.x) || (collectedTouches[j].y != touch_p1.y) ))
				{
					if(touchesFound++ == 0) touch_p1 = touchToCheck;
					else touch_p2 = touchToCheck;
					
					break;
				}
			}
			if(touchesFound == 2) break;
		}
	}
	
	/*if we've found a double tap, then was this the first double tap? or the second?*/
	if(touchesFound == 2)
	{
		/*if the stage is 1, then that's it. we've had two double taps in a close enough time, we just need to check whether they were in the same position:*/
		if(doubleTapDetectionStage == 1)
		{
			if( 
			   (([self point: touch_p1 equalsPoint: doubleTapDetection_p1 withinRadius: DOUBLE_TAP_SPACE_THRESHOLD])&&([self point: touch_p2 equalsPoint: doubleTapDetection_p2 withinRadius: DOUBLE_TAP_SPACE_THRESHOLD])) || 
			   (([self point: touch_p1 equalsPoint: doubleTapDetection_p2 withinRadius: DOUBLE_TAP_SPACE_THRESHOLD])&&([self point: touch_p2 equalsPoint: doubleTapDetection_p1 withinRadius: DOUBLE_TAP_SPACE_THRESHOLD])) 
			   )
			{
				/*This is a double tap. Close the mini app it fell inside:*/
				[self miniAppDidDetectQuitGesture: (miniAppView *)[self hitTestMiniApp: touch_p1]];
			}
			
			/*set everything back to normal:*/
			collectingTouches = 0;
			numTouchesCollected = 0;
			doubleTapDetectionStage = 0;
			[NSObject cancelPreviousPerformRequestsWithTarget: self];
		}
		
		/*if we're still at stage 0, then this is the first double tap. One final test for validity: check that both taps fall inside *one* mini app. If not, fail. Otherwise record it, and the fact that we're now in stage 2: (set off a timer after before which the next touch events must come through otherwise the double tap detection will end*/
		else 
		{
			if([self hitTestMiniApp: touch_p1] == [self hitTestMiniApp: touch_p2])
			{
				doubleTapDetection_p1 = touch_p1;
				doubleTapDetection_p2 = touch_p2;
			
				doubleTapDetectionStage = 1;
			
				collectingTouches = 0;
				numTouchesCollected = 0;
			
				[NSObject cancelPreviousPerformRequestsWithTarget: self];
				[self performSelector: @selector(stopDoubleTapDetection) withObject: nil afterDelay: DOUBLE_TAP_TIME_THRESHOLD];
			}
			
			else 
			{
				collectingTouches = 0;
				numTouchesCollected = 0;
				doubleTapDetectionStage = 0;
			}
		}
	}
	
	/*if there weren't two coherent taps, then set everything back to the beginning:*/
	else 
	{
		collectingTouches = 0;
		numTouchesCollected = 0;
		doubleTapDetectionStage = 0;
	}
}


/*
 'point equalsPoint withinRadius' - useful method which considers two CGPoints to be equal if they are within a certain distance of each other:
 */
- (BOOL)point: (CGPoint)p1 equalsPoint: (CGPoint)p2 withinRadius: (int)rad
{
	float dist = (p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y);
	
	if(dist < (rad * rad))	return YES;
	else					return NO;
}


/*
	Custom method. Simply returns, for a given point, the mini app in which that point falls.
*/

- (UIView *)hitTestMiniApp: (CGPoint)point
{
	UIView *miniAppViewThatIsHit;
	
	/*just check to see which view the point is inside:*/
	for(int i = 0; i< [[self subviews] count]; i++)
	{
		/*as always, ignore the mini app menu view, it's not a mini app view*/
		if([self.subviews objectAtIndex: i] == theMiniAppIconsView) continue;
		if([self.subviews objectAtIndex: i] == theInstructionsView) continue;
		
		miniAppViewThatIsHit = [[self subviews] objectAtIndex: i];
		
		if((point.x >= miniAppViewThatIsHit.frame.origin.x) && (point.x <= (miniAppViewThatIsHit.frame.origin.x + miniAppViewThatIsHit.frame.size.width)) && (point.y >= miniAppViewThatIsHit.frame.origin.y) && (point.y <= (miniAppViewThatIsHit.frame.origin.y + miniAppViewThatIsHit.frame.size.height)))
		{
			return miniAppViewThatIsHit;
		}
	}
}


/*
	receive touch events:
*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	/*if we're in new mini app choice mode, this is very simple. Just work out which icon was touched down on:*/
	if(newMiniAppChoiceMode == 1)
	{
		CGPoint touchPoint = [[touches anyObject] locationInView:self];
		
		for(int i = 0; i < 4; i++)
		{
			CALayer *iconLayerToTest = [[[self layer] sublayers] objectAtIndex: i];
			
			if([iconLayerToTest hitTest:touchPoint] == iconLayerToTest)
			{
				[iconLayerToTest setOpacity:0.5]; 
				[iconLayerToTest removeAllAnimations];
				iconTouchDown = i;
			}
		}
	}
	
	else
	{
		//Depending on the number of touches, i.e. the nature of the touch event, different actions will take place:
		int numberOfTouches = [[event allTouches] count];
	
		/*If a single touch, we will assume that this is a swipe event:*/
		if(numberOfTouches == 1)
		{
			//CGPoint point = [[touches anyObject] locationInView: self];
			//UIView *subviewHit = [self hitTestMiniApp: point];
			
			//NSLog(@"touch point: %f %f, view frame: %f %f %f %f", point.x, point.y, [subviewHit frame].origin.x, [subviewHit frame].origin.y, [subviewHit frame].size.width, [subviewHit frame].size.height);
			
			//if((point.x > ([subviewHit frame].origin.x + [subviewHit frame].size.width - 50))&&(point.y < ([subviewHit frame].origin.y + 50)))
			//{
			//	NSLog(@"Corner hit quit event!!!!");
			//	[self miniAppDidDetectQuitGesture: subviewHit];
			//}
			
			//else 
			//{
				//Retrieve the touch:
				UITouch *touchStart = [touches anyObject];


				touchSwipeEventStartPoint = [touchStart locationInView: self];
				touchEventTypeInProgress = 0;
			//}
		}
		
		/*If a double touch, then this is now a shift event:*/
		if(numberOfTouches == 2)
		{
			touchEventTypeInProgress = -1;
		
			/*To qualify as the beginning of a shift event, the touch positions will need to define, within reason, a perfectly horizontal or prefectly vertical line:*/
			NSArray *shiftTouches = [[event allTouches] allObjects];
			CGPoint shiftTouchPoints[2];
			CGPoint shiftTouchPoint_tmp;
		
			shiftTouchPoints[0] = [[shiftTouches objectAtIndex: 0] locationInView:self];
			shiftTouchPoints[1] = [[shiftTouches objectAtIndex: 1] locationInView:self];
		
			shiftEventMetaData shiftEventMetaDataObjFromController;
		
			/*if gradient less than 1, then it's closer to a horizontal line:*/
			if(fabs(shiftTouchPoints[0].x - shiftTouchPoints[1].x) > fabs(shiftTouchPoints[0].y - shiftTouchPoints[1].y))
			{
				/*if this line is close enough to the perfect horizontal, then it will be considered the start of a shift event:*/
				if(fabs(shiftTouchPoints[0].y - shiftTouchPoints[1].y) <= TOUCH_SHIFT_MAXIMUM_LINE_ERROR)
				{
					touchShiftEventDimension = 0;
					touchShiftEventLocation = (int)(0.5*(shiftTouchPoints[0].y + shiftTouchPoints[1].y));
			
					/*check that end points are increasing order:*/
					if(shiftTouchPoints[0].x > shiftTouchPoints[1].x)
					{
						shiftTouchPoint_tmp = shiftTouchPoints[0];
						shiftTouchPoints[0] = shiftTouchPoints[1];
						shiftTouchPoints[1] = shiftTouchPoint_tmp;
					}
					
					/*Finally, to accept this line as the beginning of a shift event, it must coincide with an actual boundary between panels. Call the view controller to confirm:*/
					miniAppsAffectedByShiftEvent = [[NSMutableArray arrayWithCapacity: 1] retain];
					touchShiftEventPanelId = [thisViewController checkShiftTouchAttemptWithDimension: touchShiftEventDimension location: touchShiftEventLocation startPoint: shiftTouchPoints[0].x endPoint: shiftTouchPoints[1].x shiftMinLocation: &touchShiftEvent_minLocation shiftMaxLocation: &touchShiftEvent_maxLocation recordAffectedMiniApps: miniAppsAffectedByShiftEvent];
					
					if(touchShiftEventPanelId != -1)
					{
						/*One exception - If there is an exempted miniApp view, and this shift event affects it, then don't carry on with the event.*/
						int cancelShiftEvent = 0;
						if(exemptedMiniAppView != nil)
						{
							for(int i = 0; i < [miniAppsAffectedByShiftEvent count]; i++) if([miniAppsAffectedByShiftEvent objectAtIndex: i] == exemptedMiniAppView) cancelShiftEvent = 1;
						}
						
						/*If no further objections, then carry on with the shift event:*/
						if(cancelShiftEvent == 0)
						{
							touchEventTypeInProgress = 1;
							/*for the all views that are about to be resized, notify them as they may want to simplfy their contents to aid speedy resizing:*/
							for(int i = 0; i < [[self subviews] count]; i++)
							{
								if([self.subviews objectAtIndex: i] == theMiniAppIconsView) continue;
								if([self.subviews objectAtIndex: i] == theInstructionsView) continue;
								
								[[[self subviews] objectAtIndex: i] shiftEventBegins];
							}
						}
					}
				}
			}
		
			/*otherwise, it's closer to a vertical line:*/
			else 
			{
				/*if this line is close enough to the perfect vertical, then it will be considered the start of a shift event:*/
				if(fabs(shiftTouchPoints[0].x - shiftTouchPoints[1].x) <= TOUCH_SHIFT_MAXIMUM_LINE_ERROR)
				{
					touchShiftEventDimension = 1;
					touchShiftEventLocation = (int)(0.5*(shiftTouchPoints[0].x + shiftTouchPoints[1].x));
				
					/*check that end points are increasing order:*/
					if(shiftTouchPoints[0].y > shiftTouchPoints[1].y)
					{
						shiftTouchPoint_tmp = shiftTouchPoints[0];
						shiftTouchPoints[0] = shiftTouchPoints[1];
						shiftTouchPoints[1] = shiftTouchPoint_tmp;
					}
				
					/*Finally, to accept this line as the beginning of a shift event, it must coincide with an actual boundary between panels. Call the view controller to confirm:*/
					miniAppsAffectedByShiftEvent = [[NSMutableArray arrayWithCapacity: 0] retain];
					touchShiftEventPanelId = [thisViewController checkShiftTouchAttemptWithDimension: touchShiftEventDimension location: touchShiftEventLocation startPoint: shiftTouchPoints[0].y endPoint: shiftTouchPoints[1].y shiftMinLocation: &touchShiftEvent_minLocation shiftMaxLocation: &touchShiftEvent_maxLocation recordAffectedMiniApps: miniAppsAffectedByShiftEvent];
					
				
					if(touchShiftEventPanelId != -1)
					{
						/*One exception - If there is an exempted miniApp view, and this shift event affects it, then don't carry on with the event.*/
						int cancelShiftEvent = 0;
						if(exemptedMiniAppView != nil)
						{
							for(int i = 0; i < [miniAppsAffectedByShiftEvent count]; i++) if([miniAppsAffectedByShiftEvent objectAtIndex: i] == exemptedMiniAppView) cancelShiftEvent = 1;
						}
						
						/*If no further objections, then carry on with the shift event:*/
						if(cancelShiftEvent == 0)
						{
							touchEventTypeInProgress = 1;
							for(int i = 0; i < [miniAppsAffectedByShiftEvent count]; i++)
							{
								panelTreeDesc *theDescNode = (panelTreeDesc *)([[miniAppsAffectedByShiftEvent objectAtIndex: i] getPanelTreeDescNodePointer]);
							}
							
							/*for the all views that are about to be resized, notify them as they may want to simplfy their contents to aid speedy resizing:*/
							for(int i = 0; i < [[self subviews] count]; i++) 
							{
								if([self.subviews objectAtIndex: i] == theMiniAppIconsView) continue;
								if([self.subviews objectAtIndex: i] == theInstructionsView) continue;
							
								[[[self subviews] objectAtIndex: i] shiftEventBegins];
						
							}
						}
					}
				}
			}
		}
	
	
		/*if more than two fingers, this is an unrecogised event, and therefore will not be handled:*/
		if(numberOfTouches > 2)
		{
			touchEventTypeInProgress = -1;
		}
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	/*If there is a shift event in progress (horizontal code first, vertical code is equivalent:*/
	if(touchEventTypeInProgress == 1)
	{
		NSArray *shiftTouches = [[event allTouches] allObjects];
		CGPoint shiftTouchPoints[4];
		shiftTouchPoints[0] = [[shiftTouches objectAtIndex:0] previousLocationInView:self];
		shiftTouchPoints[2] = [[shiftTouches objectAtIndex:0] locationInView:self];
		shiftTouchPoints[1] = [[shiftTouches objectAtIndex:1] previousLocationInView:self];
		shiftTouchPoints[3] = [[shiftTouches objectAtIndex:1] locationInView:self];
			
		/*HORIZONTAL CODE*/
		if(touchShiftEventDimension == 0)
		{
			/*First of all, if the two fingers have drifted too far apart in the shift dimension, then the event ends here:*/
			if(fabs(shiftTouchPoints[2].y - shiftTouchPoints[3].y) > TOUCH_SHIFT_MAXIMUM_LINE_ERROR)
			{
				touchEventTypeInProgress = -1;
				
				/*notify all affected apps that this shift event has ended:*/
				for(int i = 0; i < [miniAppsAffectedByShiftEvent count]; i++) [[miniAppsAffectedByShiftEvent objectAtIndex: i] shiftEventEnded];
				
				/*we can now release our array of shift-event-affected mini apps:*/
				[miniAppsAffectedByShiftEvent removeAllObjects];
				[miniAppsAffectedByShiftEvent release];
				
				//for(int i = 0; i < [miniAppViewsAffectedByCurrentShiftEvent count]; i++) [[miniAppViewsAffectedByCurrentShiftEvent objectAtIndex: i] shiftEventEnded];
				//[miniAppViewsAffectedByCurrentShiftEvent removeAllObjects];
				
				return;
			}
			
			int newShiftEventLocation;
			/*if therefore the fingers are getting further apart, and/or only one finger is moving, then no action will be taken. *Only* if *both* are moving, and in the *same direction* will a shift be considered:*/
			if([shiftTouches count] == 2)
			{
				if((((shiftTouchPoints[2].y-shiftTouchPoints[0].y) > 0)&&((shiftTouchPoints[3].y-shiftTouchPoints[1].y) > 0)) || (((shiftTouchPoints[2].y-shiftTouchPoints[0].y) < 0)&&((shiftTouchPoints[3].y-shiftTouchPoints[1].y) < 0)))
				{
					newShiftEventLocation = (int)(0.5*(shiftTouchPoints[2].y + shiftTouchPoints[3].y));
					
					/*Final condition - if this shift event location moves outside the range of allowed shift that was defined at the beginning of the event, then again the shift event will not end, but nothing will happen until the shift moves back into range at a future point:*/
					if((newShiftEventLocation >= touchShiftEvent_minLocation) && (newShiftEventLocation <= touchShiftEvent_maxLocation))
					{
						[thisViewController shiftEventHasMovedSplitPositionForPanel: touchShiftEventPanelId newLocation: newShiftEventLocation];
						[self setNeedsDisplay];
						[self setNeedsLayout];
					}
				}
			}
		}
		
		/*VERTICAL CODE:*/
		else
		{
			/*First of all, if the two fingers have drifted too far apart in the shift dimension, then the event ends here:*/
			if(fabs(shiftTouchPoints[2].x - shiftTouchPoints[3].x) > TOUCH_SHIFT_MAXIMUM_LINE_ERROR)
			{
				touchEventTypeInProgress = -1;
				
				/*notify all affected apps that this shift event has ended:*/
				for(int i = 0; i < [miniAppsAffectedByShiftEvent count]; i++) [[miniAppsAffectedByShiftEvent objectAtIndex: i] shiftEventEnded];
				
				/*we can now release our array off shift-event-affected mini apps:*/
				[miniAppsAffectedByShiftEvent removeAllObjects];
				[miniAppsAffectedByShiftEvent release];
				
				/*notify all affected apps that this shift event has ended:*/
				//for(int i = 0; i < [miniAppViewsAffectedByCurrentShiftEvent count]; i++) [[miniAppViewsAffectedByCurrentShiftEvent objectAtIndex: i] shiftEventEnded];
				//[miniAppViewsAffectedByCurrentShiftEvent removeAllObjects];
				
				return;
			}
			
			int newShiftEventLocation;
			/*if therefore the fingers are getting further apart, and/or only one finger is moving, then no action will be taken. *Only* if *both* are moving, and in the *same direction* will a shift be considered:*/
			if([shiftTouches count] == 2)
			{
				if((((shiftTouchPoints[2].x-shiftTouchPoints[0].x) > 0)&&((shiftTouchPoints[3].x-shiftTouchPoints[1].x) > 0)) || (((shiftTouchPoints[2].x-shiftTouchPoints[0].x) < 0)&&((shiftTouchPoints[3].x-shiftTouchPoints[1].x) < 0)))
				{
					newShiftEventLocation = (int)(0.5*(shiftTouchPoints[2].x + shiftTouchPoints[3].x));
					
					/*Final condition - if this shift event location moves outside the range of allowed shift that was defined at the beginning of the event, then again the shift event will not end, but nothing will happen until the shift moves back into range at a future point:*/
					if((newShiftEventLocation >= touchShiftEvent_minLocation) && (newShiftEventLocation <= touchShiftEvent_maxLocation))
					{
						[thisViewController shiftEventHasMovedSplitPositionForPanel: touchShiftEventPanelId newLocation: newShiftEventLocation];
						[self setNeedsDisplay];
						[self setNeedsLayout];
					}
				}
			}
		}
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(newMiniAppChoiceMode == 1)
	{
		if(iconTouchDown != -1)
		{
			CALayer *iconTouchedDown = [[[self layer] sublayers] objectAtIndex: iconTouchDown];
			
			[iconTouchedDown setOpacity:1.0];
			[iconTouchedDown removeAllAnimations];
			
			/*the new mini app has now been chosen, so create it and display it:*/
			[self newMiniAppChosen: iconTouchDown];
			
			iconTouchDown = -1;
		}
	}
	
	else
	{
		/*If at the end of a swipe, i.e. single touch event:*/
		if(touchEventTypeInProgress == 0)
		{
			//Retrieve the touch:
			UITouch *touchEnd = [touches anyObject];
	
			//The event has just ended, so record the final position, converting it to window/root space:
			CGPoint touchSwipeEventEndPoint = [touchEnd locationInView:self];
	
			//Now determine whether this is a valid swipe, and if so, attempt to split the panel tree with it:
			int swipeDimension=-1;
			float tmpCoordinate;
	
			
			//is the swipe closer to the horizontal or vertical?
			if(fabs(touchSwipeEventEndPoint.y - touchSwipeEventStartPoint.y) <= fabs(touchSwipeEventEndPoint.x - touchSwipeEventStartPoint.x))
			{
				//closer to horizontal, but is it close enough to a perfect horizontal line?
				if(fabs(touchSwipeEventEndPoint.y - touchSwipeEventStartPoint.y) <= TOUCH_SWIPE_MAXIMUM_PERPENDICULAR_DISPLACEMENT)
				{
					//We have a horizontal swipe
					swipeDimension = 0;
				
					//Average out the vertical coordinates to make it perfectly horizontal:
					touchSwipeEventStartPoint.y = touchSwipeEventEndPoint.y = (touchSwipeEventStartPoint.y + touchSwipeEventEndPoint.y) / 2.0;
				
					//Make sure the points are in increasing order:
					if(touchSwipeEventStartPoint.x > touchSwipeEventEndPoint.x)
					{
						tmpCoordinate = touchSwipeEventStartPoint.x;
						touchSwipeEventStartPoint.x = touchSwipeEventEndPoint.x;
						touchSwipeEventEndPoint.x = tmpCoordinate;
					}
				}
			}
	
			else 
			{
				//closer to vertical, but is it close enough to a perfect vertical line?
				if(fabs(touchSwipeEventEndPoint.x - touchSwipeEventStartPoint.x) <= TOUCH_SWIPE_MAXIMUM_PERPENDICULAR_DISPLACEMENT)
				{
					//We have a vertical swipe
					swipeDimension = 1;
				
					//Average out the horizontal coordinates to make it perfectly vertical:
					touchSwipeEventStartPoint.x = touchSwipeEventEndPoint.x = (touchSwipeEventStartPoint.x + touchSwipeEventEndPoint.x) / 2.0;
					
					//Make sure the points are in increasing order:
					if(touchSwipeEventStartPoint.y > touchSwipeEventEndPoint.y)
					{
						tmpCoordinate = touchSwipeEventStartPoint.y;
						touchSwipeEventStartPoint.y = touchSwipeEventEndPoint.y;
						touchSwipeEventEndPoint.y = tmpCoordinate;
					}
				}	
			}
		
			//If the swipe is valid, then call the panelTree with it to attempt a split.
			if(swipeDimension != -1)
			{
				/*which panel did the swipe slice in two?:*/
				UIView *slicedPanel = [self hitTestMiniApp: CGPointMake(0.5*(touchSwipeEventStartPoint.x + touchSwipeEventEndPoint.x), 0.5*(touchSwipeEventStartPoint.y + touchSwipeEventEndPoint.y))];
				
				
				/*One possible reason to not carry out this creation of a new min app; If it would be partly obscured by an exmpted mini app, then do not create said new mini app:*/
				int cancelNewMiniAppCreation = 0;
				if(exemptedMiniAppView != nil)
				{
					CGRect exemptedMiniAppViewRect = [exemptedMiniAppView frame];
					CGRect newRect;
					if(swipeDimension == 0)
					{
						if((touchSwipeEventStartPoint.y - [slicedPanel frame].origin.y) > (([slicedPanel frame].origin.y + [slicedPanel frame].size.height) - touchSwipeEventStartPoint.y)) newRect = CGRectMake([slicedPanel frame].origin.x, [slicedPanel frame].origin.y + touchSwipeEventStartPoint.y, [slicedPanel frame].size.width, [slicedPanel frame].origin.y + [slicedPanel frame].size.height - touchSwipeEventStartPoint.y);
						else	newRect = CGRectMake([slicedPanel frame].origin.x, [slicedPanel frame].origin.y, [slicedPanel frame].size.width, touchSwipeEventStartPoint.y - [slicedPanel frame].origin.y);  
					}
					else
					{
						if((touchSwipeEventStartPoint.x - [slicedPanel frame].origin.x) > (([slicedPanel frame].origin.x + [slicedPanel frame].size.width) - touchSwipeEventStartPoint.x)) newRect = CGRectMake([slicedPanel frame].origin.x + touchSwipeEventStartPoint.x, [slicedPanel frame].origin.y, [slicedPanel frame].origin.x + [slicedPanel frame].size.width - touchSwipeEventStartPoint.x, [slicedPanel frame].size.height);
						else	newRect = CGRectMake([slicedPanel frame].origin.x, [slicedPanel frame].origin.y, touchSwipeEventStartPoint.x - [slicedPanel frame].origin.x, [slicedPanel frame].size.height);  
					}
					 
					if((newRect.origin.x < (exemptedMiniAppViewRect.origin.x + exemptedMiniAppViewRect.size.width))&&(exemptedMiniAppViewRect.origin.x < (newRect.origin.x + newRect.size.width))&&(newRect.origin.y < (exemptedMiniAppViewRect.origin.y + exemptedMiniAppViewRect.size.height))&&(exemptedMiniAppViewRect.origin.y < (newRect.origin.y + newRect.size.height)))
					{
						cancelNewMiniAppCreation = 1;
					}
				}
				
				
				/*if there are no other objections, split this swiped miniApp and create a new one in the gap left over:*/
				if(cancelNewMiniAppCreation == 0)
				{
					int newPanelDescPointer = [thisViewController userSwipedToSplitPanelWithP1x: touchSwipeEventStartPoint.x p1y: touchSwipeEventStartPoint.y p2x: touchSwipeEventEndPoint.x p2y: touchSwipeEventEndPoint.y splitDimension: swipeDimension];
				
					if(newPanelDescPointer != 0)
					{
						/*which panel did the swipe slice in two?:*/
						UIView *slicedPanel = [self hitTestMiniApp: CGPointMake(0.5*(touchSwipeEventStartPoint.x + touchSwipeEventEndPoint.x), 0.5*(touchSwipeEventStartPoint.y + touchSwipeEventEndPoint.y))];
					
						[self openNewMiniAppWithDescNodeAddress: newPanelDescPointer andPanelToTruncate: slicedPanel];
					}
				}
			}
			
			/*This event has now finished, so set record of current event type back to unknown:*/
			touchEventTypeInProgress = -1;
		}
		
		/*if any touch has lifted during a shift event, then the event ends immediately. Notify the mini app in question that this shift event is now over. (also clear out the NSMutableArray we've been using to record these views)*/
		if(touchEventTypeInProgress == 1)
		{
			touchEventTypeInProgress = -1;
		
			/*notify all affected apps that this shift event has ended:*/
			for(int i = 0; i < [miniAppsAffectedByShiftEvent count]; i++) [[miniAppsAffectedByShiftEvent objectAtIndex: i] shiftEventEnded];
			
			/*we can now release our array off shift-event-affected mini apps:*/
			[miniAppsAffectedByShiftEvent removeAllObjects];
			[miniAppsAffectedByShiftEvent release];
			
			//for(int i = 0; i < [miniAppViewsAffectedByCurrentShiftEvent count]; i++) [[miniAppViewsAffectedByCurrentShiftEvent objectAtIndex: i] shiftEventEnded];
			
			//[miniAppViewsAffectedByCurrentShiftEvent removeAllObjects];
		}
	}
}
	

/*
	requestMiniAppViewExemption -	this method is called by a mini app view in the rare case that it wants to move itself to an arbitrary out-of-panel-structure position, e.g. to allow it to be visible above the keyboard.
									In this method we grant this, and while exempt, the view in question's requested position etc will not be affected by shift events etc.
 */
- (void)requestMiniAppViewExemption: (NSTimer *)theTimer;
{
	/*only one miniAppView can by exempted at any one time:*/
	if(exemptedMiniAppView != nil) [self endMiniAppViewExemption];
	
	if(exemptViewBorderLayer_old == exemptViewBorderLayer_b)
	{
		exemptViewBorderLayer = exemptViewBorderLayer_a;
		exemptViewBorderLayer_anim = exemptViewBorderLayer_a_anim;
	}
	
	else
	{
		exemptViewBorderLayer = exemptViewBorderLayer_b;
		exemptViewBorderLayer_anim = exemptViewBorderLayer_b_anim;
	}
	
		
	/*record that a mini app view is to be exempted:*/
	exemptedMiniAppView = [[theTimer userInfo] objectAtIndex: 0];
	
	/*retrieve the center coordinates that the view would like to have:*/
	CGPoint requestedCenter = CGPointMake([[[theTimer userInfo] objectAtIndex: 1] floatValue], [[[theTimer userInfo] objectAtIndex: 2] floatValue]);
	
	/*record its current center so that it can be returned here later:*/
	exemptedMiniAppViewOriginalCenter = [exemptedMiniAppView center]; 
	
	/*bring the view to the front:*/
	[[exemptedMiniAppView layer] setZPosition: 6.0];
	
	/*slot the border layer in just behind the view:*/
	CATransform3D exemptViewBorderLayerTransform = {[exemptedMiniAppView transform].a, [exemptedMiniAppView transform].b, 0, [exemptedMiniAppView transform].tx, [exemptedMiniAppView transform].c, [exemptedMiniAppView transform].d, 0, [exemptedMiniAppView transform].ty, 0, 0, 0, 0, 0, 0, 0, 1};
	[exemptViewBorderLayer setPosition: [exemptedMiniAppView center]];
	[exemptViewBorderLayer setBounds: CGRectMake(0, 0, [exemptedMiniAppView bounds].size.width + 2, [exemptedMiniAppView bounds].size.height + 2)];
	[exemptViewBorderLayer setTransform: exemptViewBorderLayerTransform];
	[exemptViewBorderLayer setHidden: NO];
	[exemptViewBorderLayer removeAllAnimations];
	
	/*now notify the view in question that it is abount to be animated to its exempted state:*/
	[exemptedMiniAppView miniAppViewExemptionWillStart];
	
	/*now animate the view and its border to the requested location:*/
	[exemptViewBorderLayer_anim setFromValue: [NSValue value: &exemptedMiniAppViewOriginalCenter withObjCType: @encode(CGPoint)]];
	[exemptViewBorderLayer_anim setToValue: [NSValue value: &requestedCenter withObjCType: @encode(CGPoint)]];
	[exemptViewBorderLayer setPosition: requestedCenter];
	[exemptViewBorderLayer addAnimation: exemptViewBorderLayer_anim forKey: @"position"];
	
	[UIView animateWithDuration: EXEMPTION_ANIM_DURATION animations: ^{ [exemptedMiniAppView setCenter: requestedCenter]; }];

	
	[[theTimer userInfo] removeAllObjects];
	[[theTimer userInfo] release];
}

/*
	endMiniAppViewExemption - opposite of above method. Returns the currently exempted mini app to its original position:
 */
- (void)endMiniAppViewExemption
{
	[exemptedMiniAppView miniAppViewExemptionWillEnd];
	
	exemptedMiniAppView_old = exemptedMiniAppView;
	exemptViewBorderLayer_old = exemptViewBorderLayer;
	exemptViewBorderLayer_anim_old = exemptViewBorderLayer_anim;
	
	CGPoint fromPoint = [exemptViewBorderLayer_old position];
	CGPoint toPoint = exemptedMiniAppViewOriginalCenter;
	
	
	/*animate border layer and view back to original position: (and at the end of the animation, hide the border layer again and set the exempted view back to its neutral Z position:)*/
	[exemptViewBorderLayer_anim_old setFromValue: [NSValue value: &fromPoint withObjCType: @encode(CGPoint)]];
	[exemptViewBorderLayer_anim_old setToValue: [NSValue value: &toPoint withObjCType: @encode(CGPoint)]];
	[exemptViewBorderLayer_old setPosition: exemptedMiniAppViewOriginalCenter];
	[exemptViewBorderLayer_old addAnimation: exemptViewBorderLayer_anim_old forKey: @"position"];
	
	[UIView animateWithDuration: 0.35 animations: ^{ [exemptedMiniAppView_old setCenter: exemptedMiniAppViewOriginalCenter]; } completion: ^(BOOL finished){ [[exemptedMiniAppView_old layer] setZPosition: 0.0]; [exemptViewBorderLayer_old setHidden: YES]; [exemptViewBorderLayer_old removeAllAnimations]; } ];
	
	/*there is now no exempted view:*/
	exemptedMiniAppView = nil;
}


/*
	Standard getter method. Returns our mutable array of all mini app views:
 */
- (NSMutableArray *)getMiniAppSubviewsArray
{
	return miniAppSubviews;
}


/*
	getCurrentAppOrientation - a way for other objects to find out what the app's current orientation is (0 = portrait, 1 = landscapeLeft, 2 = portraitUpsideDown, 3 = landscapeRight)
 */
- (int)getCurrentAppOrientation
{
	if(currentDeviceOrientation == UIDeviceOrientationPortrait) return 0;
	if(currentDeviceOrientation == UIDeviceOrientationLandscapeLeft) return 1;
	if(currentDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) return 2;
	if(currentDeviceOrientation == UIDeviceOrientationLandscapeRight) return 3;
}


- (void)dealloc {
	
	/*release some arrays:*/
	[miniAppIconLayers release];
	[miniAppIconLayerAppearAnims release];
	[newMiniAppAppearAnims release];
	
	[miniAppViewsAffectedByCurrentShiftEvent release];
	
	[miniAppSubviews removeAllObjects];
	[miniAppSubviews release];
	
	
	/*release the mini app menu view:*/
	[theMiniAppIconsView release];
	
	free(collectedTouches);
	
	[exemptViewBorderLayer_a_anim release];
	[exemptViewBorderLayer_b_anim release];
	
    [super dealloc];
}


@end
