//
//  EventsViewCell.m
//  iStreet
//
//  Created by Rishi on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventCell.h"

@implementation EventCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // ALEXA - insert custom background code, label fonts, etc. here.
        //example:
        [self.textLabel setBackgroundColor:[UIColor clearColor]]; //necessary
        [self.detailTextLabel setBackgroundColor:[UIColor clearColor]]; //necessary
        [self.contentView setBackgroundColor:[UIColor colorWithWhite:0 alpha:.7]]; //this obviously isn't the permanent color, just to show you though.
        //random font...
        [self.textLabel setFont:[UIFont fontWithName:@"Optima" size:16]];
        self.textLabel.textColor = [UIColor orangeColor];
        self.detailTextLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        [self.detailTextLabel setFont:[UIFont fontWithName:@"Optima" size:12]];
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    CGSize itemSize = CGSizeMake(kCellHeight, kCellHeight);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [image drawInRect:imageRect];
    [self.imageView setImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
}

- (BOOL)packCellWithEventInformation:(Event *)event atIndexPath:(NSIndexPath *)indexPath whileScrolling:(BOOL)isScrolling
{
    //If there is an activity indicator, remove it.
    [(UIActivityIndicatorView *)[self.contentView viewWithTag:kLoadingIndicatorTag] removeFromSuperview];
    
    // If there is no event title, make the title "On tap"
    [self.textLabel setText:([event.title isEqualToString:@""] ? @"On Tap" : event.title)];
    [self.detailTextLabel setText:event.name];
    
    if([event.poster isEqualToString:@""])
    {
        NSString *imageName = [NSString stringWithFormat:@"%@.png", event.name];
        [self setImage:[UIImage imageNamed:imageName]];
        return false;
    }
    
    // Use the icon if it's already available
    if (event.posterImageData)
    {
        [self setImage:[UIImage imageWithData:event.posterImageData]];
        return false;
    }
    
    // Otherwise, unless the table is scrolling, start downloading the icon.
    // Meanwhile, set a placeholder image.
    [self setImage:[UIImage imageNamed:@"Placeholder.png"]];     

    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGSize imageViewSize = self.imageView.image.size;
    [loadingIndicator setCenter:CGPointMake(imageViewSize.width/2, imageViewSize.height/2)];
    [loadingIndicator setTag:kLoadingIndicatorTag];
    [self.imageView addSubview:loadingIndicator];
    [loadingIndicator startAnimating];

    
    return !isScrolling;
}

@end
