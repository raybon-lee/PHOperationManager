//
//  PHOperationManager.m
//  PHOperationManager
//
//  Created by Dinotech on 16/4/15.
//  Copyright © 2016年 Raybon. All rights reserved.
//

#import "PHOperationManager.h"
@interface PHOperationManager()
@property (nonnull ,strong, nonatomic) PHFetchResult   * ph_FetchReslt;
@end
static PHOperationManager * __operationManager = nil;
@implementation PHOperationManager

    //用户授权判断
- (void)requestAuthorizationStatus:(void (^)(RYAuthorizationStatus))authorBlock{

        //获取用户授权状态
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        RYAuthorizationStatus authStatus;
        switch (status) {
            case PHAuthorizationStatusNotDetermined:
                authStatus =RYAuthorizationStatus_NotDetermined;

                break;
                case PHAuthorizationStatusDenied:
                authStatus =RYAuthorizationStatus_Denied;

                break;
                case PHAuthorizationStatusAuthorized:
                authStatus =RYAuthorizationStatus_Authorized;
                break;

                case PHAuthorizationStatusRestricted:
                authStatus =RYAuthorizationStatus_Restricted;
                break;

                
            default:
                break;
        }
        CHECK_BLOCK_EXIST(authorBlock,authStatus);
        

    }];
}

#pragma mark -- smart albums
    //获取智能相册集
- (void)managerQueryThePHAssetCollectionsFromSmartAlbumsHandleWithCompletion:(void (^)(NSArray<PHAlbumMode *> * _Nonnull))collectionBlock{

        //不通过operations  获取正常下的智能相册
    self.ph_FetchReslt= [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    if (self.ph_FetchReslt) {
//        __weak __typeof(self) weakSelf = self;
        NSMutableArray <PHAlbumMode *>* resultArray = [NSMutableArray arrayWithCapacity:self.ph_FetchReslt.count];
        [self.ph_FetchReslt enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[PHCollection class]]) {
                PHCollection * collectionList = (PHCollection *)obj;
                PHAlbumMode * mode =   [PHAlbumMode  transformToAlbumModeFromCollection:collectionList album_Type:RYAlbumType_SmartAlbumCollection];
                [resultArray addObject:mode];

            }
        }];
        CHECK_BLOCK_EXIST(collectionBlock,resultArray);
    }
    NSLog(@"smartalbumscount = %d",self.ph_FetchReslt.count);
}

#pragma mark --userTopLevel collection

- (void)managerRequestTopLevelUserCollectionWithCompletion:(void (^)(NSArray<PHAlbumMode *> * _Nonnull))userCollectionBlock{

    PHFetchResult * topUserFetchResult = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    if (topUserFetchResult) {
        NSMutableArray <PHAlbumMode *> * albumArray = [NSMutableArray arrayWithCapacity:topUserFetchResult.count];
        [topUserFetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[PHCollection class]]) {
//                NSLog(@"album_name = %@",[(PHCollection *)obj localizedTitle]);
                PHAlbumMode * mode = [PHAlbumMode transformToAlbumModeFromCollection:(PHCollection *)obj album_Type:RYAlbumType_TopUserLevelCollection];
                [albumArray addObject:mode];
            }
        }];
        CHECK_BLOCK_EXIST(userCollectionBlock,albumArray);
        

    }
    NSLog(@"topusercount = %d",topUserFetchResult.count);


}

#pragma mark --all photos

- (void)managerRequestAllPhotosWithCompletion:(void (^)(NSArray * _Nonnull))assetBlock{

    PHFetchResult * fetchResult = [PHAsset fetchAssetsWithOptions:self.manager_FetchOptions?self.manager_FetchOptions:nil];
    if (fetchResult) {
        NSLog(@"fetchcount = %d",fetchResult.count);
        NSMutableArray <PHAssetMode *> * assetModeArray = [NSMutableArray arrayWithCapacity:fetchResult.count];
        [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[PHAsset class]]) {
                PHAsset * asset = (PHAsset *)obj;
                if (asset) {
                    PHAssetMode * mode = [PHAssetMode manager_TransformAssetToAssetMode:asset];
                    [assetModeArray addObject:mode];
//                    NSLog(@"onb = %@ \n array = %d",asset.creationDate,assetModeArray.count);
                }
            }
        }];
        NSLog(@"====================================");
        CHECK_BLOCK_EXIST(assetBlock,assetModeArray);
       



    }

}
#pragma mark --请求所有单个相册的所有资源
- (void)managerRequestUnitAssetsOfAssetCollections:(PHAssetCollection *)assetCollection allAssetsWithCompletion:(void (^)(NSArray * _Nonnull))unitAssetBlock{

    PHFetchResult * assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.manager_FetchOptions?self.manager_FetchOptions:nil];
    NSMutableArray <PHAssetMode *> * assetModeArray = [NSMutableArray arrayWithCapacity:assetsFetchResult.count];
    if (assetsFetchResult) {
        [assetsFetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[PHAsset class]]) {
                PHAsset * asset = (PHAsset *)obj;
                if (asset.mediaType & PHAssetMediaTypeImage) {

                    PHAssetMode * mode = [PHAssetMode manager_TransformAssetToAssetMode:asset];
                    [assetModeArray addObject:mode];


                }
            }
        }];
        CHECK_BLOCK_EXIST(unitAssetBlock,assetModeArray);

    }


}
#pragma mark --按照月返回每个月的资源集合
- (void)managerRequestMonthAssetsListOfTotalResource:(void (^)(NSArray<NSDictionary *> * _Nonnull))monthListBlock{

    self.manager_FetchOptions =[[PHFetchOptions alloc]init];
    self.manager_FetchOptions.sortDescriptors= @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult * monthFetch = [PHAsset fetchAssetsWithOptions:self.manager_FetchOptions?self.manager_FetchOptions:nil];
    NSMutableArray * yearArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * monthArray = [NSMutableArray array];
    NSMutableArray * modelArray = [NSMutableArray array];

   __block UtilTools * tools ;

    PHContentEditingInputRequestOptions * op = [[PHContentEditingInputRequestOptions alloc]init];
    op.networkAccessAllowed = NO;
    op.canHandleAdjustmentData = ^BOOL(PHAdjustmentData * data){
        return NO;
    };
    PHImageRequestOptions * operations = [[PHImageRequestOptions alloc]init];
    operations.networkAccessAllowed = NO;
    operations.synchronous = NO;
    for (int i=0; i<monthFetch.count; i++) {
        PHAsset * asset = [monthFetch objectAtIndex:i];
        NSLog(@"----");

        
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:operations resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            NSLog(@"info = %@",info);

        }];

//        [asset requestContentEditingInputWithOptions:op completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
//            NSLog(@"请求到图片");
//        }];
    }
    return ;
    if (monthFetch) {

        [monthFetch enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            PHAsset * asset = (PHAsset *)obj;
//            PHAssetMode * assModel = [PHAssetMode manager_TransformAssetToAssetMode:asset];
//            [assModel handleCallBackTheLocalFilePathWithAsset:asset withCompletionBlock:^(id assetMode) {
//                PHAssetMode * mod = (PHAssetMode *)assModel;
//                NSLog(@"=======modfilepath = %@",mod.mode_fileName);
//
//            }];
             tools = [UtilTools getCurrentWeekOfYearByDate:asset.creationDate];
            [modelArray addObject:tools];

            if (![yearArray containsObject:tools.tool_year]) {

                [yearArray addObject:tools.tool_year];
            }
            if (![monthArray containsObject:tools.tool_month]) {
                [monthArray addObject:tools.tool_month];
//                NSLog(@"month = %@",monthArray);
            }



        }];


        NSMutableDictionary * totalDict = [NSMutableDictionary dictionaryWithCapacity:yearArray.count];
        for (NSString * yearKey in yearArray) {

            for (int i=0; i<modelArray.count; i++) {
                PHAsset   * modelAsset =monthFetch[i];
                PHAssetMode * mode = [PHAssetMode manager_TransformAssetToAssetMode:modelAsset];

                UtilTools * utilTools = modelArray[i];
                if ([yearKey isEqualToString:utilTools.tool_year]) {
                    if ([[totalDict allKeys]containsObject:utilTools.tool_year]) {
                        NSMutableDictionary * yearDic = [totalDict objectForKey:yearKey];
                        if ([[yearDic allKeys]containsObject:utilTools.tool_month]) {
                            NSMutableArray * tempArray = [yearDic objectForKey:utilTools.tool_month];
                            [tempArray addObject:mode];
                            [yearDic setObject:tempArray forKey:utilTools.tool_month];
                            [totalDict setObject:yearDic forKey:yearKey];

                        }
                        else{
                            NSMutableArray * monthArray = [NSMutableArray array];
                            [monthArray addObject:mode];
                            [yearDic setObject:monthArray forKey:utilTools.tool_month];
                            [totalDict setObject:yearDic forKey:yearKey];


                        }

                    }else{

                        NSMutableDictionary * yearDict = [NSMutableDictionary dictionary];
                        NSMutableArray * monthList = [NSMutableArray array];
                        [monthList addObject:mode];
                        [yearDict setObject:monthList forKey:utilTools.tool_month];
                        [totalDict setObject:yearDict forKey:utilTools.tool_year];

                    }
                }
            }
        }
        
        NSMutableArray *  blockArray = [NSMutableArray array];
        [blockArray addObject:totalDict];
        CHECK_BLOCK_EXIST(monthListBlock,blockArray);

//        NSLog(@"total = %@",totalDict);



    }

}
#pragma mark -- 获取资源时所配置的资源参数 ，要求效率最高
- (PHVideoRequestOptions *)manager_VideoRequestOptions{
    if (!_manager_VideoRequestOptions) {
        _manager_VideoRequestOptions = [[PHVideoRequestOptions alloc]init];
        _manager_VideoRequestOptions.networkAccessAllowed = self.isSupportiCloudRequest?YES:NO;
        _manager_VideoRequestOptions.version =self.isGetCurrentSource?PHVideoRequestOptionsVersionCurrent:PHVideoRequestOptionsVersionOriginal;
        _manager_VideoRequestOptions.deliveryMode = self.isSupportDeliveryMode?PHVideoRequestOptionsDeliveryModeHighQualityFormat:PHVideoRequestOptionsDeliveryModeFastFormat;

    }
    return _manager_VideoRequestOptions;
}
- (PHContentEditingInputRequestOptions *)manager_EdittingInputRequestOperations{
    if (_manager_EdittingInputRequestOperations) {
        _manager_EdittingInputRequestOperations = [[PHContentEditingInputRequestOptions alloc]init];
        _manager_EdittingInputRequestOperations.networkAccessAllowed = self.isSupportiCloudRequest?YES:NO;
        _manager_EdittingInputRequestOperations.canHandleAdjustmentData = ^BOOL(PHAdjustmentData *data){
            return YES;
        };

    }
    return _manager_EdittingInputRequestOperations;
}

#pragma mark --shareOperationManager  单利对象调用此方法
+ (instancetype)shareOperationManager{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __operationManager = [[PHOperationManager alloc]init];
    });
    return __operationManager;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    @synchronized (__operationManager) {
        return [super allocWithZone:zone];
    }
}
- (id)copyWithZone:(NSZone *)zone{
    @synchronized (__operationManager) {
        return __operationManager;

    }
}
- (id)mutableCopyWithZone:(NSZone *)zone{
    @synchronized (__operationManager) {
        return __operationManager;
    }
}
@end
