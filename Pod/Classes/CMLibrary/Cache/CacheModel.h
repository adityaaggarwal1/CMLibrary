//
//  CacheModel.h
//
//  Created by Aditya Aggarwal on 09/04/14.
//
//

#import <Foundation/Foundation.h>

@interface CacheModel : NSObject{
    
}

@property (nonatomic, assign) NSInteger cacheId;
@property (nonatomic, retain) NSString *cacheKey;
@property (nonatomic, retain) id cacheValue;
@property (nonatomic, retain) NSDate *createdDate;
@property (nonatomic, retain) NSDate *modifiedDate;

@end
