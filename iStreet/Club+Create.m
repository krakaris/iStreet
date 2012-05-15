//
//  Club+Create.m
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import "Club+Create.h"
#import "AppDelegate.h"

#import "Event.h"

@implementation Club (Create)

// Return the club entity with the given data (clubs are unique based on the club_id key)
+ (Club *)clubWithData:(NSDictionary *)clubData
{
    int clubID = [(NSString *)[clubData objectForKey:@"club_id"] intValue];
    
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Club"];
    request.predicate = [NSPredicate predicateWithFormat:@"club_id == %d", clubID];
    
    NSError *error;
    NSArray *clubs = [document.managedObjectContext executeFetchRequest:request error:&error];
    if([clubs count] > 1)
        [NSException raise:@"More than one club in core data with a given id" format:nil];
    
    Club *club;
    if ([clubs count] == 0) 
        club = [NSEntityDescription insertNewObjectForEntityForName:@"Club" inManagedObjectContext:document.managedObjectContext];
    else 
        club = [clubs objectAtIndex:0];
    
    NSEnumerator *keyEnumerator = [clubData keyEnumerator];
    for(NSString *key in keyEnumerator)
        [club setValue:[clubData objectForKey:key] forKey:key];
    
    return club;
}

@end
