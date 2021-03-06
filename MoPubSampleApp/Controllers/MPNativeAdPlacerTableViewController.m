//
//  MPNativeAdSourceTableViewController.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPNativeAdPlacerTableViewController.h"

#import "MPNativeAdTableViewController.h"
#import "MPNativeAdRequestTargeting.h"
#import "MPNativeAdCell.h"
#import "MPAdInfo.h"
#import "MPTableViewAdPlacer.h"
#import "MPClientAdPositioning.h"
#import "MPNativeAdConstants.h"
#import <CoreLocation/CoreLocation.h>

@interface MPNativeAdPlacerTableViewController ()

@property (nonatomic, strong) NSMutableArray *contentItems;
@property (nonatomic, strong) MPAdInfo *adInfo;
@property (nonatomic, strong) MPTableViewAdPlacer *placer;

@end

@implementation MPNativeAdPlacerTableViewController

#pragma mark - Object Lifecycle

- (id)initWithAdInfo:(MPAdInfo *)info
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = @"Table View Ad Placer";
        self.adInfo = info;
        self.contentItems = [NSMutableArray array];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_7_0
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
#endif
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self.tableView respondsToSelector:@selector(registerClass:forCellReuseIdentifier:)]) {
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDefaultCellIdentifier];
    }

    [self setupContent];
    [self setupAdPlacer];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

#pragma mark - Content

- (void)setupContent
{
    self.contentItems = [NSMutableArray array];

    for (NSString *fontFamilyName in [UIFont familyNames]) {
        for (NSString *fontName in [UIFont fontNamesForFamilyName:fontFamilyName]) {
            [self.contentItems addObject:fontName];
        }
    }

    [self.contentItems sortUsingSelector:@selector(compare:)];
}

#pragma mark - AdPlacer

- (void)setupAdPlacer
{
    // Create a targeting object to serve better ads.
    MPNativeAdRequestTargeting *targeting = [MPNativeAdRequestTargeting targeting];
    targeting.location = [[CLLocation alloc] initWithLatitude:37.7793 longitude:-122.4175];
    targeting.desiredAssets = [NSSet setWithObjects:kAdIconImageKey, kAdMainImageKey, kAdCTATextKey, kAdTextKey, kAdTitleKey, nil];

    // Create a table view ad placer that uses server-side ad positioning.
    self.placer = [MPTableViewAdPlacer placerWithTableView:self.tableView viewController:self defaultAdRenderingClass:[MPNativeAdCell class]];

    // If you wish to use client-side ad positioning rather than configuring your ad unit on the
    // MoPub website, comment out the line above and use the code below instead.

    /*
    // Create an ad positioning object and register the index paths where ads should be displayed.
    MPClientAdPositioning *positioning = [MPClientAdPositioning positioning];
    [positioning addFixedIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [positioning addFixedIndexPath:[NSIndexPath indexPathForRow:10 inSection:0]];
    [positioning enableRepeatingPositionsWithInterval:10];

    self.placer = [MPTableViewAdPlacer placerWithTableView:self.tableView viewController:self adPositioning:positioning defaultAdRenderingClass:[MPNativeAdCell class]];
     */

    // Load ads (using a test ad unit ID). Feel free to replace this ad unit ID with your own.
    [self.placer loadAdsForAdUnitID:self.adInfo.ID targeting:targeting];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contentItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     * IMPORTANT: add the mp_ prefix to dequeueReusableCellWithReuseIdentifier:forIndexPath:.
     */
    UITableViewCell *cell = [tableView mp_dequeueReusableCellWithIdentifier:kDefaultCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCellIdentifier];
    }

    NSString *fontName = self.contentItems[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:fontName size:20.0];
    cell.textLabel.text = fontName;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     * IMPORTANT: add the mp_ prefix to deselectRowAtIndexPath:animated:.
     */
    [tableView mp_deselectRowAtIndexPath:indexPath animated:YES];
}

@end
