//
//  WebserviceConstants.m
//  Mobitime
//
//  Created by Mohit Jain on 9/11/15.
//  Copyright (c) 2015 Net Solutions. All rights reserved.
//

#import "WebserviceConstants.h"

@implementation WebserviceConstants

/**
 *  Dev Server
 */
//NSString *const BASE_URL = @"http://192.168.0.211:81/";

/**
 *  Local Server
 */
NSString *const BASE_URL = @"http://172.16.13.140:800/";

/**
 *  Sub Url
 */
NSString *const APP_URL = @"app/api/";
NSString *const AUTH_URL = @"o/";


/*****************************************Webservice Constants******************************/
// Webservice Key or Value constants

NSInteger const DeviceType = 1;
NSInteger const WebserviceSuccessValue = 200;

NSString *const WebserviceAccessTokenKey  = @"access_token";
NSString *const WebserviceStatusCodeKey  = @"status_code";
NSString *const WebserviceResponseKey  = @"response";
NSString *const WebserviceKeyForPublicToken  = @"KeyForFetchPublicToken";
NSString *const WebserviceValueForPublicToken  = @"ValueForFetchPublicToken";

/**
 *  Web services
 */
NSString *const WebservicePublicToken = @"token/";
NSString *const WebserviceSignUp  = @"SignUp/";
NSString *const WebserviceSignIn  = @"SignIn/";
NSString *const WebserviceSignOut  = @"SignOut/";
NSString *const WebserviceForgotPassword  = @"ForgotPassword/";
NSString *const WebserviceOTP  = @"ValidateOTP/";
NSString *const WebserviceResetPassword = @"ResetPassword/";
NSString *const WebserviceChangePassword = @"ChangePassword/";

@end
