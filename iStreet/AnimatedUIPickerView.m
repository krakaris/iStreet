//
//  AnimatedUIPickerView.m
//  Squash Court Report
//
//  Created by Rishi Narang on 10/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimatedUIPickerView.h"

@implementation AnimatedUIPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/* Add the AnimatedUIPickerView as a subview of view, hidden below the bottom of its superview, and with the hidden field set to YES */
- (void)addToView:(UIView *)view
{
    [view addSubview:self];
    self.frame = CGRectMake(0, view.frame.size.height, self.frame.size.width, self.frame.size.height);
    self.hidden = YES;
}

- (void)enterSuperviewAnimatedWithRow:(int)row
{
    [self.delegate pickerView:self didSelectRow:row inComponent:0]; 
    [self selectRow:row inComponent:0 animated:NO];
    
    self.hidden = NO;
    CGRect endFrame = CGRectMake(0, self.superview.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:0.45 delay:0 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{self.frame = endFrame;}  
                     completion:NULL];
}

- (void)exitSuperviewAnimated
{
    CGRect endFrame = CGRectMake(0, self.superview.frame.size.height, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:0.45 delay:0 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{self.frame = endFrame;}  
                     completion:^(BOOL finished){self.hidden = YES; [self selectRow:0 inComponent:0 animated:NO];
                     }];
}


@end
