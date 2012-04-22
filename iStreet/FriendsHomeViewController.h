//
//  FriendsHomeViewController.h
//  iStreet
//
//  Created by Akarshan Kumar on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"


@interface FriendsHomeViewController : UINavigationController <FBRequestDelegate, FBSessionDelegate>
{
    Facebook *facebook;

}


@property (nonatomic, retain) IBOutlet UIButton *fConnectButton;
@property (nonatomic, retain) Facebook *facebook;

- (IBAction)fbconnect:(id)sender;
- (void) loggedInLoadFriendsNow;

@end
