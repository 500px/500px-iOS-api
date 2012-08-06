//
//  PXNonAuthenticatedTests.m
//  500px-iOS-api
//
//  Created by Ash Furrow on 2012-08-05.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXNonAuthenticatedTests.h"

@implementation PXNonAuthenticatedTests
{
    PXAPIHelper *helper;
}

- (void)setUp
{
    [super setUp];
    
    helper = [[PXAPIHelper alloc] initWithHost:nil
                                   consumerKey:kPXAPIConsumerKey
                                consumerSecret:kPXAPIConsumerSecret];
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
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotos] expectingResponseCode:200];
    
    STAssertNotNil(dictionary, @"API returned nil response");
}

-(void)testForDefaultFeature
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotos] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"popular", @"Default photo stream request not returning popular, the default feature");
}

-(void)testForDefaultPhotoSizes
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotos] expectingResponseCode:200];

    STAssertTrue([[[[dictionary valueForKey:@"photos"] lastObject] valueForKey:@"images"] count] > 1, @"GET photos returned only 1 or no photos");
}

-(void)testForUpcomingFeature
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:PXAPIHelperPhotoFeatureUpcoming] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"upcoming", @"Photo stream request not returning upcoming");
}

-(void)testForEditorsChoiceFeature
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:PXAPIHelperPhotoFeatureEditors] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"editors", @"Photo stream request not returning editors");
}

-(void)testForFreshTodayFeature
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:PXAPIHelperPhotoFeatureFreshToday] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"fresh_today", @"Photo stream request not returning fresh_today");
}

-(void)testForFreshYesterdayFeature
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:PXAPIHelperPhotoFeatureFreshYesterday] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"fresh_yesterday", @"Photo stream request not returning fresh_yesterday");
}

-(void)testForFreshThisWeekFeature
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:PXAPIHelperPhotoFeatureFreshWeek] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"fresh_week", @"Photo stream request not returning fresh_week");
}

-(void)testForDefaultResultsPageSize
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotos] expectingResponseCode:200];
    
    NSInteger numberOfReturnedPhotos = [[dictionary valueForKey:@"photos"] count];
    
    STAssertEquals(numberOfReturnedPhotos, kPXAPIHelperDefaultResultsPerPage, @"Default photo stream request returning %d photos, not the default page size of %d", numberOfReturnedPhotos, kPXAPIHelperDefaultResultsPerPage);
}

-(void)testForDefaultpage
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotos] expectingResponseCode:200];
    
    NSInteger returnedpage = [[dictionary valueForKey:@"current_page"] intValue];
    
    STAssertEquals(returnedpage, 1, @"Default photo stream request returning page %d, not the default page of 1", returnedpage);
}

-(void)testForExcludeNude
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:kPXAPIHelperDefaultFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage page:1 photoSizes:kPXAPIHelperDefaultPhotoSize sortOrder:kPXAPIHelperDefaultSortOrder except:PXPhotoModelCategoryNude] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.exclude"] intValue], PXPhotoModelCategoryNude, @"API Request exlucding nude photographs contains unfiltered results");
}

-(void)testForOnlyLanscapes
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:kPXAPIHelperDefaultFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage page:1 photoSizes:kPXAPIHelperDefaultPhotoSize sortOrder:kPXAPIHelperDefaultSortOrder except:PXAPIHelperUnspecifiedCategory only:PXPhotoModelCategoryLandscapes] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.category"] intValue], PXPhotoModelCategoryLandscapes, @"API Request including only landscape photographs contains unfiltered results");
}

#pragma mark - GET Photos of specific user

-(void)testForNonNillUserPhotosResponseByID
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID] expectingResponseCode:200];
    
    STAssertNotNil(dictionary, @"API returned nil response");
}

-(void)testForCorrectUserID
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.user_id"] intValue], kTestUserID, @"Default photo stream request not returning correct user");
}

-(void)testForuserFavouritesFeatureByID
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID userFeature:PXAPIHelperUserPhotoFeatureFavourites] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"user_favorites", @"Photo stream request not returning user_favorites");
}

-(void)testForuserFriendsFeatureByID
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID userFeature:PXAPIHelperUserPhotoFeatureFriends] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"user_friends", @"Photo stream request not returning user_friends");
}

-(void)testForDefaultUserPhotosFeatureByID
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"user", @"Default photo stream request not returning user, the default feature");
}

-(void)testForDefaultuserPhotosResultsPageSizeByID
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID] expectingResponseCode:200];
    
    NSInteger numberOfReturnedPhotos = [[dictionary valueForKey:@"photos"] count];
    
    STAssertEquals(numberOfReturnedPhotos, kPXAPIHelperDefaultResultsPerPage, @"Default photo stream request returning %d photos, not the default page size of %d", numberOfReturnedPhotos, kPXAPIHelperDefaultResultsPerPage);
}

-(void)testForDefaultUserPhotospageByID
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID] expectingResponseCode:200];
    
    NSInteger returnedpage = [[dictionary valueForKey:@"current_page"] intValue];
    
    STAssertEquals(returnedpage, 1, @"Default photo stream request returning page %d, not the default page of 1", returnedpage);
}

-(void)testForExcludeNudeFromUserPhotosByID
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID userFeature:kPXAPIHelperDefaultFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage page:1 photoSizes:kPXAPIHelperDefaultPhotoSize sortOrder:kPXAPIHelperDefaultSortOrder except:PXPhotoModelCategoryNude] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.exclude"] intValue], PXPhotoModelCategoryNude, @"API Request exlucding nude photographs contains unfiltered results");
}

-(void)testForOnlyLanscapesOfUserPhotosByID
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID userFeature:kPXAPIHelperDefaultFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage page:1 photoSizes:kPXAPIHelperDefaultPhotoSize sortOrder:kPXAPIHelperDefaultSortOrder except:PXAPIHelperUnspecifiedCategory only:PXPhotoModelCategoryLandscapes] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.category"] intValue], PXPhotoModelCategoryLandscapes, @"API Request including only landscape photographs contains unfiltered results");
}

-(void)testForNonNillUserPhotosResponseByName
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserName:kTestUserName] expectingResponseCode:200];
    
    STAssertNotNil(dictionary, @"API returned nil response");
}

-(void)testForCorrectUserName
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserName:kTestUserName] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.user_id"] intValue], kTestUserID, @"Default photo stream request not returning correct user");
}

-(void)testForDefaultUserPhotosFeatureByName
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"user", @"Default photo stream request not returning user, the default feature");
}

-(void)testForDefaultuserPhotosResultsPageSizeByName
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserName:kTestUserName] expectingResponseCode:200];
    
    NSInteger numberOfReturnedPhotos = [[dictionary valueForKey:@"photos"] count];
    
    STAssertEquals(numberOfReturnedPhotos, kPXAPIHelperDefaultResultsPerPage, @"Default photo stream request returning %d photos, not the default page size of %d", numberOfReturnedPhotos, kPXAPIHelperDefaultResultsPerPage);
}

-(void)testForDefaultUserPhotospageByName
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserID:kTestUserID] expectingResponseCode:200];
    
    NSInteger returnedpage = [[dictionary valueForKey:@"current_page"] intValue];
    
    STAssertEquals(returnedpage, 1, @"Default photo stream request returning page %d, not the default page of 1", returnedpage);
}

-(void)testForExcludeNudeFromUserPhotosByName
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserName:kTestUserName userFeature:kPXAPIHelperDefaultFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage page:1 photoSizes:kPXAPIHelperDefaultPhotoSize sortOrder:kPXAPIHelperDefaultSortOrder except:PXPhotoModelCategoryNude] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.exclude"] intValue], PXPhotoModelCategoryNude, @"API Request exlucding nude photographs contains unfiltered results");
}

-(void)testForOnlyLanscapesOfUserPhotosByName
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserName:kTestUserName userFeature:kPXAPIHelperDefaultFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage page:1 photoSizes:kPXAPIHelperDefaultPhotoSize sortOrder:kPXAPIHelperDefaultSortOrder except:PXAPIHelperUnspecifiedCategory only:PXPhotoModelCategoryLandscapes] expectingResponseCode:200];
    
    STAssertEquals([[dictionary valueForKeyPath:@"filters.category"] intValue], PXPhotoModelCategoryLandscapes, @"API Request including only landscape photographs contains unfiltered results");
}

-(void)testForuserFavouritesFeatureByName
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserName:kTestUserName userFeature:PXAPIHelperUserPhotoFeatureFavourites] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"user_favorites", @"Photo stream request not returning user_favorites");
}

-(void)testForuserFriendsFeatureByName
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotosOfUserName:kTestUserName userFeature:PXAPIHelperUserPhotoFeatureFriends] expectingResponseCode:200];
    
    STAssertEqualObjects([dictionary valueForKey:@"feature"], @"user_friends", @"Photo stream request not returning user_friends");
}

-(void)testForRetrievePhotoID
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotoID:kTestPhotoID] expectingResponseCode:200];
    
    STAssertNotNil([dictionary valueForKey:@"comments"], @"Photo details returned no comments array.");
}

-(void)testForRetrievePhotoIDComments
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotoID:kTestPhotoID commentsPage:1] expectingResponseCode:200];
    
    STAssertNotNil(dictionary, @"Photo details returned nil details");
}

-(void)testForMaximumResultsPerPage
{
    NSDictionary *dictionary = [PXTests jsonDictionaryForRequest:[helper urlRequestForPhotoFeature:PXAPIHelperPhotoFeaturePopular resultsPerPage:kPXAPIHelperMaximumResultsPerPage+1] expectingResponseCode:200];
    
    STAssertTrue([[dictionary valueForKey:@"photos"] count] < kPXAPIHelperMaximumResultsPerPage+1, @"Requested more than maximum allowable results per page.");
}

-(void)testFavouriteRequestIsNilWhenNotAuthenticated
{
    NSURLRequest *request = [helper urlRequestToFavouritePhoto:kTestPhotoID];
    
    STAssertNil(request, @"Request to favourite a photo did not return nil despite not being logged in");
}

-(void)testVoteRequestIsNilWhenNotAuthenticated
{
    NSURLRequest *request = [helper urlRequestToVoteForPhoto:kTestPhotoID];
    
    STAssertNil(request, @"Request to vote for a photo did not return nil despite not being logged in");
}

-(void)testCommentRequestIsNilWhenNotAuthenticated
{
    NSURLRequest *request = [helper urlRequestToComment:@"some comment" onPhoto:kTestPhotoID];
    
    STAssertNil(request, @"Request to comment a photo did not return nil despite not being logged in");
}

@end
