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

-(void)testForUserSearch
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserSearchWithTerm:kTestUserName] expectingResponseCode:200];
    
    STAssertTrue([[dictionary valueForKey:@"users"] count] > 0, @"User search for existing user returned no users while authenticated");
    
    dictionary = [PXTests jsonDictionaryForRequest:[nonAuthenticatedHelper urlRequestForUserSearchWithTerm:kTestUserName] expectingResponseCode:200];
    
    STAssertTrue([[dictionary valueForKey:@"users"] count] > 0, @"User search for existing user returned no users");
}

-(void)testForFollowingDetaultPageNumber
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserFollowing:kTestUserID] expectingResponseCode:200];
    
    STAssertTrue([[dictionary valueForKey:@"page"] intValue] == 1, @"User following returned non the first page while autenticated");
    
    dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserFollowing:kTestUserID] expectingResponseCode:200];
    
    STAssertTrue([[dictionary valueForKey:@"page"] intValue] == 1, @"User following returned not the first page");
}

-(void)testForAnotherFollowingPageNumber
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserFollowing:kTestUserID page:2] expectingResponseCode:200];
    
    STAssertTrue([[dictionary valueForKey:@"page"] intValue] == 2, @"User following returned non the second page while autenticated");
    
    dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserFollowing:kTestUserID page:2] expectingResponseCode:200];
    
    STAssertTrue([[dictionary valueForKey:@"page"] intValue] == 2, @"User following returned not the second page");
}


-(void)testForFollowingExists
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserFollowing:kTestUserID] expectingResponseCode:200];
    
    STAssertTrue([[dictionary valueForKey:@"friends"] count] > 0, @"User following returned no users while authenticated");
    
    dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserFollowing:kTestUserID] expectingResponseCode:200];
    
    STAssertTrue([[dictionary valueForKey:@"friends"] count] > 0, @"User following returned no users");
}

-(void)testForDetaultFollowersPageNumber
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserFollowers:kTestUserID] expectingResponseCode:200];
    
    STAssertTrue([[dictionary valueForKey:@"page"] intValue] == 1, @"User following returned non the first page while autenticated");
    
    dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserFollowers:kTestUserID] expectingResponseCode:200];
    
    STAssertTrue([[dictionary valueForKey:@"page"] intValue] == 1, @"User following returned not the first page");
}

-(void)testForAnotherFollowersPageNumber
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserFollowers:kTestUserID page:2] expectingResponseCode:200];
    
    STAssertTrue([[dictionary valueForKey:@"page"] intValue] == 2, @"User following returned non the second page while autenticated");
    
    dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserFollowers:kTestUserID page:2] expectingResponseCode:200];
    
    STAssertTrue([[dictionary valueForKey:@"page"] intValue] == 2, @"User following returned not the second page");
}

-(void)testForFollowersExists
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserFollowers:kTestUserID] expectingResponseCode:200];
    
    STAssertTrue([[dictionary valueForKey:@"followers"] count] > 0, @"User followers returned no users while authenticated");
    
    dictionary = [PXTests jsonDictionaryForRequest:[authenticatedHelper urlRequestForUserFollowers:kTestUserID] expectingResponseCode:200];
    
    STAssertTrue([[dictionary valueForKey:@"followers"] count] > 0, @"User followers returned no users");
}

-(void)testFollowRequestIsNilWhenNotAuthenticated
{
    NSURLRequest *request = [nonAuthenticatedHelper urlRequestToFollowUser:123456];
    
    STAssertNil(request, @"Request to follow a user did not return nil despite not being logged in");
}

@end
