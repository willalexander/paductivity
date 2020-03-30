//
//  WorkPadAppDelegate.h
//  WorkPad
//
//  Created by William Alexander on 28/09/2010.
//  Copyright Framestore-CFC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "panelTree.h"

@class alwaysAutorotateViewController;
@class panelViewController;
@class panelView;


@interface WorkPadAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
	
	panelTree *panelTreeStructure;
	
	panelView *thePanelView;
	
	alwaysAutorotateViewController *rootOrientResponsiveViewController;
	panelViewController *appContentViewController;
	
	//panelViewController *viewController_back;
	//panelViewController *viewController_front;
}

- (void)swapTwinViewControllers: (NSTimer *)theTimer;

@property (nonatomic, retain) IBOutlet UIWindow *window;

//@property (nonatomic, retain) IBOutlet panelViewController *viewController_back;
//@property (nonatomic, retain) IBOutlet panelViewController *viewController_front;

@property (nonatomic, retain) IBOutlet UIViewController *rootOrientResponsiveViewController;
@property (nonatomic, retain) IBOutlet panelViewController *appContentViewController;

@end



/*
	We need a view controller behind the scenes that will autorotate to any orientation, this is it. A simple subclass of UIViewController with just one method overridden:
 */
@interface alwaysAutorotateViewController : UIViewController
{
}

@end

