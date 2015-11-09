//
//  CMLibraryConstants.h
//
//
//  Created by Aditya Aggarwal on 9/11/15.
//

#import <Foundation/Foundation.h>

@interface CMLibraryConstants : NSObject
#ifndef CMLibraryTest_CMLibraryConstants_h
#define CMLibraryTest_CMLibraryConstants_h

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#endif



@end
