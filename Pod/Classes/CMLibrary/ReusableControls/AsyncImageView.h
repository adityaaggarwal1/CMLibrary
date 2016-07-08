//
//  AsyncImageView.h
//
//  Created by Aditya Aggarwal on 24/04/14.
//
//

#import <UIKit/UIKit.h>

@interface AsyncImageView : UIImageView{
    
}

@property (nonatomic, retain) NSString *imageUrl;

-(void)setImageFromURL:(NSString *)url;

@end
