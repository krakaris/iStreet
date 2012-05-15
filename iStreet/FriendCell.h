//
//  FriendCell.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import <Foundation/Foundation.h>

enum friendCellConstants {
    fCellHeight = 50,
    fCellImageHeight = 50
};

@interface FriendCell : UITableViewCell

- (void)setImage:(UIImage *)image;

@end
