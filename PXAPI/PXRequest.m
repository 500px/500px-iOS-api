//
//  PXRequest.m
//  PXAPI
//
//  Created by Ash Furrow on 2012-08-10.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXRequest.h"
#import "PXAPIHelper+Auth.h"

#import "PXAPI.h"

NSString *const PXRequestErrorConnectionDomain = @"connection error";
NSString *const PXRequestErrorRequestDomain = @"request cancelled";
NSString *const PXRequestAPIDomain = @"api error";

NSString *const PXRequestPhotosCompleted = @"photos returned";
NSString *const PXRequestPhotosFailed = @"photos failed";

NSString *const PXRequestLoggedInUserCompleted = @"logged in user request completed";
NSString *const PXRequestLoggedInUserFailed = @"logged in user request failed";

NSString *const PXRequestUserDetailsCompleted = @"logged in user request completed";
NSString *const PXRequestUserDetailsFailed = @"logged in user request failed";

NSString *const PXRequestPhotoDetailsCompleted = @"photo details completed";
NSString *const PXRequestPhotoDetailsFailed = @"photo details request failed";

NSString *const PXRequestToFavouritePhotoCompleted = @"request to favourite photo completed";
NSString *const PXRequestToFavouritePhotoFailed = @"request to favourite photo failed";

NSString *const PXRequestToVoteForPhotoCompleted = @"request to vote for photo completed";
NSString *const PXRequestToVoteForPhotoFailed = @"request to vote for photo failed";

NSString *const PXRequestToCommentOnPhotoCompleted = @"request to comment on photo completed";
NSString *const PXRequestToCommentOnPhotoFailed = @"request to comment on photo failed";

NSString *const PXRequestSearchCompleted = @"search completed";
NSString *const PXRequestSearchFailed = @"search failed";

NSString *const PXRequestToFollowUserCompleted = @"request to follow user completed";
NSString *const PXRequestToFollowUserFailed = @"request to follow user failed";

NSString *const PXRequestForUserFollowingListCompleted = @"request to list user following completed";
NSString *const PXRequestForUserFollowingListFailed = @"request to list user following failed";

NSString *const PXRequestForUserFollowersListCompleted = @"request to list user followers completed";
NSString *const PXRequestForUserFollowersListFailed = @"request to list user followers failed";

NSString *const PXAuthenticationChangedNotification = @"500px authentication changed";
NSString *const PXAuthenticationFailedNotification = @"500px authentication failed";

@interface PXRequest () <NSURLConnectionDataDelegate>
@end

@implementation PXRequest
{
    NSURLConnection *urlConnection;
    NSMutableData *connectionMutableData;
    
    PXRequestCompletionBlock requestCompletionBlock;
}

static NSMutableSet *inProgressRequestsMutableSet;
static dispatch_queue_t inProgressRequestsMutableSetAccessQueue;
static PXAPIHelper *apiHelper;

@synthesize urlRequest = _urlRequest;
@synthesize requestStatus = _requestStatus;

+(void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inProgressRequestsMutableSet = [NSMutableSet set];
        inProgressRequestsMutableSetAccessQueue = dispatch_queue_create("com.inProgressRequestsMutableSetSetAccessQueue", DISPATCH_QUEUE_SERIAL);
    });
}

#pragma mark - Private Instance Methods

-(id)initWithURLRequest:(NSURLRequest *)urlRequest completion:(PXRequestCompletionBlock)completion
{
    if (!(self = [super init])) return nil;
    
    _urlRequest = urlRequest;
    requestCompletionBlock = [completion copy];
    _requestStatus = PXRequestStatusNotStarted;
    
    return self;
}

#pragma mark - Public Instance Methods

-(void)start
{
    if (self.requestStatus != PXRequestStatusNotStarted)
    {
        NSLog(@"Attempt to start existing request. Ignoring.");
    }
    
    _requestStatus = PXRequestStatusStarted;
    
    connectionMutableData = [NSMutableData data];
    
    urlConnection = [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self];
    [urlConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                          forMode:NSDefaultRunLoopMode];
    
    [urlConnection start];
    
    [PXRequest addRequestToInProgressMutableSet:self];
}

-(void)cancel
{
    [urlConnection cancel];
    _requestStatus = PXRequestStatusCancelled;
    
    if (requestCompletionBlock)
    {
        NSError *error = [NSError errorWithDomain:PXRequestErrorRequestDomain
                                             code:PXRequestStatusCancelled
                                         userInfo:nil];
        requestCompletionBlock(nil, error);
    }
    
    [PXRequest removeRequestFromInProgressMutableSet:self];
}

#pragma mark - Private class methods

+(void)generateNotLoggedInError:(PXRequestCompletionBlock)completionBlock
{
    NSLog(@"Error: consumer key and secret not specified.");
    
    if (completionBlock)
    {
        completionBlock(nil, [NSError errorWithDomain:PXRequestErrorRequestDomain code:PXRequestErrorCodeUserNotLoggedIn userInfo:@{ NSLocalizedDescriptionKey : @"User must be authenticated to use this request." }]);
    }
}

+(void)generateNoConsumerKeyError:(PXRequestCompletionBlock)completionBlock
{
    NSLog(@"Error: User must be authenticated in for this request.");
    
    if (completionBlock)
    {
        completionBlock(nil, [NSError errorWithDomain:PXRequestErrorRequestDomain code:PXRequestErrorCodeNoConsumerKeyAndSecret userInfo:@{ NSLocalizedDescriptionKey : @"No Consumer Key and Consumer Secret were specified before using PXRequest." }]);
    }
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

#pragma mark - Public Class Methods
+(void)authenticateWithUserName:(NSString *)userName password:(NSString *)password
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:nil];
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *accessTokenDictionary = [apiHelper authenticate500pxUserName:userName password:password];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (accessTokenDictionary.allKeys.count > 0)
            {
                [PXRequest setAuthToken:[accessTokenDictionary valueForKey:@"oauth_token"] authSecret:[accessTokenDictionary valueForKey:@"oauth_token_secret"]];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:PXAuthenticationFailedNotification object:nil];
            }
        });
    });
}

+(void)removeUserAuthentication
{
    [PXRequest setAuthToken:nil authSecret:nil];
}

+(void)setConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret
{
    apiHelper = [[PXAPIHelper alloc] initWithHost:nil consumerKey:consumerKey consumerSecret:consumerSecret];
}

+(void)setAuthToken:(NSString *)authToken authSecret:(NSString *)authSecret
{
    if (authToken && authSecret)
    {
        [apiHelper setAuthModeToOAuthWithAuthToken:authToken authSecret:authSecret];
        [[NSNotificationCenter defaultCenter] postNotificationName:PXAuthenticationChangedNotification object:@(YES)];
    }
    else
    {
        [apiHelper setAuthModeToNoAuth];
        [[NSNotificationCenter defaultCenter] postNotificationName:PXAuthenticationChangedNotification object:@(NO)];
    }
}

#pragma mark - NSURLConnectionDelegate Methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"PXRequest to %@ failed with error: %@", self.urlRequest.URL, error);
    _requestStatus = PXRequestStatusFailed;
    
    if (requestCompletionBlock)
    {
        requestCompletionBlock(nil, error);
    }
    
    [PXRequest removeRequestFromInProgressMutableSet:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if (httpResponse.statusCode != 200)
    {
        [connection cancel];
        _requestStatus = PXRequestStatusFailed;
        
        if (requestCompletionBlock)
        {
            NSError *error = [NSError errorWithDomain:PXRequestErrorConnectionDomain
                                                 code:httpResponse.statusCode
                                             userInfo:@{ NSURLErrorKey : self.urlRequest.URL}];
            requestCompletionBlock(nil, error);
        }
        
        [PXRequest removeRequestFromInProgressMutableSet:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [connectionMutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _requestStatus = PXRequestStatusCompleted;
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:connectionMutableData options:0 error:nil];
    
    if (requestCompletionBlock)
    {
        requestCompletionBlock(responseDictionary, nil);
    }
    
    [PXRequest removeRequestFromInProgressMutableSet:self];
}


#pragma mark - Convenience methods for access 500px API

+(PXRequest *)requestForPhotosWithCompletion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoFeature:kPXAPIHelperDefaultFeature completion:completionBlock];
}

+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoFeature:photoFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage completion:completionBlock];
}

+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:1 completion:completionBlock];
}

+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:page photoSizes:kPXAPIHelperDefaultPhotoSize completion:completionBlock];
}

+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:kPXAPIHelperDefaultSortOrder completion:completionBlock];
}

+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:excludedCategory only:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
    }

    NSURLRequest *urlRequest = [apiHelper urlRequestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:excludedCategory only:includedCategory];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        if (error)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotosFailed object:error];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotosCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, error);
        }
    }];
    
    [request start];
    
    return request;
}

#pragma mark Specific Users

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserID:userID userFeature:kPXAPIHelperDefaultUserPhotoFeature completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:1 completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:kPXAPIHelperDefaultPhotoSize completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:kPXAPIHelperDefaultSortOrder completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:excludedCategory only:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory completion:(PXRequestCompletionBlock)completionBlock
{   
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:excludedCategory only:includedCategory];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        if (error)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotosFailed object:error];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotosCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, error);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserName:userName userFeature:kPXAPIHelperDefaultUserPhotoFeature completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:1 completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:kPXAPIHelperDefaultPhotoSize completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:kPXAPIHelperDefaultSortOrder completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:excludedCategory only:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:excludedCategory only:includedCategory];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        if (error)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotosFailed object:error];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotosCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, error);
        }
    }];
    
    [request start];
    
    return request;
}
#pragma mark Favourite, Vote, and Comment

//Requires Authentication
+(PXRequest *)requestToFavouritePhoto:(NSInteger)photoID completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestToFavouritePhoto:photoID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeFavouriteWasRejected userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodePhotoDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFavouritePhotoFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFavouritePhotoCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestToUnFavouritePhoto:(NSInteger)photoID completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestToUnFavouritePhoto:photoID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeFavouriteWasRejected userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodePhotoDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFavouritePhotoFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFavouritePhotoCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestToVoteForPhoto:(NSInteger)photoID completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestToVoteForPhoto:photoID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeVoteWasRejected userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodePhotoDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToVoteForPhotoFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToVoteForPhotoCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestToComment:(NSString *)comment onPhoto:(NSInteger)photoID completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestToComment:comment onPhoto:photoID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeCommentWasMissing userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodePhotoDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToCommentOnPhotoFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToCommentOnPhotoCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}


#pragma mark Photo Details

//Comment pages are 1-indexed
//20 comments per page

+(PXRequest *)requestForPhotoID:(NSInteger)photoID completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoID:photoID photoSizes:kPXAPIHelperDefaultPhotoSize commentsPage:1 completion:completionBlock];
}

+(PXRequest *)requestForPhotoID:(NSInteger)photoID commentsPage:(NSInteger)commentsPage completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoID:photoID photoSizes:kPXAPIHelperDefaultPhotoSize commentsPage:commentsPage completion:completionBlock];
}

+(PXRequest *)requestForPhotoID:(NSInteger)photoID photoSizes:(PXPhotoModelSize)photoSizesMask commentsPage:(NSInteger)commentPage completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestForPhotoID:photoID photoSizes:photoSizesMask commentsPage:commentPage];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodePhotoDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodePhotoWasDeletedOrUserWasDeactivated userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotoDetailsFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotoDetailsCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}


#pragma mark Photo Searching

//Search page results are 1-indexed

+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTerm:searchTerm page:1 completion:completionBlock];
}

+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTerm:searchTerm page:page resultsPerPage:kPXAPIHelperDefaultResultsPerPage completion:completionBlock];
}

+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTerm:searchTerm page:page resultsPerPage:resultsPerPage photoSizes:kPXAPIHelperDefaultPhotoSize completion:completionBlock];
}

+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTerm:searchTerm page:page resultsPerPage:resultsPerPage photoSizes:photoSizesMask except:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestForSearchTerm:searchTerm page:page resultsPerPage:resultsPerPage photoSizes:photoSizesMask except:excludedCategory];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}


+(PXRequest *)requestForSearchTag:(NSString *)searchTag completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTag:searchTag page:1 completion:completionBlock];
}

+(PXRequest *)requestForSearchTag:(NSString *)searchTag page:(NSUInteger)page completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTag:searchTag page:1 resultsPerPage:kPXAPIHelperDefaultResultsPerPage completion:completionBlock];
}

+(PXRequest *)requestForSearchTag:(NSString *)searchTag page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTag:searchTag page:1 resultsPerPage:kPXAPIHelperDefaultResultsPerPage photoSizes:kPXAPIHelperDefaultPhotoSize completion:completionBlock];
}

+(PXRequest *)requestForSearchTag:(NSString *)searchTag page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTag:searchTag page:1 resultsPerPage:kPXAPIHelperDefaultResultsPerPage photoSizes:kPXAPIHelperDefaultPhotoSize except:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForSearchTag:(NSString *)searchTag page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestForSearchTag:searchTag page:page resultsPerPage:resultsPerPage photoSizes:photoSizesMask except:excludedCategory];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}


#pragma mark Users

//Requires Authentication
+(PXRequest *)requestForCurrentlyLoggedInUserWithCompletion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    if (apiHelper.authMode == PXAPIHelperModeNoAuth)
    {
        [self generateNotLoggedInError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestForCurrentlyLoggedInUser];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestLoggedInUserFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestLoggedInUserCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestForUserWithID:(NSInteger)userID completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestForUserWithID:userID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissing userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserHasBeenDisabled userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestUserDetailsCompleted object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestUserDetailsFailed object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestForUserWithUserName:(NSString *)userName completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestForUserWithUserName:userName];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissing userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserHasBeenDisabled userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestUserDetailsFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestUserDetailsCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestForUserWithEmailAddress:(NSString *)userEmailAddress completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestForUserWithEmailAddress:userEmailAddress];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissing userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserHasBeenDisabled userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestUserDetailsFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestUserDetailsCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}


+(PXRequest *)requestForUserSearchWithTerm:(NSString *)searchTerm completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestForUserSearchWithTerm:searchTerm];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}


//pages are 1-indexed
+(PXRequest *)requestForUserFollowing:(NSInteger)userID completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForUserFollowing:userID page:1 completion:completionBlock];
}

+(PXRequest *)requestForUserFollowing:(NSInteger)userID page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestForUserFollowing:userID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserHasBeenDisabled userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestForUserFollowingListFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestForUserFollowingListCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestForUserFollowers:(NSInteger)userID completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForUserFollowers:userID page:1 completion:completionBlock];
}

+(PXRequest *)requestForUserFollowers:(NSInteger)userID page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestForUserFollowers:userID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserHasBeenDisabled userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestForUserFollowersListFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestForUserFollowersListCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

//Requires Authentication
+(PXRequest *)requestToFollowUser:(NSInteger)userToFollowID completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    if (apiHelper.authMode == PXAPIHelperModeNoAuth)
    {
        [self generateNotLoggedInError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestToFollowUser:userToFollowID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserHasBeenDisabledOrIsAlreadyFollowingUser userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFollowUserFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFollowUserCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestToUnFollowUser:(NSInteger)userToUnFollowID completion:(PXRequestCompletionBlock)completionBlock
{
    if (!apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    if (apiHelper.authMode == PXAPIHelperModeNoAuth)
    {
        [self generateNotLoggedInError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [apiHelper urlRequestToUnFollowUser:userToUnFollowID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserHasBeenDisabledOrIsNotFollowingUser userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFollowUserFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFollowUserCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

@end
