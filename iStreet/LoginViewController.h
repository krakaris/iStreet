//
//  LoginViewController.h
//  iStreet
//
//  Created by Akarshan Kumar on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerDelegate <NSObject>
- (void) screenGotCancelled:(id) sender;
@end

@interface LoginViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *loginWebView;
@property (nonatomic, retain) NSURL *urlToLoad;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (assign) id delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andURL: (NSURL *) thisURL;

- (IBAction)cancelThisScreen:(id)sender;

@end


