//
//  EventsViewCell.h
//  iStreet
//
//  Created by Rishi on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

enum cellConstants {
    kLoadingIndicatorTag = 1,
    kCellHeight =45
};

@interface EventCell : UITableViewCell

//set image/icon of the cell
- (void)setImage:(UIImage *)image;

// Returns true if the cell needs its icon to be downloaded, or false otherwise.
- (BOOL)packCellWithEventInformation:(Event *)event atIndexPath:(NSIndexPath *)indexPath whileScrolling:(BOOL)isScrolling;
@end
