// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

@protocol ECDraggableItemContentController <NSObject>
- (NSArray*)itemsAtIndexes:(NSSet*)indexes;
- (BOOL)setSelection:(NSSet*)indexes;
- (NSSet*)moveObjectsFromIndexes:(NSSet*)fromIndexSet toIndexPath:(NSIndexPath*)path;
- (NSSet*)indexesOfItemsAtIndexes:(NSSet*)indexes thatCanWriteType:(NSString*)type;
@end

@protocol ECDraggableItem <NSObject>
- (BOOL)canWriteType:(NSString*)type;
@end

@interface ECDraggableItemsController : NSObject

@property (assign, nonatomic) BOOL canCopy;
@property (strong, nonatomic) NSArray* supportedTypes;
@property (strong, nonatomic) id<ECDraggableItemContentController> contentController;

// --------------------------------------------------------------------------
// Methods That Subclasses Can Extend (should call super)
// --------------------------------------------------------------------------

+ (ECDraggableItemsController*)itemsControllerForContentController:(id<ECDraggableItemContentController>)contentController view:(id)view;
- (NSDragOperation)localSourceMaskToUse;
- (NSDragOperation)remoteSourceMaskToUse;
- (NSArray*)typesToRegister;

/**
 Return types to write when starting a drag of some items.
 */

- (NSArray*)typesToDragForIndexes:(NSSet*)indexes;

- (BOOL)writeItemsWithIndexes:(NSSet*)indexes toPasteboard:(NSPasteboard*)pasteboard view:(NSView *)view;
- (BOOL)acceptDrop:(id <NSDraggingInfo>)info index:(NSIndexPath*)index view:(NSView*)view;
- (NSDragOperation)validateDrop:(id <NSDraggingInfo>)info proposedIndex:(NSIndexPath*)proposedIndex view:(NSView*)view;

/**
 Write data of a particular type to a pasteboard for some rows.
 */

- (void)writeDataOfType:(NSString*)type toPasteboard:(NSPasteboard*)pasteboard forIndexes:(NSSet*)indexes;

@end


