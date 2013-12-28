//
//  FRPPhotoModel.h
//  FunctionalReactivePixels
//
//  Created by David Paschich on 12/27/13.
//  Copyright (c) 2013 David Paschich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRPPhotoModel : NSObject

@property (nonatomic, strong) NSString *photoName;
@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSString *photographerName;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSString *thumbnailURL;
@property (nonatomic, strong) NSData *thumbnailData;
@property (nonatomic, strong) NSString *fullsizedURL;
@property (nonatomic, strong) NSData *fullsizedData;

@end
