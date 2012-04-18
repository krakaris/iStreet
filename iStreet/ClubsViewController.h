//
//  MapViewController.h
//  iStreet
//
//  Created by Rishi on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  Alexa's change

#import <UIKit/UIKit.h>

@interface ClubsViewController : UIViewController {
    IBOutlet UIButton *Cannon;
    IBOutlet UIButton *Cap;
    IBOutlet UIButton *Cloister;
    IBOutlet UIButton *Colonial;
    IBOutlet UIButton *Cottage;
    IBOutlet UIButton *Ivy;
    IBOutlet UIButton *Quad;
    IBOutlet UIButton *TI;
    IBOutlet UIButton *Terrace;
    IBOutlet UIButton *Tower;
    //UIButton *Campus;
    IBOutlet UIButton *Charter;
     
    NSArray *clubs;
    
    __weak IBOutlet UILabel *dateLabel;
    
}
//@property (weak, nonatomic) IBOutlet UILabel *datelabel;


@end
