//
//  Loader.h
//
//  Created by Aditya Aggarwal on 16/04/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Loader : NSObject
{
    UIView *loaderView;
}

- (void)showLoader;
- (void)hideLoader;

@end
