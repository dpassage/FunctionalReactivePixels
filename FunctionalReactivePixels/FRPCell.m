//
//  FRPCell.m
//  FunctionalReactivePixels
//
//  Created by David Paschich on 12/27/13.
//  Copyright (c) 2013 David Paschich. All rights reserved.
//

#import "FRPCell.h"
#import "FRPPhotoModel.h"
@interface FRPCell ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, strong) RACDisposable *subscription;

@end

@implementation FRPCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor darkGrayColor];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
    }
    return self;
}

- (void)setPhotoModel:(FRPPhotoModel *)photoModel
{
    if (self.imageView) {
        self.subscription = [[[RACObserve(photoModel, thumbnailData) filter:^BOOL(id value) {
            return value != nil;
        }] map:^id(id value) {
            UIImage *ret = [UIImage imageWithData:value];
            NSAssert(ret != nil, @"image actually built");
            return ret;
        }] setKeyPath:@keypath(self.imageView, image) onObject:self.imageView];

    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    [self.subscription dispose];
    self.subscription = nil;
}
@end
