/*
 *  panelTree.cpp
 *  WorkPad
 *
 *  Created by William Alexander on 28/09/2010.
 *  Copyright 2010 Framestore-CFC. All rights reserved.
 *
 */

#include <iostream>
#include <math.h>

#include "panelTree.h"


/*
	Default Constructor.
 
	Initialise the object as a 786x1004 vertical leaf panel, with origin 0,0
*/
panelTree::panelTree()
{
	originX = 0;
	originY = 0;
	width = 768;
	height = 1004;
	
	childA = childB = NULL;
}


/*
	Scale-Specific Constructor.
 
	Caller provides geometric description of panel
	If isRootNode is equal to 1, this new instance will be regarded as the root node. if 0, it won't, and it'll need the root node's address to be passed in through rootNodeAddress
*/
panelTree::panelTree(int originX_in, int originY_in, int width_in, int height_in, int isRootNode, panelTree *rootNodeAddress)
{
	/*set basic size information:*/
	originX = originX_in;
	originY = originY_in;
	width = width_in;
	height = height_in;
	
	/*depth and panelId default to 0, these values will be set in method called separately:*/
	depth = 0;
	panelId = 0;
	
	/*Being new, this will be a leaf node by default, so no children to point to:*/
	childA = childB = NULL;
	
	/*a panel tree desc node will be allocated when appropriate:*/
	panelTreeDescNode = NULL;
	
	/*If this is the root node, then there are some extra values and data to set up:*/
	if(isRootNode == 1)
	{
		rootNode = this;
		parent = NULL;
		currentTreeDepth = 1;
		
		/*the root node has a linear structure set of references to descendants*/
		linearStructure = (panelTree **)(malloc(sizeof(panelTree *)));
		linearStructure[0] = this;
		linearStructureLength = 1;
		
		/*in the case of the root node, we know that it as a leaf upon initialization, so it should be allocated a panelTreeDescNode:*/
		panelTreeDescNode = (panelTreeDesc *)(malloc(sizeof(panelTreeDesc)));
		panelTreeDescNode->originX = originX_in;
		panelTreeDescNode->originY = originY_in;
		panelTreeDescNode->width = width;
		panelTreeDescNode->height = height;
		panelTreeDescNode->panelId = 0;
	}
	else rootNode = rootNodeAddress;
}


/*
	setDepthAndPanelId.
 
	Simple setter method for depth and panelId member variables
 */
void panelTree::setDepthAndPanelId(int depth_in, int panelId_in)
{
	depth = depth_in;
	panelId = panelId_in;
}


/*
	setPanelTreeDescLayout
 
	If the object already has a panelTreeDescNode, this sets its bounds values to the objects current bound values
	If it doesn't already have one, then this method creates a panelTreeDescNode for itself, and gives it the object's own bounds
	Returns the address of the panel's desc node:
 
 */
panelTreeDesc * panelTree::setPanelTreeDescNode()
{
	if(panelTreeDescNode == NULL) panelTreeDescNode = (panelTreeDesc *)(malloc(sizeof(panelTreeDesc)));
	
	panelTreeDescNode->originX = originX;
	panelTreeDescNode->originY = originY;
	panelTreeDescNode->width = width;
	panelTreeDescNode->height = height;
	
	panelTreeDescNode->panelId = panelId;
	
	return panelTreeDescNode;
}


/*
	isLeafNode.
 
	returns whether or not this node is a leaf. (1 for yes, 0 for no)
*/
int panelTree::isLeafNode(void)
{
	if(childA == NULL) return 1;
	else return 0;
}


/*
	treeDepth.
 
	Will return the depth of the tree from this point downwards. (For reference, if this panel is a leaf, then the depth = 1);
	The caller should call this method with a value of 1 for 'currentDepth':
 */
int panelTree::treeDepth(int currentDepth)
{
	int branchADepth, branchBDepth;
	
	if(this->isLeafNode() == 0)
	{
		branchADepth = childA->treeDepth(currentDepth+1);
		branchBDepth = childB->treeDepth(currentDepth+1);
	
		if(branchADepth > branchBDepth) return branchADepth;
		else return branchBDepth;
	}
	
	else return currentDepth;
}


/*
	traverseTree.
 
	Tree traversal mechanism, has several 'action options':
 
	if action is set to '0', then this method simply traverses the tree, depth first using the 'startNode' as the root, and accumulates a count in 'count' of how many leaf nodes there are. It is assumed that 'count' points to a value of 0 to start with
	if action is set to '1', then the method also adds, for each leaf node, a 'panelTreeDesc' object with that node's dimensions, to the 'leafNodeDescs' array. It is assumed that enough space has already been allocated to this pointer
	if action is set to '2', the tree is deleted
	if action is set to '3', prints out all node info:
*/
void panelTree::traverseTree(panelTree *nodeToProcess, int action, panelTreeDesc *leafNodeDescs, int *count)
{
	panelTreeDesc newPanelTreeDesc_tmp;
	
	/*keep count of leaf nodes:*/
	if(action == 0)
	{
		if(nodeToProcess->isLeafNode() == 1) (*count)++;
	}
	
	/*record content of leaf nodes:*/
	if(action == 1)
	{
		if(nodeToProcess->isLeafNode() == 1)
		{
			/*simply make a new panelTreeDesc, and give it this leaf node's dimensions, then add it to the array:*/
			newPanelTreeDesc_tmp.originX = nodeToProcess->originX;
			newPanelTreeDesc_tmp.originY = nodeToProcess->originY;
			newPanelTreeDesc_tmp.width = nodeToProcess->width;
			newPanelTreeDesc_tmp.height = nodeToProcess->height;
			newPanelTreeDesc_tmp.depth = nodeToProcess->depth;
			newPanelTreeDesc_tmp.panelId = nodeToProcess->panelId;
			
			leafNodeDescs[(*count)] = newPanelTreeDesc_tmp;
			
			(*count)++;
		}
	}
	
	/*delete leaf nodes:*/
	if(action == 2)
	{
		if((nodeToProcess->isLeafNode() == 1) && (nodeToProcess != nodeToProcess->rootNode)) delete nodeToProcess;
	}
	
	/*print node's information:*/
	if(action == 3)
	{
		printf("Depth %d node.\n\n\tAddress: %d \n\tPanelId: %d \n\tOriginX: %d \n\tOriginY: %d \n\twidth: %d \n\theight: %d \n\tdepth: %d \n\tisLeafNode? %d \n\tsplitDimension: %d \n\tsplitPoint: %f \n\tchildA: %d \n\tchildB: %d \n\tparent: %d \n\trootNode: %d  \n", nodeToProcess->depth, nodeToProcess, nodeToProcess->panelId, nodeToProcess->originX, nodeToProcess->originY, nodeToProcess->width, nodeToProcess->height, nodeToProcess->depth, nodeToProcess->isLeafNode(), nodeToProcess->splitDimension, nodeToProcess->splitPoint, nodeToProcess->childA, nodeToProcess->childB, nodeToProcess->parent, nodeToProcess->rootNode);
		if(nodeToProcess->isLeafNode() == 1) printf("Node is a leaf node, its desc address is: %d\n",(int)(nodeToProcess->panelTreeDescNode));
		printf("\n\n");
	}
	
	/*now traverse downwards (if this is not a leaf node):*/
	if(nodeToProcess->isLeafNode() != 1)
	{
		traverseTree(nodeToProcess->childA,action,leafNodeDescs,count);
		traverseTree(nodeToProcess->childB,action,leafNodeDescs,count);
		
		/*some actions have post-traversal tasks:*/
		if(action == 2) if(nodeToProcess != nodeToProcess->rootNode) delete(nodeToProcess);
	}
}


/*
	determineNumberOfSplitsInGivenDimensionBelowSelf. 
 
	Called on a given node, this method traverses all nodes below itself in the tree, including itself, and simply counts how many splits there are below itself in a given dimension (horizontal or vertical)
 */
int panelTree::determineNumberOfSplitsInGivenDimensionBelowSelf(int dimension)
{
	/*if this is a leaf, then obviously none:*/
	if(this->isLeafNode() == 1) return 0;
	
	/*if not, then we'll need to gather each child's number of splits in the dimension:*/
	int childASplitCount = childA->determineNumberOfSplitsInGivenDimensionBelowSelf(dimension);
	int childBSplitCount = childB->determineNumberOfSplitsInGivenDimensionBelowSelf(dimension);
	
	/*if this node's split is *not* in the given dimension, then the result to return is simply the larger of the two results from the children (we don't want to combine both split numbers, just which ever is more)*/
	if(splitDimension != dimension)
	{
		if(childASplitCount > childBSplitCount) return childASplitCount;
		else return childBSplitCount;
	}
	
	/*if this node's split *is* in the given dimension, then this split itself counts as one, and we add together both childrens' split counts:*/
	else 
	{
		return childASplitCount + childBSplitCount + 1;
	}
}


/*
	traverseTreeAndBuildLinearStructure
 
	traverses entire tree starting at the root, and builds the root node's linear structure array of pointers to nodes.
	N.B. this assumes that the root node's linearStructure pointer points to an array that is empty, and of the correct size to accommodate all the tree's nodes
*/
void panelTree::traverseTreeAndBuildLinearStructure(int depthToTake, int panelIdToTake)
{
	int panelIdForThisNode;
	
	/*simply update this node's record of its panelId and depth, and insert it into the linear structure:*/
	depth = depthToTake;
	panelId = panelIdToTake;
	
	/*update this node's panelTreeDescNode to have the these values as well:*/
	if(this->isLeafNode() == 1)
	{
		panelTreeDescNode->depth = depth;
		panelTreeDescNode->panelId = panelId;
	}
		
	//printf("\n\n     ***** panelTreeDescNode's new values: %d, %d\n\n", panelTreeDescNode->depth, panelTreeDescNode->panelId);
	
	
	rootNode->linearStructure[panelIdToTake] = this;
	
	/*if not a leaf, then propagate down to children:*/
	if(this->isLeafNode() == 0)
	{
		childA->traverseTreeAndBuildLinearStructure(depthToTake + 1, pow(2,(depth + 1)) - 1 + 2*(panelId - (pow(2,depth) - 1)));
		childB->traverseTreeAndBuildLinearStructure(depthToTake + 1, pow(2,(depth + 1)) - 1 + 2*(panelId - (pow(2,depth) - 1)) + 1);
	}
}


/*
	rebuildLinearStructure
 
	If nodes have been removed midway up the hierarchy, then the linear structure of the tree may need rebuilding. This method totally removes the linear structure and rebuilds it from scratch to ensure that it is clean and up-to-date.
	N.B. this method can only be called on the root node
*/
void panelTree::rebuildLinearStructure()
{
	int i;
	
	/*if not the root node, stop here:*/
	if(this != this->rootNode) return;
	
	/*remove linear structure, and allocate afresh:*/
	free(linearStructure);
	
	currentTreeDepth = this->treeDepth(1);
	
	linearStructureLength = 0;
	for(i = 0; i<currentTreeDepth; i++) linearStructureLength += pow(2,i);
	linearStructure = (panelTree **)(malloc(linearStructureLength*sizeof(panelTree *)));
	for(i = 0; i<linearStructureLength; i++) linearStructure[i] = NULL;
	
	/*traverse whole tree, and update both hierarchical and linear structures by calculating each node's panelID:*/
	this->traverseTreeAndBuildLinearStructure(0,0);
	
#ifdef OB_NOT
	/*For completeness, traverse the whole tree and print out information about its structure:*/
	for(i = 0; i<linearStructureLength; i++)
	{
		if(linearStructure[i] != NULL)
		{
			printf("Node #%d at depth: %d has panelId %d, and originX: %d, originY: %d, width: %d, height: %d\n",i,linearStructure[i]->depth, linearStructure[i]->panelId, linearStructure[i]->originX, linearStructure[i]->originY, linearStructure[i]->width, linearStructure[i]->height);
		}
		
		else 
		{
			printf("Node #%d at is NULL\n",i);
		}
	}
	printf("\n\n");
#endif
}


/*
	isValidSplitLine
 
	This method takes a line described by end points, and tests it against its 'self' panel and all this panel's children, so see if amongst them there is a leaf panel that the given line intersects, within certain constraints.
	If a success, returns 1 and sets 'panelTreeToReturn' to point to the leaf panel in question 
*/
int panelTree::isValidSplitLine(panelTree *panelTreeNodeToTry, int splitDimension, int p1x, int p1y, int p2x, int p2y, panelTree **panelTreeToReturn)
{
	/*if this node is a leaf, then test it:*/
	if(panelTreeNodeToTry->childA == NULL)
	{
		if(splitDimension == 0)
		{
			/*First, fail if infinite line doesn't intersect panel, and intersect it with AT LEAST a reasonable (as defined by 'PANEL_TREE_PANEL_MINIMUM_OPERABLE_WIDTH')  distance from line to panel edge:*/
			if((p1y < (panelTreeNodeToTry->originY + PANEL_TREE_PANEL_MINIMUM_OPERABLE_WIDTH))||(p1y > (panelTreeNodeToTry->originY + panelTreeNodeToTry->height - PANEL_TREE_PANEL_MINIMUM_OPERABLE_WIDTH))) return 0;
			
			/*First, fail if panel doesn't wholly fall between splitLine's end points (within reason) :*/
			if((p1x > (panelTreeNodeToTry->originX + PANEL_TREE_SPLIT_LINE_MAX_PROTRUSION))||(p2x < (panelTreeNodeToTry->originX + panelTreeNodeToTry->width - PANEL_TREE_SPLIT_LINE_MAX_PROTRUSION))) return 0;
			
			/*Second, now that we know the split line crosses the panel, fail if it protrudes too far out at either end:*/
			if(((panelTreeNodeToTry->originX - p1x) > PANEL_TREE_SPLIT_LINE_MAX_PROTRUSION)||((p2x - (panelTreeNodeToTry->originX + panelTreeNodeToTry->width)) > PANEL_TREE_SPLIT_LINE_MAX_PROTRUSION)) return 0;
			
			/*if we get this far, then this panel can be split, so set itself as the successful panel, and return 1:*/
			*panelTreeToReturn = panelTreeNodeToTry;
			return 1;
		}
		
		if(splitDimension == 1)
		{
			/*First, fail if infinite line doesn't intersect panel, and intersect it with AT LEAST a reasonable (as defined by 'PANEL_TREE_PANEL_MINIMUM_OPERABLE_WIDTH')  distance from line to panel edge::*/
			if((p1x < (panelTreeNodeToTry->originX + PANEL_TREE_PANEL_MINIMUM_OPERABLE_WIDTH))||(p1x > (panelTreeNodeToTry->originX + panelTreeNodeToTry->width - PANEL_TREE_PANEL_MINIMUM_OPERABLE_WIDTH))) return 0;
			
			/*Second, fail if panel doesn't wholly fall between splitLine's end points (within reason) :*/
			if((p1y > ( panelTreeNodeToTry->originY + PANEL_TREE_SPLIT_LINE_MAX_PROTRUSION))||(p2y < (panelTreeNodeToTry->originY + panelTreeNodeToTry->height - PANEL_TREE_SPLIT_LINE_MAX_PROTRUSION))) return 0;
			
			/*Third, now that we know the split line crosses the panel, fail if it protrudes too far out at either end:*/
			if(((panelTreeNodeToTry->originY - p1y) > PANEL_TREE_SPLIT_LINE_MAX_PROTRUSION)||((p2y - (panelTreeNodeToTry->originY + panelTreeNodeToTry->height)) > PANEL_TREE_SPLIT_LINE_MAX_PROTRUSION)) return 0;
			
			/*if we get this far, then this panel can be split, so set itself as the successful panel, and return 1:*/
			*panelTreeToReturn = panelTreeNodeToTry;
			return 1;
		}
	}
	
	/*if not, call this test on its children:*/
	else
	{
		if(isValidSplitLine(panelTreeNodeToTry->childA, splitDimension, p1x, p1y, p2x, p2y, panelTreeToReturn) == 1) return 1;
		if(isValidSplitLine(panelTreeNodeToTry->childB, splitDimension, p1x, p1y, p2x, p2y, panelTreeToReturn) == 1) return 1;
	}
	
	/*if we get this far, then no valid leaf panel has been found, so return 0:*/
	return 0;
}


/*
	isCloseToPanelSplit
 
	traverses tree, to see if given directed segment comes close enough to overlapping a panel's split.
	If yes, returns the panelId of the panel. If no, returns -1;
	Also, if yes, returns by reference through splitMinimumShift and splitMaximumShift, the max and min extent to which the split can be moved (the UI should then use this info to prevent the split from being moved outside the bounds of its parent, or 'squashing' any sub panels adjacent to it to below acceptable size
 */
int panelTree::isCloseToPanelSplit(panelTree *panelNodeToTry, int dimension, int location, int startPoint, int endPoint, int *splitMinimumShift, int *splitMaximumShift)
{
	int resultOfCheck;
	
	int panelSplitLocation;
	int numSubPanelsInDimensionOfSplitBelowSplit, numSubPanelsInDimensionOfSplitAboveSplit;
	int depthRecordCount;
	
	/*check against this node first: (horizontal code first, equivalent vertical code after)*/
	if((dimension == 0) && (panelNodeToTry->splitDimension == 0))
	{
		panelSplitLocation = panelNodeToTry->originY + panelNodeToTry->splitPoint;
		
		if(fabs(panelSplitLocation - location) <= PANEL_TREE_SHIFTSTARTLINE_MAXIMUM_ERROR)
		{
			if((startPoint > panelNodeToTry->originX)&&(endPoint < (panelNodeToTry->originX + panelNodeToTry->width)))
			{
				/*Then the attempted segment is close enough to this panel's split line. Any user shifting must accommodate for other child panels, not squeezing them out:*/
				numSubPanelsInDimensionOfSplitBelowSplit = 1;
				depthRecordCount = 0;
				countDimensionalPanels(panelNodeToTry->childA, 0, 1, &numSubPanelsInDimensionOfSplitBelowSplit, &depthRecordCount);
				
				numSubPanelsInDimensionOfSplitAboveSplit = 1;
				depthRecordCount = 0;
				countDimensionalPanels(panelNodeToTry->childB, 0, 1, &numSubPanelsInDimensionOfSplitAboveSplit, &depthRecordCount);
				
				
				*splitMinimumShift = panelNodeToTry->originY + numSubPanelsInDimensionOfSplitBelowSplit * PANEL_TREE_PANEL_MINIMUM_ABSOLUTE_WIDTH;
				*splitMaximumShift = panelNodeToTry->originY + panelNodeToTry->height - numSubPanelsInDimensionOfSplitAboveSplit * PANEL_TREE_PANEL_MINIMUM_ABSOLUTE_WIDTH;
				
				return panelNodeToTry->panelId;
			}
		}
		
	}
	
	if((dimension == 1) && (panelNodeToTry->splitDimension == 1))
	{
		panelSplitLocation = panelNodeToTry->originX + panelNodeToTry->splitPoint;
		
		if(fabs(panelSplitLocation - location) <= PANEL_TREE_SHIFTSTARTLINE_MAXIMUM_ERROR)
		{
			if((startPoint > panelNodeToTry->originY)&&(endPoint < (panelNodeToTry->originY + panelNodeToTry->height)))
			{
				/*Then the attempted segment is close enough to this panel's split line. Any user shifting must accommodate for other child panels, not squeezing them out:*/
				numSubPanelsInDimensionOfSplitBelowSplit = 1;
				depthRecordCount = 0;
				countDimensionalPanels(panelNodeToTry->childA, 1, 1, &numSubPanelsInDimensionOfSplitBelowSplit, &depthRecordCount);
				
				numSubPanelsInDimensionOfSplitAboveSplit = 1;
				depthRecordCount = 0;
				countDimensionalPanels(panelNodeToTry->childB, 1, 1, &numSubPanelsInDimensionOfSplitAboveSplit, &depthRecordCount);
				
				*splitMinimumShift = panelNodeToTry->originX + numSubPanelsInDimensionOfSplitBelowSplit* PANEL_TREE_PANEL_MINIMUM_ABSOLUTE_WIDTH;
				*splitMaximumShift = panelNodeToTry->originX + panelNodeToTry->width - numSubPanelsInDimensionOfSplitAboveSplit * PANEL_TREE_PANEL_MINIMUM_ABSOLUTE_WIDTH;
				
				return panelNodeToTry->panelId;
			}
		}
	}
	
	
	/*try child nodes, *if they are not leaf nodes*:*/
	if(childA->isLeafNode() == 0)
	{
		resultOfCheck = childA->isCloseToPanelSplit(childA, dimension, location, startPoint, endPoint, splitMinimumShift, splitMaximumShift);
		if(resultOfCheck != -1) return resultOfCheck;
	}
	
	if(childB->isLeafNode() == 0)
	{
		resultOfCheck = childB->isCloseToPanelSplit(childB, dimension, location, startPoint, endPoint, splitMinimumShift, splitMaximumShift);
		if(resultOfCheck != -1) return resultOfCheck;
	}
	
	/*if we get this far, then all attempts at and below this hierarchical point have failed, therefore return failure:*/
	return -1;
}


/*
	countDimensionalPanels
 
	Recursively traverses down the tree starting at the given node, and counts how many panels there are in the tree in the given dimension, with only one split allowed per level of hierarchy depth.
	N.B. the external caller this method must supply 1 as the currentDepth, 1 as the current count and 0 as the depth at which the last split was counted
*/
void panelTree::countDimensionalPanels(panelTree *panelToCheck, int dimension, int currentDepth, int *currentCount, int *depthAtWhichLastSplitWasCounted)
{
	/*if this is a leaf node, end here:*/
	if(panelToCheck->isLeafNode() == 1) return;
	
	/*if this panel splits into sub-panels by via a split in the requested dimension, then this is what the method needs to keep count of:*/
	if(panelToCheck->splitDimension == dimension)
	{
		*currentCount += 1;
		*depthAtWhichLastSplitWasCounted = currentDepth;
	}
	
	/*regardless of dimension, recursively call on the panel's children:*/
	panelToCheck->countDimensionalPanels(panelToCheck->childA, dimension, currentDepth + 1, currentCount, depthAtWhichLastSplitWasCounted);
	panelToCheck->countDimensionalPanels(panelToCheck->childB, dimension, currentDepth + 1, currentCount, depthAtWhichLastSplitWasCounted);
}


/*
	Split.
 
	This subdivides a leaf node into two binary leaf nodes, split at the given point (distance from minimum lower end) along the given dimension (if dimension = 0, then that's the X axis, if 1 then Y)
	Returns the address of the new child node's panelDesc object for success, 0 for failure.
	Only valid if called on a leaf node
*/
int panelTree::split(int dimension, int splitPoint_in)
{
	int largerChild;
	int panelTreeDescNodeToReturn;
	
	if(this->isLeafNode() == 0) return 0;
	if((dimension < 0)||(dimension > 1)) return 0;
	
	splitDimension = dimension;
	splitPoint = splitPoint_in;
	
	/*calculate the panelIds of the two new child panels:*/
	int newPanelIdA, newPanelIdB; 
	newPanelIdA = pow(2,(depth + 1)) - 1 + 2*(panelId - (pow(2,depth) - 1));
	newPanelIdB = pow(2,(depth + 1)) - 1 + 2*(panelId - (pow(2,depth) - 1)) + 1;
	
	
	/*let the root node of the tree know that we're making new leaves at a certain level:*/
	rootNode->creatingNewLeafAtNewDepth(depth + 1 + 1);
	
	if(dimension == 0)
	{
		/*allocate the child panelTree nodes:*/
		childA = new panelTree(originX,originY,width, splitPoint,0,rootNode);
		childB = new panelTree(originX,originY+splitPoint,width,height-splitPoint,0,rootNode);
		
		/*assign them their meta data values:*/
		childA->setDepthAndPanelId(depth + 1, newPanelIdA);
		childB->setDepthAndPanelId(depth + 1, newPanelIdB);
		
		/*link the new child nodes up to the broader structure:*/
		rootNode->linearStructure[newPanelIdA] = childA;
		rootNode->linearStructure[newPanelIdB] = childB;
		
		childA->parent = childB->parent = this;
		
		/*determine which child is the larger:*/
		if(splitPoint_in > (0.5*height)) largerChild = 0;
		else largerChild = 1;
	}
	
	if(dimension == 1)
	{
		childA = new panelTree(originX,originY,splitPoint,height,0,rootNode);
		childB = new panelTree(originX+splitPoint,originY,width-splitPoint,height,0,rootNode);
		
		childA->setDepthAndPanelId(depth + 1, newPanelIdA);
		childB->setDepthAndPanelId(depth + 1, newPanelIdB);
		
		rootNode->linearStructure[newPanelIdA] = childA;
		rootNode->linearStructure[newPanelIdB] = childB;
		
		childA->parent = childB->parent = this;
		
		/*determine which child is the larger:*/
		if(splitPoint_in > (0.5*width)) largerChild = 0;
		else largerChild = 1;
	}
	
	/*the larger child takes on the identity of its parent (this node), so it inherits the parent's panelTreeDescNode. Meanwhile the smaller child creates its own new panelTreeDescNode:*/
	if(largerChild == 0)
	{
		childA->panelTreeDescNode = panelTreeDescNode;
		childA->setPanelTreeDescNode();
		panelTreeDescNodeToReturn = (int)(childB->setPanelTreeDescNode());
	}
	else 
	{
		childB->panelTreeDescNode = panelTreeDescNode;
		panelTreeDescNodeToReturn = (int)(childA->setPanelTreeDescNode());
		childB->setPanelTreeDescNode();
	}
	panelTreeDescNode = NULL;
	
	
	return panelTreeDescNodeToReturn;
}


/*
	creatingNewLeafAtNewDepth.
 
	This will only be called on the root node, and is called when a panel node is split in two, thus possibly creating a new level of depth in the tree, specified though the argument 'newDepth'. 
	*if* this depth is deeper than the tree has yet gone, then it can now update its internal info
*/
void panelTree::creatingNewLeafAtNewDepth(int newDepth)
{
	panelTree **newLinearStructure;
	int newLinearStructureLength;
	int i;
	
	
	/*if this new depth is less than or equal to the current tree depth, then nothing needs to happen*/
	if(newDepth <= currentTreeDepth) return;
	
	/*If not, we can *assume* that the only possible alternative value then is for this new depth to be 1 more than the current depth. Therefore, allocate a new version of the linear structure array with space for the new level of depth:*/
	currentTreeDepth = newDepth;
	
	newLinearStructureLength = 0;
	for(i = 0;i<currentTreeDepth;i++) newLinearStructureLength += pow(2,i);
	newLinearStructure = (panelTree **)(malloc(newLinearStructureLength*sizeof(panelTree *)));
	
	for(i = 0;i<newLinearStructureLength;i++)
	{
		if(i < linearStructureLength) newLinearStructure[i] = linearStructure[i];
		else newLinearStructure[i] = NULL;
	}
	
	free(linearStructure);
	linearStructure = newLinearStructure;
	linearStructureLength = newLinearStructureLength;
}


/*
	changePanelNodeBounds
 
	simply informs the panel that its bounds must change to new values, and supplies updated values for originX, originY, width and height
*/
void panelTree::changePanelNodeBounds(int newOriginX, int newOriginY, int newWidth, int newHeight)
{
	/*If this is a leaf node, then very simple, simply replace current bounds values with the ones provided above as parameters:*/
	if(isLeafNode() == 1)
	{
		originX = newOriginX;
		originY = newOriginY;
		width = newWidth;
		height = newHeight;
	}
	
	/*if not a leaf, then slightly more complicated. Must update its split location proportionately, and notify its children of the updates:*/
	else 
	{
		/*If a horizontal split:*/
		if(splitDimension == 0)
		{
			/*update the split location:*/
			splitPoint = (float)(newHeight) * (splitPoint / (float)(height));
			
			/*important - do not allow any child node to have a dimension less than 'MINIMUM_TREE_PANEL_DIMENSION':*/
			if(splitPoint < MINIMUM_TREE_PANEL_DIMENSION) splitPoint = MINIMUM_TREE_PANEL_DIMENSION;
			if((newHeight - splitPoint) < MINIMUM_TREE_PANEL_DIMENSION) splitPoint = newHeight - MINIMUM_TREE_PANEL_DIMENSION;   
			
			/*now update the bounds of this panel node*/
			originX = newOriginX;
			originY = newOriginY;
			width = newWidth;
			height = newHeight;
			
			/*now force update the bounds of the two children:*/
			childA->changePanelNodeBounds(originX, originY, width, (int)(splitPoint));
			childB->changePanelNodeBounds(originX, originY + (int)(splitPoint), width, height - (int)(splitPoint));
		}
		
		/*If a vertical split:*/
		else 
		{
			/*update the split location:*/
			splitPoint = (float)(newWidth) * (splitPoint / (float)(width));
			
			/*important - do not allow any child node to have a dimension less than 'MINIMUM_TREE_PANEL_DIMENSION':*/
			if(splitPoint < MINIMUM_TREE_PANEL_DIMENSION) splitPoint = MINIMUM_TREE_PANEL_DIMENSION;
			if((newWidth - splitPoint) < MINIMUM_TREE_PANEL_DIMENSION) splitPoint = newWidth - MINIMUM_TREE_PANEL_DIMENSION;  
			
			/*now update the bounds of this panel node*/
			originX = newOriginX;
			originY = newOriginY;
			width = newWidth;
			height = newHeight;
			
			/*now force update the bounds of the two children:*/
			childA->changePanelNodeBounds(originX, originY, (int)(splitPoint), height);
			childB->changePanelNodeBounds(originX + splitPoint, originY, width - (int)(splitPoint), height);
		}
	}
	
	/*update the panelTreeDescNode with the new size:*/
	this->setPanelTreeDescNode();
}








/*
	requestSplit
 
	The caller calls this method with an arbitrary vertical or horizontal line in the area defined by this panel. IF this line crosses a leaf panel at (this panel or at a level below), all the way across and doesn't 'stick out' too much beyond that panel's edges, then the panel will be split into two
	This method *assumes* that the line passed in is either perfectly horizontal or perfectly vertical, and that in the line's dimension, the end points are in *increasing order*, e.g. in a horizontal line, p1's x coord is less than p2's x coord
	Returns the address of the new child node's panelDesc for a success, 0 for a failure
 */
int panelTree::requestSplit(int p1x, int p1y, int p2x, int p2y, int splitDimension)
{
	panelTree *panelToSplit;
	int panelTreeDescNodeAddrToReturn;
	
	/*if a valid panel leaf node was found, then ask it to split:*/
	if(this->isValidSplitLine(this, splitDimension, p1x, p1y, p2x, p2y, &panelToSplit) == 1)
	{
		if(splitDimension == 0) panelTreeDescNodeAddrToReturn = panelToSplit->split(0, p1y-panelToSplit->originY);
		if(splitDimension == 1) panelTreeDescNodeAddrToReturn = panelToSplit->split(1, p1x-panelToSplit->originX);
		return panelTreeDescNodeAddrToReturn;
	}
	
	return 0;
}


/*
	verifyPanelSplitLocation
		
	Given a directed segment, this method traverses the panel tree to see if it closely overlaps a split between panels. 
	If it does, the method returns the panelId of that panel. If not, it returns -1;
	It also calculates how much space the split has to move around in its panel - so as not to reduce the child/grandchlid etc panels to zero size or worse. This info is returned via the 'splitMinimumShift' and 'splitMaximumShift' arguments;
	On top of this, it returns via 'affectedPanels' and 'numberOfAffectedPanels', an array of pointers to the panelTreeDesc's of all the panels/nodes that would be affected by movement of the split in question
	N.B. it is the responsibility of the caller to free the array mentioned above.
*/
int panelTree::verifyPanelSplitLocation(int shiftDimension, int shiftLocation, int shiftStartPoint, int shiftEndPoint, int *splitMinimumShift, int *splitMaximumShift, panelTreeDesc ***affectedPanels, int *numberOfAffectedPanels)
{
	/*if this (presumably) top-level node is a leaf, then it is not possible to overlap a split, as there aren't any, so fail:*/
	if(this->isLeafNode() == 1) return -1;
	
	/*first do the geometric testing required to determine whether these coordinate points actually coincide with a panel split:*/
	int splitTestResult = this->isCloseToPanelSplit(this, shiftDimension, shiftLocation, shiftStartPoint, shiftEndPoint, splitMinimumShift, splitMaximumShift);
	
	/*if not, return failure:*/
	if(splitTestResult == -1) return -1;
	
	/*if so, then create an array of pointers to the panel tree nodes which are affected by the split line in question:*/
	if(splitTestResult != -1)
	{
		/*find out how many affected nodes there are:*/
		int numberOfAffectedNodes = 0;
		traverseTree(linearStructure[splitTestResult], 0, NULL, &numberOfAffectedNodes);
		
		/*allocate memory for an array of pointers to the panelTreeDesc's of said affected nodes:*/
		*affectedPanels = (panelTreeDesc **)malloc(numberOfAffectedNodes * sizeof(panelTreeDesc *));
		
		/*fill this allocated array with the pointers:*/
		*numberOfAffectedPanels = 0;
		traverseTreeToGetArrayOfAllNodesDescNodes(linearStructure[splitTestResult], *affectedPanels, numberOfAffectedPanels);
		
		/*now compute the amount of freedom the split has to move - expressed as a minimum/maximum split location value. (respectively determined by the sum of the minimum acceptable width/height for the descendant nodes above/below this node's split)*/
		if(linearStructure[splitTestResult]->splitDimension == 0)
		{
			*splitMinimumShift = linearStructure[splitTestResult]->originY + (MINIMUM_TREE_PANEL_DIMENSION * (linearStructure[splitTestResult]->childA->determineNumberOfSplitsInGivenDimensionBelowSelf(shiftDimension) + 1));
			*splitMaximumShift = linearStructure[splitTestResult]->originY + linearStructure[splitTestResult]->height - (MINIMUM_TREE_PANEL_DIMENSION * (linearStructure[splitTestResult]->childB->determineNumberOfSplitsInGivenDimensionBelowSelf(shiftDimension) + 1));
		}
		else
		{
			*splitMinimumShift = linearStructure[splitTestResult]->originX + (MINIMUM_TREE_PANEL_DIMENSION * (linearStructure[splitTestResult]->childA->determineNumberOfSplitsInGivenDimensionBelowSelf(shiftDimension) + 1));
			*splitMaximumShift = linearStructure[splitTestResult]->originX + linearStructure[splitTestResult]->width - (MINIMUM_TREE_PANEL_DIMENSION * (linearStructure[splitTestResult]->childB->determineNumberOfSplitsInGivenDimensionBelowSelf(shiftDimension) + 1));
		}
		
		return splitTestResult;
	}
}


/*
	specifyNewSplitLocationForSubPanel
 
	This method takes a panelId specifiying a panel whose split is to move location, and the offset from its current location to new said location. Method then finds the panel from its Id, and updates its and all its childrens' geometric info to reflect this change
*/
void panelTree::specifyNewSplitLocationForSubPanel(int panelIdForSplit, int newSplitLocation)
{
	/*get pointer to the actual panel whose split is to be relocated:*/
	panelTree *panelWhoseSplitToMove = rootNode->linearStructure[panelIdForSplit];
	int shiftOffset;
	
	/*If panel has horizontal split:*/
	if(panelWhoseSplitToMove->splitDimension == 0)
	{
		/*update panel's split info:*/
		shiftOffset = newSplitLocation - (panelWhoseSplitToMove->originY + panelWhoseSplitToMove->splitPoint);
		panelWhoseSplitToMove->splitPoint = panelWhoseSplitToMove->splitPoint + shiftOffset;
		
		/*update the panel's children:*/
		panelWhoseSplitToMove->childA->changePanelNodeBounds(panelWhoseSplitToMove->childA->originX,panelWhoseSplitToMove->childA->originY,panelWhoseSplitToMove->childA->width,panelWhoseSplitToMove->childA->height + shiftOffset);
		panelWhoseSplitToMove->childB->changePanelNodeBounds(panelWhoseSplitToMove->childB->originX,panelWhoseSplitToMove->childB->originY + shiftOffset, panelWhoseSplitToMove->childB->width, panelWhoseSplitToMove->childB->height - shiftOffset);
	}
		
	/*if vertical split:*/
	else 
	{
		/*update panel's split info:*/
		shiftOffset = newSplitLocation - (panelWhoseSplitToMove->originX + panelWhoseSplitToMove->splitPoint);
		panelWhoseSplitToMove->splitPoint = panelWhoseSplitToMove->splitPoint + shiftOffset;
		
		/*update the panel's subviews:*/
		panelWhoseSplitToMove->childA->changePanelNodeBounds(panelWhoseSplitToMove->childA->originX,panelWhoseSplitToMove->childA->originY,panelWhoseSplitToMove->childA->width + shiftOffset,panelWhoseSplitToMove->childA->height);
		panelWhoseSplitToMove->childB->changePanelNodeBounds(panelWhoseSplitToMove->childB->originX + shiftOffset,panelWhoseSplitToMove->childB->originY, panelWhoseSplitToMove->childB->width - shiftOffset, panelWhoseSplitToMove->childB->height);
	}
}


/*
 queryRemovalOfPanel
 
 given a panelId, this method removes said panel from the tree and returns 1 for a success.
 To remove the panel, it is completely deleted, and its sibling will fill the whole space of the parent node, previously occupied by both the sibling and the panel in question.
 N.B. will only work if the panel in question is a leaf node.
 N.N.B *THIS METHOD ALLOCATES MEMORY FOR THE 'affectedNodes' ARRAY. IT IS THE RESPONSIBILITY OF THE CALLER TO FREE THIS*
 */
int panelTree::queryRemovalOfPanel(int panelIdOfPanel, int *numberOfAffectedNodes, panelTreeDesc ***affectedNodes)
{
	panelTree *panelToRemove;
	panelTree *panelSibling;
	
	/*if panelId is somehow invalid, fail:*/
	if(panelIdOfPanel >= linearStructureLength) return 0;
	
	/*get direct pointer to panel to remove:*/
	panelToRemove = rootNode->linearStructure[panelIdOfPanel];
	
	/*if this is not a leaf, fail:*/
	if(panelToRemove->isLeafNode() == 0) return 0;
	
	/*get pointer to panel's sibling:*/
	if((panelToRemove->parent)->childA == panelToRemove) panelSibling = (panelToRemove->parent)->childB;
	else panelSibling = (panelToRemove->parent)->childA;
	
	/*return to the caller a list of the remaining panels that are affected by this, i.e. the sibling panel and any descendants. Do this by returning a list of the panels' desc nodes:*/
	*numberOfAffectedNodes = 0;
	traverseTree(panelSibling, 0, NULL, numberOfAffectedNodes);
	*(affectedNodes) = (panelTreeDesc **)malloc(*(numberOfAffectedNodes) * sizeof(panelTreeDesc *));
	
	int count = 0;
	traverseTreeToGetArrayOfAllNodesDescNodes(panelSibling, *affectedNodes, &count);
	
	return 1;
}



/*
	requestRemovalOfPanel
 
	given a panelId, this method removes said panel from the tree and returns 1 for a success.
	To remove the panel, it is completely deleted, and its sibling will fill the whole space of the parent node, previously occupied by both the sibling and the panel in question.
	N.B. will only work if the panel in question is a leaf node.
*/
int panelTree::requestRemovalOfPanel(int panelIdOfPanel)
{
	panelTree *panelToRemove;
	panelTree *panelSibling;
	
	/*if panelId is somehow invalid, fail:*/
	if(panelIdOfPanel >= linearStructureLength) return 0;
	
	/*get direct pointer to panel to remove:*/
	panelToRemove = rootNode->linearStructure[panelIdOfPanel];
	
	/*if this is not a leaf, fail:*/
	if(panelToRemove->isLeafNode() == 0) return 0;
	
	/*get pointer to panel's sibling:*/
	if((panelToRemove->parent)->childA == panelToRemove) panelSibling = (panelToRemove->parent)->childB;
	else panelSibling = (panelToRemove->parent)->childA;


	
	/*If the sibling is not also a leaf, then resize it to cover both panels, (i.e. to match its parent's size, it will disappear and its parent will take over), and link the parent straight to the sibling's children. If it is a leaf, simply remove it:*/
	if(panelSibling->isLeafNode() == 0)
	{
		panelSibling->changePanelNodeBounds(panelToRemove->parent->originX,panelToRemove->parent->originY,panelToRemove->parent->width,panelToRemove->parent->height);
		
		panelToRemove->parent->childA = panelSibling->childA;
		panelToRemove->parent->childB = panelSibling->childB;
		panelToRemove->parent->splitDimension = panelSibling->splitDimension;
		panelToRemove->parent->splitPoint = panelSibling->splitPoint;
		
		panelSibling->childA->parent = panelToRemove->parent;
		panelSibling->childB->parent = panelToRemove->parent;
	}
	
	else 
	{
		panelToRemove->parent->childA = NULL;
		panelToRemove->parent->childB = NULL;
	}

	/*either way, because the parent takes over the sibling's identity, it must be given its panelTreeDescNode:*/
	//printf();
	panelToRemove->parent->panelTreeDescNode = panelSibling->panelTreeDescNode;
	panelToRemove->parent->setPanelTreeDescNode();
	panelSibling->panelTreeDescNode = NULL;

	
	/*By now, the panel and its sibling have been decoupled from the tree, and it is safe to just remove them:*/
	delete panelToRemove;
	delete panelSibling;

	
	/*Now that one generation in the hierarchy has been destroyed, the tree's linear structure will need rebuiling:*/
	rootNode->rebuildLinearStructure();
	
	return 1;
}


void panelTree::traverseTreeToGetArrayOfAllNodesDescNodes(panelTree *node, panelTreeDesc **descNodeArray, int *count)
{
	/*if this is a leaf node, record it:*/
	if(node->isLeafNode() == 1)
	{
		descNodeArray[(*count)] = node->panelTreeDescNode;
		*count = *count + 1;
	}
	
	/*if not, keep traversing to find the leaves:*/
	else
	{
		if(node->childA!= NULL) traverseTreeToGetArrayOfAllNodesDescNodes(node->childA, descNodeArray, count);
		if(node->childB!= NULL) traverseTreeToGetArrayOfAllNodesDescNodes(node->childB, descNodeArray, count); 
	}
}


/*
	getRootPanelTreeDescNodePointer
 
	simply returns the address of the root node's panelTreeDescNode
*/
int panelTree::getRootPanelTreeDescNodePointer()
{
	return (int)(rootNode->panelTreeDescNode);
}


/*
	printStateOfTree
 
	Essentially for a health check. This function prints out the entire internal state, both hierarchical and linear, of the tree.
	This can only be called on the root node
*/
void panelTree::printStateOfTree()
{
	/*Ensure that this is the root node:*/
	if(rootNode != this) return;
	
	printf("\n\n####################################################################################################\n####################################################################################################\n\n\nPanel Tree Health Check. The depth of the tree is: %d\n\n\n\n",currentTreeDepth);
	
	printf("Root Node.\n\n\tAddress: %d \n\tPanelId: %d \n\tOriginX: %d \n\tOriginY: %d \n\twidth: %d \n\theight: %d \n\tdepth: %d \n\tisLeafNode? %d \n\tsplitDimension: %d \n\tsplitPoint: %f \n\tchildA: %d \n\tchildB: %d \n\tparent: %d \n\trootNode: %d  \n\n\n\n",this, panelId, originX, originY, width, height, depth, this->isLeafNode(), splitDimension, splitPoint, childA, childB, parent, rootNode);
	
	traverseTree(this,3,NULL,NULL);
	
	printf("\n\nThe tree's depth of %d means that the linear structure is %d nodes long:\n\n", currentTreeDepth, linearStructureLength);
	for(int i = 0; i<linearStructureLength; i++)
	{
		if(linearStructure[i] == NULL) printf("\tNode #%d in linear structure is NULL\n",i);
		else printf("\tNode #%d in linear structure has address: %d\n", i, linearStructure[i]);
	}
	
	printf("\n\n");
}


/*
	Destructor.
*/
panelTree::~panelTree()
{
	/*free the panel tree desc node, if this object has one:*/
	if(panelTreeDescNode != NULL) free(panelTreeDescNode);
	
	/*If this is the root node, then the entire structure needs to be freed:*/
	if(rootNode == this)
	{
		free(linearStructure);
		traverseTree(this,2,NULL,NULL);
	}
}