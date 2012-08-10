//
//  PXRequest.m
//  PXAPI
//
//  Created by Ash Furrow on 2012-08-10.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXRequest.h"

@implementation PXRequest

static NSMutableSet *inProgressRequestsMutableSet;
static dispatch_queue_t inProgressRequestsMutableSetAccessQueue;

+(void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inProgressRequestsMutableSet = [NSMutableSet set];
        inProgressRequestsMutableSetAccessQueue = dispatch_queue_create("com.inProgressRequestsMutableSetSetAccessQueue", DISPATCH_QUEUE_SERIAL);
    });
}

+(void)addRequestToInProgressMutableSet:(PXRequest *)request
{
    dispatch_sync(inProgressRequestsMutableSetAccessQueue, ^{
        [inProgressRequestsMutableSet addObject:request];
    });
}

+(void)removeRequestFromInProgressMutableSet:(PXRequest *)request
{
    dispatch_sync(inProgressRequestsMutableSetAccessQueue, ^{
        if ([inProgressRequestsMutableSet containsObject:request])
        {
            [inProgressRequestsMutableSet removeObject:request];
        }
    });
}

@end
