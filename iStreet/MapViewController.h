//
//  MapViewController.h
//  iStreet
//
//  Created by Rishi on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController {
    IBOutlet UIButton *Cannon;
    IBOutlet UIButton *Cap;
    IBOutlet UIButton *Charter;
    IBOutlet UIButton *Colonial;
    UIButton *Cottage;
    UIButton *Ivy;
    UIButton *Quad;
    UIButton *TI;
    UIButton *Terrace;
    UIButton *Tower;
    //UIButton *Campus;
    IBOutlet UIButton *Campus;
    
}

- (IBAction)pushCampus:(id)sender;


@end
