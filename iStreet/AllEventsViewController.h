//
//  AllEventsViewController.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import "EventsViewController.h"
#import "Facebook.h"

@interface AllEventsViewController : EventsViewController <FBSessionDelegate, UIAlertViewDelegate>
{
    BOOL _userLoggedOut;
}
@end
