//
//  ViewController.m
//  Juke
//
//  Created by Stefan Britton on 1/24/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "SearchCollectionViewCell.h"

@interface ViewController ()
@property (strong, nonatomic) SPTSession *session;
@property (strong, nonatomic) SPTAudioStreamingController *player;
@property (strong, nonatomic) NSMutableArray *results;

@end

static NSString * const kClientId = @"421e715a799b47f79925e26f05f5c5cf";
static NSString * const kCallbackURL = @"juke://callback";
static NSString * const kTokenSwapURL = @"https://aqueous-meadow-3841.herokuapp.com/swap";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchField.delegate = self;
    
//    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"session"];
//    SPTSession *object = (SPTSession*)[NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
//    _session = object;
//    
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    NSURL *loginURL = [auth loginURLForClientId:kClientId declaredRedirectURL:[NSURL URLWithString:kCallbackURL] scopes:@[SPTAuthStreamingScope]];
    [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:loginURL afterDelay:0.1f];
    
//    [auth renewSession:_session withServiceEndpointAtURL:[NSURL URLWithString:kTokenSwapURL] callback:^(NSError *error, SPTSession *session) {
//        _session = session;
//    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _session = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).session;
    self.results = [[NSMutableArray alloc] init];
    [SPTRequest performSearchWithQuery:textField.text queryType:SPTQueryTypeTrack session:_session callback:^(NSError *error, id object) {
        SPTListPage *page = (SPTListPage*)object;
        [self.results addObjectsFromArray:page.items];
        [self.collectionView reloadData];
    }];
    return NO;
}

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
    SearchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell initWithPartialTrack:[self.results objectAtIndex:indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width, 64.0f);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self playTrack:[self.results objectAtIndex:indexPath.row]];
}

- (void)playTrack:(SPTPartialTrack*)track
{
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:kClientId];
    }
    [self.player loginWithSession:_session callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** Enabling playback got error: %@", error);
            return;
        }
        NSString *urlString = [NSString stringWithFormat:@"spotify:track:%@", track.identifier];
        [SPTRequest requestItemAtURI:[NSURL URLWithString:urlString] withSession:nil callback:^(NSError *error, id object) {
            SPTAlbum *album = (SPTAlbum*)object;
            if (error != nil) {
                NSLog(@"*** Album lookup got error %@", error);
                return;
            }
            [self.player playTrackProvider:album callback:nil];
        }];
        
    }];
}

- (IBAction)searchButton:(id)sender {
    [self.searchField resignFirstResponder];
}
@end
