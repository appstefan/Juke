//
//  SearchViewController.m
//  Juke
//
//  Created by Stefan Britton on 2/12/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import "SearchViewController.h"
#import <Spotify/Spotify.h>
#import "AppDelegate.h"
#import "SearchSongCollectionViewCell.h"
#import "SongViewController.h"

@interface SearchViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) NSMutableArray *songResults;
@property (strong, nonatomic) NSMutableArray *artistResults;
@property (strong, nonatomic) SPTSession *session;
@property (strong, nonatomic) SPTAudioStreamingController *player;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) SPTPartialTrack *selectedTrack;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadInterface];
}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    [self.searchField resignFirstResponder];
//}

- (void)loadInterface {
    self.searchView.layer.cornerRadius = 4.0f;
    self.searchView.layer.masksToBounds = YES;
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:@"Search for songs to play" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"GothamHTF-Book" size:13.0f], NSForegroundColorAttributeName : [UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1.0f]}];
    [self.searchField setAttributedPlaceholder:placeholder];
    self.searchField.delegate = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"SearchSongCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SearchSongCell"];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchField resignFirstResponder];
    _session = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).session;
    self.songResults = [[NSMutableArray alloc] init];
    [SPTRequest performSearchWithQuery:textField.text queryType:SPTQueryTypeTrack session:_session callback:^(NSError *error, id object) {
        SPTListPage *page = (SPTListPage*)object;
        [self.songResults addObjectsFromArray:page.items];
        [self.collectionView reloadData];
    }];
    return NO;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    NSInteger sections = 0;
    if (self.songResults.count)
        sections++;
    if (self.artistResults.count)
        sections++;
    return sections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 1 || !self.artistResults.count)
        return self.songResults.count;
    if (section == 0)
        return 1;
    return 0;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SearchSongCollectionViewCell *cell = (SearchSongCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"SearchSongCell" forIndexPath:indexPath];
    [cell initWithPartialTrack:[self.songResults objectAtIndex:indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width, 64.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(84.0f, 0.0f, 50.0f, 0.0f);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SearchSongCollectionViewCell *cell = (SearchSongCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    self.selectedTrack = cell.track;
    [self performSegueWithIdentifier:@"SongSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SongSegue"]) {
        SongViewController *songViewController = (SongViewController*)segue.destinationViewController;
        songViewController.track = self.selectedTrack;
        songViewController.party = self.party;
    }
}

@end
