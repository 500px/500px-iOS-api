//
//  PXRequest.h
//  PXAPI
//
//  Created by Ash Furrow on 2012-08-10.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXAPIHelper.h"

extern NSString *const PXRequestErrorConnectionDomain;
extern NSString *const PXRequestErrorRequestDomain;
extern NSString *const PXRequestAPIDomain;

extern NSString *const PXRequestPhotosCompleted;
extern NSString *const PXRequestPhotosFailed;

extern NSString *const PXRequestPhotoDetailsCompleted;
extern NSString *const PXRequestPhotoDetailsFailed;

extern NSString *const PXRequestLoggedInUserCompleted;
extern NSString *const PXRequestLoggedInUserFailed;

extern NSString *const PXRequestUserDetailsCompleted;
extern NSString *const PXRequestUserDetailsFailed;

extern NSString *const PXRequestToFavouritePhotoCompleted;
extern NSString *const PXRequestToFavouritePhotoFailed;

extern NSString *const PXRequestToVoteForPhotoCompleted;
extern NSString *const PXRequestToVoteForPhotoFailed;

extern NSString *const PXRequestToCommentOnPhotoCompleted;
extern NSString *const PXRequestToCommentOnPhotoFailed;

extern NSString *const PXRequestSearchCompleted;
extern NSString *const PXRequestSearchFailed;

extern NSString *const PXRequestToFollowUserCompleted;
extern NSString *const PXRequestToFollowUserFailed;

extern NSString *const PXRequestForUserFollowingListCompleted;
extern NSString *const PXRequestForUserFollowingListFailed;

extern NSString *const PXRequestForUserFollowersListCompleted;
extern NSString *const PXRequestForUserFollowersListFailed;

typedef enum : NSInteger
{
    PXRequestErrorCodeNoConsumerKeyAndSecret = 0,
    PXRequestErrorCodeUserNotLoggedIn,
    PXRequestErrorCodeCancelled,
}PXRequestErrorCode;

typedef enum : NSInteger
{
    //General API Errors
    PXRequestAPIDomainCodeRequiredParametersWereMissing = 0,
    PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid,
    //User Errors
    PXRequestAPIDomainCodeUserHasBeenDisabled,
    PXRequestAPIDomainCodeUserDoesNotExist,
    PXRequestAPIDomainCodeUserHasBeenDisabledOrIsAlreadyFollowingUser,
    PXRequestAPIDomainCodeUserHasBeenDisabledOrIsNotFollowingUser,
    //Photo Errors
    PXRequestAPIDomainCodePhotoDoesNotExist,
    PXRequestAPIDomainCodePhotoWasDeletedOrUserWasDeactivated,
    PXRequestAPIDomainCodeCommentWasMissing,
    PXRequestAPIDomainCodeVoteWasRejected,      //common reasons are: current user is inactive, has not completed their profile, is trying to vote on their own photo, or has already voted for the photo.
    PXRequestAPIDomainCodeFavouriteWasRejected  //common reasons are: current user is inactive, has not completed their profile, or already has the photo in favorites list (or is not, and is trying to be removed).
}PXRequestAPIDomainCode;

extern NSString * const PXAuthenticationChangedNotification;
extern NSString * const PXAuthenticationFailedNotification;

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

@property (nonatomic, readonly) NSURLRequest *urlRequest;
@property (nonatomic, readonly) PXRequestStatus requestStatus;

+(PXAPIHelper *)apiHelper;

+(void)setConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret;
+(void)authenticateWithUserName:(NSString *)userName password:(NSString *)password completion:(void (^)(BOOL stop))completionBlock;
+(void)removeUserAuthentication;
+(void)setAuthToken:(NSString *)authToken authSecret:(NSString *)authSecret;

-(void)cancel;

@end
