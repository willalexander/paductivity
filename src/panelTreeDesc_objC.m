//
//  panelTreeDesc_objC.m
//  WorkPad
//
//  Created by William Alexander on 28/09/2010.
//  Copyright 2010 Framestore-CFC. All rights reserved.
//

#import "panelTreeDesc_objC.h"


@implementation panelTreeDesc_objC

@synthesize originX;
@synthesize originY;
@synthesize width;
@synthesize height;
@synthesize panelId;

- (void) setOriginX:(int)orX_in originY:(int)orY_in width:(int)width_in height:(int)height_in panelId:(int)panelId_in
{
	originX = orX_in;
	originY = orY_in;
	width = width_in;
	height = height_in;
	panelId = panelId_in;
}

@end
