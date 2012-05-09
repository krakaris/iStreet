//
//  AllEventsViewController.h
//  iStreet
//
//  Created by Rishi on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventsViewController.h"
#import "Facebook.h"

@interface AllEventsViewController : EventsViewController <FBSessionDelegate>
{
    BOOL _serverLoadedOnce;
}
@end
