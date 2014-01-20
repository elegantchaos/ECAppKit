// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDraggableTreeController.h"
#import "ECDraggableItemsController.h"

ECDefineDebugChannel(ECDraggableTreeControllerChannel);

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
    NSArray* paths = [items valueForKey:@"indexPath"];
    NSSet* indexes = [NSSet setWithArray:paths];

    return [self.itemsController writeItemsWithIndexes:indexes toPasteboard:pasteboard view:outlineView];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index
{
    NSIndexPath* path = item ? [item indexPath] : [NSIndexPath new];
    NSIndexPath* childPath = [path indexPathByAddingIndex:index];
    return [self.itemsController acceptDrop:info index:childPath view:outlineView];
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    NSIndexPath* path = item ? [item indexPath] : [NSIndexPath new];
    NSIndexPath* childPath = [path indexPathByAddingIndex:index];
    NSDragOperation result = [self.itemsController validateDrop:info proposedIndex:childPath view:outlineView];

    return result;
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(NSTreeNode*)item
{
    if (!_itemsController)
    {
        _itemsController = [ECDraggableItemsController itemsControllerForContentController:self view:outlineView];
        ECDebug(ECDraggableTreeControllerChannel, @"created items controller %@", _itemsController);
    }

    NSCell* result = [tableColumn dataCell];
    result.representedObject = [item representedObject];
    
    return result;
}

- (NSArray*)itemsAtIndexes:(NSSet *)indexes
{
    NSMutableArray* result = [NSMutableArray array];
    id objects = self.arrangedObjects;
    for (NSIndexPath* path in indexes)
    {
        id object = [objects descendantNodeAtIndexPath:path];
        [result addObject:object];
    }
    
    return result;
}

- (BOOL)setSelectionIndexes:(NSSet *)indexes
{
    return [self setSelectionIndexPaths:[indexes allObjects]];
}

- (NSSet*)moveObjectsFromIndexes:(NSSet *)fromIndexSet toIndexPath:(NSIndexPath *)path
{
    NSArray* nodes = [self itemsAtIndexes:fromIndexSet];
    [self moveNodes:nodes toIndexPath:path];
    return nil;
}


@end
