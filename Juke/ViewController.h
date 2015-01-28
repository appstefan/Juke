//
//  ViewController.h
//  Juke
//
//  Created by Stefan Britton on 1/24/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>

@interface ViewController : UIViewController <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)searchButton:(id)sender;

@end

