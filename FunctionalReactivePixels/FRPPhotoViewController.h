//
//  FRPPhotoViewController.h
//  FunctionalReactivePixels
//
//  Created by David Paschich on 12/27/13.
//  Copyright (c) 2013 David Paschich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRPPhotoModel;

@interface FRPPhotoViewController : UIViewController

- (instancetype)initWithPhotoModel:(FRPPhotoModel *)photoModel index:(NSInteger)index;

@property (nonatomic,readonly)NSInteger photoIndex;
@property (nonatomic,readonly)FRPPhotoModel *photoModel;
@end
