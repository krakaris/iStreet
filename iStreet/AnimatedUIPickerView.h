//
//  AnimatedUIPickerView.h
//  Squash Court Report
//
//  Created by Rishi Narang on 10/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 AnimatedUIPickerView builds on top of UIPickerView with a few simple animation methods for having a UIPickerView
 enter and exit the screen.
 */
@interface AnimatedUIPickerView : UIPickerView

- (void)addToView:(UIView *)view;
- (void)enterSuperviewAnimatedWithRow:(int)row;
- (void)exitSuperviewAnimated;

@end
