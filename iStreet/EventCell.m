//
//  EventsViewCell.m
//  iStreet
//
//  Created by Rishi on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventCell.h"
#import "User.h"
#import "AppDelegate.h"
@implementation EventCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // ALEXA - insert custom background code, label fonts, etc. here.
        //example:
        [self.textLabel setBackgroundColor:[UIColor clearColor]]; //necessary
        [self.detailTextLabel setBackgroundColor:[UIColor clearColor]]; //necessary
        
        //[self.contentView setBackgroundColor:[UIColor colorWithWhite:0 alpha:.5]]; //this obviously isn't the permanent color, just to show you though.
        //[self.contentView setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:76.0/255.0 alpha:1.0]];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
        [self.textLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:16]];
        //self.textLabel.textColor = [UIColor orangeColor];
        self.textLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        [self.detailTextLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:13]];
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
    
    NSString *userAttendingNetid = [[event userAttending] netid];
    NSString *myNetid = [(AppDelegate *)[[UIApplication sharedApplication] delegate] netID];
    
    
    if([userAttendingNetid isEqualToString:myNetid])
    {
        //[self.accessoryView setHidden:NO];
        //[self setAccessoryType:UITableViewCellAccessoryCheckmark];
        UIImage *image = [UIImage imageNamed:@"checkicon.png"];
        //UIImage *image = [UIImage imageNamed:@"beercap.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kCellHeight * 1.0/2, kCellHeight * 1.0/2)];
        [imageView setImage:image];
        self.accessoryView = imageView;
    }
    else 
        self.accessoryView = nil;
    
    
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
