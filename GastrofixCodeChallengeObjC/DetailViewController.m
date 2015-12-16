//
//  DetailViewController.m
//  GastrofixCodeChallengeObjC
//
//  Created by Rabbot on 15/12/15.
//  Copyright © 2015 Gastrofix. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.flickrPhotoInfo.title;
    [self.webView loadHTMLString:[NSString stringWithFormat:@"<div style=\"font-family: Helvetica; padding: 1em;\"> %@ </div>", self.flickrPhotoInfo.itemDescription] baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
