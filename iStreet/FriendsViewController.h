//
//  FriendsViewController.h
//  iStreet
//
//  Created by Akarshan Kumar on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Facebook.h"
#import "JSON.h"
#import "ServerCommunication.h"
#import "User.h"

@interface FriendsViewController : UIViewController <FBSessionDelegate, FBRequestDelegate, UIAlertViewDelegate, UITabBarControllerDelegate, ServerCommunicationDelegate>
{
    Facebook *localFacebook;
    NSArray *friendsArray;
    Facebook *fb;
    BOOL alreadyLoadedFriends;
    User *userInCoreData;
}


@property (nonatomic, retain) IBOutlet UIButton *fConnectButton;
@property (nonatomic, retain) IBOutlet UILabel *loadingFriendsLabel;
@property (nonatomic, retain) Facebook *fb;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)fbconnect:(id)sender;

@end
