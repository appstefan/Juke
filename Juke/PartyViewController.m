//
//  PartyViewController.m
//  Juke
//
//  Created by Stefan Britton on 2/11/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import "PartyViewController.h"
#import "SongCollectionViewCell.h"
#import "HeaderCollectionReusableView.h"
#import <Spotify/Spotify.h>
#import "AppDelegate.h"
#import "CachedImageView.h"

@interface PartyViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CachedImageViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *songIDs;
@property (strong, nonatomic) NSMutableArray *songs;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *playerViewTop;
@property (strong, nonatomic) IBOutlet UIView *playerView;
@property (strong, nonatomic) IBOutlet CachedImageView *coverImage;
@property (strong, nonatomic) IBOutlet CachedImageView *albumImage;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *titeLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistLabel;
@property (strong, nonatomic) IBOutlet UIImageView *navBarImageView;


@end

@implementation PartyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadInterface];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadSongs];
}

- (void)loadInterface {
    self.nameLabel.text = self.party[@"name"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SongCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SongCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SongCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SongCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderCell"];
}

- (void)loadSongs {
    SPTSession* session = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).session;
    if (session) {
        NSURL *playlistURI = [NSURL URLWithString:[NSString stringWithFormat:@"%@", self.party[@"playlistURI"]]];
        
        [SPTRequest requestItemAtURI:playlistURI withSession:session callback:^(NSError *error, id object) {
            if (error) {
                NSLog(@"%@", error);
            }
            SPTPlaylistSnapshot *playlist = (SPTPlaylistSnapshot*)object;
            SPTListPage *page = playlist.firstTrackPage;
            self.songs = [[NSMutableArray alloc] initWithArray:page.items];
            [self.collectionView reloadData];
        }];
    } else {
        [self.party fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                self.songIDs = (NSArray*)self.party[@"songs"];
                self.songs = [[NSMutableArray alloc] init];
                for (NSString *songID in self.songIDs) {
                    NSURL *songURI = [NSURL URLWithString:[NSString stringWithFormat:@"spotify:track:%@", songID]];
                    [SPTRequest requestItemAtURI:songURI withSession:nil callback:^(NSError *error, id object) {
                        SPTPartialTrack *track = (SPTPartialTrack*)object;
                        [self.songs addObject:track];
                        if (self.songs.count == self.songIDs.count) {
                            [self sortSongs];
                        }
                    }];
                }
        }];
    }
}

- (void)sortSongs {
    NSMutableArray *sortedSongs = [[NSMutableArray alloc] init];
    for (NSString *songID in self.songIDs) {
        for (SPTPartialTrack *track in self.songs) {
            if ([track.identifier isEqualToString:songID]) {
                [sortedSongs addObject:track];
            }
        }
    }
    self.songs = sortedSongs;
    [self setNowPlaying];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void)setNowPlaying {
    SPTPartialTrack *track = [self.songs lastObject];
    if (track) {
        self.titeLabel.text = track.name;
        self.nameLabel.text = [NSString stringWithFormat:@"%@ - Now Playing", self.party[@"name"]];
        [SPTTrack trackWithURI:track.uri session:nil callback:^(NSError *error, id object) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SPTTrack *fullTrack = (SPTTrack*)object;
                SPTArtist *artist = [fullTrack.artists firstObject];
//                SPTPartialAlbum *album = fullTrack.album;
                self.artistLabel.text = [NSString stringWithFormat:@"%@", artist.name];

                NSArray *covers = fullTrack.album.covers;
                SPTImage *cover = [covers objectAtIndex:1];
                self.coverImage.delegate = self;
                self.coverImage.imageURL = cover.imageURL;
                self.albumImage.imageURL = cover.imageURL;
                
                
            });
        }];
    }
}

- (void)cachedImageViewDidChangeImage:(CachedImageView *)imageView
{
    if ([imageView isEqual:self.coverImage]) {
        UIImage *image = [self imageWithView:self.coverImage];
        image = [self cropImage:image rect:CGRectMake(0.0f, 0.0f, self.navBarImageView.frame.size.width, self.navBarImageView.frame.size.height)];
        self.navBarImageView.image = image;
    }

}

- (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIImage *)cropImage:(UIImage*)image rect:(CGRect)rect {
    if (image.scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * image.scale,
                          rect.origin.y * image.scale,
                          rect.size.width * image.scale,
                          rect.size.height * image.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.songs.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SongCollectionViewCell *cell = (SongCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"SongCell" forIndexPath:indexPath];
    [cell initWithPartialTrack:[self.songs objectAtIndex:indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (collectionView.frame.size.width - 55.0f)/2.0f;
    CGFloat height = width * (192.0f/160.0f);
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(self.playerView.frame.size.height, 20.0f, 70.0f, 20.0f);
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    HeaderCollectionReusableView *headerView = (HeaderCollectionReusableView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderCell" forIndexPath:indexPath];
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 44.0f);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offset = MIN(0, MAX(-(self.playerView.frame.size.height-64.0f), -scrollView.contentOffset.y));
    CGFloat alpha = (((self.playerView.frame.size.height-64.0f) - (scrollView.contentOffset.y))/(self.playerView.frame.size.height-64.0f));
    NSLog(@"%f", alpha);
    self.progressView.alpha = alpha;
    self.timeLabel.alpha = alpha;
    self.albumImage.alpha = alpha;
    self.titeLabel.alpha = alpha;
    self.artistLabel.alpha = alpha;
    self.playerView.alpha = alpha;
    self.playerViewTop.constant = offset;
    
}


@end
