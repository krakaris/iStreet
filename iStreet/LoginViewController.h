//
//  LoginViewController.h
//  iStreet
//
//  Created by Akarshan Kumar on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerDelegate;

@interface LoginViewController : UIViewController <UIWebViewDelegate>
{
    NSString *html;
    IBOutlet UIWebView *loginWebView;
}

@property (nonatomic, retain) NSString *html;
@property (nonatomic, retain) IBOutlet UIWebView *loginWebView;
@property __strong NSMutableArray *delegates;


// Present a loginviewcontroller - called from ServerCommunication. If multiple requests call this method, multiple login view controllers are NOT presented; instead, the caller is added as a delegate, and once the user has successfully logged in, all delegates are informed.
+ (void)presentSharedLoginViewControllerWithHTMLString:(NSString *)markup andDelegate:(id <LoginViewControllerDelegate>)delegate inViewController:(UIViewController *)parentViewController;

@end

@protocol LoginViewControllerDelegate <NSObject>
// This method is called on the delegate once the user has logged in through the webview.
- (void)userLoggedIn:(id)sender;
@end



