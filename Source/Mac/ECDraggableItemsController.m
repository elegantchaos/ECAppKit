// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDraggableItemsController.h"

NSString *const RowIndexesType = @"com.elegantchaos.ecappkit.rowindexes";

@interface ECDraggableItemsController()
@end

@implementation ECDraggableItemsController

ECDefineDebugChannel(ECDraggableItemsControllerChannel);

+ (ECDraggableItemsController*)itemsControllerForContentController:(id<ECDraggableItemContentController>)contentController view:(id)view
{
    ECDraggableItemsController* controller = [ECDraggableItemsController new];
    controller.contentController = contentController;
    [controller setupView:view];
    
    return controller;
}

// --------------------------------------------------------------------------
//! Set up the table for dragging.
// --------------------------------------------------------------------------

- (void)setupView:(id)view
{
	NSArray* types = [self typesToRegister];
	NSDragOperation remoteMask = [self remoteSourceMaskToUse];
	NSDragOperation localMask = [self localSourceMaskToUse];
	
    self.supportedTypes = types;
    [view setDraggingSourceOperationMask:remoteMask forLocal:NO];
    [view setDraggingSourceOperationMask:localMask forLocal:YES];
    [view registerForDraggedTypes:self.supportedTypes];
    
    ECDebug(ECDraggableItemsControllerChannel, @"set up view %@ for dragging with types %@", view, self.supportedTypes);
}

// --------------------------------------------------------------------------
//! Return mask to use for local drags.
// --------------------------------------------------------------------------

- (NSDragOperation)localSourceMaskToUse
{
    NSDragOperation mask = NSDragOperationMove;
    if (self.canCopy)
    {
        mask |= NSDragOperationCopy;
    }
    
    return mask;
}

// --------------------------------------------------------------------------
//! Return mask to use for remote drags.
// --------------------------------------------------------------------------

- (NSDragOperation)remoteSourceMaskToUse
{
    return 0;
}

// --------------------------------------------------------------------------
//! Return drag types that we support.
// --------------------------------------------------------------------------

- (NSArray*)typesToRegister
{
    return [NSArray arrayWithObject:RowIndexesType];
}

// --------------------------------------------------------------------------
//! Return types to write when starting a drag of some rows.
// --------------------------------------------------------------------------

- (NSArray*)typesToDragForRows:(NSIndexSet*)rowIndexes
{
    return [NSArray arrayWithObject:RowIndexesType];
}

// --------------------------------------------------------------------------
//! Write data of a particular type to a pasteboard for some rows.
// --------------------------------------------------------------------------

- (void)writeDataOfType:(NSString*)type toPasteboard:(NSPasteboard*)pasteboard forRows:(NSIndexSet*)rowIndexes
{
    if ([type isEqualToString:RowIndexesType])
    {
        ECDebug(ECDraggableItemsControllerChannel, @"writing row indexes");
        
        NSData* rowIndexesArchive = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
        [pasteboard setData:rowIndexesArchive forType:RowIndexesType];
    }
}

// --------------------------------------------------------------------------
//! Is a given drag a copy operation?
// --------------------------------------------------------------------------

- (BOOL)dragIsCopyForView:(NSView*)view info:(id <NSDraggingInfo>)info
{
    // by default we do a copy
    BOOL isCopy = YES;
    
    // if the move is internal, and the option key isn't pressed, we move instead
    if ([info draggingSource] == view)
    {
		NSEvent* currentEvent = [NSApp currentEvent];
		BOOL optionKeyPressed = ([currentEvent modifierFlags] & NSAlternateKeyMask) != 0;
        isCopy = self.canCopy && optionKeyPressed;
    }
    
    return isCopy;
}

// --------------------------------------------------------------------------
//! Perform a move of some rows.
// --------------------------------------------------------------------------

- (BOOL)performMoveToIndex:(NSUInteger)index withPasteboard:(NSPasteboard*)pasteboard
{
    NSData* rowsData = [pasteboard dataForType:RowIndexesType];
    NSIndexSet* indexSet = [NSKeyedUnarchiver unarchiveObjectWithData:rowsData];
    
    NSIndexSet *destinationIndexes = [self moveObjectsInArrangedObjectsFromIndexes:indexSet toIndex:index];
    
    // set selected rows to those that were just moved
    [self.contentController setSelectionIndexes:destinationIndexes];
    
    ECDebug(ECDraggableItemsControllerChannel, @"moved items %@ to %@", indexSet, destinationIndexes);
    
    return YES;
}

// --------------------------------------------------------------------------
//! Perform a local copy of some rows.
// --------------------------------------------------------------------------

- (BOOL)performLocalCopyToIndex:(NSUInteger)index withPasteboard:(NSPasteboard*)pasteboard
{
    ECDebug(ECDraggableItemsControllerChannel, @"copied items");
    
    return NO;
}

// --------------------------------------------------------------------------
//! Perform a remote copy of some data from elsewhere.
// --------------------------------------------------------------------------

- (BOOL)performRemoteCopyToIndex:(NSUInteger)index withPasteboard:(NSPasteboard*)pasteboard
{
    ECDebug(ECDraggableItemsControllerChannel, @"accepted drop for table");
    
    return NO;
}

- (NSDragOperation)validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index view:(NSView*)view
{
	ECDebug(ECDraggableItemsControllerChannel, @"validate drop");
    
    // by default we do a copy
    BOOL isCopy = [self dragIsCopyForView:view info:info];
    NSDragOperation dragOp = isCopy ? NSDragOperationCopy : NSDragOperationMove;
    
    return dragOp;
}

- (BOOL)acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index view:(NSView*)view
{
	ECDebug(ECDraggableItemsControllerChannel, @"accept drop");
	
    if (index < 0)
    {
		index = 0;
	}
    
    NSPasteboard* pasteboard = [info draggingPasteboard];
    if (![self dragIsCopyForView:view info:info])
    {
        return [self performMoveToIndex:index withPasteboard:pasteboard];
    }
    else if (view == [info draggingSource])
    {
        return [self performLocalCopyToIndex:index withPasteboard:pasteboard];
    }
    else
    {
        return [self performRemoteCopyToIndex:index withPasteboard:pasteboard];
    }
}


-(NSIndexSet *) moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)fromIndexSet toIndex:(NSUInteger)insertIndex
{
	// If any of the removed objects come before the insertion index,
	// we need to decrement the index appropriately
	NSUInteger adjustedInsertIndex =
	insertIndex - [fromIndexSet countOfIndexesInRange:(NSRange){0, insertIndex}];
	NSRange destinationRange = NSMakeRange(adjustedInsertIndex, [fromIndexSet count]);
	NSIndexSet *destinationIndexes = [NSIndexSet indexSetWithIndexesInRange:destinationRange];
	
    [self.contentController moveItemsFromIndexSet:fromIndexSet toIndexes:destinationIndexes];
	
	return destinationIndexes;
}

// --------------------------------------------------------------------------
//! Write some items to a pasteboard.
// --------------------------------------------------------------------------

- (BOOL)writeItemsWithIndexes:(NSIndexSet*)indexes toPasteboard:(NSPasteboard*)pasteboard view:(NSView *)view
{
    NSArray* types = [self typesToDragForRows:indexes];
    [pasteboard declareTypes:types owner:self];
    for (NSString* type in types)
    {
        [self writeDataOfType:type toPasteboard:pasteboard forRows:indexes];
    }
    
    return YES;
}

- (BOOL)view:(NSView*)view acceptDrop:(id <NSDraggingInfo>)info index:(NSInteger)index dropOperation:(NSTableViewDropOperation)op
{
	ECDebug(ECDraggableItemsControllerChannel, @"accept drop");
	
    if (index < 0)
    {
		index = 0;
	}
    
    NSPasteboard* pasteboard = [info draggingPasteboard];
    if (![self dragIsCopyForView:view info:info])
    {
        return [self performMoveToIndex:index withPasteboard:pasteboard];
    }
    else if (view == [info draggingSource])
    {
        return [self performLocalCopyToIndex:index withPasteboard:pasteboard];
    }
    else
    {
        return [self performRemoteCopyToIndex:index withPasteboard:pasteboard];
    }
}

@end

