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
static const char * manager_queue_identifer = "phoperationmanager.queue";

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
                PHAssetMode * mode = [PHAssetMode manager_TransformAssetToAssetMode:asset];
                [assetModeArray addObject:mode];


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
    dispatch_async(self.manager_ImageSerialQueue, ^{
        [self resetFetchResult:monthFetch withCompletion:monthListBlock];
    });


}
- (void)resetFetchResult:(PHFetchResult *)monthFetch withCompletion:(void (^)(NSArray <NSDictionary *>* list))monthListBlock{


    NSMutableArray * yearArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * monthArray = [NSMutableArray array];
    NSMutableArray * modelArray = [NSMutableArray array];
    if (monthFetch) {

        __block UtilTools * tools ;
        [monthFetch enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            PHAsset * asset = (PHAsset *)obj;
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
//                NSLog(@"utistoolsmonth = %@",utilTools.tool_month);

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



//    NSLog(@"total = %@",blockArray);
            //2.  开始遍历请求图片的真实地址  按照月份进行分类
            // e.g  2015-7  2015 -10
        NSMutableArray * sortArray = [NSMutableArray array];

        for (NSDictionary * yearDictTotal in blockArray) {

            for (NSString * yearKeys in [yearDictTotal allKeys]) {
//                NSLog(@"###########   yearkey = %@",yearKeys);
                NSDictionary   * yearSubDict = yearDictTotal[yearKeys];

               NSArray * monthCaterArr = [[yearSubDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                   return [obj1 compare:obj2 options:NSNumericSearch];
               }];
                for (NSString * monthKeys in monthCaterArr) {
//                    NSLog(@"##########  monthkeys = %@",monthKeys);
                    NSDictionary  * year_month_dict = @{[NSString stringWithFormat:@"%@-%@",yearKeys,monthKeys]:yearSubDict[monthKeys]};
//                    NSLog(@"year_month = %@",year_month_dict);

                    [sortArray addObject:year_month_dict];

                }
            }
        }
         CHECK_BLOCK_EXIST(monthListBlock,sortArray);


    }

}

static inline  dispatch_group_t  CreateNotifyGroup(){
   static  dispatch_group_t  group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        group = dispatch_group_create();
    });
    return group;

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

- (dispatch_queue_t)manager_ImageSerialQueue{
    if (!_manager_ImageSerialQueue) {
        _manager_ImageSerialQueue = dispatch_queue_create(manager_queue_identifer, DISPATCH_QUEUE_CONCURRENT);
    }
    return _manager_ImageSerialQueue;
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
