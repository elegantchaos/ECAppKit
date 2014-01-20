// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDraggableItemsController.h"

NSString *const ItemIndexesType = @"com.elegantchaos.ecappkit.rowindexes";

@interface ECDraggableItemsController()
@property (strong, nonatomic) NSSet* sourceIndexes;
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
    return [NSArray arrayWithObject:ItemIndexesType];
}

- (NSArray*)typesToDragForIndexes:(NSSet *)indexes
{
    return [NSArray arrayWithObject:ItemIndexesType];
}

- (void)writeDataOfType:(NSString*)type toPasteboard:(NSPasteboard*)pasteboard forIndexes:(NSSet*)indexes
{
    if ([type isEqualToString:ItemIndexesType])
    {
        ECDebug(ECDraggableItemsControllerChannel, @"writing row indexes");
        
        NSData* itemIndexesArchive = [NSKeyedArchiver archivedDataWithRootObject:indexes];
        [pasteboard setData:itemIndexesArchive forType:ItemIndexesType];
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

- (BOOL)performMoveToIndex:(NSIndexPath*)index withPasteboard:(NSPasteboard*)pasteboard
{
    NSData* rowsData = [pasteboard dataForType:ItemIndexesType];
    NSSet* indexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowsData];
    
    NSSet* destinationIndexes = [self.contentController moveObjectsFromIndexes:indexes toIndexPath:index];
    [self.contentController setSelection:destinationIndexes];
    
    ECDebug(ECDraggableItemsControllerChannel, @"moved items %@ to %@", indexes, destinationIndexes);
    
    return YES;
}

// --------------------------------------------------------------------------
//! Perform a local copy of some rows.
// --------------------------------------------------------------------------

- (BOOL)performLocalCopyToIndex:(NSIndexPath*)index withPasteboard:(NSPasteboard*)pasteboard
{
    ECDebug(ECDraggableItemsControllerChannel, @"copied items");
    
    return NO;
}

// --------------------------------------------------------------------------
//! Perform a remote copy of some data from elsewhere.
// --------------------------------------------------------------------------

- (BOOL)performRemoteCopyToIndex:(NSIndexPath*)index withPasteboard:(NSPasteboard*)pasteboard
{
    ECDebug(ECDraggableItemsControllerChannel, @"accepted drop for table");
    
    return NO;
}

- (BOOL)destination:(NSIndexPath*)destination containsIndexes:(NSSet*)indexes
{
    BOOL result = NO;
    NSUInteger destinationLength = destination.length;
    for (NSIndexPath* path in indexes)
    {
        NSUInteger pathLength = path.length;
        if (pathLength < destinationLength)
        {
            // if the item is being copied into itself, the whole path will match the destination path - we shouldn't allow this
            result = YES;
            for (NSUInteger n = 0; n < pathLength; ++n)
            {
                if ([path indexAtPosition:n] != [destination indexAtPosition:n])
                {
                    result = NO;
                    break;
                }
            }
        }
        
        if (result)
            break;
    }
    
    return result;
}

- (NSDragOperation)validateDrop:(id <NSDraggingInfo>)info proposedIndex:(NSIndexPath *)proposedIndex view:(NSView *)view
{
	ECDebug(ECDraggableItemsControllerChannel, @"validate drop");
    
    NSDragOperation result = NSDragOperationNone;
    if (![self destination:proposedIndex containsIndexes:self.sourceIndexes])
    {
        BOOL isCopy = [self dragIsCopyForView:view info:info];
        result = isCopy ? NSDragOperationCopy : NSDragOperationMove;
    }
    
    return result;
}

- (BOOL)acceptDrop:(id <NSDraggingInfo>)info index:(NSIndexPath *)index view:(NSView *)view
{
	ECDebug(ECDraggableItemsControllerChannel, @"accept drop");
	
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



// --------------------------------------------------------------------------
//! Write some items to a pasteboard.
// --------------------------------------------------------------------------

- (BOOL)writeItemsWithIndexes:(NSSet*)indexes toPasteboard:(NSPasteboard*)pasteboard view:(NSView *)view
{
    self.sourceIndexes = indexes;
    NSArray* types = [self typesToDragForIndexes:indexes];
    [pasteboard declareTypes:types owner:self];
    for (NSString* type in types)
    {
        [self writeDataOfType:type toPasteboard:pasteboard forIndexes:indexes];
    }
    
    return YES;
}

@end

