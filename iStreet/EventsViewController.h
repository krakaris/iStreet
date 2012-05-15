//
//  SecondViewController.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "IconDownloader.h"
#import "ServerCommunication.h"
#import "Event.h"

@interface EventsViewController : UIViewController <IconDownloaderDelegate, ServerCommunicationDelegate>
{
    NSMutableArray *_eventsByNight; 
    /* an array of arrays of events of a given date (considered making this a dictionary (date : events array), but the events must be ordered, which a dictionary is not.
     For example:
     eventsByNight[0] --> an array of events on 4/14/2012
     eventsByNight[1] --> an array of events on 4/12/2012
     eventsByNight[2] --> an array of events on 4/07/2012
     etc.
     */
    
    NSMutableDictionary *_iconsBeingDownloaded;
}

@property(nonatomic, retain) IBOutlet UITableView *eventsTable;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic, retain) IBOutlet UILabel *noUpcomingEvents;

- (Event *)eventAtIndexPath:(NSIndexPath *)indexPath;

/* Subclasses of EventsViewController must override these two methods */
- (NSArray *)getCoreDataEvents;
- (void)requestServerEventsData;

/* Optional override (recommended to call [super ...] first) */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data;
- (void)setPropertiesWithNewEventData:(NSArray *)newData;

@end
