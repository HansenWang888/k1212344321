//
//  LSYAlbumPicker.m
//  AlbumPicker
//
//  Created by okwei on 15/7/23.
//  Copyright (c) 2015年 okwei. All rights reserved.
//

#import "LSYAlbumPicker.h"
#import "LSYDelegateDataSource.h"
#import "LSYAlbum.h"
#import "LSYPickerButtomView.h"
#import "LSYAssetPreview.h"
@interface LSYAlbumPicker ()<UICollectionViewDelegate,LSYPickerButtomViewDelegate,LSYAssetPreviewDelegate>
@property (nonatomic,strong) UICollectionView *albumView;
@property (nonatomic,strong) LSYDelegateDataSource *albumDelegateDataSource;
@property (nonatomic,strong) NSMutableArray *albumAssets;
@property (nonatomic,strong) LSYPickerButtomView *pickerButtomView;
@property (nonatomic,strong) NSMutableArray *assetsSort;
@property (nonatomic,strong) NSMutableArray *selectedAssets;
@property (nonatomic)int selectNumbers;
@end

@implementation LSYAlbumPicker

-(UICollectionView *)albumView
{
    if (!_albumView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = kThumbnailSize;
        flowLayout.sectionInset = UIEdgeInsetsMake(5,5,5, 5);
        flowLayout.minimumInteritemSpacing = 5;
        flowLayout.minimumLineSpacing = 5;
        _albumView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ViewSize(self.view).width, ViewSize(self.view).height-44) collectionViewLayout:flowLayout];
        _albumView.allowsMultipleSelection = YES;
        [_albumView registerClass:[LSYAlbumCell class] forCellWithReuseIdentifier:kAlbumCellIdentifer];
        _albumView.delegate = self;
        _albumView.dataSource = self.albumDelegateDataSource;
        _albumView.backgroundColor = [UIColor whiteColor];
        _albumView.alwaysBounceVertical = YES;
    }
    return _albumView;
}
-(LSYDelegateDataSource *)albumDelegateDataSource
{
    if (!_albumDelegateDataSource) {
        _albumDelegateDataSource = [[LSYDelegateDataSource alloc] init];
    }
    return _albumDelegateDataSource;
}
-(LSYPickerButtomView *)pickerButtomView
{
    if (!_pickerButtomView) {
        _pickerButtomView = [[LSYPickerButtomView alloc] initWithFrame:CGRectMake(0, ViewSize(self.view).height-44, ViewSize(self.view).width, 44)];
        _pickerButtomView.delegate = self;
        [_pickerButtomView setSendNumber:self.selectNumbers];
    }
    return _pickerButtomView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [self.group valueForProperty:ALAssetsGroupPropertyName];
    self.assetsSort = [NSMutableArray array];
    [self.view addSubview:self.albumView];
    [self.view addSubview:self.pickerButtomView];
    [[LSYAlbum sharedAlbum] setupAlbumAssets:self.group withAssets:^(NSMutableArray *assets) {
        self.albumAssets = assets;
        self.albumDelegateDataSource.albumDataArray = assets;
        [self.albumView reloadData];
    }];
    // Do any additional setup after loading the view.
}
-(void)setSelectNumbers:(int)selectNumbers
{
    _selectNumbers = selectNumbers;
    [self.pickerButtomView setSendNumber:selectNumbers];
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.selectNumbers = (int)self.albumView.indexPathsForSelectedItems.count;
}
#pragma mark -LSYPickerButtomViewDelegate
-(void)previewButtonClick
{
    LSYAssetPreview *assetPreview = [[LSYAssetPreview alloc] init];
    [self.navigationController pushViewController:assetPreview animated:YES];
    assetPreview.assets = self.selectedAssets;
    assetPreview.AlbumCollection = self.albumView;
    assetPreview.delegate = self;
}
-(void)sendButtonClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(AlbumPickerDidFinishPick:)]) {
        NSMutableArray *assets = [NSMutableArray array];
        for (LSYAlbumModel *model in self.selectedAssets) {
            [assets addObject:model.asset];
        }
        [self.delegate AlbumPickerDidFinishPick:assets];
    }
    
}
#pragma mark -LSYAssetPreviewDelegate
-(void)AssetPreviewDidFinishPick:(NSArray *)assets
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(AlbumPickerDidFinishPick:)]){
        [self.delegate AlbumPickerDidFinishPick:assets];
    }
}
#pragma mark -UICollectionViewDelegate
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.maxminumNumber) {
        if (!(self.maxminumNumber>collectionView.indexPathsForSelectedItems.count)) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:[NSString stringWithFormat:@"%@%d%@",NSLocalizedString(@"最多只能选", nil),(int)self.maxminumNumber,NSLocalizedString(@"张照片", nil)] delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles: nil];
            [alertView show];
            return NO;
        }
        return YES;
    }
    else
        return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectNumbers = (int)collectionView.indexPathsForSelectedItems.count;
    [self.assetsSort addObject:indexPath];
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectNumbers = (int)collectionView.indexPathsForSelectedItems.count;
    [self.assetsSort removeObject:indexPath];
}
-(NSMutableArray *)selectedAssets
{
    if (!_selectedAssets) {
        _selectedAssets = [NSMutableArray array];
       
    }
    [_selectedAssets removeAllObjects];
    for (NSIndexPath *indexPath in self.assetsSort) {
        [_selectedAssets addObject:self.albumAssets[indexPath.item]];
    }
    return _selectedAssets;
}

@end
