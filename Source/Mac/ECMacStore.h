// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
// --------------------------------------------------------------------------

#import "ECLicenseChecker.h"

@class ECMacStoreReceipt;

@interface ECMacStore : ECLicenseChecker

// --------------------------------------------------------------------------
// Public Properties
// --------------------------------------------------------------------------

@property (strong, nonatomic) ECMacStoreReceipt* receipt;
@property (strong, nonatomic) NSString* status;

// --------------------------------------------------------------------------
// Public Methods
// --------------------------------------------------------------------------

- (BOOL)            isValid;
- (NSDictionary*)   info;

+ (NSURL*) defaultReceiptURL;
+ (NSURL*) savedReceiptURLForGuid:(NSData*)guid;


@end
