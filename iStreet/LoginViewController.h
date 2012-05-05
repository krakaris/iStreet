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


+ (void)presentSharedLoginViewControllerWithHTMLString:(NSString *)markup andDelegate:(id <LoginViewControllerDelegate>)delegate inViewController:(UIViewController *)parentViewController;

@end

@protocol LoginViewControllerDelegate <NSObject>
- (void)userLoggedIn:(id)sender;
@end



