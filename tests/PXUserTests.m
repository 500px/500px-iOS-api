//
//  PXUserTests.m
//  500px-iOS-api
//
//  Created by Ash Furrow on 2012-08-06.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXUserTests.h"

@implementation PXUserTests
{
    PXAPIHelper *authenticatedHelper;
    PXAPIHelper *nonAuthenticatedHelper;
}

- (void)setUp
{
    [super setUp];
    
    authenticatedHelper = [[PXAPIHelper alloc] initWithHost:nil
                                                consumerKey:kPXAPIConsumerKey
                                             consumerSecret:kPXAPIConsumerSecret];
    NSDictionary *accessTokenDictionary = [authenticatedHelper authenticate500pxUserName:kUserNameForAuthentication password:kPasswordForAuthentication];
    
    [authenticatedHelper setAuthModeToOAuthWithAuthToken:[accessTokenDictionary valueForKey:@"oauth_token"] authSecret:[accessTokenDictionary valueForKey:@"oauth_token_secret"]];
    
    nonAuthenticatedHelper =[[PXAPIHelper alloc] initWithHost:nil
                                                  consumerKey:kPXAPIConsumerKey
                                               consumerSecret:kPXAPIConsumerSecret];
    [nonAuthenticatedHelper setAuthModeToNoAuth];
}

-(void)testForNonEmptyResponseFromRequestWithUserID
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserWithID:kTestUserID] expectingResponseCode:200];
    
    STAssertNotNil(dictionary, @"Authenticated request for user ID returned nil");
    
    dictionary = [PXTests jsonDictionaryForRequest:[nonAuthenticatedHelper urlRequestForUserWithID:kTestUserID] expectingResponseCode:200];
    
    STAssertNotNil(dictionary, @"Non-Authenticated request for user ID returned nil");
}

-(void)testForNonEmptyResponseFromRequestWithUserName
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserWithUserName:kTestUserName] expectingResponseCode:200];
    
    STAssertNotNil(dictionary, @"Authenticated request for user name returned nil");
    
    dictionary = [PXTests jsonDictionaryForRequest:[nonAuthenticatedHelper urlRequestForUserWithUserName:kTestUserName] expectingResponseCode:200];
    
    STAssertNotNil(dictionary, @"Non-Authenticated request for user name returned nil");
}

-(void)testForNonEmptyResponseFromRequestWithUserEmail
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserWithEmailAddress:kTestUserEmail] expectingResponseCode:200];
    
    STAssertNotNil(dictionary, @"Authenticated request for user email returned nil");
    
    dictionary = [PXTests jsonDictionaryForRequest:[nonAuthenticatedHelper urlRequestForUserWithEmailAddress:kTestUserEmail] expectingResponseCode:200];
    
    STAssertNotNil(dictionary, @"Non-Authenticated request for user email returned nil");
}

@end
