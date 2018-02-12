// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDraggableTreeController.h"
#import "ECDraggableItemsController.h"

ECDefineDebugChannel(ECDraggableTreeControllerChannel);

@implementation ECDraggableTreeController

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	return NSDragOperationMove;
}
#pragma clang diagnostic pop

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
    BOOL result = [self.itemsController acceptDrop:info index:childPath view:outlineView];
    
    return result;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    NSIndexPath* path = item ? [item indexPath] : [NSIndexPath new];
    NSIndexPath* childPath = [path indexPathByAddingIndex:index];
    NSDragOperation result = [self.itemsController validateDrop:info proposedIndex:childPath view:outlineView];

    return result;
}

- (ECDraggableItemsController*)makeItemsControllerForView:(NSView*)view
{
    return [ECDraggableItemsController itemsControllerForContentController:self view:view];
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(NSTreeNode*)item
{
    if (!_itemsController)
    {
        _itemsController = [self makeItemsControllerForView:outlineView];
        ECDebug(ECDraggableTreeControllerChannel, @"created items controller %@", _itemsController);
    }

    NSCell* result = [tableColumn dataCell];
    result.representedObject = [item representedObject];
    
    return result;
}

- (NSArray*)nodesAtIndexes:(NSSet *)indexes
{
    NSMutableArray* result = [NSMutableArray array];
    id objects = self.arrangedObjects;
    for (NSIndexPath* path in indexes)
    {
        NSTreeNode* object = [objects descendantNodeAtIndexPath:path];
        [result addObject:object];
    }
    
    return result;
}

- (NSArray*)itemsAtIndexes:(NSSet *)indexes
{
    NSMutableArray* result = [NSMutableArray array];
    id objects = self.arrangedObjects;
    for (NSIndexPath* path in indexes)
    {
        NSTreeNode* object = [objects descendantNodeAtIndexPath:path];
        [result addObject:object.representedObject];
    }
    
    return result;
}

- (NSSet*)indexesOfItemsAtIndexes:(NSSet *)indexes thatCanWriteType:(NSString *)type
{
    NSMutableSet* result = [NSMutableSet new];
    NSArray* nodes = [self nodesAtIndexes:indexes];
    for (NSTreeNode* node in nodes)
    {
        id item = node.representedObject;
        if ([item respondsToSelector:@selector(canWriteType:)])
            if ([item canWriteType:type])
                [result addObject:node.indexPath];
    }
    
    return result;
}

- (BOOL)setSelection:(NSSet *)indexes
{
    return [self setSelectionIndexPaths:[indexes allObjects]];
}

- (NSSet*)moveObjectsFromIndexes:(NSSet *)fromIndexSet toIndexPath:(NSIndexPath *)path
{
    NSArray* nodes = [self nodesAtIndexes:fromIndexSet];
    [self moveNodes:nodes toIndexPath:path];
    return nil;
}

- (void)insertObjects:(NSArray*)objects atIndexPath:(NSIndexPath*)path
{
    NSIndexPath* basePath = [path indexPathByRemovingLastIndex];
    NSUInteger index = [path indexAtPosition:[path length] - 1];
    NSMutableArray* newIndexes = [NSMutableArray new];
    for (id newItem in objects)
    {
        (void)newItem;
        NSIndexPath* itemPath = [basePath indexPathByAddingIndex:index++];
        [newIndexes addObject:itemPath];
    }
    [self insertObjects:objects atArrangedObjectIndexPaths:newIndexes];
}

@end
