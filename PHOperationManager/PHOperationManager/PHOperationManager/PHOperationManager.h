//
//  PHOperationManager.h
//  PHOperationManager
//
//  Created by Dinotech on 16/4/15.
//  Copyright © 2016年 Raybon. All rights reserved.
//
/*
 PHOperationManager ： 该类支持iOS8 以上版本 ，如果APP支持iOS6  ，请使用 ALAssetLibrary
 
 */

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "PHAlbumMode.h"
#import "PHAssetMode.h"
#import "UtilTools.h"
NS_ASSUME_NONNULL_BEGIN
/*!
 *  @author Raybon.Lee, 16-04-15 13:04:06
 *
 *  @brief 获取用户授权状态
 *
 *  @since <#1.0#>
 */
typedef NS_ENUM(NSInteger,RYAuthorizationStatus) {
    /*!
     *  @author Raybon.Lee, 16-04-15 13:04:06
     *
     *  用户第一次使用APP，还未进行选择授权，提示用户进行授权处理
     *
     *  @since <#1.0#>
     */
    RYAuthorizationStatus_NotDetermined,
    /*!
     *  @author Raybon.Lee, 16-04-15 13:04:07
     *
     *  @brief 用户拒绝授权，APP无法获取到图库资源内容
     *
     *  @since <#1.0#>
     */
    RYAuthorizationStatus_Denied,
    /*!
     *  @author Raybon.Lee, 16-04-15 13:04:37
     *
     *  @brief 该选项表示用户曾经授权过，但是现在授权关闭了，需要重新到设置界面开启授权模式  隐私->照片->打开即可
     *
     *  @since <#1.0#>
     */
    RYAuthorizationStatus_Restricted,
    /*!
     *  @author Raybon.Lee, 16-04-15 13:04:51
     *
     *  @brief 该选项表示用户已经授权，正常获取资源
     *
     *  @since <#1.0#>
     */
    RYAuthorizationStatus_Authorized,
};
    //检测block是否存在
#define CHECK_BLOCK_EXIST(block_name,...) \
    if (block_name) { \
        block_name(__VA_ARGS__); \
    }  \


NS_CLASS_AVAILABLE_IOS(8_0)  @interface PHOperationManager : NSObject<NSCopying,NSMutableCopying>
/*!
 *  @brief 用于处理获取相册或者图片资源时的一个操作，提供排序，搜索
 *
 *  @since <#1.0#>
 */
@property (nonatomic,strong) PHFetchOptions  *   manager_FetchOptions;

/*!
 *  @brief 获取video时所要做的一些参数
 */
@property (nonatomic,strong) PHVideoRequestOptions  * manager_VideoRequestOptions;

/*!
 *  @brief 获取编辑时的参数
 */
@property (nonatomic,strong) PHContentEditingInputRequestOptions * manager_EdittingInputRequestOperations;

/*!
 *  @brief 获取图片时的并行队列
 */
@property (nonatomic,strong) dispatch_queue_t        manager_ImageSerialQueue;


/*!
 *  @brief 是否获取当前编辑后的资源，默认状态是NO，  设置为YES，则获取最新编辑后的资源
 */
@property (nonatomic,assign) BOOL     isGetCurrentSource;


/*!
 *  @brief 是否支持联网获取iCloud  内的图片  默认是不支持
 */
@property (nonatomic,assign) BOOL     isSupportiCloudRequest;


/*!
 *  @brief 是否支持低质量的图片请求 默认是低质量 设置为NO  ,如果要请求高质量，设置为YES
 */
@property (nonatomic,assign) BOOL      isSupportDeliveryMode;


/*!
 *  @author Raybon.Lee, 16-04-15 12:04:16
 *
 *  @brief shareOperationManager  作为一个单利对象返回，该类主要提供PHKit 所管理的图库操作 e.g 查询、删除、编辑、
 *
 *  @return 返回一个 [PHOperationManager  shareOperationManager] 对象
 *
 *  @since <#1.0#>
 */
+ (__kindof instancetype)shareOperationManager;



/*!
 *  @brief 获取照片前先处理一下用户相册的授权状态，否则直接获取程序 会出现exception
 *
 *  @param authorBlock 获取用户授权状态的回调
 *
 *  @since <#1.0#>
 */
- (void)requestAuthorizationStatus:(void (^)(RYAuthorizationStatus authorStatus))authorBlock;


/*!
 *  @author Raybon.Lee, 16-04-15 13:04:06
 *
 *  @brief 该方法主要用于查询手机内的图库资源相册列表(smartAlbums 下系统提供的资源文件)名称,不指定operations
 *
 *  @param collectionBlock 回调一个collectionAlbums 的数组集合
 *
 *  @since <#1.0#>
 */
- (void)managerQueryThePHAssetCollectionsFromSmartAlbumsHandleWithCompletion:(void (^)(NSArray <PHAlbumMode  *> * collectionAlbums))collectionBlock;

/*!
 *  @brief 获取用户自己的相册，非系统创建的相册
 *
 *  @param userCollectionBlock 使用block进行回调
 *
 *  @since <#1.0#>
 */
- (void)managerRequestTopLevelUserCollectionWithCompletion:(void (^)(NSArray <PHAlbumMode *> * user_Albums))userCollectionBlock;
/*!
 *  @brief 请求用户手机下的所有资源，包含图片和视频
 *
 *  @param assetBlock 获取到资源之后用于回调的block
 *
 *  @since <#1.0#>
 */
- (void)managerRequestAllPhotosWithCompletion:(void (^)(NSArray * assetArray))assetBlock;
/*!
 *  @brief 请求单个相册下的所有资源
 *
 *  @param assetCollection 相册名字
 *  @param unitAssetBlock  相册内的资源
 */
- (void)managerRequestUnitAssetsOfAssetCollections:(PHAssetCollection *)assetCollection  allAssetsWithCompletion:(void (^)(NSArray *  assetArray))unitAssetBlock;
/*!
 *  @brief 按照月对资源进行一个划分，排序规则，每个月的资源在一起
 *
 *  @param monthListBlock 划分完毕回调当前数据
 */
- (void)managerRequestMonthAssetsListOfTotalResource:(void (^)(NSArray <NSDictionary *> * monthArrayList))monthListBlock;

@end
NS_ASSUME_NONNULL_END
