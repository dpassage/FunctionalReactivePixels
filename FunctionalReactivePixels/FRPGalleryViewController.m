//
//  FRPGalleryViewController.m
//  FunctionalReactivePixels
//
//  Created by David Paschich on 12/27/13.
//  Copyright (c) 2013 David Paschich. All rights reserved.
//

#import "FRPGalleryViewController.h"

#import <RACDelegateProxy.h>

#import "FRPCell.h"
#import "FRPGalleryFlowLayout.h"
#import "FRPPhotoImporter.h"
#import "FRPFullSizePhotoViewController.h"

@interface FRPGalleryViewController () <FRPFullSizePhotoViewControllerDelegate, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *photos;

@property (nonatomic, strong) id collectionViewDelegate;

@end

@implementation FRPGalleryViewController

- (id)init
{
    FRPGalleryFlowLayout *flowLayout = [[FRPGalleryFlowLayout alloc] init];

    self = [self initWithCollectionViewLayout:flowLayout];

    if (!self) return nil;

    return self;
}

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Popular on 500px";

    [self.collectionView registerClass:[FRPCell class] forCellWithReuseIdentifier:CellIdentifier];

    @weakify(self);
    [RACObserve(self, photos) subscribeNext:^(id x) {
        @strongify(self);
        [self.collectionView reloadData];
    }];

    [[self rac_signalForSelector:@selector(collectionView:didSelectItemAtIndexPath:) fromProtocol:@protocol(UICollectionViewDelegate)]
     subscribeNext:^(RACTuple *arguments) {
        @strongify(self)
         NSLog(@"in sub for clicking on item index path is %@", arguments.second);
        FRPFullSizePhotoViewController *viewController = [[FRPFullSizePhotoViewController alloc] initWithPhotoModels:self.photos currentPhotoIndex:[(NSIndexPath *)arguments.second item]];
        viewController.delegate = self;
        [self.navigationController pushViewController:viewController animated:YES];

    } error:^(NSError *error) {
        NSLog(@"trying to get to collectionView:didSelectItemAtIndexPath failed: %@", error);
    }];

    self.collectionView.delegate = self;

    [self loadPopularPhotos];
}

- (void)loadPopularPhotos
{
    [[FRPPhotoImporter importPhotos] subscribeNext:^(id x) {
        self.photos = x;
    } error:^(NSError *error) {
        NSLog(@"Couln't fetch photos from 500px: %@", error);
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FRPCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    [cell setPhotoModel:self.photos[indexPath.row]];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"in original cv:dsiaip with index path %@", indexPath);
}

- (void)userDidScroll:(FRPFullSizePhotoViewController *)viewController toPhotoAtIndex:(NSInteger)index
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
}

@end
