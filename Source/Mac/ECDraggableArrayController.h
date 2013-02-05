
// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 16/06/11
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

ECDeclareDebugChannel(ECDraggableArrayControllerChannel);

@interface ECDraggableArrayController : NSArrayController<NSCollectionViewDelegate>

@property (assign, nonatomic) BOOL canCopy;
@property (strong, nonatomic) IBOutlet NSCollectionView* collection;
@property (strong, nonatomic) NSArray* supportedTypes;
@property (strong, nonatomic) IBOutlet NSTableView* table;

// --------------------------------------------------------------------------
// Methods That Subclasses Can Extend (should call super)
// --------------------------------------------------------------------------

- (NSDragOperation)localSourceMaskToUse;
- (NSDragOperation)remoteSourceMaskToUse;
- (NSArray*)typesToRegister;
- (NSArray*)typesToDragForRows:(NSIndexSet*)rowIndexes;
- (void)writeDataOfType:(NSString*)type toPasteboard:(NSPasteboard*)pasteboard forRows:(NSIndexSet*)rowIndexes;
- (BOOL)performMoveToIndex:(NSUInteger)index withPasteboard:(NSPasteboard*)pasteboard;
- (BOOL)performLocalCopyToIndex:(NSUInteger)index withPasteboard:(NSPasteboard*)pasteboard;
- (BOOL)performRemoteCopyToIndex:(NSUInteger)index withPasteboard:(NSPasteboard*)pasteboard;

@end


