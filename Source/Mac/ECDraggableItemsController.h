// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

@protocol ECDraggableItemContentController <NSObject>
- (NSArray*)objectsAtIndexes:(NSIndexSet*)indexes;
- (BOOL)setSelectionIndexes:(NSIndexSet *)indexes;
- (void)moveItemsFromIndexSet:(NSIndexSet*)fromIndexSet toIndexes:(NSIndexSet*)destinationIndexes;
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
- (NSArray*)typesToDragForRows:(NSIndexSet*)rowIndexes;
- (BOOL)writeItemsWithIndexes:(NSIndexSet*)indexes toPasteboard:(NSPasteboard*)pasteboard view:(NSView*)view;
- (BOOL)acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index view:(NSView*)view;
- (NSDragOperation)validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index view:(NSView*)view;
- (void)writeDataOfType:(NSString*)type toPasteboard:(NSPasteboard*)pasteboard forRows:(NSIndexSet*)rowIndexes;

@end


