//
//  FRPGalleryFlowLayout.m
//  FunctionalReactivePixels
//
//  Created by David Paschich on 12/27/13.
//  Copyright (c) 2013 David Paschich. All rights reserved.
//

#import "FRPGalleryFlowLayout.h"

@implementation FRPGalleryFlowLayout

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }

    self.itemSize = CGSizeMake(145, 145);
    self.minimumInteritemSpacing = 10;
    self.minimumLineSpacing = 10;
    self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);

    return self;
}
@end
