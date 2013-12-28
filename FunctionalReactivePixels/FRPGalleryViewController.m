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

@interface FRPGalleryViewController ()

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

    RACDelegateProxy *viewControllerDelegate = [[RACDelegateProxy alloc] initWithProtocol:@protocol(FRPFullSizePhotoViewControllerDelegate)];

    [[viewControllerDelegate rac_signalForSelector:@selector(userDidScroll:toPhotoAtIndex:)
                                      fromProtocol:@protocol(FRPFullSizePhotoViewControllerDelegate)]
     subscribeNext:^(RACTuple *value) {
         @strongify(self);
         [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[value.second integerValue] inSection:0]
                                     atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                             animated:NO];
     }];

    self.collectionViewDelegate = [[RACDelegateProxy alloc] initWithProtocol:@protocol(UICollectionViewDelegate)];
    [[self.collectionViewDelegate rac_signalForSelector:@selector(collectionView:didDeselectItemAtIndexPath:)]
     subscribeNext:^(RACTuple *arguments) {
         @strongify(self);
         FRPFullSizePhotoViewController *viewController = [[FRPFullSizePhotoViewController alloc] initWithPhotoModels:self.photos currentPhotoIndex:[(NSIndexPath *)arguments.second item]];
         viewController.delegate = (id<FRPFullSizePhotoViewControllerDelegate>)viewControllerDelegate;
         [self.navigationController pushViewController:viewController animated:YES];
     }];

    RAC(self,photos) = [[[[FRPPhotoImporter importPhotos]
                          doCompleted:^{
                              @strongify(self)
                              [self.collectionView reloadData];
                          }] logError] catchTo:[RACSignal empty]];
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

@end
