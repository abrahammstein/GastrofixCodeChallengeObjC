//
//  FlickrPhoto+CoreDataProperties.h
//  GastrofixCodeChallengeObjC
//
//  Created by Rabbot on 15/12/15.
//  Copyright © 2015 Gastrofix. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FlickrPhoto.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlickrPhoto (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *author;
@property (nullable, nonatomic, retain) NSString *authorId;
@property (nullable, nonatomic, retain) NSDate *dateTaken;
@property (nullable, nonatomic, retain) NSString *itemDescription;
@property (nullable, nonatomic, retain) NSString *link;
@property (nullable, nonatomic, retain) NSString *media;
@property (nullable, nonatomic, retain) NSDate *published;
@property (nullable, nonatomic, retain) NSString *tags;
@property (nullable, nonatomic, retain) NSString *title;

@end

NS_ASSUME_NONNULL_END
