//
//  AuthToken.h
//  Pods
//
//  Created by Aditya Aggarwal on 7/1/16.
//
//

#import <Foundation/Foundation.h>

@interface AuthToken : NSObject <NSCoding>

@property (strong, nonatomic) NSString *access_token;
@property (strong, nonatomic) NSString *token_type;
@property (strong, nonatomic) NSNumber *expires_in;
@property (strong, nonatomic) NSString *scope;
@property (strong, nonatomic) NSString *refresh_token;
@property (strong, nonatomic) NSString *client_id;
@property (strong, nonatomic) NSString *client_secret;
@property (strong, nonatomic) NSString *grant_type;
@property (strong, nonatomic) NSString *url;

@end
