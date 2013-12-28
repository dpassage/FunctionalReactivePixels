//
//  FRPPhotoImporter.h
//  FunctionalReactivePixels
//
//  Created by David Paschich on 12/27/13.
//  Copyright (c) 2013 David Paschich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRPPhotoImporter : NSObject

+ (RACSignal *)importPhotos;

@end
