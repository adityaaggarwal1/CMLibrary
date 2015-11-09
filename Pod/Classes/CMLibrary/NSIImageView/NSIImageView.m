//
//  NSIImageView.m
//  VideoTag
//
//  Created by Aditya Aggarwal on 24/04/14.
//
//

#import "NSIImageView.h"
#import "CMLibraryUtility.h"
#import "WebserviceCall.h"

@implementation NSIImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setImageFromURL:(NSString *)url
{
    [self setImage:nil];
    
    if(![CMLibraryUtility checkIfStringContainsText:url])
        return;
    
    [self setImageUrl:url];
    [self fetchImageFromUrl:url];
}

#pragma mark - Webservice manager

-(void)fetchImageFromUrl:(NSString *)url
{
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] initWithResponseType:WebserviceCallResponsePNG cachePolicy:WebserviceCallCachePolicyRequestFromCacheFirstAndThenFromUrlAndUpdateInCache];
    
    [webserviceCall downloadFileFromUrl:[NSURL URLWithString:url] withSuccessHandler:^(WebserviceResponse *response) {
        
        NSString *url = [response webserviceUrl];
        
        if(![_imageUrl isEqualToString:url])
            return;
        
        id responseObject = response.webserviceResponse;
        
        if([responseObject isKindOfClass:[NSData class]]){      // If response is NSData
            [self setImage:[UIImage imageWithData:responseObject]];
        }
        else if([responseObject isKindOfClass:[NSString class]]){       // If response is Filepath in string
            
            NSData *data = [NSData dataWithContentsOfFile:responseObject];
            [self setImage:[UIImage imageWithData:data]];
        }
        
    } withFailureHandler:^(NSError *error) {
        
    }];
}

- (void)dealloc
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
