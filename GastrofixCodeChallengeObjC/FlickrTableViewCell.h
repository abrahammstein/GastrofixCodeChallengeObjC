//
//  FlickrTableViewCell.h
//  GastrofixCodeChallengeObjC
//
//  Created by Rabbot on 15/12/15.
//  Copyright © 2015 Gastrofix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *flickrImage;
@property (nonatomic, weak) IBOutlet UILabel *flickrTitle;
@property (nonatomic, weak) IBOutlet UILabel *publishedLabel;

@end
