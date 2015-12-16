//
//  SyncSingleton.h
//  GastrofixCodeChallengeObjC
//
//  Created by Rabbot on 15/12/15.
//  Copyright © 2015 Gastrofix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncSingleton : NSObject

+ (SyncSingleton*)getInstance;

- (void)downloadFlickrJsonData;

@end
