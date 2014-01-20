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
    if (!_itemsController)
        _itemsController = [self makeItemsControllerForView:tableView];
}

-(ECDraggableItemsController*)makeItemsControllerForView:(NSView*)tableView
{
    return [ECDraggableItemsController itemsControllerForContentController:self view:tableView];
}

// --------------------------------------------------------------------------
//! Handle start of a drag.
// --------------------------------------------------------------------------

- (BOOL)tableView:(NSTableView*)view writeRowsWithIndexes:(NSIndexSet*)indexSet toPasteboard:(NSPasteboard*)pasteboard
{
    NSSet* indexes = [self indexSetAsSet:indexSet];
	BOOL result = [self.itemsController writeItemsWithIndexes:indexes toPasteboard:pasteboard view:view];
	
	return result;
}

// --------------------------------------------------------------------------
//! Validate a drop operation.
// --------------------------------------------------------------------------

- (NSDragOperation)tableView:(NSTableView*)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
	ECDebug(ECDraggableArrayControllerChannel, @"validate drop");
    if (row < 0)
        row = 0;
    
    NSIndexPath* index = [NSIndexPath indexPathWithIndex:row];
    NSDragOperation result = [self.itemsController validateDrop:info proposedIndex:index view:tableView];
    [tableView setDropRow:row dropOperation:NSTableViewDropAbove];
	
    return result;
}

// --------------------------------------------------------------------------
//! Accept a drop operation.
// --------------------------------------------------------------------------

- (BOOL)tableView:(NSTableView*)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op
{
    NSIndexPath* index = [NSIndexPath indexPathWithIndex:row];
	BOOL result = [self.itemsController acceptDrop:info index:index view:tableView];
	
	return result;
}

#pragma mark - NSCollectionViewDelegate Drag & Drop Methods

- (NSDragOperation)collectionView:(NSCollectionView*)collectionView validateDrop:(id<NSDraggingInfo>)info proposedIndex:(NSInteger*)proposedDropIndex dropOperation:(NSCollectionViewDropOperation*)proposedDropOperation
{

	ECDebug(ECDraggableArrayControllerChannel, @"validate drop");
    if (*proposedDropIndex < 0)
        *proposedDropIndex = 0;
    
    NSIndexPath* index = [NSIndexPath indexPathWithIndex:*proposedDropIndex];
	NSDragOperation result = [self.itemsController validateDrop:info proposedIndex:index view:collectionView];
    return result;

}

- (BOOL)collectionView:(NSCollectionView*)collectionView writeItemsAtIndexes:(NSIndexSet*)indexSet toPasteboard:(NSPasteboard *)pasteboard
{
    if (!_itemsController)
        _itemsController = [self makeItemsControllerForView:collectionView];

    NSSet* indexes = [self indexSetAsSet:indexSet];
    BOOL result = [self.itemsController writeItemsWithIndexes:indexes toPasteboard:pasteboard view:collectionView];
    
    return result;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id <NSDraggingInfo>)info index:(NSInteger)index dropOperation:(NSCollectionViewDropOperation)operation
{
    NSIndexPath* path = [NSIndexPath indexPathWithIndex:index];
	BOOL result = [self.itemsController acceptDrop:info index:path view:collectionView];
	
	return result;
}

- (BOOL)setSelection:(NSSet*)indexes
{
    NSIndexSet* indexSet = [self indexesAsIndexSet:indexes];
    return [self setSelectionIndexes:indexSet];
}

-(NSSet*)moveObjectsFromIndexes:(NSSet*)fromIndexes toIndexPath:(NSIndexPath *)path
{
    NSInteger insertIndex = [path indexAtPosition:0];
    NSIndexSet* fromIndexSet = [self indexesAsIndexSet:fromIndexes];
	// If any of the removed objects come before the insertion index,
	// we need to decrement the index appropriately
	NSUInteger adjustedInsertIndex =
	insertIndex - [fromIndexSet countOfIndexesInRange:(NSRange){0, insertIndex}];
	NSRange destinationRange = NSMakeRange(adjustedInsertIndex, [fromIndexSet count]);
	NSIndexSet *destinationIndexes = [NSIndexSet indexSetWithIndexesInRange:destinationRange];
	
    NSArray *objectsToMove = [[self arrangedObjects] objectsAtIndexes:fromIndexSet];
    [self removeObjectsAtArrangedObjectIndexes:fromIndexSet];
    [self insertObjects:objectsToMove atArrangedObjectIndexes:destinationIndexes];

	NSSet* result = [self indexSetAsSet:destinationIndexes];
	return result;
}

- (NSArray*)itemsAtIndexes:(NSSet*)indexes
{
    NSIndexSet* indexSet = [self indexesAsIndexSet:indexes];
    NSArray* items = [[self arrangedObjects] objectsAtIndexes:indexSet];
    return items;
}

- (NSSet*)indexSetAsSet:(NSIndexSet*)indexSet
{
    NSUInteger count = [indexSet count];
    NSMutableSet* result = [NSMutableSet setWithCapacity:count];
    [indexSet enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        NSUInteger last = range.location + range.length;
        for (NSUInteger n = range.location; n < last; ++n)
        {
            [result addObject:[NSIndexPath indexPathWithIndex:n]];
        }
    }];
    
    return result;
}

- (NSIndexSet*)indexesAsIndexSet:(NSSet*)indexes
{
    NSMutableIndexSet* result = [NSMutableIndexSet new];
    for (NSIndexPath* path in indexes)
    {
        [result addIndex:[path indexAtPosition:0]];
    }
    
    return result;
}
@end

