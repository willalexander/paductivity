    //
//  panelViewController.m
//  WorkPad
//
//  Created by William Alexander on 28/09/2010.
//  Copyright 2010 Framestore-CFC. All rights reserved.
//

#import "panelViewController.h"



@implementation panelViewController


// Create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	/*Both the root view and the panel tree root have a rectangular size of 768x1004. But the view has a vertical offset of 20px within its parent to account for the iPad toolbar, while the panel tree root has no origin offset, as it fully fills its parent, the root view */
	//CGRect rootViewFrame = CGRectMake(0, 20, 768, 1004);
	//CGRect panelTreeRootFrame = CGRectMake(0, 0, 768, 1004);
	
	/*Initialise the panel tree structure:*/
	panelTreeStructure = new panelTree(0, 0, 768, 1024 , 1, NULL);
	
	/*we can also assume the layout of the flat panel layout, i.e just the one top level view:*/
	//latestFlatPanelLayout = [[NSMutableArray alloc] initWithCapacity:1];
	//[latestFlatPanelLayout retain];
	
	//panelTreeDesc_objC *newPanelDesc = [[panelTreeDesc_objC alloc] init];
	//[newPanelDesc setOriginX:rootViewFrame.origin.x originY: rootViewFrame.origin.y width: rootViewFrame.size.width height: rootViewFrame.size.height panelId: 0];
	//[latestFlatPanelLayout addObject:newPanelDesc];
	//[newPanelDesc release];
	
	/*create the root view, add give it a reference to this view controller instance:*/
	self.view = [[panelView alloc] initWithFrame: CGRectMake(0, 0, 768, 1024) andRootPanelDescNodePointer:panelTreeStructure->getRootPanelTreeDescNodePointer()];
	[self.view setThisViewController: self];
	
	/*create a simple, white, empty view as the view for this controller:*/
	//self.view = [[panelViewParentView alloc] initWithFrame: CGRectMake(0, 0, 768, 1024)];
}


- (void)setPanelTreeStructurePointer: (panelTree *)thePointer;
{
	panelTreeStructure = thePointer;
}


/*
	userSwipedToSplitPanelWithP1x
 
	The view will call this method when it recognises a vertical or horizontal swipe event. 
	This method passes the info on to the panel tree to request a split:
*/
- (int)userSwipedToSplitPanelWithP1x:(int)p1x p1y:(int)p1y p2x:(int)p2x p2y:(int)p2y splitDimension:(int)splitDimension
{
	int result = panelTreeStructure->requestSplit(p1x,p1y,p2x,p2y,splitDimension);
	
	return result;
}


/*
	checkShiftTouchAttemptWithDimension
 
	Essentially a wrapper. 
	The view event handlers will, once they verify an attempted shift motion, call this method to check whether the start position of the shift is actually on a split boundary between panels
	This consults the panelView C++ object to check this, then returns the result. and if successful, other information such as the maximum range of space the split can move around in without crushing subpanels
*/
- (int)checkShiftTouchAttemptWithDimension:(int)shiftDimension location:(int)shiftLocation startPoint:(int)touchStartPoint endPoint:(int)touchEndPoint shiftMinLocation: (int *)shiftMinLocation shiftMaxLocation: (int *)shiftMaxLocation recordAffectedMiniApps: (NSMutableArray *)affectedMiniApps
{
	/*N.B given that the view that this view controller 'controls' is a grandchild rather than a direct subview, get a reference to it here for use in this method:*/
	panelView *thePanelView = self.view;//[[self.view subviews] objectAtIndex: 0];
	
	int panelIdOfShiftLine;
	panelTreeDesc **affectedMiniApps_panelTreeDescs;
	int numberOfAffectedMiniApps;
	
	
	/*First, query the internal tree structure to determine whether the attempt actually lines up with a panel split and if so, get information about the related panels:*/
	panelIdOfShiftLine = panelTreeStructure->verifyPanelSplitLocation(shiftDimension, shiftLocation, touchStartPoint, touchEndPoint, shiftMinLocation, shiftMaxLocation, &affectedMiniApps_panelTreeDescs, &numberOfAffectedMiniApps);

	/*if a success, then convert the C array of panelTreeDesc's into an ObjC mutable array of mini app views:*/
	if(panelIdOfShiftLine != -1)
	{
		for(int i = 0; i < [[thePanelView getMiniAppSubviewsArray] count]; i++)
		{
			for(int j = 0; j < numberOfAffectedMiniApps; j++)
			{
				if((int)(affectedMiniApps_panelTreeDescs[j]) == [[[thePanelView getMiniAppSubviewsArray] objectAtIndex: i] getPanelTreeDescNodePointer])
				{
					[affectedMiniApps addObject: [[thePanelView getMiniAppSubviewsArray]  objectAtIndex: i]];
					break;
				}
			}
		}
	}
	free(affectedMiniApps_panelTreeDescs);
	
	return panelIdOfShiftLine;
}


/*
	shiftEventHasMovedSplitPositionForPanel
 
	Essentially a wrapper, simply passes the parameters on to the equivalent panelTree method
*/
- (void)shiftEventHasMovedSplitPositionForPanel:(int)splitsPanelId newLocation:(int)splitOffset
{
	/*carry out the actual split*/
	panelTreeStructure->specifyNewSplitLocationForSubPanel(splitsPanelId, splitOffset);
}


/*
	queryRemovalOfPanel.
 
	calls the panel tree's query removal method. This returns an array of the panels that would be affected by removal of the given panel. This method converts this array to a nice ObjC array of views:
 */
- (int)queryRemovalOfPanel:(int) panelIdToRemove recordAffectedMiniApps: (NSMutableArray *)affectedMiniApps
{
	//panelTreeStructure->printStateOfTree();
	
	/*N.B given that the view that this view controller 'controls' is a grandchild rather than a direct subview, get a reference to it here for use in this method:*/
	panelView *thePanelView = self.view;
	
	int numberOfAffectedNodes;
	panelTreeDesc **affectedNodes_panelTreeDescs;
	
	int removalResult = panelTreeStructure->queryRemovalOfPanel(panelIdToRemove, &numberOfAffectedNodes, &affectedNodes_panelTreeDescs);
	
	
	/*now use this list of affected nodes' panelDescNodes to add to the caller's mutable array of the actual nodes' views:*/
	miniAppView *miniAppToCheck;
	
	
	//for(int j = 0; j < numberOfAffectedNodes; j++) NSLog(@"affected panel id: %d", affectedNodes_panelTreeDescs[j]->panelId);
	
	
	/*Convert the C array of panelTreeDesc's into an ObjC mutable array of mini app views:*/
	for(int i = 0; i < [[thePanelView getMiniAppSubviewsArray] count]; i++)
	{
		for(int j = 0; j < numberOfAffectedNodes; j++)
		{
			if( ((int)(affectedNodes_panelTreeDescs[j])) == [[[thePanelView getMiniAppSubviewsArray] objectAtIndex: i] getPanelTreeDescNodePointer] )
			{
				[affectedMiniApps addObject: [[thePanelView getMiniAppSubviewsArray] objectAtIndex: i]];
				break;
			}
		}
	}
	
	/*free the C array 'affectedMiniApps_panelTreeDescs' as it is no longer needed:*/
	if(removalResult == 1) free(affectedNodes_panelTreeDescs);
	
	return removalResult;
}



/*
	requestRemovalOfPanel.
 
	goes ahead and removes the panel given by the panelId - by calling the panel tree's request removal method: 
*/
- (int)requestRemovalOfPanel:(int) panelIdToRemove
{
	int removalResult = panelTreeStructure->requestRemovalOfPanel(panelIdToRemove);
	
//	panelTreeStructure->printStateOfTree();
	
	return removalResult;
}


/*
	getRootPanelTreeDescNodePointer
 
	wrapper.
*/
- (int)getRootPanelTreeDescNodePointer
{
	return panelTreeStructure->getRootPanelTreeDescNodePointer();
}


/*
	ensure that there is no *system automated* behaviour when the device's orientation changes. We will handle this manually
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
   if(
			(interfaceOrientation == UIDeviceOrientationPortrait)||
			(interfaceOrientation == UIDeviceOrientationLandscapeLeft)||
			(interfaceOrientation == UIDeviceOrientationPortraitUpsideDown)||
			(interfaceOrientation == UIDeviceOrientationLandscapeRight)
	  )
   {  
	   return YES;
   }
   
   else return NO;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (void)dealloc {
    
	delete panelTreeStructure;
	
	[latestFlatPanelLayout release];
	
	[super dealloc];
}


@end



@implementation panelViewParentView

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) 
	{
		self.multipleTouchEnabled = YES;
	}
	
	return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	//NSLog(@"I HAVE %d SUBVIEWS!!!", [[self subviews] count]);
	
	//return [[self subviews] objectAtIndex: 0];
	
	return [[[self subviews] objectAtIndex: 0] hitTest: point withEvent: event];
}

@end