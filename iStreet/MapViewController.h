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
    IBOutlet UIButton *Cottage;
    IBOutlet UIButton *Ivy;
    IBOutlet UIButton *Quad;
    IBOutlet UIButton *TI;
    IBOutlet UIButton *Terrace;
    IBOutlet UIButton *Tower;
    //UIButton *Campus;
    IBOutlet UIButton *Campus;
    
    __weak IBOutlet UILabel *dateLabel;
   // __weak IBOutlet UILabel *datelabel;
}
//@property (weak, nonatomic) IBOutlet UILabel *datelabel;

- (IBAction)pushCampus:(id)sender;
- (IBAction)pushCannon:(id)sender;
- (IBAction)pushCap:(id)sender;
- (IBAction)pushCharter:(id)sender;
- (IBAction)pushColonial:(id)sender;
- (IBAction)pushCottage:(id)sender;
- (IBAction)pushIvy:(id)sender;
- (IBAction)pushQuad:(id)sender;
- (IBAction)pushTI:(id)sender;
- (IBAction)pushTerrace:(id)sender;
- (IBAction)pushTower:(id)sender;


@end
