//
//  WebserviceCall.h
//
//  Created by Aditya Aggarwal on 02/04/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "WebserviceResponse.h"

#define NSError_Request_Timed_Out_Code -1001

#define ResponseAccessTokenKey @"access_token"
#define ResponseTokenExpiresInKey @"expires_in"
#define ResponseTokenScopeKey @"scope"
#define ResponseTokenTypeKey @"token_type"
#define ResponseRefreshTokenKey @"refresh_token"

#define RequestClientIdKey @"client_id"
#define RequestClientSecretKey @"client_secret"
#define RequestGrantTypeKey @"grant_type"

FOUNDATION_EXPORT NSString const *CachedResourcesFolderName;

@class Loader;

typedef enum{
 
    WebserviceCallResponseJSON,
    WebserviceCallResponseXML,
    WebserviceCallResponsePNG,
    WebserviceCallResponseJPEG,
    WebserviceCallResponsePDF,
    WebserviceCallResponseMP4,
    WebserviceCallResponseSqliteFile,
    WebserviceCallResponseString
    
}WebserviceCallResponseType;

typedef enum{
    
    WebserviceCallCachePolicyRequestFromUrlNoCache,   // For file download this will not work
    WebserviceCallCachePolicyRequestFromUrlAndUpdateInCache,
    WebserviceCallCachePolicyRequestFromCacheIfAvailableOtherwiseFromUrlAndUpdateInCache,
    WebserviceCallCachePolicyRequestFromCacheFirstAndThenFromUrlAndUpdateInCache,
    WebserviceCallCachePolicyRequestFromCacheOnlyThenCallUrlInBackgroundAndUpdateInCache
    
}WebserviceCallCachePolicy;

typedef enum{
    
    WebserviceCallRequestMethodPost,
    WebserviceCallRequestMethodPut,
    WebserviceCallRequestMethodGet,
    WebserviceCallRequestMethodPatch,
    WebserviceCallRequestMethodDelete
    
}WebserviceCallRequestMethod;

typedef enum{
    
    WebserviceCallRequestTypeJson,
    WebserviceCallRequestTypeMultipartFormData,
    WebserviceCallRequestTypeFormURLEncoded
    
}WebserviceCallRequestType;

//typedef enum{
//    
//    WebserviceCallRequestAuthTokenTypeNone,
//    WebserviceCallRequestAuthTokenTypePublic,
//    WebserviceCallRequestAuthTokenTypeUser
//    
//}WebserviceCallRequestAuthTokenType;

typedef void(^SuccessHandler)(WebserviceResponse *response);
typedef void(^FailureHandler)(NSError *error);

@interface WebserviceCall : NSObject{
    
    NSMutableData *receivedData;
    NSURLConnection * connectionForFile;
    long long expectedBytes;
//    __weak id fileOwner;
//    SEL fileOwnerSuccessSelector;
//    SEL fileOwnerFailureSelector;
    Reachability *internetReach;
    UIActivityIndicatorView *activityView;
    Loader *ObjLoader;
    
    UIBackgroundTaskIdentifier bgTask;
    NSFileHandle *fileHandle;
    
    BOOL isDataReturnedFromCache;
    
    SuccessHandler successHandler;
    FailureHandler failureHandler;
    
    WebserviceCallRequestMethod requestMethod;
    
}

@property (nonatomic, assign) int downloadId; // ref for Webservice response for accurate delegate
//@property (nonatomic, assign) id notificationDelegate;
//@property (nonatomic, copy) NSString *successNotification;
//@property (nonatomic, copy) NSString *failureNotification;
//@property (nonatomic, copy) NSString *progressNotification;
@property (nonatomic, assign) WebserviceCallResponseType responseType;
@property (nonatomic, assign) WebserviceCallRequestType requestType;
@property (nonatomic, assign) WebserviceCallCachePolicy cachePolicy;
//@property (nonatomic, assign) WebserviceCallRequestAuthTokenType authTokenType;
@property (assign, nonatomic) void(^ProgressHandler)(WebserviceResponse *response);
@property (nonatomic, copy) NSDictionary *parametersDict;
@property (nonatomic, assign) BOOL isShowLoader;
@property (nonatomic, assign) BOOL shouldDisableInteraction;
//@property (nonatomic, assign) BOOL isAuthEnabled;
@property (nonatomic, copy) NSDictionary *headerFieldsDict;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic,strong)  NSString *headerBody;




/**
 *  Initializes WebserviceCall object
 *
 *  @param responseType Defines the type of the response [Default is 'WebserviceCallResponseJSON']
 *  @param requestType Defines the type of the request [Default is 'WebserviceCallRequestTypeJSON']
 *  @param cachePolicy  Defines the Cache policy [Default is 'WebserviceCallCachePolicyRequestFromUrlNoCache']
 *
 *  @return WebserviceCall object
 */
- (instancetype)initWithResponseType:(WebserviceCallResponseType)responseType requestType:(WebserviceCallRequestType)requestType cachePolicy:(WebserviceCallCachePolicy)cachePolicy;

/**
 *  Call this method before calling the service to store the returned token at the given key.
 *
 *  @param clientSecret Client secret
 *  @param clientId     Client id
 *  @param grantType    Grant type
 *  @param key          Key at which the token will be stored.
 */
- (void)fetchAuthTokenForClientSecret:(NSString *)clientSecret clientId:(NSString *)clientId grantType:(NSString *)grantType andStoreAtKey:(NSString *)key;

/**
 *  Call this method before calling the service to add the auth token in the header of the service call.
 *
 *  @param key Defines the key on which the token is stored.
 */
- (void)addAuthTokenInHeaderFromKey:(NSString *)key;

-(void)GET:(NSURL *)url parameters:(NSDictionary *)parameters withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure;
-(void)POST:(NSURL *)url parameters:(NSDictionary *)parameters withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure;
-(void)PUT:(NSURL *)url parameters:(NSDictionary *)parameters withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure;
-(void)PATCH:(NSURL *)url parameters:(NSDictionary *)parameters withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure;
-(void)DELETE:(NSURL *)url parameters:(NSDictionary *)parameters withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure;

-(void)downloadFileFromUrl:(NSURL *)url withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure;
-(void)uploadFile:(NSData *)file withFileName:(NSString *)fileName withFieldName:(NSString *)fieldName mimeType:(NSString *)mimeType onUrl:(NSURL *)url withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure;

@end
