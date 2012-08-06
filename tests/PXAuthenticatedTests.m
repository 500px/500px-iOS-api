//
//  PXAuthenticatedTests.m
//  500px-iOS-api
//
//  Created by Ash Furrow on 2012-08-05.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXAuthenticatedTests.h"

@implementation PXAuthenticatedTests
{
    PXAPIHelper *helper;
}

- (void)setUp
{
    [super setUp];
    
    helper = [[PXAPIHelper alloc] initWithHost:nil
                                   consumerKey:kPXAPIConsumerKey
                                consumerSecret:kPXAPIConsumerSecret];
    
    NSDictionary *accessTokenDictionary = [helper authenticate500pxUserName:kUserNameForAuthentication password:kPasswordForAuthentication];
    
    [helper setAuthModeToOAuthWithAuthToken:[accessTokenDictionary valueForKey:@"oauth_token"] authSecret:[accessTokenDictionary valueForKey:@"oauth_token_secret"]];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark - Helper Methods

-(NSDictionary *)jsonDictionaryForRequest:(NSURLRequest *)urlRequest expectingResponseCode:(NSInteger)httpResponseCode
{
    NSHTTPURLResponse *returnResponse;
    NSError *connectionError;
    NSData *returnedData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&returnResponse error:&connectionError];
    
    if (connectionError)
    {
        STFail(@"Connection returned error: %@", connectionError);
        return nil;
    }
    
    if (returnResponse.statusCode != httpResponseCode)
    {
        STFail(@"Connection returned response code %d but we were expecting %d", returnResponse.statusCode, httpResponseCode);
        return nil;
    }
    
    NSError *jsonParseError;
    NSDictionary *returnedDictionary = [NSJSONSerialization JSONObjectWithData:returnedData options:0 error:&jsonParseError];
    
    return returnedDictionary;
}

#pragma mark - GET Photos

- (void)testBundleLoading {
    NSLog(@"Main Bundle Path: %@", [[NSBundle mainBundle] bundlePath]);
    
    for (NSBundle *bundle in [NSBundle allBundles]) {
        NSLog(@"%@: %@", [bundle bundleIdentifier],
              [bundle pathForResource:@"fire" ofType:@"png"]);
    }
}

-(void)testForNonNillResponse
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotos] expectingResponseCode:200];
    
    STAssertNotNil(dictionary, @"API returned nil response");
}

-(void)testForDefaultFeature
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotos] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"popular", @"Default photo stream request not returning popular, the default feature");
}

-(void)testForDefaultPhotoSizes
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotos] expectingResponseCode:200];
    
    STAssertTrue([[[[dictionary valueForKey:@"photos"] lastObject] valueForKey:@"images"] count] > 1, @"GET photos returned only 1 or no photos");
}

-(void)testForUpcomingFeature
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:PXAPIHelperPhotoFeatureUpcoming] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"upcoming", @"Photo stream request not returning upcoming");
}

-(void)testForEditorsChoiceFeature
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:PXAPIHelperPhotoFeatureEditors] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"editors", @"Photo stream request not returning editors");
}

-(void)testForFreshTodayFeature
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:PXAPIHelperPhotoFeatureFreshToday] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"fresh_today", @"Photo stream request not returning fresh_today");
}

-(void)testForFreshYesterdayFeature
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:PXAPIHelperPhotoFeatureFreshYesterday] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"fresh_yesterday", @"Photo stream request not returning fresh_yesterday");
}

-(void)testForFreshThisWeekFeature
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:PXAPIHelperPhotoFeatureFreshWeek] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"fresh_week", @"Photo stream request not returning fresh_week");
}

-(void)testForDefaultResultsPageSize
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotos] expectingResponseCode:200];
    
    NSInteger numberOfReturnedPhotos = [[dictionary valueForKey:@"photos"] count];
    
    STAssertEquals(numberOfReturnedPhotos, kPXAPIHelperDefaultResultsPerPage, @"Default photo stream request returning %d photos, not the default page size of %d", numberOfReturnedPhotos, kPXAPIHelperDefaultResultsPerPage);
}

-(void)testForDefaultPageNumber
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotos] expectingResponseCode:200];
    
    NSInteger returnedPageNumber = [[dictionary valueForKey:@"current_page"] intValue];
    
    STAssertEquals(returnedPageNumber, 1, @"Default photo stream request returning page %d, not the default page of 1", returnedPageNumber);
}

-(void)testForExcludeNude
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:kPXAPIHelperDefaultFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage pageNumber:1 photoSizes:kPXAPIHelperDefaultPhotoSize sortOrder:kPXAPIHelperDefaultSortOrder except:PXPhotoModelCategoryNude] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.exclude"] intValue], PXPhotoModelCategoryNude, @"API Request exlucding nude photographs contains unfiltered results");
}

-(void)testForOnlyLanscapes
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:kPXAPIHelperDefaultFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage pageNumber:1 photoSizes:kPXAPIHelperDefaultPhotoSize sortOrder:kPXAPIHelperDefaultSortOrder except:PXAPIHelperUnspecifiedCategory only:PXPhotoModelCategoryLandscapes] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.category"] intValue], PXPhotoModelCategoryLandscapes, @"API Request including only landscape photographs contains unfiltered results");
}

#pragma mark - GET Photos of specific user

-(void)testForNonNillUserPhotosResponseByID
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID] expectingResponseCode:200];
    
    STAssertNotNil(dictionary, @"API returned nil response");
}

-(void)testForCorrectUserID
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.user_id"] intValue], kTestUserID, @"Default photo stream request not returning correct user");
}

-(void)testForuserFavouritesFeatureByID
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID userFeature:PXAPIHelperUserPhotoFeatureFavourites] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"user_favorites", @"Photo stream request not returning user_favorites");
}

-(void)testForuserFriendsFeatureByID
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID userFeature:PXAPIHelperUserPhotoFeatureFriends] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"user_friends", @"Photo stream request not returning user_friends");
}

-(void)testForDefaultUserPhotosFeatureByID
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"user", @"Default photo stream request not returning user, the default feature");
}

-(void)testForDefaultuserPhotosResultsPageSizeByID
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID] expectingResponseCode:200];
    
    NSInteger numberOfReturnedPhotos = [[dictionary valueForKey:@"photos"] count];
    
    STAssertEquals(numberOfReturnedPhotos, kPXAPIHelperDefaultResultsPerPage, @"Default photo stream request returning %d photos, not the default page size of %d", numberOfReturnedPhotos, kPXAPIHelperDefaultResultsPerPage);
}

-(void)testForDefaultUserPhotosPageNumberByID
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID] expectingResponseCode:200];

    NSInteger returnedPageNumber = [[dictionary valueForKey:@"current_page"] intValue];
    
    STAssertEquals(returnedPageNumber, 1, @"Default photo stream request returning page %d, not the default page of 1", returnedPageNumber);
}

-(void)testForExcludeNudeFromUserPhotosByID
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID userFeature:kPXAPIHelperDefaultFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage pageNumber:1 photoSizes:kPXAPIHelperDefaultPhotoSize sortOrder:kPXAPIHelperDefaultSortOrder except:PXPhotoModelCategoryNude] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.exclude"] intValue], PXPhotoModelCategoryNude, @"API Request exlucding nude photographs contains unfiltered results");
}

-(void)testForOnlyLanscapesOfUserPhotosByID
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID userFeature:kPXAPIHelperDefaultFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage pageNumber:1 photoSizes:kPXAPIHelperDefaultPhotoSize sortOrder:kPXAPIHelperDefaultSortOrder except:PXAPIHelperUnspecifiedCategory only:PXPhotoModelCategoryLandscapes] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.category"] intValue], PXPhotoModelCategoryLandscapes, @"API Request including only landscape photographs contains unfiltered results");
}

-(void)testForNonNillUserPhotosResponseByName
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserName:kTestUserName] expectingResponseCode:200];

    STAssertNotNil(dictionary, @"API returned nil response");
}

-(void)testForCorrectUserName
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserName:kTestUserName] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.user_id"] intValue], kTestUserID, @"Default photo stream request not returning correct user");
}

-(void)testForDefaultUserPhotosFeatureByName
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"user", @"Default photo stream request not returning user, the default feature");
}

-(void)testForDefaultuserPhotosResultsPageSizeByName
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserName:kTestUserName] expectingResponseCode:200];
    
    NSInteger numberOfReturnedPhotos = [[dictionary valueForKey:@"photos"] count];
    
    STAssertEquals(numberOfReturnedPhotos, kPXAPIHelperDefaultResultsPerPage, @"Default photo stream request returning %d photos, not the default page size of %d", numberOfReturnedPhotos, kPXAPIHelperDefaultResultsPerPage);
}

-(void)testForDefaultUserPhotosPageNumberByName
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID] expectingResponseCode:200];
    
    NSInteger returnedPageNumber = [[dictionary valueForKey:@"current_page"] intValue];
    
    STAssertEquals(returnedPageNumber, 1, @"Default photo stream request returning page %d, not the default page of 1", returnedPageNumber);
}

-(void)testForExcludeNudeFromUserPhotosByName
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserName:kTestUserName userFeature:kPXAPIHelperDefaultFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage pageNumber:1 photoSizes:kPXAPIHelperDefaultPhotoSize sortOrder:kPXAPIHelperDefaultSortOrder except:PXPhotoModelCategoryNude] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.exclude"] intValue], PXPhotoModelCategoryNude, @"API Request exlucding nude photographs contains unfiltered results");
}

-(void)testForOnlyLanscapesOfUserPhotosByName
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserName:kTestUserName userFeature:kPXAPIHelperDefaultFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage pageNumber:1 photoSizes:kPXAPIHelperDefaultPhotoSize sortOrder:kPXAPIHelperDefaultSortOrder except:PXAPIHelperUnspecifiedCategory only:PXPhotoModelCategoryLandscapes] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.category"] intValue], PXPhotoModelCategoryLandscapes, @"API Request including only landscape photographs contains unfiltered results");
}

-(void)testForuserFavouritesFeatureByName
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserName:kTestUserName userFeature:PXAPIHelperUserPhotoFeatureFavourites] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"user_favorites", @"Photo stream request not returning user_favorites");
}

-(void)testForuserFriendsFeatureByName
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserName:kTestUserName userFeature:PXAPIHelperUserPhotoFeatureFriends] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"user_friends", @"Photo stream request not returning user_friends");
}

-(void)testForLoggedInUserWithNoAuth
{
    PXAPIHelper *notLoggedInHelper = [[PXAPIHelper alloc] initWithHost:nil consumerKey:kPXAPIConsumerKey consumerSecret:kPXAPIConsumerSecret];
    [notLoggedInHelper setAuthModeToNoAuth];
    
    NSURLRequest *request = [notLoggedInHelper urlRequestForCurrentlyLoggedInUser];
    
    STAssertNil(request, @"Request for logged in user without auth returns non-nil value.");
}

-(void)testForLoggedInUser
{
    NSDictionary *dictionary = [self jsonDictionaryForRequest:[helper urlRequestForCurrentlyLoggedInUser] expectingResponseCode:200];

    STAssertNotNil(dictionary, @"Logged in user returned null.");
}

@end
