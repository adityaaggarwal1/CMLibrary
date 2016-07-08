//
//  AuthToken.m
//  Pods
//
//  Created by Aditya Aggarwal on 7/1/16.
//
//

#import "AuthToken.h"

#define AccessToken @"access_token"
#define TokenType @"token_type"
#define ExpiresIn @"expires_in"
#define Scope @"scope"
#define RefreshToken @"refresh_token"
#define ClientId @"client_id"
#define SecretKey @"secret_key"
#define GrantType @"grant_type"
#define RefreshUrl @"refresh_url"

@implementation AuthToken

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        [self setAccess_token:[coder decodeObjectForKey:AccessToken]];
        [self setToken_type:[coder decodeObjectForKey:TokenType]];
        [self setExpires_in:[coder decodeObjectForKey:ExpiresIn]];
        [self setScope:[coder decodeObjectForKey:Scope]];
        [self setRefresh_token:[coder decodeObjectForKey:RefreshToken]];
        [self setClient_id:[coder decodeObjectForKey:ClientId]];
        [self setClient_secret:[coder decodeObjectForKey:SecretKey]];
        [self setGrant_type:[coder decodeObjectForKey:GrantType]];
        [self setUrl:[coder decodeObjectForKey:RefreshUrl]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_access_token forKey:AccessToken];
    [coder encodeObject:_token_type forKey:TokenType];
    [coder encodeObject:_expires_in forKey:ExpiresIn];
    [coder encodeObject:_scope forKey:Scope];
    [coder encodeObject:_refresh_token forKey:RefreshToken];
    [coder encodeObject:_client_id forKey:ClientId];
    [coder encodeObject:_client_secret forKey:SecretKey];
    [coder encodeObject:_grant_type forKey:GrantType];
    [coder encodeObject:_url forKey:RefreshUrl];
}

@end
