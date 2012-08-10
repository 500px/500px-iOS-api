//
//  PXRequest.m
//  PXAPI
//
//  Created by Ash Furrow on 2012-08-10.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXRequest.h"
#import "PXAPIHelper.h"
#import "PXAPIHelper+Auth.h"

#import "PXAPI.h"

NSString * const PXRequestErrorConnectionDomain = @"connection error";
NSString * const PXRequestErrorRequestDomain = @"request cancelled";

NSString * const PXAuthenticationChangedNotification = @"500px authentication changed";

@interface PXRequest () <NSURLConnectionDataDelegate>
@end

@implementation PXRequest
{
    NSURLConnection *urlConnection;
    NSMutableData *connectionMutableData;
}

static NSMutableSet *inProgressRequestsMutableSet;
static dispatch_queue_t inProgressRequestsMutableSetAccessQueue;
static PXAPIHelper *apiHelper;

@synthesize urlRequest = _urlRequest;
@synthesize completionBlock = _completionBlock;
@synthesize requestStatus = _requestStatus;

+(void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inProgressRequestsMutableSet = [NSMutableSet set];
        inProgressRequestsMutableSetAccessQueue = dispatch_queue_create("com.inProgressRequestsMutableSetSetAccessQueue", DISPATCH_QUEUE_SERIAL);
        apiHelper = [[PXAPIHelper alloc] initWithHost:nil consumerKey:kPXConsumerKey consumerSecret:kPXConsumerSecret];
    });
}

#pragma mark - Private Instance Methods

-(id)initWithURLRequest:(NSURLRequest *)urlRequest completion:(PXRequestCompletionBlock)completionBlock
{
    if (!(self = [super init])) return nil;
    
    _urlRequest = urlRequest;
    _completionBlock = [completionBlock copy];
    _requestStatus = PXRequestStatusNotStarted;
    
    return self;
}

#pragma mark - Public Instance Methods

-(void)start
{
    _requestStatus = PXRequestStatusStarted;
    
    connectionMutableData = [NSMutableData data];
    
    urlConnection = [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self startImmediately:YES];
    
    [PXRequest addRequestToInProgressMutableSet:self];
}

-(void)cancel
{
    [urlConnection cancel];
    _requestStatus = PXRequestStatusCancelled;
    
    if (self.completionBlock)
    {
        NSError *error = [NSError errorWithDomain:PXRequestErrorRequestDomain
                                             code:PXRequestStatusCancelled
                                         userInfo:nil];
        self.completionBlock(nil, error);
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
    if (self.completionBlock)
    {
        self.completionBlock(nil, error);
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
        
        if (self.completionBlock)
        {
            NSError *error = [NSError errorWithDomain:PXRequestErrorConnectionDomain
                                                 code:httpResponse.statusCode
                                             userInfo:@{ NSURLErrorKey : self.urlRequest.URL}];
            self.completionBlock(nil, error);
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
    
    if (self.completionBlock)
    {
        self.completionBlock(responseDictionary, nil);
    }
    
    [PXRequest removeRequestFromInProgressMutableSet:self];
}

@end
