// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDraggableTreeController.h"
#import "ECDraggableItemsController.h"

@implementation ECDraggableTreeController

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	return NSDragOperationMove;
}

-(ECDraggableItemsController*)makeItemsControllerForTableView:(NSOutlineView*)outlineView
{
    return [ECDraggableItemsController itemsControllerForContentController:self view:outlineView];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
    NSMutableIndexSet* indexSet = [NSMutableIndexSet new];
    for (NSTreeNode* item in items)
        [indexSet addIndex:item.indexPath];
    // TODO: make indexSet from items
    return [self.itemsController writeItemsWithIndexes:indexSet toPasteboard:pasteboard view:outlineView];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index
{
    return [self.itemsController acceptDrop:info item:item childIndex:index view:outlineView];
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    NSDragOperation result = [self.itemsController validateDrop:info proposedItem:item proposedChildIndex:index view:outlineView];

    return result;
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(NSTreeNode*)item
{
    if (!_itemsController)
    {
        _itemsController = [ECDraggableItemsController itemsControllerForContentController:self view:outlineView];
    }

    NSCell* result = [tableColumn dataCell];
    result.representedObject = [item representedObject];
    
    return result;
}

- (BOOL)setSelectionIndexes:(NSIndexSet *)indexes
{
//    return [super setSelectionIndexPaths:[indexes ]]
    return YES;
}

- (void)moveItemsFromIndexSet:(NSIndexSet*)fromIndexSet toIndexes:(NSIndexSet*)destinationIndexes
{
//    NSArray *objectsToMove = [[self arrangedObjects] objectsAtIndexes:fromIndexSet];
//	[self removeObjectsAtArrangedObjectIndexes:fromIndexSet];
//	[self insertObjects:objectsToMove atArrangedObjectIndexes:destinationIndexes];
}

- (NSArray*)objectsAtIndexes:(NSIndexSet *)indexes
{
    NSArray* items = [[self arrangedObjects] objectsAtIndexes:indexes];
    return items;
}


@end
