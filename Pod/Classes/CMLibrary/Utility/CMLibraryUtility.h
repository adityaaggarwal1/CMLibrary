//
//  CMLibraryUtility.h
//  EdPlace
//
//  Created by Aditya Aggarwal on 1/22/15.
//  Copyright (c) 2015 Net Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CMLibraryUtility : NSObject

+(BOOL)checkIfStringContainsText:(NSString *)string;
+(NSString *)getStringFromChar:(char const *)characterString;
+(void)addBasicConstraintsOnSubView:(UIView *)subView onSuperView:(UIView *)superView;
+(void)showAlert:(NSString *)title withMessage:(NSString *)message delegate:(id)delegate;
+(NSString *)getCacheResourcePathByAppendingFileInnerPath:(NSString *)innerFilePath;

@end
