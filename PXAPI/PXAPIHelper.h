//
//  PXAPIHelper.h
//  500px-iOS-api
//
//  Created by Ash Furrow on 12-07-27.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger
{
    PXAPIHelperPhotoFeaturePopular = 0,
    PXAPIHelperPhotoFeatureUpcoming,
    PXAPIHelperPhotoFeatureEditors,
    PXAPIHelperPhotoFeatureFreshToday,
    PXAPIHelperPhotoFeatureFreshYesterday,
    PXAPIHelperPhotoFeatureFreshWeek,
}PXAPIHelperPhotoFeature;

typedef enum : NSInteger
{
    PXAPIHelperUserPhotoFeaturePhotos = 0,
    PXAPIHelperUserPhotoFeatureFriends,
    PXAPIHelperUserPhotoFeatureFavourites
}PXAPIHelperUserPhotoFeature;

typedef enum : NSInteger
{
    PXAPIHelperSortOrderCreatedAt = 0,
    PXAPIHelperSortOrderRating,
    PXAPIHelperSortOrderTimesViewed,
    PXAPIHelperSortOrderVotesCount,
    PXAPIHelperSortOrderFavouritesCount,
    PXAPIHelperSortOrderCommentsCount,
    PXAPIHelperSortOrderTakenAt
}PXAPIHelperSortOrder;

typedef enum : NSUInteger
{
    PXPhotoModelSizeExtraSmallThumbnail = (1 << 0),
    PXPhotoModelSizeSmallThumbnail = (1 << 1),
    PXPhotoModelSizeThumbnail = (1 << 2),
    PXPhotoModelSizeLarge = (1 << 3),
    PXPhotoModelSizeExtraLarge = (1 << 4)
}PXPhotoModelSize;

typedef enum : NSInteger
{
    PXPhotoModelCategoryUncategorized = 0,
    PXPhotoModelCategoryAbstract = 10,
    PXPhotoModelCategoryAnimals = 11,
    PXPhotoModelCategoryBlackAndWhite = 5,
    PXPhotoModelCategoryCelbrities = 1,
    PXPhotoModelCategoryCityAndArchitecture = 9,
    PXPhotoModelCategoryCommercial = 15,
    PXPhotoModelCategoryConcert = 16,
    PXPhotoModelCategoryFamily = 20,
    PXPhotoModelCategoryFashion = 14,
    PXPhotoModelCategoryFilm = 2,
    PXPhotoModelCategoryFineArt = 24,
    PXPhotoModelCategoryFood = 23,
    PXPhotoModelCategoryJournalism = 3,
    PXPhotoModelCategoryLandscapes = 8,
    PXPhotoModelCategoryMacro = 12,
    PXPhotoModelCategoryNature = 18,
    PXPhotoModelCategoryNude = 4,
    PXPhotoModelCategoryPeople = 7,
    PXPhotoModelCategoryPerformingArts = 19,
    PXPhotoModelCategorySport = 17,
    PXPhotoModelCategoryStillLife = 6,
    PXPhotoModelCategoryStreet = 21,
    PXPhotoModelCategoryTransportation = 26,
    PXPhotoModelCategoryTravel = 13,
    PXPhotoModelCategoryUnderwater = 22,
    PXPhotoModelCategoryUrbanExploration = 27,
    PXPhotoModelCategoryWedding = 25,
    
    PXAPIHelperUnspecifiedCategory = -1
}PXPhotoModelCategory;

typedef enum : NSInteger
{
    PXAPIHelperModeNoAuth = 0,
    PXAPIHelperModeOAuth
}PXAPIHelperMode;

#define kPXAPIHelperDefaultResultsPerPage   20
#define kPXAPIHelperMaximumResultsPerPage   100
#define kPXAPIHelperDefaultFeature          PXAPIHelperPhotoFeaturePopular
#define kPXAPIHelperDefaultUserPhotoFeature PXAPIHelperUserPhotoFeaturePhotos
#define kPXAPIHelperDefaultPhotoSize        PXPhotoModelSizeLarge | PXPhotoModelSizeThumbnail
#define kPXAPIHelperDefaultSortOrder        PXAPIHelperSortOrderCreatedAt

@interface PXAPIHelper : NSObject

- (id)initWithHost:(NSString *)host
       consumerKey:(NSString *)consumerKey
    consumerSecret:(NSString *)consumerSecret;

@property (nonatomic, readonly) NSString *host;
@property (nonatomic, readonly) NSString *consumerKey;
@property (nonatomic, readonly) NSString *consumerSecret;

@property (nonatomic, readonly) NSString *authToken;
@property (nonatomic, readonly) NSString *authSecret;

@property (nonatomic, readonly) PXAPIHelperMode authMode;

#pragma mark - Methods to change auth mode

-(void)setAuthModeToNoAuth;
-(void)setAuthModeToOAuthWithAuthToken:(NSString *)authToken authSecret:(NSString *)authSecret;

#pragma mark - Photos

//photo pages are 1-indexed

-(NSURLRequest *)urlRequestForPhotos;
-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature;
-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage;
-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page;
-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask;
-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder;
-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory;
-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory;

#pragma mark - Photos for Specified User

-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID;
-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature;
-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage;
-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page;
-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask;
-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder;
-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory;
-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory;

-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName;
-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature;
-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage;
-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page;
-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask;
-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder;
-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory;
-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory;

#pragma mark - Favourite, Vote, and Comment

//Requires Authentication
-(NSURLRequest *)urlRequestToFavouritePhoto:(NSInteger)photoID;
-(NSURLRequest *)urlRequestToUnFavouritePhoto:(NSInteger)photoID;
-(NSURLRequest *)urlRequestToVoteForPhoto:(NSInteger)photoID;
-(NSURLRequest *)urlRequestToComment:(NSString *)comment onPhoto:(NSInteger)photoID;

#pragma mark - Photo Details

//Comment pages are 1-indexed
//20 comments per page

-(NSURLRequest *)urlRequestForPhotoID:(NSInteger)photoID;
-(NSURLRequest *)urlRequestForPhotoID:(NSInteger)photoID commentsPage:(NSInteger)commentsPage;
-(NSURLRequest *)urlRequestForPhotoID:(NSInteger)photoID photoSizes:(PXPhotoModelSize)photoSizesMask commentsPage:(NSInteger)commentPage;

#pragma mark - Photo Searching

//Search page results are 1-indexed

-(NSURLRequest *)urlRequestForSearchTerm:(NSString *)searchTerm;
-(NSURLRequest *)urlRequestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page;
-(NSURLRequest *)urlRequestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage;
-(NSURLRequest *)urlRequestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask;
-(NSURLRequest *)urlRequestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory;

-(NSURLRequest *)urlRequestForSearchTag:(NSString *)searchTag;
-(NSURLRequest *)urlRequestForSearchTag:(NSString *)searchTag page:(NSUInteger)page;
-(NSURLRequest *)urlRequestForSearchTag:(NSString *)searchTag page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage;
-(NSURLRequest *)urlRequestForSearchTag:(NSString *)searchTag page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask;
-(NSURLRequest *)urlRequestForSearchTag:(NSString *)searchTag page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory;

#pragma mark - Users

//Requires Authentication
-(NSURLRequest *)urlRequestForCurrentlyLoggedInUser;

-(NSURLRequest *)urlRequestForUserWithID:(NSInteger)userID;
-(NSURLRequest *)urlRequestForUserWithUserName:(NSString *)userName;
-(NSURLRequest *)urlRequestForUserWithEmailAddress:(NSString *)userEmailAddress;

-(NSURLRequest *)urlRequestForUserSearchWithTerm:(NSString *)searchTerm;

//pages are 1-indexed
-(NSURLRequest *)urlRequestForUserFollowing:(NSInteger)userID;
-(NSURLRequest *)urlRequestForUserFollowing:(NSInteger)userID page:(NSInteger)page;
-(NSURLRequest *)urlRequestForUserFollowers:(NSInteger)userID;
-(NSURLRequest *)urlRequestForUserFollowers:(NSInteger)userID page:(NSInteger)page;

//Requires Authentication
-(NSURLRequest *)urlRequestToFollowUser:(NSInteger)userToFollowID;
-(NSURLRequest *)urlRequestToUnFollowUser:(NSInteger)userToUnFollowID;

@end
