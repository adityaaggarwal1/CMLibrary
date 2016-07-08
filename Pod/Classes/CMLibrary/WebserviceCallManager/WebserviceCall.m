//
//  WebserviceCall.m
//
//  Created by Aditya Aggarwal on 02/04/14.
//
//

#import "WebserviceCall.h"
#import "XMLDictionary.h"
#import "CacheManager.h"
#import "CacheModel.h"
#import "Loader.h"
#import "CMLibraryConstants.h"
#import "CMLibraryUtility.h"
#import "AuthToken.h"
#import "FXKeychain.h"
#import "NSDictionary+URLEncoding.h"

NSString const *CachedResourcesFolderName = @"CachedResources";

@interface WebserviceCall ()

@property (strong, nonatomic) NSString *authTokenKey;
@property (nonatomic) BOOL shouldStoreAuthToken;
@property (nonatomic, copy) NSString *downloadFilePath;
@property (strong, nonatomic) AuthToken *authToken;

@end

@implementation WebserviceCall

- (id)init
{
    self = [super init];
    if (self) {
        _cachePolicy = WebserviceCallCachePolicyRequestFromUrlNoCache;
        _responseType = WebserviceCallResponseJSON;
        _requestType = WebserviceCallRequestTypeJson;
//        _authTokenType = WebserviceCallRequestAuthTokenTypeNone;
    }
    return self;
}

- (instancetype)initWithResponseType:(WebserviceCallResponseType)responseType requestType:(WebserviceCallRequestType)requestType cachePolicy:(WebserviceCallCachePolicy)cachePolicy{
    
    self = [super init];
    if (self) {
        _responseType = responseType;
        _cachePolicy = cachePolicy;
        _requestType = requestType;
    }
    return self;
}

#pragma mark - Web service calls

- (void)webserviceCall:(NSURL *)url parameters:(NSDictionary *)parameters withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure
{
    if(!url)
        return;
    
    successHandler = handlerSuccess;
    failureHandler = handlerFailure;
    _parametersDict = parameters;
    
    [self setUrl:url];
    
    isDataReturnedFromCache = NO;
    
    if (![self checkNetworkConnectivity]){
        
        failureHandler([NSError errorWithDomain:@"No Internet" code:NotReachable userInfo:nil]);
        return;
    }
    
    if(_cachePolicy != WebserviceCallCachePolicyRequestFromUrlNoCache && _cachePolicy != WebserviceCallCachePolicyRequestFromUrlAndUpdateInCache)
    {
        NSString *cacheKey = [self getKeyForCacheAccordingToUrl:url];
        
        if([[CacheManager sharedInstance] isDataAvailableForKey:cacheKey])
        {
            isDataReturnedFromCache = YES;
            
            CacheModel *cache = [[CacheManager sharedInstance] dataInCacheForKey:cacheKey];
            
            [self respondToSuccessHandlerWithData:cache.cacheValue isResponseFromCache:YES];
            
            [self setIsShowLoader:NO];
            [self setShouldDisableInteraction:NO];
            
            if(_cachePolicy == WebserviceCallCachePolicyRequestFromCacheIfAvailableOtherwiseFromUrlAndUpdateInCache)
                return;
        }
    }
    
    if(_isShowLoader)////self showLoader];
    {
        if(!ObjLoader)
            ObjLoader = [[Loader alloc] init];
        
        [ObjLoader showLoader];
    }
    
    if(_shouldDisableInteraction){
        [[[[UIApplication sharedApplication] delegate] window] setUserInteractionEnabled:NO];
    }
    
    [self makeRequestForWebServiceAtURL:url];
}

- (void)GET:(NSURL *)url parameters:(NSDictionary *)parameters withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure
{
    requestMethod = WebserviceCallRequestMethodGet;
    
    url = [self getURLForGet:url withParameters:parameters];
    
    [self webserviceCall:url parameters:parameters withSuccessHandler:handlerSuccess withFailureHandler:handlerFailure];
}

- (void)POST:(NSURL *)url parameters:(NSDictionary *)parameters withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure
{
    requestMethod = WebserviceCallRequestMethodPost;
    
    [self webserviceCall:url parameters:parameters withSuccessHandler:handlerSuccess withFailureHandler:handlerFailure];
}

- (void)PUT:(NSURL *)url parameters:(NSDictionary *)parameters withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure
{
    requestMethod = WebserviceCallRequestMethodPut;
    
    [self webserviceCall:url parameters:parameters withSuccessHandler:handlerSuccess withFailureHandler:handlerFailure];
}

- (void)PATCH:(NSURL *)url parameters:(NSDictionary *)parameters withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure
{
    requestMethod = WebserviceCallRequestMethodPatch;
    
    [self webserviceCall:url parameters:parameters withSuccessHandler:handlerSuccess withFailureHandler:handlerFailure];
}

- (void)DELETE:(NSURL *)url parameters:(NSDictionary *)parameters withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure
{
    requestMethod = WebserviceCallRequestMethodDelete;
    
    [self webserviceCall:url parameters:parameters withSuccessHandler:handlerSuccess withFailureHandler:handlerFailure];
}

- (NSURL *)getURLForGet:(NSURL *)url withParameters:(NSDictionary *)parameters{
    
    if(!url || !parameters)
        return url;
    
    NSString *stringURL = [url absoluteString];

    stringURL = [stringURL stringByAppendingString:@"?"];
    
    for (NSString *key in [parameters allKeys]) {
        
        NSString *value = [parameters objectForKey:key];
        
        stringURL = [stringURL stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,value]];
    }
    
    stringURL = [stringURL stringByReplacingCharactersInRange:NSMakeRange(stringURL.length - 1, 1) withString:@""];
    
    NSURL *newURL = [NSURL URLWithString:stringURL];
    
    return newURL;
}

- (void)setHttpMethodForRequest:(NSMutableURLRequest *)request{
    
    if(!request)
        return;
    
    switch (requestMethod) {
        case WebserviceCallRequestMethodPost:
            [request setHTTPMethod:@"POST"];
            break;
        case WebserviceCallRequestMethodPut:
            [request setHTTPMethod:@"PUT"];
            break;
        case WebserviceCallRequestMethodGet:
            [request setHTTPMethod:@"GET"];
            break;
        case WebserviceCallRequestMethodPatch:
            [request setHTTPMethod:@"PATCH"];
            break;
        case WebserviceCallRequestMethodDelete:
            [request setHTTPMethod:@"DELETE"];
            break;
            
        default:
            break;
    }
}

//- (AuthToken *)getTokenByTokenType{
//    switch (_authTokenType) {
//        case WebserviceCallRequestAuthTokenTypePublic:
//            
//            break;
//        case WebserviceCallRequestAuthTokenTypeUser:
//            
//            break;
//            
//        default:
//            break;
//    }
//}

- (void)addClientCredentialsInParamterDict{
    
    if (!_authToken)
        return;
    
    NSMutableDictionary *paramDict;
    
    if (_parametersDict){
        paramDict = [NSMutableDictionary dictionaryWithDictionary:_parametersDict];
    }
    else{
        paramDict = [NSMutableDictionary dictionary];
    }
    
    if (_authToken.client_id)
        [paramDict setObject:_authToken.client_id forKey:RequestClientIdKey];
    if (_authToken.client_secret)
        [paramDict setObject:_authToken.client_secret forKey:RequestClientSecretKey];
    if (_authToken.grant_type)
        [paramDict setObject:_authToken.grant_type forKey:RequestGrantTypeKey];
    
    [self setParametersDict:paramDict];
}

- (void)setRequestHeaderAndBody:(NSMutableURLRequest *)request{
    
    if(_headerFieldsDict)
    {
        NSArray *allKeys = [_headerFieldsDict allKeys];
        
        //        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        for (NSString *key in allKeys)
        {
            [request setValue:[_headerFieldsDict objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    if(requestMethod == WebserviceCallRequestMethodGet)
        return;
    
    if (_shouldStoreAuthToken){
        [self addClientCredentialsInParamterDict];
    }
        
    NSMutableData *httpBodyData;
    
    switch (_requestType) {
        case WebserviceCallRequestTypeJson:{
            
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            if (_parametersDict){
                NSError *error;
                httpBodyData = [NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:_parametersDict options:NSJSONWritingPrettyPrinted error:&error]];
            }
            else if (_headerBody){
                httpBodyData = [NSMutableData dataWithBytes:[_headerBody UTF8String] length:[_headerBody length]];;
            }
        }
            break;
        case WebserviceCallRequestTypeFormURLEncoded:{
            
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            
            if (_parametersDict){
                NSString *headerBodyString = [_parametersDict urlEncodedString];
                httpBodyData = [NSMutableData dataWithBytes:[headerBodyString UTF8String] length:[headerBodyString length]];
            }
            else if (_headerBody){
                httpBodyData = [NSMutableData dataWithBytes:[_headerBody UTF8String] length:[_headerBody length]];
            }
        }
            break;
        case WebserviceCallRequestTypeMultipartFormData:{
            
            if (!_parametersDict || [[_parametersDict allKeys] count] == 0)
                break;
            
            httpBodyData = [NSMutableData data];
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            
            //    Open form
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
            [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            NSArray *allKeys = [_parametersDict allKeys];
            
            for (NSString *key in allKeys)
            {
                [httpBodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [httpBodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
                
                [httpBodyData appendData:[[_parametersDict valueForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
                [httpBodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            // close form
            [httpBodyData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
//                if (_parametersDict){
//                    NSString *headerBodyString = [self urlEncodedString:_parametersDict];
//                    httpBodyData = [NSData dataWithBytes:[headerBodyString UTF8String] length:[headerBodyString length]];
//                }
//                else if (_headerBody){
//                    httpBodyData = [NSData dataWithBytes:[_headerBody UTF8String] length:[_headerBody length]];;
//                }
        }
            break;
            
        default:
            break;
    }
    
    if (httpBodyData){
        [request setHTTPBody:httpBodyData];
    }

//    if(requestMethod != WebserviceCallRequestMethodGet)
//    {
//        if(_parametersDict)
//        {
//            NSError *error;
//            NSData *postData = [NSJSONSerialization dataWithJSONObject:_parametersDict options:NSJSONWritingPrettyPrinted error:&error];
//            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//            [request setHTTPBody:postData];
//        }
//    }
    
    
//    else if(_headerBody)
//    {
//        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//        [request setHTTPBody:[NSData dataWithBytes:[_headerBody UTF8String] length:[_headerBody length]]];
//    }
}

-(void)makeRequestForWebServiceAtURL:(NSURL *)url
{
    if (![self checkNetworkConnectivity])
    {
        failureHandler([NSError errorWithDomain:@"No Internet" code:NotReachable userInfo:nil]);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    if (_authToken && !_shouldStoreAuthToken){
        [self embedAuthInRequest:request];
    }
    
    [self setHttpMethodForRequest:request];
    
    [self setRequestHeaderAndBody:request];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(_shouldDisableInteraction){
            [[[[UIApplication sharedApplication] delegate] window] setUserInteractionEnabled:YES];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (data.length > 0)
            {
                NSString *cacheKey = [self getKeyForCacheAccordingToUrl:url];
                
                if(_cachePolicy == WebserviceCallCachePolicyRequestFromCacheIfAvailableOtherwiseFromUrlAndUpdateInCache)
                {
                    [[CacheManager sharedInstance] cacheData:data forKey:cacheKey];
                }
                else if(_cachePolicy == WebserviceCallCachePolicyRequestFromCacheFirstAndThenFromUrlAndUpdateInCache || _cachePolicy == WebserviceCallCachePolicyRequestFromCacheOnlyThenCallUrlInBackgroundAndUpdateInCache || _cachePolicy == WebserviceCallCachePolicyRequestFromUrlAndUpdateInCache)
                {
                    if([[CacheManager sharedInstance] isDataAvailableForKey:cacheKey])
                    {
                        [[CacheManager sharedInstance] updateData:data forKey:cacheKey];
                    }
                    else
                    {
                        [[CacheManager sharedInstance] cacheData:data forKey:cacheKey];
                    }
                }
                
                if(_cachePolicy != WebserviceCallCachePolicyRequestFromCacheOnlyThenCallUrlInBackgroundAndUpdateInCache || !isDataReturnedFromCache){
                    [self respondToSuccessHandlerWithData:data isResponseFromCache:NO];
                }
            }
            else if(error)
            {
                failureHandler(error);
            }
            else
            {
                failureHandler (nil);
            }
        

            if(_isShowLoader)
            {
                if (ObjLoader)
                    [ObjLoader hideLoader];
            }
        });
        
    }] resume];
    
    
//    Deprecated.....
    
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response,
//                                               NSData *data, NSError *connectionError)
//     {
//         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//         
//         if(_isShowLoader)
//         {
//             if (ObjLoader)
//                 [ObjLoader hideLoader];
//         }
//         
//         if(_shouldDisableInteraction){
//             [[[[UIApplication sharedApplication] delegate] window] setUserInteractionEnabled:YES];
//         }
//         
//         if (data.length > 0)
//         {
//             NSString *cacheKey = [self getKeyForCacheAccordingToUrl:url];
//
//             if(_cachePolicy == WebserviceCallCachePolicyRequestFromCacheIfAvailableOtherwiseFromUrlAndUpdateInCache)
//             {
//                 [[CacheManager sharedInstance] cacheData:data forKey:cacheKey];
//             }
//             else if(_cachePolicy == WebserviceCallCachePolicyRequestFromCacheFirstAndThenFromUrlAndUpdateInCache || _cachePolicy == WebserviceCallCachePolicyRequestFromCacheOnlyThenCallUrlInBackgroundAndUpdateInCache || _cachePolicy == WebserviceCallCachePolicyRequestFromUrlAndUpdateInCache)
//             {
//                 if([[CacheManager sharedInstance] isDataAvailableForKey:cacheKey])
//                 {
//                     [[CacheManager sharedInstance] updateData:data forKey:cacheKey];
//                 }
//                 else
//                 {
//                     [[CacheManager sharedInstance] cacheData:data forKey:cacheKey];
//                 }
//             }
//             
//             if(_cachePolicy != WebserviceCallCachePolicyRequestFromCacheOnlyThenCallUrlInBackgroundAndUpdateInCache || !isDataReturnedFromCache)
//                 [self respondToSuccessHandlerWithData:data isResponseFromCache:NO];
//         }
//         else if(connectionError)
//         {
//             failureHandler(connectionError);
//         }
//         else
//         {
//             failureHandler (nil);
//         }
//     }];
}

#pragma mark - Network Reachability
-(BOOL)checkNetworkConnectivity
{
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    
    NetworkStatus internetStatus = [internetReach currentReachabilityStatus];
    
    switch(internetStatus)
    {
        case NotReachable:
        {
            [CMLibraryUtility showAlert:@"No Internet Connection" withMessage:@"Please check your internet connection and try again." delegate:nil];
            
            return NO;
        }
        case ReachableViaWiFi:
        {
            return YES;
        }
        case ReachableViaWWAN:
        {
            return YES;
        }
    }
    return YES;
}

#pragma mark - Loader

-(void) showLoader
{
    //Add loading indicator
    activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    
    activityView.center= window.center;
    
    [activityView startAnimating];
    
    [window addSubview:activityView];
}

-(void)hideLoader
{
    [activityView removeFromSuperview];
    [activityView stopAnimating];
}

#pragma mark - Download files

-(NSString *)createCachedResourcesFolder
{
    NSError *error;
    NSString *directoryPath = [CMLibraryUtility getCacheResourcePathByAppendingFileInnerPath:[NSString stringWithFormat:@"%@",CachedResourcesFolderName]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:&error];
    return directoryPath;
}

-(void)downloadFileFromUrl:(NSURL *)url withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure
{
    if(!url)
        return;
    
    successHandler = handlerSuccess;
    failureHandler = handlerFailure;
    
    if(!_downloadFilePath){
        
        NSString *fileName = [self getFileNameAccordingToCurrentUrl:url.absoluteString];
        _downloadFilePath = [[self createCachedResourcesFolder] stringByAppendingPathComponent:fileName];
    }
    
    [self setUrl:url];
    
    if(_cachePolicy != WebserviceCallCachePolicyRequestFromUrlNoCache && _cachePolicy != WebserviceCallCachePolicyRequestFromUrlAndUpdateInCache)
    {
        NSString *cacheKey = [self getKeyForCacheAccordingToUrl:url];
        
        cacheKey = [cacheKey stringByReplacingOccurrencesOfString:@"'" withString:@""];
        
        if([[CacheManager sharedInstance] isDataAvailableForKey:cacheKey])
        {
            CacheModel *cache = [[CacheManager sharedInstance] dataInCacheForKey:cacheKey];
            NSString *filePath = [[NSString alloc] initWithData:cache.cacheValue encoding:NSUTF8StringEncoding];
            
            if([filePath rangeOfString:[NSString stringWithFormat:@"%@",CachedResourcesFolderName]].location != NSNotFound){
                NSString *fileName = [filePath lastPathComponent];
                filePath = [[self createCachedResourcesFolder] stringByAppendingPathComponent:fileName];
            }
    //            NSData *file = [self getFileFromPath:filePath];
    //            
            [self respondToSuccessHandlerWithData:filePath isResponseFromCache:YES];
            
            if(_cachePolicy == WebserviceCallCachePolicyRequestFromCacheIfAvailableOtherwiseFromUrlAndUpdateInCache)
                return;
        }
    }
    
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        // Clean up any unfinished task business by marking where you
        
        // stopped or ending the task outright.
        
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    [self resumeOrStartDownload];
}

-(void)resumeOrStartDownload
{
    if (![self checkNetworkConnectivity])
    {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        
        bgTask = UIBackgroundTaskInvalid;
        
//        WebserviceResponse *errorResponse = [WebserviceResponse new];
//        [errorResponse setWebserviceUrl:[_url absoluteString]];
//        [errorResponse setWebserviceResponse:[NSError errorWithDomain:@"No Internet" code:NotReachable userInfo:nil]];
//        [errorResponse setDownloadId:_downloadId];
        
        failureHandler([NSError errorWithDomain:@"No Internet" code:NotReachable userInfo:nil]);
        
        return;
    }
    
    if(_isShowLoader)
    {
        if(!ObjLoader)
            ObjLoader = [[Loader alloc] init];
        
        [ObjLoader showLoader];
    }
    
    if(_shouldDisableInteraction){
        [[[[UIApplication sharedApplication] delegate] window] setUserInteractionEnabled:NO];
    }
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    
    NSUInteger downloadedLength = 0;
    
    if([CMLibraryUtility checkIfStringContainsText:_downloadFilePath])
    {
        NSFileManager *fm = [NSFileManager defaultManager];
//        NSString *filePath = [CMLibraryUtility getCacheResourcePathByAppendingFileInnerPath:_downloadFilePath];
        NSString *filePath = _downloadFilePath;
        
        if ([fm fileExistsAtPath:filePath])
        {
            NSError *error = nil;
            NSDictionary *fileDictionary = [fm attributesOfItemAtPath:filePath error:&error];
            if (!error && fileDictionary)
                downloadedLength = (NSUInteger)[fileDictionary fileSize];
        }
    }
    else
    {
        if(receivedData)
        {
            downloadedLength = receivedData.length;
        }
    }
    
    if(downloadedLength > 0)
    {
//        NSLog(@"restart download %ld",downloadedLength);
        NSString *range = [NSString stringWithFormat:@"bytes=%ld-", (unsigned long)downloadedLength];
        [theRequest setValue:range forHTTPHeaderField:@"Range"];
    }
    
    connectionForFile = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    [connectionForFile start];
}

#pragma mark - NSURLConnection delegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    if([CMLibraryUtility checkIfStringContainsText:_downloadFilePath])
    {
        unsigned long long downloadedBytes = 0;
//        BOOL isFileCreated = YES;
        NSString *filePath = _downloadFilePath;
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:filePath])
        {
            NSError *error = nil;
            NSDictionary *fileDictionary = [fm attributesOfItemAtPath:filePath error:&error];
            if (!error && fileDictionary)
                downloadedBytes = [fileDictionary fileSize];
        }
        else
        {
            [fm createFileAtPath:filePath contents:nil attributes:nil];
        }
        
        if([response expectedContentLength] == downloadedBytes)
            expectedBytes = downloadedBytes;
        else
            expectedBytes = [response expectedContentLength] + downloadedBytes;
    }
    else
    {
        if(!receivedData)
        {
            expectedBytes = [response expectedContentLength];
            receivedData = [[NSMutableData alloc] initWithLength:0];
        }
        else
        {
            expectedBytes = [response expectedContentLength] + receivedData.length;
        }
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    float progressive = 0.0f;
    
    if([CMLibraryUtility checkIfStringContainsText:_downloadFilePath])
    {
        unsigned long long downloadedBytes = 0;
        NSString *filePath = _downloadFilePath;
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:filePath])
        {
            if(!fileHandle)
            {
                fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
                [fileHandle seekToEndOfFile];
            }
            
            [fileHandle writeData:data];
//            [fileHandle closeFile];
//            fileHandle = nil;
            
            NSError *error = nil;
            NSDictionary *fileDictionary = [fm attributesOfItemAtPath:filePath error:&error];
            if (!error && fileDictionary)
                downloadedBytes = [fileDictionary fileSize];
        }
        
        progressive = (float)downloadedBytes / (float)expectedBytes;
    }
    else
    {
        [receivedData appendData:data];
        progressive = (float)[receivedData length] / (float)expectedBytes;
    }
    
    if(_ProgressHandler)
    {
        WebserviceResponse *response = [WebserviceResponse new];
        [response setWebserviceUrl:[_url absoluteString]];
        [response setWebserviceResponse:[NSNumber numberWithFloat:progressive]];
        [response setDownloadId:_downloadId];
        
        _ProgressHandler(response);
    }
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    if(_isShowLoader)
    {
        if (ObjLoader)
            [ObjLoader hideLoader];
    }
    
    if(_shouldDisableInteraction){
        [[[[UIApplication sharedApplication] delegate] window] setUserInteractionEnabled:YES];
    }
    
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    
    bgTask = UIBackgroundTaskInvalid;
    
//    {
//    NSError *newError = nil;
//    NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:_downloadFilePath error:&newError];
//    if (!newError && fileDictionary)
//        NSILog(@"error download end %@",[NSNumber numberWithUnsignedLongLong:[fileDictionary fileSize]]);
//    }
//    if(error.code == NSError_Request_Timed_Out_Code)
//    {
//        [self performSelector:@selector(resumeOrStartDownload) withObject:nil afterDelay:1];
//        
//        return;
//    }

    if(fileHandle)
    {
        [fileHandle closeFile];
        fileHandle = nil;
    }
    
//    WebserviceResponse *response = [WebserviceResponse new];
//    [response setWebserviceUrl:[_url absoluteString]];
//    [response setWebserviceResponse:error];
//    [response setDownloadId:_downloadId];
    
    failureHandler(error);
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if(_isShowLoader)
    {
        if (ObjLoader)
            [ObjLoader hideLoader];
    }
    
    if(_shouldDisableInteraction){
        [[[[UIApplication sharedApplication] delegate] window] setUserInteractionEnabled:YES];
    }
    
    if(fileHandle)
    {
        [fileHandle closeFile];
        fileHandle = nil;
    }
    
    if(_cachePolicy == WebserviceCallCachePolicyRequestFromUrlNoCache)
    {
        if([CMLibraryUtility checkIfStringContainsText:_downloadFilePath])
        {
            [self respondToSuccessHandlerWithData:[NSData dataWithContentsOfFile:_downloadFilePath] isResponseFromCache:NO];
        }
        else
        {
            [self respondToSuccessHandlerWithData:receivedData isResponseFromCache:NO];
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        
        bgTask = UIBackgroundTaskInvalid;
        
        NSError *error;
        if ([[NSFileManager defaultManager] fileExistsAtPath:_downloadFilePath])
            [[NSFileManager defaultManager] removeItemAtPath:_downloadFilePath error:&error];
        return;
    }

    NSString *currentURL = [[[connection currentRequest] URL] absoluteString];
    NSString *filePath = @"";
    NSString *fileName = [self getFileNameAccordingToCurrentUrl:currentURL];
    NSString *fileInnerPath = nil;
    
    if([CMLibraryUtility checkIfStringContainsText:_downloadFilePath])
    {
        filePath = _downloadFilePath;
        if([filePath rangeOfString:[NSString stringWithFormat:@"%@",CachedResourcesFolderName]].location != NSNotFound){
            fileInnerPath = [CachedResourcesFolderName stringByAppendingPathComponent:fileName];
        }
    }
    else
    {
        NSError *error;
        NSString *directoryPath = [self createCachedResourcesFolder];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:&error];
        
        filePath = [directoryPath stringByAppendingPathComponent:fileName];
        
        [receivedData writeToFile:filePath atomically:YES];
    }
    
    [self respondToSuccessHandlerWithData:filePath isResponseFromCache:NO];
    
    NSData *filePathData = nil;
    if(fileInnerPath){
        filePathData = [fileInnerPath dataUsingEncoding:NSUTF8StringEncoding];
    }
    else{
        filePathData = [filePath dataUsingEncoding:NSUTF8StringEncoding];
    }

    
    currentURL = [currentURL stringByReplacingOccurrencesOfString:@"'" withString:@""];
    
    if(_cachePolicy == WebserviceCallCachePolicyRequestFromCacheIfAvailableOtherwiseFromUrlAndUpdateInCache)
    {
        [[CacheManager sharedInstance] cacheData:filePathData forKey:currentURL];
    }
    else if(_cachePolicy == WebserviceCallCachePolicyRequestFromCacheFirstAndThenFromUrlAndUpdateInCache)
    {
        if([[CacheManager sharedInstance] isDataAvailableForKey:currentURL])
        {
            [[CacheManager sharedInstance] updateData:filePathData forKey:currentURL];
        }
        else
        {
            [[CacheManager sharedInstance] cacheData:filePathData forKey:currentURL];
        }
    }
    
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    
    bgTask = UIBackgroundTaskInvalid;
}

#pragma mark - Helper methods

-(NSString *)getFileNameAccordingToCurrentUrl:(NSString *)currentUrl
{
    if(![CMLibraryUtility checkIfStringContainsText:currentUrl])
        return currentUrl;
    
    NSString *fileName = [currentUrl lastPathComponent];
    
    if(_responseType == WebserviceCallResponsePNG)
    {
        if(![[fileName pathExtension] isEqualToString:@"png"])
            fileName = [fileName stringByAppendingString:@".png"];
    }
    else if(_responseType == WebserviceCallResponseJPEG)
    {
        if(![[fileName pathExtension] isEqualToString:@"jpeg"] && ![[fileName pathExtension] isEqualToString:@"jpg"])
            fileName = [fileName stringByAppendingString:@".jpg"];
    }
    else if(_responseType == WebserviceCallResponsePDF)
    {
        if(![[fileName pathExtension] isEqualToString:@"pdf"])
            fileName = [fileName stringByAppendingString:@".pdf"];
    }
    else if(_responseType == WebserviceCallResponseMP4)
    {
        if(![[fileName pathExtension] isEqualToString:@"mp4"])
            fileName = [fileName stringByAppendingString:@".mp4"];
    }
    else if(_responseType == WebserviceCallResponseSqliteFile)
    {
        if(![[fileName pathExtension] isEqualToString:@"sqlite"])
            fileName = [fileName stringByAppendingString:@".sqlite"];
    }
    
    return fileName;
}

-(NSData *)getFileFromPath:(NSString *)filePath
{
    if(![CMLibraryUtility checkIfStringContainsText:filePath])
        return nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        return nil;
    
    NSData *file = [NSData dataWithContentsOfFile:filePath];
    
    return file;
}

-(void)respondToSuccessHandlerWithData:(id)data isResponseFromCache:(BOOL)isResponseFromCache
{
    id responseData;
    if(_responseType == WebserviceCallResponseJSON)
        responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    else if(_responseType == WebserviceCallResponseXML)
        responseData = [NSDictionary dictionaryWithXMLData:data];
    else if(_responseType == WebserviceCallResponsePNG || _responseType == WebserviceCallResponseJPEG)
        responseData = data;
    else if(_responseType == WebserviceCallResponseString)
        responseData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    else
        responseData = data;
    
    if ([self isAuthTokenDisabledOrNotExpired:responseData]){
        
        if ([CMLibraryUtility checkIfStringContainsText:_authTokenKey] && _shouldStoreAuthToken){        // Storing auth token from response
            [self storeAuthTokenFromResponse:responseData];
        }
        
        WebserviceResponse *webserviceResponse = [WebserviceResponse new];
        [webserviceResponse setWebserviceUrl:[_url absoluteString]];
        [webserviceResponse setWebserviceResponse:responseData];
        [webserviceResponse setDownloadId:_downloadId];
        [webserviceResponse setIsResponseFromCache:isResponseFromCache];
        
        successHandler(webserviceResponse);
    }
    else{
        // Refresh token
        [self webserviceCallToRefreshToken];
    }
}

-(NSString *)getKeyForCacheAccordingToUrl:(NSURL *)url
{
    if(!url)
        return nil;
    
    NSString *cacheKey = url.absoluteString;
    
    if(_parametersDict)
    {
        NSArray *allKeys = [_parametersDict allKeys];
        
        for (NSString *key in allKeys)
        {
            cacheKey = [cacheKey stringByAppendingString:[NSString stringWithFormat:@"%@:%@",key,[_parametersDict objectForKey:key]]];
        }
    }
    
    if(_headerFieldsDict)
    {
        NSArray *allKeys = [_headerFieldsDict allKeys];
        
        for (NSString *key in allKeys)
        {
            cacheKey = [cacheKey stringByAppendingString:[NSString stringWithFormat:@"%@:%@",key,[_headerFieldsDict objectForKey:key]]];
        }
    }
    
    if([CMLibraryUtility checkIfStringContainsText:_headerBody])
    {
        cacheKey = [cacheKey stringByAppendingString:[NSString stringWithFormat:@"_(HeaderBody) --> %@",_headerBody]];
    }
    
    return cacheKey;
}

#pragma mark - File upload

-(void)uploadFile:(NSData *)file withFileName:(NSString *)fileName withFieldName:(NSString *)fieldName mimeType:(NSString *)mimeType onUrl:(NSURL *)url withSuccessHandler:(void (^)(WebserviceResponse *response))handlerSuccess withFailureHandler:(void (^)(NSError *error))handlerFailure
{
    if(!url || !file || ![CMLibraryUtility checkIfStringContainsText:mimeType])
        return;
    
    if (![self checkNetworkConnectivity])
    {
        failureHandler([NSError errorWithDomain:@"No Internet" code:NotReachable userInfo:nil]);
        return;
    }
    
    successHandler = handlerSuccess;
    failureHandler = handlerFailure;
    
    [self setUrl:url];
    
    if(![CMLibraryUtility checkIfStringContainsText:fieldName])
        fieldName = @"file";
    
    if(_isShowLoader)////self showLoader];
    {
        if(!ObjLoader)
            ObjLoader = [[Loader alloc] init];
        
        [ObjLoader showLoader];
    }
    
    if(_shouldDisableInteraction){
        [[[[UIApplication sharedApplication] delegate] window] setUserInteractionEnabled:NO];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    
    //    Open form
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    if(file)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",fieldName,fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:file]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSArray *allKeys = [_parametersDict allKeys];
    
    for (NSString *key in allKeys)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[_parametersDict valueForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [request setHTTPMethod:@"POST"];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    if(_headerFieldsDict)
    {
        NSArray *allKeys = [_headerFieldsDict allKeys];
        
        for (NSString *key in allKeys)
        {
            [request setValue:[_headerFieldsDict objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    [[[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:body completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(_shouldDisableInteraction){
            [[[[UIApplication sharedApplication] delegate] window] setUserInteractionEnabled:YES];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (data.length > 0 && error == nil)
            {
                
                    [self respondToSuccessHandlerWithData:data isResponseFromCache:NO];
            }
            else if(error)
            {
                failureHandler(error);
            }
        
            if(_isShowLoader)
            {
                if (ObjLoader)
                    [ObjLoader hideLoader];
            }
        });
        
    }] resume];
    
//    Deprecated...
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response,
//                                               NSData *data, NSError *connectionError)
//     {
//         if(_isShowLoader)
//         {
//             if (ObjLoader)
//                 [ObjLoader hideLoader];
//         }
//         
//         if(_shouldDisableInteraction){
//             [[[[UIApplication sharedApplication] delegate] window] setUserInteractionEnabled:YES];
//         }
//         
//         if (data.length > 0 && connectionError == nil)
//         {
//             [self respondToSuccessHandlerWithData:data isResponseFromCache:NO];
//         }
//         else if(connectionError)
//         {
//             failureHandler(connectionError);
//         }
//     }];
}

#pragma mark - AuthToken

- (void)embedAuthInRequest:(NSMutableURLRequest *)request{
    
    if(!request)
        return;
    
    [request setValue:[self getBearerToken] forHTTPHeaderField:@"Authorization"];
}

- (NSString *)getBearerToken{
    
    NSString *token = [_authToken access_token];
    
    if (![CMLibraryUtility checkIfStringContainsText:token])
        token = @"";
    
    return [NSString stringWithFormat:@"Bearer %@",token];
}

- (BOOL)isAuthTokenDisabledOrNotExpired:(NSDictionary *)responseDict{
    
    if (!responseDict || ![responseDict isKindOfClass:[NSDictionary class]])
        return YES;
    
    if(_authToken){
        if (![responseDict objectForKey:@"status_code"] || [[responseDict objectForKey:@"status_code"] integerValue] != 401)
            return YES;
        
        return NO;
    }
    else{
        return YES;
    }
}

- (void)fetchAuthTokenForClientSecret:(NSString *)clientSecret clientId:(NSString *)clientId grantType:(NSString *)grantType andStoreAtKey:(NSString *)key{
    if (![CMLibraryUtility checkIfStringContainsText:key] || ![CMLibraryUtility checkIfStringContainsText:clientSecret] || ![CMLibraryUtility checkIfStringContainsText:clientId] || ![CMLibraryUtility checkIfStringContainsText:grantType])
        return;
    
    _shouldStoreAuthToken = YES;
    [self setAuthTokenKey:key];
    
    AuthToken *authToken = [AuthToken new];
    authToken.client_id = clientId;
    authToken.client_secret = clientSecret;
    authToken.grant_type = grantType;
    
    [self setAuthToken:authToken];
}

- (void)storeAuthTokenFromResponse:(NSDictionary *)responseDict{
    if (!responseDict || ![responseDict isKindOfClass:[NSDictionary class]])
        return;
    
    if (!_authToken){
        AuthToken *authToken = [AuthToken new];
        [self setAuthToken:authToken];
    }
    _authToken.access_token = [CMLibraryUtility getObjectForKey:ResponseAccessTokenKey fromDict:responseDict];
    _authToken.expires_in = [CMLibraryUtility getObjectForKey:ResponseTokenExpiresInKey fromDict:responseDict];
    _authToken.scope = [CMLibraryUtility getObjectForKey:ResponseTokenScopeKey fromDict:responseDict];
    _authToken.token_type = [CMLibraryUtility getObjectForKey:ResponseTokenTypeKey fromDict:responseDict];
    _authToken.refresh_token = [CMLibraryUtility getObjectForKey:ResponseRefreshTokenKey fromDict:responseDict];
    _authToken.url = _url.absoluteString;
    
    [[FXKeychain defaultKeychain] setObject:_authToken forKey:_authTokenKey];
}

- (void)addAuthTokenInHeaderFromKey:(NSString *)key{
    if (![CMLibraryUtility checkIfStringContainsText:key])
        return;
    
    [self setAuthTokenKey:key];
    [self setAuthToken:[[FXKeychain defaultKeychain] objectForKey:key]];
}

- (void)webserviceCallToRefreshToken{
    
    if (!_authToken || ![CMLibraryUtility checkIfStringContainsText:_authToken.refresh_token])
        return;
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] initWithResponseType:WebserviceCallResponseJSON requestType:WebserviceCallRequestTypeFormURLEncoded cachePolicy:WebserviceCallCachePolicyRequestFromUrlNoCache];
    
    [webserviceCall fetchAuthTokenForClientSecret:_authToken.client_secret clientId:_authToken.client_id grantType:_authToken.grant_type andStoreAtKey:_authTokenKey];
    
    [webserviceCall POST:[NSURL URLWithString:_authToken.url] parameters:@{ResponseRefreshTokenKey:_authToken.refresh_token} withSuccessHandler:^(WebserviceResponse *response) {
        
        [self POST:_url parameters:_parametersDict withSuccessHandler:successHandler withFailureHandler:failureHandler];
        
    } withFailureHandler:^(NSError *error) {
        
    }];
}

#pragma mark - Dealloc

- (void)dealloc
{
    receivedData = nil;
    _downloadFilePath = nil;
    
    if(_isShowLoader)
    {
        if (ObjLoader) {
            [ObjLoader hideLoader];
        }
    }
    
    if(_shouldDisableInteraction){
        [[[[UIApplication sharedApplication] delegate] window] setUserInteractionEnabled:YES];
    }
    
    if(connectionForFile)
        [connectionForFile cancel];
    
    connectionForFile = nil;
    
//    if(_notificationDelegate)
//    {
//        if([CMLibraryUtility checkIfStringContainsText:_successNotification])
//            [[NSNotificationCenter defaultCenter] removeObserver:_notificationDelegate name:_successNotification object:nil];
//        if([CMLibraryUtility checkIfStringContainsText:_failureNotification])
//            [[NSNotificationCenter defaultCenter] removeObserver:_notificationDelegate name:_failureNotification object:nil];
//        if([CMLibraryUtility checkIfStringContainsText:_progressNotification])
//            [[NSNotificationCenter defaultCenter] removeObserver:_notificationDelegate name:_progressNotification object:nil];
//    }
}

@end
