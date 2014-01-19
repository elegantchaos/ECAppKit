// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDraggableArrayController.h"

@implementation ECDraggableArrayController

ECDefineDebugChannel(ECDraggableArrayControllerChannel);

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (_itemsController)
        _itemsController = [self makeItemsControllerForTableView:tableView];
}

-(ECDraggableItemsController*)makeItemsControllerForTableView:(NSTableView*)tableView
{
    return [ECDraggableItemsController itemsControllerForContentController:self view:tableView];
}

// --------------------------------------------------------------------------
//! Handle start of a drag.
// --------------------------------------------------------------------------

- (BOOL)tableView:(NSTableView*)view writeRowsWithIndexes:(NSIndexSet*)indexes toPasteboard:(NSPasteboard*)pasteboard
{
	BOOL result = [self.itemsController writeItemsWithIndexes:indexes toPasteboard:pasteboard view:view];
	
	return result;
}

// --------------------------------------------------------------------------
//! Validate a drop operation.
// --------------------------------------------------------------------------

- (NSDragOperation)tableView:(NSTableView*)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
	ECDebug(ECDraggableArrayControllerChannel, @"validate drop");
    NSDragOperation result = [self.itemsController validateDrop:info proposedItem:nil proposedChildIndex:row view:tableView];
    [tableView setDropRow:row dropOperation:NSTableViewDropAbove];
	
    return result;
}

// --------------------------------------------------------------------------
//! Accept a drop operation.
// --------------------------------------------------------------------------

- (BOOL)tableView:(NSTableView*)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op
{
	BOOL result = [self.itemsController acceptDrop:info item:nil childIndex:row view:tableView];
	
	return result;
}

#pragma mark - NSCollectionViewDelegate Drag & Drop Methods

- (NSDragOperation)collectionView:(NSCollectionView*)collectionView validateDrop:(id<NSDraggingInfo>)info proposedIndex:(NSInteger*)proposedDropIndex dropOperation:(NSCollectionViewDropOperation*)proposedDropOperation
{
	ECDebug(ECDraggableArrayControllerChannel, @"validate drop");
	NSDragOperation result = [self.itemsController validateDrop:info proposedItem:nil proposedChildIndex:*proposedDropIndex view:collectionView];
    return result;

}

- (BOOL)collectionView:(NSCollectionView*)collectionView writeItemsAtIndexes:(NSIndexSet*)indexes toPasteboard:(NSPasteboard *)pasteboard
{
    BOOL result = [self.itemsController writeItemsWithIndexes:indexes toPasteboard:pasteboard view:collectionView];
    
    return result;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id <NSDraggingInfo>)info index:(NSInteger)index dropOperation:(NSCollectionViewDropOperation)operation
{
	BOOL result = [self.itemsController acceptDrop:info item:nil childIndex:index view:collectionView];
	
	return result;
}

- (void)moveItemsFromIndexSet:(NSIndexSet*)fromIndexSet toIndexes:(NSIndexSet*)destinationIndexes
{
    NSArray *objectsToMove = [[self arrangedObjects] objectsAtIndexes:fromIndexSet];
    [self removeObjectsAtArrangedObjectIndexes:fromIndexSet];
    [self insertObjects:objectsToMove atArrangedObjectIndexes:destinationIndexes];
}

- (NSArray*)objectsAtIndexes:(NSIndexSet *)indexes
{
    NSArray* items = [[self arrangedObjects] objectsAtIndexes:indexes];
    return items;
}

@end

