//
//  panelViewController.h
//  WorkPad
//
//  Created by William Alexander on 28/09/2010.
//  Copyright 2010 Framestore-CFC. All rights reserved.
//

#ifndef __PANELVIEWCONTROLLER_H__
#define __PANELVIEWCONTROLLER_H__


#import <UIKit/UIKit.h>

#include "panelTree.h"
#include "panelTreeDesc_objC.h"
#include "panelView.h"


typedef struct shiftEventMetaData
{
	int panelId;
	int shiftMin;
	int shiftMax;
}shiftEventMetaData;


@interface panelViewController : UIViewController {
	
	panelTree *panelTreeStructure;
	
	panelTreeDesc *latestFlatPanelLayout_C;
	int latestFlatPanelLayoutCount;
	NSMutableArray *latestFlatPanelLayout;
}

- (void)setPanelTreeStructurePointer: (panelTree *)thePointer;

- (int)userSwipedToSplitPanelWithP1x:(int) p1x p1y:(int) p1y p2x:(int) p2x p2y:(int) p2y splitDimension:(int) splitDimension;
- (int)checkShiftTouchAttemptWithDimension: (int) shiftDimension location: (int) shiftLocation startPoint: (int) touchStartPoint endPoint: (int) touchEndPoint shiftMinLocation: (int *)shiftMinLocation shiftMaxLocation: (int *)shiftMaxLocation recordAffectedMiniApps: (NSMutableArray *)affectedMiniApps;
- (void)shiftEventHasMovedSplitPositionForPanel: (int) splitsPanelId newLocation: (int) splitOffset;
- (int)queryRemovalOfPanel:(int) panelIdToRemove recordAffectedMiniApps: (NSMutableArray *)affectedMiniApps;
- (int)requestRemovalOfPanel:(int) panelIdToRemove;
- (int)getRootPanelTreeDescNodePointer;

@end


/*
	The view type that these 'panelViewController' objects will take is an exact subclass replica of 'UIView' but set to be 'invisible' to events by passing them straight down to its subview:
 */
@interface panelViewParentView: UIView
{
}

@end


#endif
