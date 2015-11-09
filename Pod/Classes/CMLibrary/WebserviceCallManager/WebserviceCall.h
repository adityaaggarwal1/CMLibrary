//
//  WebserviceCall.h
//  VideoTag
//
//  Created by Aditya Aggarwal on 02/04/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "WebserviceResponse.h"

#define NSError_Request_Timed_Out_Code -1001

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
    
    WebserviceCallRequestTypePost,
    WebserviceCallRequestTypePut,
    WebserviceCallRequestTypeGet
    
}WebserviceCallRequestType;

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
    
    WebserviceCallRequestType requestType;
    
}

@property (nonatomic, assign) int downloadId; // ref for Webservice response for accurate delegate
//@property (nonatomic, assign) id notificationDelegate;
//@property (nonatomic, copy) NSString *successNotification;
//@property (nonatomic, copy) NSString *failureNotification;
//@property (nonatomic, copy) NSString *progressNotification;
@property (nonatomic, assign) WebserviceCallResponseType responseType;
@property (nonatomic, assign) WebserviceCallCachePolicy cachePolicy;
@property (assign, nonatomic) void(^ProgressHandler)(WebserviceResponse *response);
@property (nonatomic, copy) NSDictionary *parametersDict;
@property (nonatomic, assign) BOOL isShowLoader;
@property (nonatomic, copy) NSDictionary *headerFieldsDict;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic,strong)  NSString *headerBody;



/**
 *  Initializes WebserviceCall object
 *
 *  @param responseType Defines the type of the response [Default is 'WebserviceCallResponseJSON']
 *  @param cachePolicy  Defines the Cache policy [Default is 'WebserviceCallCachePolicyRequestFromUrlNoCache']
 *
 *  @return WebserviceCall object
 */
- (instancetype)initWithResponseType:(WebserviceCallResponseType)responseType cachePolicy:(WebserviceCallCachePolicy)cachePolicy;

-(void)GET:(NSURL *)url parameters:(NSDictionary *)parameters withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure;
-(void)POST:(NSURL *)url parameters:(NSDictionary *)parameters withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure;
-(void)PUT:(NSURL *)url parameters:(NSDictionary *)parameters withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure;


-(void)downloadFileFromUrl:(NSURL *)url withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure;
-(void)uploadFile:(NSData *)file withFileName:(NSString *)fileName withFieldName:(NSString *)fieldName mimeType:(NSString *)mimeType onUrl:(NSURL *)url withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure;

@end
