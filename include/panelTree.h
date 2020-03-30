/*
 *  panelTree.h
 *  WorkPad
 *
 *  Created by William Alexander on 28/09/2010.
 *  Copyright 2010 Framestore-CFC. All rights reserved.
 *
 */




#ifndef __PANEL_TREE_H__
#define __PANEL_TREE_H__


#include "panelTreeDesc.h"


#define PANEL_TREE_SPLIT_LINE_MAX_PROTRUSION 50
#define PANEL_TREE_PANEL_MINIMUM_OPERABLE_WIDTH 30
#define PANEL_TREE_PANEL_MINIMUM_ABSOLUTE_WIDTH 25
#define PANEL_TREE_SHIFTSTARTLINE_MAXIMUM_ERROR 20
#define PANEL_TREE_PANEL_CORNER_PROXIMITY 50
#define MINIMUM_TREE_PANEL_DIMENSION 25



class panelTree
{
	public:
	
		panelTree(void);
		panelTree(int,int,int,int,int,panelTree *);
	
	
		int requestSplit(int, int, int, int, int);
		int verifyPanelSplitLocation(int, int, int, int, int *, int *, panelTreeDesc ***, int *);
		void specifyNewSplitLocationForSubPanel(int,int);
		int queryRemovalOfPanel(int, int *numberOfAffectedNodes, panelTreeDesc ***affectedNodes);	
		int requestRemovalOfPanel(int);
		int getRootPanelTreeDescNodePointer();
		void printStateOfTree();
	
		~panelTree(void);

	
	private:
	
		int originX;
		int originY;
		int width;
		int height;
		
		int depth;
		int panelId;
	
		int splitDimension;
		float splitPoint;
	
		panelTree **linearStructure;
		int linearStructureLength;
		int currentTreeDepth;
	
		panelTree *childA;
		panelTree *childB;
	
		panelTree *parent;
		panelTree *rootNode;
	
		panelTreeDesc *panelTreeDescNode;
	
	
	
		void setDepthAndPanelId(int,int);
		panelTreeDesc * setPanelTreeDescNode();
	
		int isLeafNode(void);
		int treeDepth(int);
		void traverseTree(panelTree *, int, panelTreeDesc *, int *);
		void traverseTreeAndBuildLinearStructure(int, int);
		int determineNumberOfSplitsInGivenDimensionBelowSelf(int dimension);
		void rebuildLinearStructure();
		int isValidSplitLine(panelTree *, int, int, int, int, int, panelTree **);
		int isCloseToPanelSplit(panelTree *, int, int, int, int, int *, int *);
		void countDimensionalPanels(panelTree *, int, int, int *, int *);
		int split(int,int);
		void creatingNewLeafAtNewDepth(int);
		void changePanelNodeBounds(int, int, int, int);
	

	
		int isCloseToLeafPanelCorner(int, int);
		void traverseTreeToGetArrayOfAllNodesDescNodes(panelTree *node, panelTreeDesc **descNodeArray, int *count);	
};

#endif