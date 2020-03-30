//
//  panelTreeDesc_objC.h
//  WorkPad
//
//  Created by William Alexander on 28/09/2010.
//  Copyright 2010 Framestore-CFC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface panelTreeDesc_objC : NSObject {

	NSInteger originX;
	NSInteger originY;
	NSInteger width;
	NSInteger height;
	NSInteger panelId;
}

@property NSInteger originX;
@property NSInteger originY;
@property NSInteger width;
@property NSInteger height;
@property NSInteger panelId;

- (void)setOriginX: (int)orX_in originY: (int)orY_in width: (int)width_in height: (int)height_in panelId: (int)panelId_in;

@end
