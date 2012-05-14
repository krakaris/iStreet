//
//  FriendCell.h
//  iStreet
//
//  Created by Alexa Krakaris on 5/4/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <Foundation/Foundation.h>

enum friendCellConstants {
    fCellHeight = 50,
    fCellImageHeight = 50
};

@interface FriendCell : UITableViewCell

- (void)setImage:(UIImage *)image;

@end
