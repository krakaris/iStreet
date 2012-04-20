//
//  MapViewController.h
//  iStreet
//
//  Created by Rishi on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  Alexa's change

#import <UIKit/UIKit.h>

@interface ClubsViewController : UIViewController {

    NSMutableData *receivedData; 
    NSMutableArray *clubsList;
    __weak IBOutlet UILabel *dateLabel;
}
//@property (weak, nonatomic) IBOutlet UILabel *datelabel;


@end
