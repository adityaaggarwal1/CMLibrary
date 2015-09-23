//
//  NSIImageView.h
//  VideoTag
//
//  Created by Aditya Aggarwal on 24/04/14.
//
//

#import <UIKit/UIKit.h>

@interface NSIImageView : UIImageView{
    
}

@property (nonatomic, retain) NSString *imageUrl;

-(void)setImageFromURL:(NSString *)url;

@end
