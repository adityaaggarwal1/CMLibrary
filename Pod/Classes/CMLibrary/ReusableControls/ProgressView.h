//
//  ProgressView.h
//
//  Created by Aditya Aggarwal on 25/04/14.
//
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView{
    
    UIImageView *imgViewBackground;
    UIImageView *imgViewProgress;
    int xPosOfProgressBar;
}

@property (nonatomic, strong) UIImage *imageBackground;
@property (nonatomic, strong) UIImage *imageProgressBar;
@property (nonatomic, assign) float progress;

-(void)setBackgroundColorImageProgressBar:(UIColor *)color;

@end
