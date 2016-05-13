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
static const char * manager_queue_identifer = "phoperation.queue";
static const char * manager_concurrect_queue = "ph.concurrentqueue";
 static  NSString * const kLocalFileDirectiory = @"DCIM_Photos";
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
#pragma mark -- 批量获取相册相册资源， 按照请求数量分批请求
    //设置最大量获取数据
- (void)managerRequestAssetWithFetchLimitCount:(NSInteger)limitCount handleCompletion:(void (^)(NSArray * _Nonnull))limitBlock{

        //开始设置获取图片参数
    self.manager_FetchLimitOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        //设置单次获取的最大资源数量，限定为200 
    self.manager_FetchLimitOptions.fetchLimit = limitCount>=200?self.manager_FetchSourceLimit:limitCount;

    
    
}

#pragma mark --按照月返回每个月的资源集合
- (void)managerRequestMonthAssetsListOfTotalResource:(void (^)(NSArray<NSDictionary *> * _Nonnull))monthListBlock{

    self.manager_FetchOptions =[[PHFetchOptions alloc]init];
    self.manager_FetchOptions.sortDescriptors= @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult * monthFetch = [PHAsset fetchAssetsWithOptions:self.manager_FetchOptions?self.manager_FetchOptions:nil];
//    __weak __typeof(self) weakself = self;
    [self resetFetchResult:monthFetch withCompletion:monthListBlock];


}
- (void)resetFetchResult:(PHFetchResult *)monthFetch withCompletion:(void (^)(NSArray <NSDictionary *>* list))monthListBlock{


    NSMutableArray * yearArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * monthArray = [NSMutableArray array];
    NSMutableArray * modelArray = [NSMutableArray array];
    if (monthFetch) {

//        __block UtilTools * tools ;
        NSTimeInterval  monthTime = CFAbsoluteTimeGetCurrent();
        [monthFetch enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            PHAsset * asset = (PHAsset *)obj;
            UtilTools *  tools = [UtilTools getCurrentWeekOfYearByDate:asset.creationDate];
            [modelArray addObject:tools];

            if (![yearArray containsObject:tools.tool_year]) {

                [yearArray addObject:tools.tool_year];
            }
            if (![monthArray containsObject:tools.tool_month]) {
                [monthArray addObject:tools.tool_month];
                    //                NSLog(@"month = %@",monthArray);
            }

        }];
               NSTimeInterval  montend = CFAbsoluteTimeGetCurrent();
        NSLog(@"### time = %f ##",montend-monthTime);



        NSTimeInterval seekBeginTime = CFAbsoluteTimeGetCurrent();
        NSMutableDictionary * totalDict = [NSMutableDictionary dictionaryWithCapacity:yearArray.count];
        NSTimeInterval beginTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"#### 开始按照月份进行分类归档 ####");
        dispatch_group_t   queryGroup = dispatch_group_create();

        for (NSString * yearKey in yearArray) {

            for (int i=0; i<modelArray.count; i++) {
//                dispatch_group_enter(queryGroup);
//                dispatch_sync(self.manager_ImageConcurrentQueue, ^{
                    NSTimeInterval assBegin = CFAbsoluteTimeGetCurrent();

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
                    NSTimeInterval assEnd = CFAbsoluteTimeGetCurrent();
                    NSLog(@"## 第%d个 资源排序占用时间  %f ####",i,assEnd-assBegin);
//                    dispatch_group_leave(queryGroup);
//                });

            }
            NSLog(@"#### 正在执行 %@  年的资源 ####",yearKey);
        }
        dispatch_group_wait(queryGroup, DISPATCH_TIME_FOREVER);
        NSLog(@"## 数据组合完毕，开始执行下一步 ##");
        NSTimeInterval seekEndTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"###  seek time = %f ###",seekEndTime-seekBeginTime);
        NSMutableArray *  blockArray = [NSMutableArray array];
        [blockArray addObject:totalDict];
        NSTimeInterval  endTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"#### begiinTime- endtime = %f  ###",endTime-beginTime);



//    NSLog(@"total = %@",blockArray);
            //2.  开始遍历请求图片的真实地址  按照月份进行分类
            // e.g  2015-7  2015 -10
        NSMutableArray * sortArray = [NSMutableArray array];

        for (NSDictionary * yearDictTotal in blockArray) {

            NSArray * yearSortArray = [[yearDictTotal allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj1 compare:obj2 options:NSNumericSearch];
            }];
            NSLog(@"##  yearSortArray = %@ ##",yearSortArray);
            for (NSString * yearKeys in yearSortArray) {
                NSLog(@"###########   yearkey = %@",yearKeys);
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




#pragma mark --处理系统的asset 资源， 将系统请求到的图片写入到本地
- (void)managerSavePhotosToLocalPathWithDataItems:(id)items handleCompletion:(void (^)(BOOL, NSArray<NSString *> * _Nonnull, NSString * _Nonnull))handleBlock{

    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.manager_ImageSerialQueue, ^{


         PHAssetMode * assetMode = (PHAssetMode *)items;
        __block  NSString * fileUrl  = nil;
        __block  NSString * fileName = nil;
        __block  NSData   * fileData = nil;
        __block  NSString * fileUTI  = nil;
        UtilTools * utils = [UtilTools getCurrentWeekOfYearByDate:assetMode.mode_createDate];
        
        if (assetMode.mode_MediaType & PHAssetMediaTypeImage) {

//            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            [[PHImageManager defaultManager] requestImageDataForAsset:assetMode.mode_asset options:CreateImageOperations() resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {

                    //开始解析图片
                 NSLog(@"##############图片请求完毕 1.  ###################");
                fileUrl  = [info objectForKey:@"PHImageFileURLKey"];
                fileData = imageData;
                fileName = fileUrl.lastPathComponent;
                fileUTI  = dataUTI;
                NSString * fileDate =[NSString stringWithFormat:@"%@_%@",utils.tool_year,utils.tool_month];
                NSLog(@"local filePath = %@  filename = %@",[weakSelf getLocalTempFilePath],fileName);
                [weakSelf createImageSaveToLocalPathWithImage:fileData imageName:fileName fileDate:fileDate withCompletion:handleBlock];
//                dispatch_semaphore_signal(sema);

            }];
//            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

            NSLog(@"#############图片解析完毕  2.  #########");
//            UIImage * fileImage = [UIImage imageWithData:fileData];


        }
    });



}
/*!
 *  @brief 采用单线程访问资源，保证每一张图片都是正常创建
 *
 *  @param localImage    需要下载的图片数据
 *  @param fileName      需要创建的图片名字
 *  @param date          图片所在的日期
 *  @param completeBlock 回调处理
 */
- (void)createImageSaveToLocalPathWithImage:(NSData *)localImage  imageName:(NSString *)fileName  fileDate:(NSString *)date withCompletion:(void (^)(BOOL success ,NSArray<NSString *> *,NSString *))completeBlock{

    dispatch_semaphore_wait(CreateSmea(), DISPATCH_TIME_FOREVER);
    NSLog(@"##########       开始创建文件    ########");
    NSFileManager * manager_FileManager = CreateFileManager();
    NSString * fileLocalUrl = [[self getLocalTempFilePath] stringByAppendingPathComponent:kLocalFileDirectiory];
  BOOL  authSuccess =   [manager_FileManager setAttributes:@{NSFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication} ofItemAtPath:fileLocalUrl error:nil];
    if (authSuccess) {
        NSLog(@"授权成功");
    }
    BOOL  isDirectory;
    BOOL isdirExist =  [manager_FileManager fileExistsAtPath:fileLocalUrl isDirectory:&isDirectory];

    NSString * filePath=nil;
    BOOL isSuccess =NO;
    unsigned long long  __fileSize = 0;
    if (!(isdirExist && isDirectory)) {

        NSError * error ;
        BOOL  createDir = [manager_FileManager createDirectoryAtPath:fileLocalUrl withIntermediateDirectories:YES attributes:@{NSFileOwnerAccountName:[UIDevice currentDevice].name} error:&error];
        if (createDir) {
             NSLog(@"##### dir create-success = %d  ####",isDirectory);
            filePath = [fileLocalUrl stringByAppendingPathComponent:fileName];
            if (![manager_FileManager fileExistsAtPath:filePath]) {
                BOOL createFile =   [manager_FileManager createFileAtPath:filePath contents:localImage attributes:@{NSFileProtectionKey:NSFileProtectionCompleteUntilFirstUserAuthentication}];


                if (createFile) {
                     isSuccess = createFile;
                    NSLog(@"####  once file writeLocal success  #####");
                    __fileSize = [[manager_FileManager attributesOfItemAtPath:filePath error:nil] fileSize];

                }else{
                    NSLog(@"###### 文件写入失败 #####");
                    isSuccess = NO;
                }
            }else{
                NSLog(@"####  once   file had already exist   #####");
                isSuccess = YES;
                 __fileSize = [[manager_FileManager attributesOfItemAtPath:filePath error:nil] fileSize];
            }

        }else{
            isSuccess = NO;
            NSLog(@"#####  文件夹写入失败  fail = %@ ###",[error localizedFailureReason]);

        }

    }else{
        filePath = [fileLocalUrl stringByAppendingPathComponent:fileName];
        if (![manager_FileManager fileExistsAtPath:filePath]) {
            BOOL createFile =   [manager_FileManager createFileAtPath:filePath contents:localImage attributes:@{NSFileProtectionKey:NSFileProtectionCompleteUntilFirstUserAuthentication}];

            if (createFile) {
                isSuccess = createFile;
                NSLog(@"#### two 照片 写入成功  #####");
                 __fileSize = [[manager_FileManager attributesOfItemAtPath:filePath error:nil] fileSize];
            }else{
                isSuccess = NO;
                NSLog(@"## 文件写入失败 ###");
            }
        }else{
            NSLog(@"#####   two ==文件已经存在   #####");
             __fileSize = [[manager_FileManager attributesOfItemAtPath:filePath error:nil] fileSize];
            isSuccess = YES;
        }

        

    }
    NSLog(@"##########    单个文件写入结束         ################");
    NSLog(@"file_size = %@",@(__fileSize));
    dispatch_semaphore_signal(CreateSmea());
    CHECK_BLOCK_EXIST(completeBlock,isSuccess,@[filePath,date,[NSString stringWithFormat:@"%llu",__fileSize]],fileName);

//    NSLog(@"filelocalurl = %@",fileLocalUrl);



}

#pragma mark -- 查询本地保存下来的文件路径
- (void)managerQueryLocalFileSubPathsWithTmpPathWithCompleteHanle:(void (^)(NSArray<NSString *> * _Nonnull, NSArray<NSString *> * _Nonnull))completeBlock{

        //1.  查询本地文件
    dispatch_semaphore_wait(CreateSmea(), DISPATCH_TIME_FOREVER);
    NSFileManager * manager_FileManager = CreateFileManager();
    NSString * fileLocalUrl = [[self getLocalTempFilePath] stringByAppendingPathComponent:kLocalFileDirectiory];
    BOOL  authSuccess =   [manager_FileManager setAttributes:@{NSFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication} ofItemAtPath:fileLocalUrl error:nil];
    if (authSuccess) {
        NSLog(@"######    文件操作   授权成功  #########");
    }
    BOOL  isDir;
    NSArray * localArrayPath=nil;
    NSArray * fileNameArray = nil;
    NSMutableArray * fileArray = [NSMutableArray arrayWithCapacity:0];
        //2.  检测是否存在本地文件
    if ([manager_FileManager fileExistsAtPath:fileLocalUrl isDirectory:&isDir]) {

        NSLog(@"####   存在本地文件夹 %@  #####",kLocalFileDirectiory);
        NSError * error=nil;
        NSArray * filePathArr =  [manager_FileManager subpathsOfDirectoryAtPath:fileLocalUrl error:&error];
        if (!error) {
            NSLog(@"####  获取本地路径没有错误 ####");
            if (filePathArr.count>0) {
               [filePathArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                   [fileArray addObject:[fileLocalUrl stringByAppendingPathComponent:(NSString *)obj]];
               }];
                fileNameArray = filePathArr;
                localArrayPath = fileArray;
//                NSLog(@"filepath = %@",fileArray);
            }
        }

    }else{

        NSLog(@"####   无本地文件夹 %@  ####",kLocalFileDirectiory);
        localArrayPath =nil;

    }
    dispatch_semaphore_signal(CreateSmea());
    NSLog(@"####  查询文件操作结束  ####");
     CHECK_BLOCK_EXIST(completeBlock,localArrayPath,fileNameArray);


}
    //创建一个信号量
static inline  dispatch_semaphore_t  CreateSmea(){

    static dispatch_semaphore_t sema = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sema = dispatch_semaphore_create(1);
    });
    return sema;
}
/*!
 *  @brief 查找手机的缓存文件夹位置
 *
 *  @return 返回一个路径
 */
- (NSString *)getLocalTempFilePath{

    NSString * tmp = NSTemporaryDirectory();
     NSString *paths =NSHomeDirectory();

    NSString  * tmp2Pah = [paths stringByAppendingPathComponent:@"/tmp"];
    NSLog(@"%@  == %@",tmp2Pah,tmp);



    return tmp2Pah;
}

/*!
 *  @brief 创建一个文件管理对象
 *
 *  @return <#return value description#>
 */
static inline  NSFileManager  *  CreateFileManager(){
    static NSFileManager  * __fileManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __fileManager  = [NSFileManager defaultManager];

    });
    return __fileManager;
}


static inline  dispatch_group_t  CreateNotifyGroup(){
   static  dispatch_group_t  group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        group = dispatch_group_create();
    });
    return group;

}
static inline PHImageRequestOptions  * CreateImageOperations(){
    static PHImageRequestOptions * __operation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __operation = [[PHImageRequestOptions alloc]init];
        __operation.networkAccessAllowed = NO;
        __operation.version = PHImageRequestOptionsVersionOriginal;
        __operation.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        __operation.resizeMode = PHImageRequestOptionsResizeModeExact;
//        __operation.synchronous = YES;
//        __operation.normalizedCropRect = (CGRect){0,0,PHImageManagerMaximumSize};


    });
    return __operation;
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
        _manager_ImageSerialQueue = dispatch_queue_create(manager_queue_identifer, DISPATCH_QUEUE_SERIAL);
    }
    return _manager_ImageSerialQueue;
}
- (dispatch_queue_t)manager_ImageConcurrentQueue{
    if (!_manager_ImageConcurrentQueue) {
        _manager_ImageConcurrentQueue = dispatch_queue_create(manager_concurrect_queue, DISPATCH_QUEUE_SERIAL);
    }
    return _manager_ImageConcurrentQueue;
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
- (PHFetchOptions *)manager_FetchOptions{
    if (!_manager_FetchOptions) {
        _manager_FetchOptions = [[PHFetchOptions alloc]init];
    }
    return _manager_FetchOptions;
}
- (PHFetchOptions *)manager_FetchLimitOptions{
    if (!_manager_FetchLimitOptions) {
        _manager_FetchLimitOptions  = [[PHFetchOptions alloc]init];
    }
    return _manager_FetchLimitOptions;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
            //初始化默认操作数量
        self.manager_FetchSourceLimit = 200;

    }
    return self;
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
