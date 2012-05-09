//
//  User+Create.m
//  iStreet
//
//  Created by Rishi on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User+Create.h"
#import "AppDelegate.h"

@implementation User (Create)

+ (User *)userWithNetid:(NSString *)netid
{    
    if(netid == nil)
    {
        [NSException raise:@"Attempting to get/create a user without a netid" format:nil];
        return nil;
    }
    
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"netid like %@", netid];
    
    NSError *error;
    NSArray *users = [document.managedObjectContext executeFetchRequest:request error:&error];
    if([users count] > 1)
        [NSException raise:@"More than one user in core data with a given netid" format:nil];
    
    User *user;
    if ([users count] == 0) 
    {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:document.managedObjectContext];
        [user setNetid:netid];
    }
    else 
        user = [users objectAtIndex:0];
    
    return user;
}

@end
