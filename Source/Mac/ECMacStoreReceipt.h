// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
// --------------------------------------------------------------------------

@interface ECMacStoreReceipt : NSObject

// --------------------------------------------------------------------------
// Public Properties
// --------------------------------------------------------------------------

@property (strong, nonatomic) NSDictionary* info;

// --------------------------------------------------------------------------
// Public Methods
// --------------------------------------------------------------------------

- (id)initWithURL:(NSURL*)url;

- (BOOL)isValidForGuid:(NSData*)guid identifier:(NSString*)identifier version:(NSString*)version;
- (BOOL)isValidForGuid:(NSData*)guid identifier:(NSString*)identifier;

@end
