//
//  PXAPIHelper.m
//  500px-iOS-api
//
//  Created by Ash Furrow on 12-07-27.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXAPIHelper.h"

#define kPXAPIBaseURL   @"https://api.500px.com/v1"

@implementation PXAPIHelper

#pragma mark - Auth Mode Getters/Setters

//TODO: Need to implement OAuth support

-(PXAPIHelperMode)authMode
{
    return PXAPIHelperModeNoAuth;
}

#pragma mark - Private Methods

-(NSString *)urlStringPhotoCategoryForPhotoCategory:(PXPhotoModelCategory)photoCategory
{
    NSString *urlStringPhotoCategory;
    
    switch (photoCategory) {
        case PXPhotoModelCategoryAbstract:
            urlStringPhotoCategory = @"Abstract";
            break;
        case PXPhotoModelCategoryAnimals:
            urlStringPhotoCategory = @"Animals";
            break;
        case PXPhotoModelCategoryBlackAndWhite:
            urlStringPhotoCategory = @"Black+and+White";
            break;
        case PXPhotoModelCategoryCelbrities:
            urlStringPhotoCategory = @"Celebrities";
            break;
        case PXPhotoModelCategoryCityAndArchitecture:
            urlStringPhotoCategory = @"City+and+Architecture";
            break;
        case PXPhotoModelCategoryCommercial:
            urlStringPhotoCategory = @"Commericial";
            break;
        case PXPhotoModelCategoryConcert:
            urlStringPhotoCategory = @"Concert";
            break;
        case PXPhotoModelCategoryFamily:
            urlStringPhotoCategory = @"Family";
            break;
        case PXPhotoModelCategoryFashion:
            urlStringPhotoCategory = @"Fashion";
            break;
        case PXPhotoModelCategoryFilm:
            urlStringPhotoCategory = @"Film";
            break;
        case PXPhotoModelCategoryFineArt:
            urlStringPhotoCategory = @"Fine+Art";
            break;
        case PXPhotoModelCategoryFood:
            urlStringPhotoCategory = @"Food";
            break;
        case PXPhotoModelCategoryJournalism:
            urlStringPhotoCategory = @"Journalism";
            break;
        case PXPhotoModelCategoryLandscapes:
            urlStringPhotoCategory = @"Landscapes";
            break;
        case PXPhotoModelCategoryMacro:
            urlStringPhotoCategory = @"Macro";
            break;
        case PXPhotoModelCategoryNature:
            urlStringPhotoCategory = @"Nature";
            break;
        case PXPhotoModelCategoryNude:
            urlStringPhotoCategory = @"Nude";
            break;
        case PXPhotoModelCategoryPeople:
            urlStringPhotoCategory = @"People";
            break;
        case PXPhotoModelCategoryPerformingArts:
            urlStringPhotoCategory = @"Performing+Arts";
            break;
        case PXPhotoModelCategorySport:
            urlStringPhotoCategory = @"Sport";
            break;
        case PXPhotoModelCategoryStillLife:
            urlStringPhotoCategory = @"Still+Life";
            break;
        case PXPhotoModelCategoryStreet:
            urlStringPhotoCategory = @"Street";
            break;
        case PXPhotoModelCategoryTransportation:
            urlStringPhotoCategory = @"Transportation";
            break;
        case PXPhotoModelCategoryTravel:
            urlStringPhotoCategory = @"Travel";
            break;
        case PXPhotoModelCategoryUncategorized:
            urlStringPhotoCategory = @"Uncategorized";
            break;
        case PXPhotoModelCategoryUnderwater:
            urlStringPhotoCategory = @"Underwater";
            break;
        case PXPhotoModelCategoryUrbanExploration:
            urlStringPhotoCategory = @"Urban+Exploration";
            break;
        case PXPhotoModelCategoryWedding:
            urlStringPhotoCategory = @"Wedding";
            break;
        case PXAPIHelperUnspecifiedCategory:    //this is a sentinel value used to *not* filter results.
            urlStringPhotoCategory = nil;       //should never execute this branch; only here to silence compiler warnings.
            break;
    }
    
    return urlStringPhotoCategory;
}

-(NSString *)stringForSortOrder:(PXAPIHelperSortOrder)sortOrder
{
    NSString *sortOrderString;
    
    switch (sortOrder) {
        case PXAPIHelperSortOrderCommentsCount:
            sortOrderString = @"comments_count";
            break;
        case PXAPIHelperSortOrderCreatedAt:
            sortOrderString = @"created_at";
            break;
        case PXAPIHelperSortOrderFavouritesCount:
            sortOrderString = @"favorites_count";
            break;
        case PXAPIHelperSortOrderRating:
            sortOrderString = @"rating";
            break;
        case PXAPIHelperSortOrderTakenAt:
            sortOrderString = @"taken_at";
            break;
        case PXAPIHelperSortOrderTimesViewed:
            sortOrderString = @"times_views";
            break;
        case PXAPIHelperSortOrderVotesCount:
            sortOrderString = @"votes_count";
            break;
    }
    
    return sortOrderString;
}

-(NSString *)stringForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature
{
    NSString *photoFeatureString;
    switch (photoFeature)
    {
        case PXAPIHelperPhotoFeaturePopular:
            photoFeatureString = @"popular";
            break;
        case PXAPIHelperPhotoFeatureEditors:
            photoFeatureString = @"editors";
            break;
        case PXAPIHelperPhotoFeatureFreshToday:
            photoFeatureString = @"fresh_today";
            break;
        case PXAPIHelperPhotoFeatureFreshWeek:
            photoFeatureString = @"fresh_week";
            break;
        case PXAPIHelperPhotoFeatureFreshYesterday:
            photoFeatureString = @"fresh_yesterday";
            break;
        case PXAPIHelperPhotoFeatureUpcoming:
            photoFeatureString = @"upcoming";
            break;
    }
    
    return photoFeatureString;
}

-(NSDictionary *)photoSizeDictionaryForSizeMask:(PXPhotoModelSize)sizeMask
{
    NSMutableDictionary *sizeStringDictionary = [NSMutableDictionary dictionary];
    
    if ((sizeMask & PXPhotoModelSizeExtraSmallThumbnail) > 0)
    {
        [sizeStringDictionary setObject:@"1" forKey:@"image_size[]"];
    }
    if ((sizeMask & PXPhotoModelSizeSmallThumbnail) > 0)
    {
        [sizeStringDictionary setObject:@"2" forKey:@"image_size[]"];
    }
    if ((sizeMask & PXPhotoModelSizeThumbnail) > 0)
    {
        [sizeStringDictionary setObject:@"3" forKey:@"image_size[]"];
    }
    if ((sizeMask & PXPhotoModelSizeLarge) > 0)
    {
        [sizeStringDictionary setObject:@"4" forKey:@"image_size[]"];
    }
    if ((sizeMask & PXPhotoModelSizeExtraLarge) > 0)
    {
        [sizeStringDictionary setObject:@"5" forKey:@"image_size[]"];
    }
    
    return sizeStringDictionary;
}

#pragma mark - GET Photos

-(NSURLRequest *)urlRequestForPhotos
{
    return [self urlRequestForPhotoFeature:kPXAPIHelperDefaultFeature];
}

-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature
{
    return [self urlRequestForPhotoFeature:photoFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage];
}

-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage
{
    return [self urlRequestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage pageNumber:1];
}

-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage pageNumber:(NSInteger)pageNumber
{
    return [self urlRequestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage pageNumber:pageNumber photoSizes:kPXAPIHelperDefaultPhotoSize];
}

-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage pageNumber:(NSInteger)pageNumber photoSizes:(PXPhotoModelSize)photoSizesMask
{
    return [self urlRequestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage pageNumber:pageNumber photoSizes:photoSizesMask sortOrder:kPXAPIHelperDefaultSortOrder];
}

-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage pageNumber:(NSInteger)pageNumber photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder
{
    return [self urlRequestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage pageNumber:pageNumber photoSizes:photoSizesMask sortOrder:kPXAPIHelperDefaultSortOrder except:(PXPhotoModelCategory)PXAPIHelperUnspecifiedCategory];
}

-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage pageNumber:(NSInteger)pageNumber photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory
{
    
    return [self urlRequestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage pageNumber:pageNumber photoSizes:photoSizesMask sortOrder:kPXAPIHelperDefaultSortOrder except:excludedCategory only:PXAPIHelperUnspecifiedCategory];
}

-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage pageNumber:(NSInteger)pageNumber photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory
{
    NSMutableDictionary *options = [@{@"feature" : [self stringForPhotoFeature:photoFeature],
    @"rpp" : @(resultsPerPage),
    @"sort" : [self stringForSortOrder:sortOrder],
    @"page" : @(pageNumber)} mutableCopy];
    
    if (excludedCategory != PXAPIHelperUnspecifiedCategory)
    {
        [options setObject:[self urlStringPhotoCategoryForPhotoCategory:excludedCategory] forKey:@"exclude"];
    }
    
    if (includedCategory != PXAPIHelperUnspecifiedCategory)
    {
        [options setObject:[self urlStringPhotoCategoryForPhotoCategory:includedCategory] forKey:@"only"];
    }
    
    //image sizes may be treated differently when signing with OAuth
    NSDictionary *imageSizeDictionary = [self photoSizeDictionaryForSizeMask:photoSizesMask];
    
    NSMutableURLRequest *mutableRequest;
    
    if (self.authMode == PXAPIHelperModeNoAuth)
    {
        [options addEntriesFromDictionary:imageSizeDictionary];
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/photos?consumer_key=%@",
                                      kPXAPIBaseURL,
                                      kPXAPIConsumerKey];
        
        for (id key in options.allKeys) {
            [urlString appendFormat:@"&%@=%@", key, [options valueForKey:key]];
        }
        
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    }
    
    return mutableRequest;
}

@end
