//
//  FRPPhotoImporter.m
//  FunctionalReactivePixels
//
//  Created by David Paschich on 12/27/13.
//  Copyright (c) 2013 David Paschich. All rights reserved.
//

#import "FRPPhotoImporter.h"
#import "FRPPhotoModel.h"

@implementation FRPPhotoImporter

+ (RACReplaySubject *)importPhotos {
    RACReplaySubject *subject = [RACReplaySubject subject];

    NSURLRequest *request = [self popularURLRequest];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"results were %@", results);
            [subject sendNext:[[[results[@"photos"] rac_sequence] map:^id(NSDictionary *photoDictionary) {
                FRPPhotoModel *model = [FRPPhotoModel new];
                [self configurePhotoModel:model withDictionary:photoDictionary];
                [self downloadThumbnailForPhotoModel:model];
                return model;

            }] array]];
            [subject sendCompleted];
        }
        else {
            [subject sendError:connectionError];
        }
    }];

    return subject;
}

+ (NSURLRequest *)popularURLRequest {
    return [AppDelegate.apiHelper urlRequestForPhotoFeature:PXAPIHelperPhotoFeaturePopular resultsPerPage:100 page:0 photoSizes:PXPhotoModelSizeThumbnail sortOrder:PXAPIHelperSortOrderRating except:PXPhotoModelCategoryNude];
}

+ (void)configurePhotoModel:(FRPPhotoModel *)photoModel withDictionary:(NSDictionary *)dictionary
{
    photoModel.photoName = dictionary[@"name"];
    photoModel.identifier = dictionary[@"id"];
    photoModel.photographerName = dictionary[@"user"][@"username"];
    photoModel.rating = dictionary[@"rating"];

    photoModel.thumbnailURL = [self urlForImageSize:3 inDictionary:dictionary[@"images"]];

    if (dictionary[@"comments_count"]) {
        photoModel.fullsizedURL = [self urlForImageSize:4 inDictionary:dictionary[@"images"]];
    }
}

+(NSString *)urlForImageSize:(NSInteger)size inDictionary:(NSDictionary *)dictionary
{
    return [[[[[dictionary rac_sequence] filter:^BOOL(NSDictionary *value) {
        return [value[@"size"] integerValue] == size;
    }] map:^id(id value) {
        return value[@"url"];
    }] array] firstObject];
}

+ (void)downloadThumbnailForPhotoModel:(FRPPhotoModel *)photoModel
{
    NSAssert(photoModel.thumbnailURL, @"Thumbnail URL must not be nil");

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:photoModel.thumbnailURL]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        photoModel.thumbnailData = data;
    }];
}

@end
