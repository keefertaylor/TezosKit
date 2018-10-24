#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BTCBase58.h"
#import "BTCData.h"
#import "NS+BTCBase58.h"
#import "NSData+Hashing.h"

FOUNDATION_EXPORT double CBBase58VersionNumber;
FOUNDATION_EXPORT const unsigned char CBBase58VersionString[];

