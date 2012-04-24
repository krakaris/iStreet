//
//  FriendsTableViewController.h
//  iStreet
//
//  Created by Akarshan Kumar on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsTableViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
{
    
    BOOL isFiltered;
    CGRect originalSearchBarFrame;
}

@property (assign) BOOL isFiltered;

@property (strong, nonatomic) NSMutableArray *friendslist;
@property (strong, nonatomic) NSMutableArray *filteredFriendsList;
@property (strong, nonatomic) NSMutableArray *justFriendNames;
@property (strong, nonatomic) NSMutableArray *sectionsIndex;

@property (strong, nonatomic) IBOutlet UITableView *friendsTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
