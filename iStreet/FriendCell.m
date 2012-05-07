//
//  FriendCell.m
//  iStreet
//
//  Created by Alexa Krakaris on 5/4/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "FriendCell.h"

@implementation FriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // ALEXA - insert custom background code, label fonts, etc. here.
        //example:
        [self.textLabel setBackgroundColor:[UIColor clearColor]]; //necessary
        [self.detailTextLabel setBackgroundColor:[UIColor clearColor]]; //necessary
        
        [self.contentView setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:76.0/255.0 alpha:1.0]];
        
        [self.textLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:16]];
        self.textLabel.textColor = [UIColor blackColor];
    }
    return self;
}

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
