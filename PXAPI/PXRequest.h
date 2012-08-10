//
//  PXRequest.h
//  PXAPI
//
//  Created by Ash Furrow on 2012-08-10.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXAPIHelper.h"

extern NSString * const PXRequestErrorConnectionDomain;
extern NSString * const PXRequestErrorRequestDomain;

extern NSString * const PXRequestPhotosCompleted;
extern NSString * const PXRequestPhotosFailed;

typedef enum : NSInteger
{
    PXRequestErrorCodeCancelled = 0
}PXRequestErrorCode;

extern NSString * const PXAuthenticationChangedNotification;

typedef void (^PXRequestCompletionBlock)(NSDictionary *results, NSError *error);

typedef enum : NSInteger
{
    PXRequestStatusNotStarted = 0,
    PXRequestStatusStarted,
    PXRequestStatusCompleted,
    PXRequestStatusFailed,
    PXRequestStatusCancelled
}PXRequestStatus;

@interface PXRequest : NSObject

@property (nonatomic, copy) PXRequestCompletionBlock completionBlock;
@property (nonatomic, readonly) NSURLRequest *urlRequest;
@property (nonatomic, readonly) PXRequestStatus requestStatus;

+(void)authenticateWithUserName:(NSString *)userName password:(NSString *)password;
+(void)setAuthToken:(NSString *)authToken authSecret:(NSString *)authSecret;

-(void)start;
-(void)cancel;

#pragma mark - Convenience methods for access 500px API

+(void)requestForPhotosWithCompletion:(PXRequestCompletionBlock)completionBlock;
+(void)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature completion:(PXRequestCompletionBlock)completionBlock;
+(void)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock;
+(void)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock;
+(void)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock;
+(void)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder completion:(PXRequestCompletionBlock)completionBlock;
+(void)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock;
+(void)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory completion:(PXRequestCompletionBlock)completionBlock;

@end
