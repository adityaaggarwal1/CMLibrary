//
//  ProgressView.m
//
//  Created by Aditya Aggarwal on 25/04/14.
//
//

#import "ProgressView.h"

@implementation ProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

-(void)awakeFromNib
{
    [self setup];
}

-(void)setup
{
    xPosOfProgressBar = 1;
    [self addBackgroundImageView];
    [self addProgressBarImageView];
}

-(void)addBackgroundImageView
{
    imgViewBackground = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:imgViewBackground];
    
    if(_imageBackground)
        [imgViewBackground setImage:_imageBackground];
}

-(void)addProgressBarImageView
{
    imgViewProgress = [[UIImageView alloc] initWithFrame:CGRectMake(xPosOfProgressBar, 1, 0, self.frame.size.height - 2)];
    [self addSubview:imgViewProgress];
    
    if(_imageProgressBar)
        [imgViewProgress setImage:_imageProgressBar];
}

-(void)setImageBackground:(UIImage *)imageBackground
{
    if(!imageBackground)
        return;
    
    
    _imageBackground = imageBackground;
    [imgViewBackground setImage:imageBackground];
}

-(void)setImageProgressBar:(UIImage *)imageProgressBar
{
    if(!imageProgressBar)
        return;
    
    _imageProgressBar = imageProgressBar;
    [imgViewProgress setImage:imageProgressBar];
}

-(void)setBackgroundColorImageProgressBar:(UIColor *)color
{
    if(!color)
        return;
    
    [imgViewProgress setBackgroundColor:color];
}

-(void)setProgress:(float)progress
{
    if(progress < 0 || progress > 1 || isnan(progress))
        return;
    
    float progressBarMaxWidth = self.frame.size.width - (xPosOfProgressBar * 2);
    
    [imgViewProgress setFrame:CGRectMake(imgViewProgress.frame.origin.x, imgViewProgress.frame.origin.y, progressBarMaxWidth * progress, imgViewProgress.frame.size.height)];
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
