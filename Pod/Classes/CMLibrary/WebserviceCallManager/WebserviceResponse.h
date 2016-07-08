//
//  WebserviceResponse.h
//
//  Created by Aditya Aggarwal on 24/04/14.
//
//

#import <Foundation/Foundation.h>

@interface WebserviceResponse : NSObject{
    
}

@property(nonatomic, assign) int downloadId;
@property(nonatomic, copy) NSString *webserviceUrl;
@property(nonatomic, copy) id webserviceResponse;
@property (nonatomic, assign) BOOL isResponseFromCache;

@end
