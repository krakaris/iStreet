//
//  FriendsTableViewController.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import <UIKit/UIKit.h>
#import "ServerCommunication.h"
#import "EventsAttendingTableViewController.h"
#import "Facebook.h"
#import "IconDownloader.h"
#import "User.h"

@interface FriendsTableViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, ServerCommunicationDelegate, UIAlertViewDelegate, FBSessionDelegate, IconDownloaderDelegate>
{
    BOOL isFiltered;
    CGRect originalSearchBarFrame;
    
    NSNumber *fbid_selected;
    NSString *name_selected;
    NSMutableArray *eventsAttending_selected;
    
    NSMutableDictionary *_iconsBeingDownloaded;
}


@property (assign) BOOL isFiltered;

@property (strong, nonatomic) NSNumber *fbid_selected;
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
- (NSDictionary *) getUserAtIndexPath: (NSIndexPath *) indexPath;

@end
