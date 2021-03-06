// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
// --------------------------------------------------------------------------

#import "ECLicenseChecker.h"

@class ECMacStoreReceipt;

@interface ECMacStore : ECLicenseChecker
{
@private
    
    // --------------------------------------------------------------------------
    // Member Variables
    // --------------------------------------------------------------------------

    ECMacStoreReceipt* receipt;
    NSString* status;
}

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
