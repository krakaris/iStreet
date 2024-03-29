//
//  FriendCell.m
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import "FriendCell.h"
#import "AppDelegate.h"

@implementation FriendCell

// Init the cell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        [self.detailTextLabel setBackgroundColor:[UIColor clearColor]];
        
        [self.contentView setBackgroundColor:orangeTableColor];
        
        [self.textLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:16]];
        self.textLabel.textColor = [UIColor blackColor];
    }
    return self;
}

// Set the cell's image
- (void)setImage:(UIImage *)image
{
    CGSize itemSize = CGSizeMake(fCellImageHeight, fCellImageHeight);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [image drawInRect:imageRect];
    [self.imageView setImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
}

@end
