//
//  FlickrTableViewController.m
//  GastrofixCodeChallengeObjC
//
//  Created by Rabbot on 15/12/15.
//  Copyright © 2015 Gastrofix. All rights reserved.
//

#import "FlickrTableViewController.h"
#import "FlickrTableViewCell.h"
#import "FlickrPhoto.h"
#import "FlickrPhoto+CoreDataProperties.h"
#import "SyncSingleton.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
@import CoreData;

@interface FlickrTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSDateFormatter *presentationDateFormatter;

@end

@implementation FlickrTableViewController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FlickrPhoto" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"published" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Header View
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.image = [UIImage imageNamed:@"abrahamAvatar.jpg"];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 50.0;
        imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        imageView.layer.borderWidth = 1.0f;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        label.text = @"Jose Abraham (Gastrofix Challenge)";
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blueColor];
        [label sizeToFit];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [view addSubview:imageView];
        [view addSubview:label];
        view;
    });
    
    self.presentationDateFormatter = [[NSDateFormatter alloc] init];
    [self.presentationDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle the error appropriately.
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[SyncSingleton getInstance] downloadFlickrJsonData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FlickrTableViewCell *cell = (FlickrTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FlickrTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell indexPath:indexPath];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"flickrDetailSegue"]) {
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        DetailViewController *detailViewController = (DetailViewController *)segue.destinationViewController;
        detailViewController.flickrPhotoInfo = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
    }
}

- (void)configureCell:(FlickrTableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    FlickrPhoto *flickrItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.flickrImage sd_setImageWithURL:[NSURL URLWithString:flickrItem.media]];
    [cell.flickrTitle setText:flickrItem.title];
    [cell.publishedLabel setText:[NSString stringWithFormat:@"Published: %@", [self.presentationDateFormatter stringFromDate:flickrItem.published]]];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(FlickrTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] indexPath:indexPath];
            break;
        default:
            break;
    }
}

@end
