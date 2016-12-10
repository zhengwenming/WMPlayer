//
//  CRViewController.m
//  CRAnimation
//
//  Created by BearRan on 10/07/2016.
//  Copyright (c) 2016 BearRan. All rights reserved.
//

#import "CRViewController.h"
#import "CRDemoInfoModel.h"
#import "CRItemBriefCollectionViewCell.h"
#import "CRItemBriefSetcionHeaderView.h"

static NSString *collectionViewCellID           = @"collectionViewCellID";
static NSString *collectionViewReusableViewID   = @"collectionViewReusableViewID";

static NSString *__kCRDemoStorage       = @"动效仓库";
static NSString *__kCRDemoCombination   = @"组合动效";

@interface CRViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray    *dataArrayTitle;
@property (strong, nonatomic) NSMutableArray    *dataArrayDemoModel;

@property (strong, nonatomic) NSArray           *storageDemoInfoModelNameArray;
@property (strong, nonatomic) NSArray           *combinationDemoInfoModelNameArray;


@property (strong, nonatomic) UICollectionView  *mainCollectionView;

@end

@implementation CRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self dataReady];
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)dataReady
{
    _dataArrayTitle = [[NSMutableArray alloc] initWithArray:@[
                                                              __kCRDemoStorage,
                                                              __kCRDemoCombination,
                                                              ]];
    
    _storageDemoInfoModelNameArray = @[
                                       @"CRCardAnimationViewDemoInfoModel",
                                       @"CRImageGradientDemoInfoModel",
                                       @"GifDemoInfoModel"
                                       ];
    
    _combinationDemoInfoModelNameArray = @[
                                           @"CRMusicCardDemoInfoModel"
                                           ];
    
    [self dealDemoNameArray:_storageDemoInfoModelNameArray withGroupName:__kCRDemoStorage];
    [self dealDemoNameArray:_combinationDemoInfoModelNameArray withGroupName:__kCRDemoCombination];
}

- (void)dealDemoNameArray:(NSArray *)demoNameArray withGroupName:(NSString *)groupName
{
    for (NSString *demoName in demoNameArray) {
        [self addDemoInfoModelName:demoName withGroupName:groupName];
    }
}

- (void)addDemoInfoModelName:(NSString *)demoInfoModelName withGroupName:(NSString *)groupName
{
    if (!_dataArrayDemoModel) {
        _dataArrayDemoModel = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [_dataArrayTitle count]; i++) {
            NSMutableArray *subMutableArray = [NSMutableArray new];
            [_dataArrayDemoModel addObject:subMutableArray];
        }
    }
    
    if ([demoInfoModelName length] > 0) {
        
        CRDemoInfoModel *infoModel = [[NSClassFromString(demoInfoModelName) alloc] init];
        if (infoModel) {
            
            //  添加新的Demo数据模型
            NSInteger index = [self.dataArrayTitle indexOfObject:groupName];
            NSMutableArray *subMutableArray = self.dataArrayDemoModel[index];
            [subMutableArray addObject:infoModel];
            _dataArrayDemoModel[index] = subMutableArray;
        }
    }
}

- (void)createUI
{
    self.view.backgroundColor = color_Master;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, STATUS_HEIGHT, WIDTH, HEIGHT - STATUS_HEIGHT) collectionViewLayout:layout];
    _mainCollectionView.backgroundColor = color_Master;
    _mainCollectionView.delegate = self;
    _mainCollectionView.dataSource = self;
    [self.view addSubview:_mainCollectionView];
    [_mainCollectionView registerClass:[CRItemBriefCollectionViewCell class] forCellWithReuseIdentifier:collectionViewCellID];
    [_mainCollectionView registerClass:[CRItemBriefSetcionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionViewReusableViewID];
}


#pragma mark - collectionView dataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [_dataArrayDemoModel count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_dataArrayDemoModel[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CRItemBriefCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellID forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor purpleColor];
    
    CRDemoInfoModel *demoInfoModel = _dataArrayDemoModel[indexPath.section][indexPath.row];
    if (demoInfoModel.demoVCName) {
        [cell loadDemoInfoModel:demoInfoModel];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    if([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        CRItemBriefSetcionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:collectionViewReusableViewID forIndexPath:indexPath];
        if(headerView == nil)
        {
            headerView = [[CRItemBriefSetcionHeaderView alloc] init];
        }
        headerView.titleLabel.text = _dataArrayTitle[indexPath.section];
        
        return headerView;
    }
    else if([kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        nil;
    }
    
    return nil;
}


#pragma mark - collectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CRDemoInfoModel *demoInfoModel = _dataArrayDemoModel[indexPath.section][indexPath.row];
    
    if (demoInfoModel.demoVCName) {
        CRBaseViewController *destinationVC = [[NSClassFromString(demoInfoModel.demoVCName) alloc] init];
        [self.navigationController pushViewController:destinationVC animated:YES];
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return (CGSize){WIDTH, 40};
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = WIDTH / 2.0 - 10;
    CGFloat cellHeight = 1.0 * HEIGHT6 / WIDTH6 * cellWidth;
    return (CGSize){cellWidth, cellHeight};
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.f;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
