//
//  FriendCell.h
//  iStreet
//
//  Created by Alexa Krakaris on 5/4/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <Foundation/Foundation.h>

enum friendCellConstants {
    fCellHeight =50,
    fCellImageHeight = 36
};

//#define foregroundColor [UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:76.0/255.0 alpha:1.0]

@interface FriendCell : UITableViewCell

- (void)setImage:(UIImage *)image;

@end
