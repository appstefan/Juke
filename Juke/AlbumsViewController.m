//
//  AlbumsViewController.m
//  Juke
//
//  Created by Stefan Britton on 2/6/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import "AlbumsViewController.h"
#import "AppDelegate.h"
#import "CachedImageView.h"

@interface AlbumsViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) SPTSession *session;
@property (strong, nonatomic) NSMutableArray *results;
@end

@implementation AlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionView];
    [self getAlbums];
}

#pragma mark - Setup

- (void)setupCollectionView
{
//    LXReorderableCollectionViewFlowLayout *layout = [[LXReorderableCollectionViewFlowLayout alloc] init];
//    layout.minimumLineSpacing = 0.0f;
//    layout.minimumInteritemSpacing = 0.0f;
//    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    [_collectionView setCollectionViewLayout:layout];
}

- (void)getAlbums
{
    _session = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).session;
    self.results = [[NSMutableArray alloc] init];
    [SPTRequest performSearchWithQuery:@"Kanye" queryType:SPTQueryTypeAlbum session:_session callback:^(NSError *error, id object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            SPTListPage *page = (SPTListPage*)object;
            [self.results addObjectsFromArray:page.items];
            [self.collectionView reloadData];
        });
    }];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.results count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    SPTPartialAlbum *album = (SPTPartialAlbum*)[self.results objectAtIndex:indexPath.row];
    SPTImage *cover = album.largestCover;
    CachedImageView *imageView = [[CachedImageView alloc] initWithFrame:cell.bounds];
    imageView.imageURL = cover.imageURL;
    [cell addSubview:imageView];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.width);

    }
    return CGSizeMake(collectionView.frame.size.width/2.0f, collectionView.frame.size.width/2.0f);
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    id object = [self.results objectAtIndex:fromIndexPath.item];
    [self.results removeObjectAtIndex:fromIndexPath.item];
    [self.results insertObject:object atIndex:toIndexPath.item];
}



@end
