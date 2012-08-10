//
//  PXRequest.h
//  PXAPI
//
//  Created by Ash Furrow on 2012-08-10.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const PXRequestErrorConnectionDomain;
extern NSString * const PXRequestErrorRequestDomain;

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

@end
