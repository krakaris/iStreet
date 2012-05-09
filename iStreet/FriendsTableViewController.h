//
//  FriendsTableViewController.h
//  iStreet
//
//  Created by Akarshan Kumar on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunication.h"
#import "EventsAttendingTableViewController.h"
#import "Facebook.h"
#import "IconDownloader.h"
#import "User.h"

@interface FriendsTableViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, ServerCommunicationDelegate, UIAlertViewDelegate, FBSessionDelegate, IconDownloaderDelegate>
{
    EventsAttendingTableViewController *eatvc;
    BOOL isFiltered;
    CGRect originalSearchBarFrame;
    
    NSString *fbid_selected;
    NSString *name_selected;
    NSMutableArray *eventsAttending_selected;
    
    NSMutableDictionary *_iconsBeingDownloaded;
    
}


@property (assign) BOOL isFiltered;

@property (strong, nonatomic) NSString *fbid_selected;
@property (strong, nonatomic) NSString *name_selected;
@property (strong, nonatomic) NSMutableArray *eventsAttending_selected;

@property (strong, nonatomic) NSMutableArray *friendslist;
@property (strong, nonatomic) NSMutableArray *favoriteFriendsList;
@property (strong, nonatomic) NSMutableArray *filteredFriendsList;
@property (strong, nonatomic) NSMutableArray *justFriendNames;
@property (strong, nonatomic) NSMutableArray *sectionsIndex;

@property (strong, nonatomic) IBOutlet UITableView *friendsTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *logoutButton;

- (IBAction) logoutOfFacebook: (id) sender;

@end
