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

NSString * const PXRequestErrorConnectionDomain = @"connection error";
NSString * const PXRequestErrorRequestDomain = @"request cancelled";

NSString * const PXRequestPhotosCompleted = @"photos returned";
NSString * const PXRequestPhotosFailed = @"photos failed";

NSString * const PXAuthenticationChangedNotification = @"500px authentication changed";

@interface PXRequest () <NSURLConnectionDataDelegate>
@end

@implementation PXRequest
{
    NSURLConnection *urlConnection;
    NSMutableData *connectionMutableData;
    
    PXRequestCompletionBlock completionBlock;
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
    completionBlock = [completion copy];
    _requestStatus = PXRequestStatusNotStarted;
    
    return self;
}

-(void)dealloc
{
    
}

#pragma mark - Public Instance Methods

-(void)start
{
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
    
    if (completionBlock)
    {
        NSError *error = [NSError errorWithDomain:PXRequestErrorRequestDomain
                                             code:PXRequestStatusCancelled
                                         userInfo:nil];
        completionBlock(nil, error);
    }
    
    [PXRequest removeRequestFromInProgressMutableSet:self];
}

#pragma mark - Private class methods

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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *accessTokenDictionary = [apiHelper authenticate500pxUserName:userName password:password];
        dispatch_async(dispatch_get_main_queue(), ^{
            [PXRequest setAuthToken:[accessTokenDictionary valueForKey:@"oauth_token"] authSecret:[accessTokenDictionary valueForKey:@"oauth_token_secret"]];
        });
    });
}

+(void)setConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret
{
    apiHelper = [[PXAPIHelper alloc] initWithHost:nil consumerKey:consumerKey consumerSecret:consumerSecret];
}

+(void)setAuthToken:(NSString *)authToken authSecret:(NSString *)authSecret
{
    [apiHelper setAuthModeToOAuthWithAuthToken:authToken authSecret:authSecret];
    [[NSNotificationCenter defaultCenter] postNotificationName:PXAuthenticationChangedNotification object:nil];
}

#pragma mark - NSURLConnectionDelegate Methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"PXRequest to %@ failed with error: %@", self.urlRequest.URL, error);
    _requestStatus = PXRequestStatusFailed;
    if (completionBlock)
    {
        completionBlock(nil, error);
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
        
        if (completionBlock)
        {
            NSError *error = [NSError errorWithDomain:PXRequestErrorConnectionDomain
                                                 code:httpResponse.statusCode
                                             userInfo:@{ NSURLErrorKey : self.urlRequest.URL}];
            completionBlock(nil, error);
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
    
    if (completionBlock)
    {
        completionBlock(responseDictionary, nil);
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

@end
