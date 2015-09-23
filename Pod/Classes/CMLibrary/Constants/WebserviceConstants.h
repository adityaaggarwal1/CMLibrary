//
//  WebserviceConstants.h
//  Mobitime
//
//  Created by Mohit Jain on 9/11/15.
//  Copyright (c) 2015 Net Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebserviceConstants : NSObject
#ifndef CMLibraryTest_WebserviceConstants_h
#define CMLibraryTest_WebserviceConstants_h

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#endif

/**
 *  Local Server
 */
//

FOUNDATION_EXPORT NSString *const BASE_URL;
FOUNDATION_EXPORT NSString *const APP_URL;
FOUNDATION_EXPORT NSString *const AUTH_URL;

/********************************** Webservice Constants ****************************************************/

// Webservice Key or Value constants

FOUNDATION_EXPORT NSInteger const DeviceType;
FOUNDATION_EXPORT NSString  *const WebserviceStatusCodeKey;
FOUNDATION_EXPORT NSString  *const WebserviceResponseKey;
FOUNDATION_EXPORT NSInteger const WebserviceSuccessValue;
FOUNDATION_EXPORT NSString  *const WebserviceAccessTokenKey;
FOUNDATION_EXPORT NSString  *const WebserviceKeyForPublicToken;
FOUNDATION_EXPORT NSString  *const WebserviceValueForPublicToken;



/**
 *  Sign Up web service
 */
FOUNDATION_EXPORT NSString *const WebservicePublicToken;
FOUNDATION_EXPORT NSString *const WebserviceSignUp;
FOUNDATION_EXPORT NSString *const WebserviceSignIn;
FOUNDATION_EXPORT NSString *const WebserviceSignOut;
FOUNDATION_EXPORT NSString *const WebserviceForgotPassword;
FOUNDATION_EXPORT NSString *const WebserviceOTP;
FOUNDATION_EXPORT NSString *const WebserviceResetPassword;
FOUNDATION_EXPORT NSString *const WebserviceChangePassword;



@end
