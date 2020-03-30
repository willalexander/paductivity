//
//  panelView.h
//  WorkPad
//
//  Created by William Alexander on 28/09/2010.
//  Copyright 2010 Framestore-CFC. All rights reserved.
//


#ifndef __PANELVIEW_H__
#define __PANELVIEW_H__


#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/CAAnimation.h>

#import "WorkPadAppDelegate.h"

#import "miniAppView.h"
#import "textBoxMiniAppView.h"
#import "calculatorMiniAppView.h"
#import "webBrowserMiniAppView.h"
#import "calendarMiniAppView.h"


#define START_UP_SCREEN_DURATION 2.0

#define START_UP_LOGO_SEGMENT_DISAPPEAR_MAX_DELAY 1.0
#define START_UP_LOGO_SEGMENT_DISAPPEAR_DURATION 0.25

#define PANEL_STRUCTURE_PANEL_VIEW_BORDER_WIDTH 20

#define TOUCH_SWIPE_MAXIMUM_PERPENDICULAR_DISPLACEMENT 25
#define TOUCH_SHIFT_MAXIMUM_LINE_ERROR 50
#define TOUCH_TAP_MAXIMUM_TIME_INTERVAL 0.25

#define TRUNCATION_FOR_NEW_MINI_APP_DURATION 0.25
#define CONTRACTION_FOR_NEW_MINI_APP_DURATION 0.5
#define REORIENTATION_DURATION 0.5

#define EXEMPTION_ANIM_DURATION 0.35

#define INSTRUCTIONS_VIEW_VIS_ANIM_DURATION 0.25


@interface miniAppIconsView : UIView
{
	int iconTouchDown;
}

- (void)setBottomRightCornerPos: (CGPoint)bottomRightCornerPos;
- (void)setBottomRightCornerPosAndAnimateHelpButtonAppearance: (id)parameters;
- (void)animHelpButtonHide;

@end


@interface instructionsView : UIView
{
	UIScrollView *theScrollView;
	UIView *scrollViewContentView;
	UINavigationBar *theNavBar;
}

- (void)userDidQuit;
- (void)layoutSubviewsInLatestBounds;
- (void)animateToNewCenterAndBounds: (float)duration newCenter: (CGPoint)newCenter newBounds: (CGRect)newBounds;

@end


@class panelViewController;

@interface panelView : UIView 
{
	/*The Application Delegate:*/
	WorkPadAppDelegate *theAppDelegate;
	
	/*This view's view controller:*/
	panelViewController *thisViewController;
	
	/*variables for keeping track of panel-layout-affecting event types:*/
	int touchEventTypeInProgress;
	
	/*variables for meta data used by touch handling methods:*/
	NSMutableArray *miniAppViewsAffectedByCurrentShiftEvent;
	
	int touchShiftEventDimension;
	int touchShiftEventLocation;
	int touchShiftEventPanelId;
	int touchShiftEvent_minLocation;
	int touchShiftEvent_maxLocation;
	
	CGPoint touchSwipeEventStartPoint;
	CGPoint touchTapEventStartPoint;
	CGPoint touchTapEventEndPoint;
	double touchTapEventStartTime;
	
	
	/*variables for keeping track of device orientation:*/
	int firstDeviceOrientAwayFromPortraitHasOccurred;
	int layoutSubviewsHasBeenCalledForFirstTime;
	int lastRecordedOrientation;
	int previousDeviceOrientation;
	int previousDeviceOrientationAngle;
	int currentDeviceOrientation;
	int currentDeviceOrientationAngle;
	
	
	/*Variables relating to double tap detection:*/
	CGPoint doubleTapDetection_p1;
	CGPoint doubleTapDetection_p2;
	int collectingTouches;
	CGPoint *collectedTouches;
	int numTouchesCollected;
	int doubleTapDetectionStage;
	
	
	/*state switch to enable/disable layoutSubviews()' functionality:*/
	int suspendLayout;
	
	/*an array is kept of pointers to the mini app views that exist:*/
	NSMutableArray *miniAppSubviews;
	
	/*variables for dealing with new mini app creation:*/
	panelTreeDesc *newPanelDescPointer;
	
	int newMiniAppChoiceMode;
	int instructionsMode;
	int iconTouchDown;
	
	int newMiniAppChoiceModeStage;
	miniAppView *newMiniAppView;
	int newMiniAppTypeChosen;
	CGRect newMiniAppFrame;
	int miniAppIconsViewOffset;
	
	/*specifically variables required to operate the mini app menu:*/
	miniAppIconsView *theMiniAppIconsView;
	
	NSMutableArray *miniAppIconLayers;
	NSMutableArray *miniAppIconLayerAppearAnims;
	NSMutableArray *newMiniAppAppearAnims;
	
	
	/*variables for dealing with new mini app removal:*/
	miniAppView *miniAppToBeRemoved;
	NSMutableArray *removalAffectedMiniApps;
	NSMutableArray *miniAppsAffectedByShiftEvent;
	
	/*keeps a record of any context we're in in which graphics calls should be delayed:*/
	int graphicsDelayContext;
	
	/*variables for handling the start up screen animation:*/
	CGImageRef appLaunchImage;
	CALayer *appLaunchImageLayer;
	
	/*variables for handling mini app view exemption:*/
	miniAppView *exemptedMiniAppView;
	miniAppView *exemptedMiniAppView_old;
	CGPoint exemptedMiniAppViewOriginalCenter;
	
	CALayer *exemptViewBorderLayer;
	CALayer *exemptViewBorderLayer_old;
	CABasicAnimation *exemptViewBorderLayer_anim;
	CABasicAnimation *exemptViewBorderLayer_anim_old;
	
	CALayer *exemptViewBorderLayer_a;
	CALayer *exemptViewBorderLayer_b;
	CABasicAnimation *exemptViewBorderLayer_a_anim;
	CABasicAnimation *exemptViewBorderLayer_b_anim;
	
	int appBehaviorStage;
	
	/*Variables relating to the start up screen animation:*/
	NSMutableArray *logoCoverers;
	
	/*Members relating to the instructions view:*/
	instructionsView *theInstructionsView;
}

@property (nonatomic, retain) panelViewController *thisViewController;


- (id)initWithFrame:(CGRect)frame andRootPanelDescNodePointer:(int)rootPanelDescNodePointer;

- (void)setTheAppDelegate: (WorkPadAppDelegate *)theDelegate_in;

- (void)startUpScreenAnimation_setup;
- (void)startUpScreenAnimation_execute: (NSTimer *)theTimer;
- (void)startUpScreenAnimation_transitionToReadyState: (NSTimer *)theTimer;

- (void)deviceOrientationDidChange:(NSNotification *)theNotification;

- (void)setupMiniAppChoiceIcons;

- (void)openInstructions;
- (void)closeInstructions;

- (CGRect)cropFrameRectToAccommodatePanelGapsAndIPadToolbar: (CGRect)rect;

- (void)openNewMiniAppWithDescNodeAddress: (int)panelDescNodeAddress andPanelToTruncate: (UIView *)panelToTruncate;
- (void)prepareNewMiniAppUserChoiceMenuForLaunch;
- (void)launchNewMiniAppUserChoiceMenu: (id)parameters;
- (void)newMiniAppChosen:(int)typeChosen;
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
- (void)fadeIconToNewMiniApp;
- (void)fullyInstateNewMiniAppAndEndChoiceMode;

- (void)miniAppDidDetectQuitGesture: (miniAppView *)theMiniAppView;
- (void)setOffRemovalAffectedMiniAppsResize: (NSTimer *)theTimer;
- (void)returnSystemToNormalRunning;

- (void)miniAppViewDidFinishRedrawingInSettledFrame: (miniAppView *)theMiniAppView;

- (void)stopDoubleTapDetection;
- (BOOL)point: (CGPoint)p1 equalsPoint: (CGPoint)p2 withinRadius: (int)rad;

- (UIView *)hitTestMiniApp:(CGPoint)point;

- (void)requestMiniAppViewExemption: (NSTimer *)theTimer;
- (void)endMiniAppViewExemption;

- (NSMutableArray *)getMiniAppSubviewsArray;
- (int)getCurrentAppOrientation;


@end


#endif
