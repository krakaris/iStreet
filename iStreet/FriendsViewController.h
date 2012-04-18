//
//  FriendsViewController.h
//  iStreet
//
//  Created by Akarshan Kumar on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface FriendsViewController : UIViewController <FBSessionDelegate, FBRequestDelegate>
{
    Facebook *facebook;
    
}


@property (nonatomic, retain) IBOutlet UIButton *fConnectButton;
@property (nonatomic, retain) Facebook *facebook;

- (IBAction)fbconnect:(id)sender;
- (void) loggedInLoadFriendsNow;

@end
