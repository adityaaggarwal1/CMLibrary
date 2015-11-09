//
//  CMLibraryUtility.m
//  EdPlace
//
//  Created by Aditya Aggarwal on 1/22/15.
//

#import "CMLibraryUtility.h"

@implementation CMLibraryUtility

+(BOOL)checkIfStringContainsText:(NSString *)string
{
    if(!string || string == NULL || [string isEqual:[NSNull null]])
        return FALSE;
    
    NSString *newString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([newString isEqualToString:@""])
        return FALSE;
    
    return TRUE;
}

+(NSString *)getStringFromChar:(char const *)characterString
{
    if(!characterString || characterString == NULL)
        return nil;
    
    return [NSString stringWithUTF8String:characterString];
}

+(void)addBasicConstraintsOnSubView:(UIView *)subView onSuperView:(UIView *)superView
{
    [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [superView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[subView]-0-|",subView.frame.origin.y] options: NSLayoutFormatAlignmentMask metrics:nil views:NSDictionaryOfVariableBindings(subView)]];
    [superView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"|-%f-[subView]-%f-|",subView.frame.origin.x,subView.frame.origin.x] options: NSLayoutFormatAlignmentMask metrics:nil views:NSDictionaryOfVariableBindings(subView)]];
}

+(void)showAlert:(NSString *)title withMessage:(NSString *)message delegate:(id)delegate
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

+(NSString *)getCacheResourcePathByAppendingFileInnerPath:(NSString *)innerFilePath
{
    if(![CMLibraryUtility checkIfStringContainsText:innerFilePath])
        return innerFilePath;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    return [cachesDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@",innerFilePath]];
}

@end
