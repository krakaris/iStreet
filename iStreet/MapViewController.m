//
//  MapViewController.m
//  iStreet
//
//  Created by Rishi on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    Campus = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pushCampus:(id)sender {
}

- (IBAction)pushCannon:(id)sender {
}

- (IBAction)pushCap:(id)sender {
}

- (IBAction)pushCharter:(id)sender {
}

- (IBAction)pushColonial:(id)sender {
}

- (IBAction)pushCottage:(id)sender {
}

- (IBAction)pushIvy:(id)sender {
}

- (IBAction)pushQuad:(id)sender {
}

- (IBAction)pushTI:(id)sender {
}

- (IBAction)pushTerrace:(id)sender {
}

- (IBAction)pushTower:(id)sender {
}
@end
