// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDraggableFileArrayController.h"
#import "ECDraggableFileItemsController.h"

@implementation ECDraggableFileArrayController

     
-(ECDraggableItemsController*)makeItemsControllerForTableView:(NSTableView*)tableView
{
    return [ECDraggableFileItemsController itemsControllerForContentController:self view:tableView];
}

- (ECDraggableFileItemsController*)fileItemsController
{
    return (ECDraggableFileItemsController*)self.itemsController;
}

// --------------------------------------------------------------------------
//! Handle drop of files from a table.
// --------------------------------------------------------------------------

- (NSArray*)tableView:(NSTableView*)tableView namesOfPromisedFilesDroppedAtDestination:(NSURL*)destination forDraggedRowsWithIndexes:(NSIndexSet*)indexSet
{
    NSSet* indexes = [self indexSetAsSet:indexSet];
	NSArray* result = [self.fileItemsController namesOfPromisedFilesDroppedAtDestination:destination forDraggedRowsWithIndexes:indexes view:tableView];
	
	return result;
}

// --------------------------------------------------------------------------
//! Handle drop of files form a collection view.
// --------------------------------------------------------------------------

- (NSArray *)collectionView:(NSCollectionView*)collectionView namesOfPromisedFilesDroppedAtDestination:(NSURL*)destination forDraggedItemsAtIndexes:(NSIndexSet *)indexSet
{
    NSSet* indexes = [self indexSetAsSet:indexSet];
	NSArray* result = [self.fileItemsController namesOfPromisedFilesDroppedAtDestination:destination forDraggedRowsWithIndexes:indexes view:collectionView];
	
	return result;
}

@end

