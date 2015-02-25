//
//  TabBarViewController.m
//  Juke
//
//  Created by Stefan Britton on 2/11/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import "TabBarViewController.h"
#import "PartyViewController.h"
#import "Voltron.h"

@interface TabBarViewController () <WMLControllerCollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>
@property (strong, nonatomic) NSArray *viewControllerIdentifiers;
@property (strong, nonatomic) IBOutlet WMLCollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *tabBarView;
@property (strong, nonatomic) IBOutlet UIView *selectedView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *selectedViewLeft;
@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewControllerIdentifiers = @[@"SearchViewController", @"PartyNavController", @"ShareNavController"];
    self.collectionView.delegate = self;
    [self.party pinInBackgroundWithName:@"CurrentParty"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.viewControllerIdentifiers.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = [self.viewControllerIdentifiers objectAtIndex:indexPath.row];
    WMLCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    UINavigationController *navigationController = (UINavigationController*)cell.contentViewController;
    PartyViewController *partyViewController;
    if ([navigationController isKindOfClass:[UINavigationController class]]) {
        partyViewController = (PartyViewController*)navigationController.topViewController;
    } else {
        partyViewController = (PartyViewController*)cell.contentViewController;
    }
    partyViewController.party = self.party;
    return cell;
}

- (UIViewController*)collectionView:(WMLCollectionView *)collectionView controllerForIdentifier:(NSString *)identifier
{
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    return viewController;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

- (void)collectionView:(WMLCollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView didEndDisplayingCell:cell];
}

- (IBAction)tabButton:(id)sender {
    UIButton *button = (UIButton*)sender;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:button.tag inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = (scrollView.contentOffset.x / scrollView.frame.size.width)*(scrollView.frame.size.width/3.0);
    self.selectedViewLeft.constant = offset;
    NSLog(@"offset: %f", offset);
    [self.tabBarView layoutSubviews];
    [self.view endEditing:YES];
}

@end
