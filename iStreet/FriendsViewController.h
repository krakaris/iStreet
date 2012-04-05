//
//  FriendsViewController.h
//  iStreet
//
//  Created by Rishi on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimatedUIPickerView.h"

@interface FriendsViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    IBOutlet UIButton *Dates;
    
    __weak IBOutlet UILabel *plusLabel;
    AnimatedUIPickerView *picker;
}
- (IBAction)expandDates:(id)sender;


@end
