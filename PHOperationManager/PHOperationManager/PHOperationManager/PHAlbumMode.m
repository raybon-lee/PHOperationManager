//
//  PHAlbumMode.m
//  PHOperationManager
//
//  Created by Dinotech on 16/4/15.
//  Copyright © 2016年 Raybon. All rights reserved.
//

#import "PHAlbumMode.h"

@implementation PHAlbumMode


+ (PHAlbumMode *)transformToAlbumModeFromCollection:(PHCollection *)collectionList album_Type:(RYAlbumType)type{
    PHAlbumMode * albumMode = [[PHAlbumMode alloc]init];
    PHAssetCollection * assetCollection = (PHAssetCollection *)collectionList;
    albumMode.mode_Collection = assetCollection;
    /*!
     *  @brief  查询当前相册下的图片资源
     */
    albumMode.mode_AssetsOfCollections = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    BOOL  canEditResult = [collectionList canPerformEditOperation:PHCollectionEditOperationAddContent |PHCollectionEditOperationDelete | PHCollectionEditOperationRename |
        PHCollectionEditOperationCreateContent |
        PHCollectionEditOperationRemoveContent |
        PHCollectionEditOperationRearrangeContent];
    albumMode.isCanEdit = canEditResult;
    if (type ==RYAlbumType_TopUserLevelCollection) {
        albumMode.album_name = collectionList.localizedTitle;
    }
    albumMode.startDate = assetCollection.startDate;
    albumMode.endDate   = assetCollection.endDate;
    albumMode.album_location = assetCollection.approximateLocation;
    albumMode.localLocationAlbumsName = assetCollection.localizedLocationNames;
    if ([collectionList.localizedTitle isEqualToString:@"Camera Roll"]) {
        albumMode.album_name = @"相机胶卷";
    }
    if ([collectionList.localizedTitle isEqualToString:@"Recently Added"]) {
        albumMode.album_name = @"最近增加";
    }
    if ([collectionList.localizedTitle isEqualToString:@"Recently Deleted"]) {
        albumMode.album_name = @"最近删除";
    }
    if ([collectionList.localizedTitle isEqualToString:@"Screenshots"]) {
        albumMode.album_name = @"屏幕快照";
    }
    if ([collectionList.localizedTitle isEqualToString:@"Hidden"]) {
        albumMode.album_name  = @"隐藏";
    }
    if ([collectionList.localizedTitle isEqualToString:@"Bursts"]) {
        albumMode.album_name = @"连拍照片";
    }
    if ([collectionList.localizedTitle isEqualToString:@"Selfies"]) {
        albumMode.album_name = @"自拍照";
    }
    if ([collectionList.localizedTitle isEqualToString:@"Panoramas"]) {
        albumMode.album_name = @"全景相册";
    }
    if ([collectionList.localizedTitle isEqualToString:@"Favorites"]) {
        albumMode.album_name = @"个人收藏";
    }
    if ([collectionList.localizedTitle isEqualToString:@"Time-lapse"]) {
        albumMode.album_name = @"延时照片";
    }
    if ([collectionList.localizedTitle isEqualToString:@"Videos"]) {
        albumMode.album_name = @"视频";
    }
    if ([collectionList.localizedTitle isEqualToString:@"Slo-mo"]) {
        albumMode.album_name = @"慢动作相册";
    }


    return albumMode;
}


- (NSString *)description{
    
    return [NSString stringWithFormat:@"\n album_name = %@ \n  canEdit =%d  \n startDate = %@ \n endDate = %@ \n localNames = %@",self.album_name,self.isCanEdit,self.startDate,self.endDate,self.localLocationAlbumsName];

}
@end
