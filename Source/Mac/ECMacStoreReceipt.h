// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
// --------------------------------------------------------------------------

@interface ECMacStoreReceipt : NSObject
{
@private
    NSDictionary* info;

}

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
