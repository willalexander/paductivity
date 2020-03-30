/*
 *  panelTreeDesc.h
 *  Paductivity
 *
 *  Created by William Alexander on 15/10/2010.
 *  Copyright 2010 Framestore-CFC. All rights reserved.
 *
 */


#ifndef __PANELTREEDESC_H__
#define __PANELTREEDESC_H__


typedef struct panelTreeDesc
{
	int originX;
	int originY;
	int width;
	int height;
	
	int depth;
	int panelId;
	
}panelTreeDesc;


#endif