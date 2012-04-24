//
//  AppDelegate.m
//  iStreet
//
//  Created by Rishi on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
// 

#import "AppDelegate.h"
#import "Club+Create.h"
#import "User.h"

#import "Event.h"  

NSString *const DataLoadedNotificationString = @"Application data finished loading";

@interface AppDelegate ()
- (void)setupCoreData;
@end

@implementation AppDelegate

@synthesize window = _window, netID, document, appDataLoaded;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    netID = @"<skipped login>";
    appDataLoaded = NO;
    // Override point for customization after application launch.
    //UIView *loginWebView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //[self.view presentModalViewController:loginWebView animated:YES completion:^{}];
    //[self.window.subviews.lastObject presentModalViewController:loginWebView animated:YES];
    
    NSLog(@"going to sleep for NSFileManager startup (only for simulator)...");
    //[NSThread sleepForTimeInterval:5];
    NSLog(@"wakie wakie eggs and bakie");
    
    
    /* THIS CODE SHOULD BE CALLED ONLY AFTER A SUCCESSFUL CAS LOGIN */ 
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *dataURL = [[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    dataURL = [dataURL URLByAppendingPathComponent:@"database"];
    self.document = [[UIManagedDocument alloc] initWithFileURL:dataURL];
    
    if ([fm fileExistsAtPath:[dataURL path]]) 
    {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) 
            {
                NSLog(@"successfully opened database!");
                
                /*
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
                request.predicate = [NSPredicate predicateWithFormat:@"event_id = %d", 100];
                
                NSError *error;
                NSArray *events = [document.managedObjectContext executeFetchRequest:request error:&error];
                for(int i = 0; i < [events count]; i++)
                {
                    Event *e = [events objectAtIndex:i];
                    NSLog(@"%@: %@", e.event_id, e.title);
                }
                
                */
                appDataLoaded = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:DataLoadedNotificationString object:self];
                /*
                 NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Club"];                
                 NSError *error;
                 NSLog(@"listing clubs in data...");
                 NSArray *clubs = [document.managedObjectContext executeFetchRequest:request error:&error];
                 for(int i = 0; i < [clubs count]; i++)
                 {
                 Club *club = [clubs objectAtIndex:i];
                 //NSLog(@"%@", club.name);
                 Club *sameClub = [Club clubWithData:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", club.club_id] forKey:@"club_id"]];
                 }
                 NSLog(@"testing again!");
                 clubs = [document.managedObjectContext executeFetchRequest:request error:&error];
                 for(int i = 0; i < [clubs count]; i++)
                 {
                 Club *club = [clubs objectAtIndex:i];
                 NSString *events = @"";
                 for(Event *event in club.whichEvents)
                 events = [events stringByAppendingFormat:@"%@, ", event.title];
                 NSLog(@"%@: %@", club.name, events);
                 }
                 */
                
                 //List all events in data
                 /*NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];                
                 NSError *error;
                 NSLog(@"listing events in data...");
                 NSArray *events = [document.managedObjectContext executeFetchRequest:request error:&error];
                 for(int i = 0; i < [events count]; i++)
                 {
                 Event *event = [events objectAtIndex:i];
                 NSLog(@"%@", event.title);
                 }
                NSLog(@"done loading events in data");*/
            }
            if (!success) NSLog(@"couldn’t open document at %@", [dataURL path]);
        }]; 
    } 
    else 
    {
        [self.document saveToURL:dataURL forSaveOperation:UIDocumentSaveForCreating
               completionHandler:^(BOOL success) {
                   if (success) 
                   {
                       [self setupCoreData];
                       NSLog(@"successfully created database!");  
                       appDataLoaded = YES;
                       [[NSNotificationCenter defaultCenter] postNotificationName:DataLoadedNotificationString object:self];
                   }
                   if (!success) NSLog(@"couldn’t create document at %@", [dataURL path]);
                   
               }];
        
    }    
    
    return YES;
}

/*
 Is called the first time that the application runs in order to create the database.
 */
- (void)setupCoreData
{
    NSLog(@"setting up core data...");
    int CONNECTION_TIMEOUT = 8;
    NSURL *clubsURL = [NSURL URLWithString:@"http://istreetsvr.heroku.com/clubslist"];
    NSURLRequest *request = [NSURLRequest requestWithURL:clubsURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:CONNECTION_TIMEOUT];
    NSURLResponse *response;
    NSLog(@"sending request for clubs list...");
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    NSLog(@"data recieved!");
    if(!data)
    {
        //APPROPRIATELY HANDLE WEB FAILURE!
        NSLog(@"clubs list connection failed");
        return;
    }
    
    NSArray *clubs = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    for (NSDictionary *clubInformation in clubs)
    {
        NSLog(@"%@", [clubInformation objectForKey:@"name"]);
        [Club clubWithData:clubInformation];
    }
    
    User *thisUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:document.managedObjectContext];
    [thisUser setNetid:netID];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
