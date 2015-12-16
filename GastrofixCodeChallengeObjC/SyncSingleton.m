//
//  SyncSingleton.m
//  GastrofixCodeChallengeObjC
//
//  Created by Rabbot on 15/12/15.
//  Copyright © 2015 Gastrofix. All rights reserved.
//

#import "SyncSingleton.h"
#import "AppDelegate.h"
#import "FlickrPhoto.h"
#import "FlickrPhoto+CoreDataProperties.h"
@import CoreData;

@implementation SyncSingleton

static SyncSingleton *instanciaHelper = nil;

+ (SyncSingleton *)getInstance
{
    
    @synchronized([SyncSingleton class])
    {
        if (!instanciaHelper) {
            instanciaHelper = [[self alloc] init];
        }
        return instanciaHelper;
    }
    return nil;
}

+ (id)alloc
{
    @synchronized([SyncSingleton class])
    {
        instanciaHelper = [super alloc];
        return instanciaHelper;
    }
    
    return nil;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        // initialize stuff here
        [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
            if (![note isEqual:managedObjectContext]) {
                [managedObjectContext performBlock:^{
                    [managedObjectContext mergeChangesFromContextDidSaveNotification:note];
                }];
            }
        }];
    }
    
    return self;
}

- (NSInteger)checkIfFlickrPhotoExists:(NSString *)media
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *backgroundObjectContext = appDelegate.backgroundObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"FlickrPhoto" inManagedObjectContext:backgroundObjectContext]];
    [request setFetchLimit:1];
    [request setPredicate:[NSPredicate predicateWithFormat:@"media == %@", media]];
    
    return [backgroundObjectContext countForFetchRequest:request error:nil];
}

- (void)saveFlickrPhoto:(NSString *)tags authorId:(NSString *)authorId author:(NSString *)author published:(NSDate *)published itemDescription:(NSString *)itemDescription dateTaken:(NSDate *)dateTaken media:(NSString *)media link:(NSString *)link title:(NSString *)title
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *backgroundObjectContext = appDelegate.backgroundObjectContext;
    
    FlickrPhoto *newFlickrPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"FlickrPhoto" inManagedObjectContext:backgroundObjectContext];
    [newFlickrPhoto setTags:tags];
    [newFlickrPhoto setAuthorId:authorId];
    [newFlickrPhoto setAuthor:author];
    [newFlickrPhoto setPublished:published];
    [newFlickrPhoto setItemDescription:itemDescription];
    [newFlickrPhoto setDateTaken:dateTaken];
    [newFlickrPhoto setMedia:media];
    [newFlickrPhoto setLink:link];
    [newFlickrPhoto setTitle:title];
    
    NSError *error;
    if (![backgroundObjectContext save:&error]) {
        NSLog(@"The FlickrPhoto can't be saved.");
    }
}

- (void)downloadFlickrJsonData
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfiguration.allowsCellularAccess = YES;
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://www.flickr.com/services/feeds/photos_public.gne?tags=soccer&format=json&jsoncallback=?"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                NSError *jsonError;
                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSMutableString *mutableString = [NSMutableString stringWithString:[string substringFromIndex:1]];
                mutableString = [NSMutableString stringWithString:[mutableString substringToIndex:mutableString.length - 1]];
                mutableString = [NSMutableString stringWithString:[mutableString stringByReplacingOccurrencesOfString:@"\\'" withString:@""]];
                NSData *utfData = [mutableString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *flickrJson = [NSJSONSerialization JSONObjectWithData:utfData options:NSJSONReadingAllowFragments error:&jsonError];
                
                if (!jsonError) {
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
                        
                        NSArray *items = (NSArray *)flickrJson[@"items"];
                        for (NSDictionary *item in items) {
                            NSString *tags = (NSString *)item[@"tags"];
                            NSString *authorId = (NSString *)item[@"author_id"];
                            NSString *author = (NSString *)item[@"author"];
                            NSDate *published = [dateFormatter dateFromString:(NSString *)item[@"published"]];
                            NSMutableString *itemDescription = [[NSMutableString alloc] initWithString:@""];
                            NSString *itemDesc = (NSString *)item[@"description"];
                            if (itemDesc != nil) {
                                itemDescription = [[NSMutableString alloc] initWithString:itemDesc];
                            }
                            
                            NSDate *dateTaken = [dateFormatter dateFromString:(NSString *)item[@"date_taken"]];
                            NSDictionary *media = (NSDictionary *)item[@"media"];
                            NSString *mediaUrl = (NSString *)media[@"m"];
                            NSString *link = (NSString *)item[@"link"];
                            NSString *title = (NSString *)item[@"title"];
                            
                            if ([self checkIfFlickrPhotoExists:mediaUrl] != 1) {
                                [self saveFlickrPhoto:tags authorId:authorId author:author published:published itemDescription:itemDescription dateTaken:dateTaken media:mediaUrl link:link title:title];
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                        });
                    });
                    
                } else {
                    NSLog(@"jsonError: %@", jsonError.description);
                }
            } else {
                // The JSON is not well formed
                NSLog(@"The JSON is not well formed");
            }
        } else {
            // Cannot handle the connection sueccessfuly
            NSLog(@"Cannot hande the connection susccessfuly");
        }
        
    }] resume];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
