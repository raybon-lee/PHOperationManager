//
//  PHAssetMode.h
//  PHOperationManager
//
//  Created by Dinotech on 16/4/15.
//  Copyright © 2016年 Raybon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
/*!
 *  @brief 检测手机系统版本是否大于 8.0
 *
 *  @return 返回BOOL类型 ，成立返回YES
 */
static BOOL CHECK_IOS_VERSION_NUMBER_8_0(){
    if (NSFoundationVersionNumber_iOS_8_0 >=1047.25f) {
        return YES;
    }
    return NO;
}
/*!
 *  @brief 检测手机系统版本是否大于 9.0
 *
 *  @return 如果 版本 大于 9.0 则返回 YES， 否则返回NO
 */
static BOOL CHECK_IOS_VERSION_NUMBER_9_0(){

    if ([[UIDevice currentDevice].systemVersion floatValue]>=9.0) {
        return YES;
    }
    return NO;
}

typedef void (^HandleFilePathCompletion)(id assetMode);

@interface PHAssetMode : NSObject


@property (nonatomic,copy) HandleFilePathCompletion mode_filePathBlock;


/*!
 *  @brief 视频资源类型
 */
@property (nonatomic,strong) PHLivePhotoView * mode_livePhotoView;
/*!
 *  @brief 相册小视频预览图
 */
@property (nonatomic,strong) UIImage         *  mode_livePhotoImage;
/*!
 *  @brief 相册缩略图
 */
@property (nonatomic,strong) UIImage         *  mode_assetImage;
/*!
 *  @brief 图片管理器
 */
@property (nonatomic,strong) PHImageManager  *  mode_imageManager;
/*!
 *  @brief 获取到的文件的URL路径
 */
@property (nonatomic,strong) NSString      * mode_fileUrl;
/*!
 *  @brief 获取到的文件的名字
 */
@property (nonatomic,strong) NSString      * mode_fileName;
/*!
 *  @brief 所获取的文件类型
 */
@property (nonatomic,strong) NSString      * mode_UTI;

/*!
 *  @brief 资源ID
 */
@property (nonatomic,strong) NSString        *  mode_localIdentifer;

/*!
 *  @brief 模型类对原资源进行一份保留，方便后续使用
 *
 *  @since <#1.0#>
 */
@property (nonatomic,strong) PHAsset       *   mode_asset;

/*!
 *  @brief 资源文件的多媒体类型
 * PHAssetMediaTypeUnknown 未知类型
 * PHAssetMediaTypeImage  图片类型
 * PHAssetMediaTypeVideo  视频类型的
 * PHAssetMediaTypeAudio  音频类型
 *  @since <#1.0#>
 */
@property (nonatomic,assign) PHAssetMediaType    mode_MediaType;
/*!
 *  @brief 具体到资源属于相册还是视频资源，
 * PHAssetMediaSubtypeNone  无类型
 * PHAssetMediaSubtypePhotoPanorama  获取全景照片
 * PHAssetMediaSubtypePhotoHDR  获取开启HDR的照片
 * PHAssetMediaSubtypePhotoScreenshot 获取屏幕快照 iOS9.0 之后使用
 * PHAssetMediaSubtypePhotoLive  照片视频  iOS9.1  之后才能用
 * PHAssetMediaSubtypeVideoStreamed  视频流
 * PHAssetMediaSubtypeVideoHighFrameRate  高帧率的视频
 * PHAssetMediaSubtypeVideoTimelapse  延迟拍摄的视频
 *  @since <#1.0#>
 */
@property (nonatomic,assign) PHAssetMediaSubtype mode_MediaSubType;
/*!
 *  @brief 获取资源的像素大小
 *
 *  @since <#1.0#>
 */
@property (nonatomic,assign)  NSUInteger   mode_pixsWidth;
@property (nonatomic,assign)  NSUInteger   mode_pixsHeight;
/*!
 *  @brief 资源创建时间
 *
 *  @since <#1.0#>
 */
@property (nonatomic,strong)  NSDate     *  mode_createDate;
/*!
 *  @brief 资源修改的时间
 *
 *  @since <#1.0#>
 */
@property (nonatomic,strong)  NSDate     *  mode_modificationDate;
/*!
 *  @brief 资源拍摄位置
 *
 *  @since <#1.0#>
 */
@property (nonatomic,strong)  CLLocation * mode_location;
/*!
 *  @brief 资源所用的时间
 *
 *  @since <#1.0#>
 */
@property (nonatomic,assign)  NSTimeInterval  mode_duration;
/*!
 *  @brief 资源是否隐藏
 *
 *  @since <#1.0#>
 */
@property (nonatomic,assign)  BOOL            mode_hidden;
/*!
 *  @brief 是否是用户收藏的资源
 */
@property (nonatomic,assign)  BOOL            mode_favorite;
/*!
 *  @brief 资源连拍资源标识符ID
 */
@property (nonatomic,strong)  NSString    *   mode_burstIdentifer;
/*!
 *  @brief  资源连拍选择类型 ： 1. none  2. auto  3.  userAction
 * PHAssetBurstSelectionTypeNone  无选择类型
 * PHAssetBurstSelectionTypeAutoPick  自动选择
 * PHAssetBurstSelectionTypeUserPick  用户选择
 */
@property (nonatomic,assign)  PHAssetBurstSelectionType  mode_burstSelectionType;
/*!
 *  @brief 资源来源类型  iOS9.0  才能使用
 * PHAssetSourceTypeNone  无资源类型
 * PHAssetSourceTypeUserLibrary 用户资源库
 * PHAssetSourceTypeCloudShared  来自cloud 分享
 * PHAssetSourceTypeiTunesSynced  来自iTunes同步
 */
@property (nonatomic,assign)  PHAssetSourceType   mode_sourceType NS_AVAILABLE_IOS(9_0);
/*!
 *  @brief 是否是连拍照片
 */
@property (nonatomic,assign) BOOL   mode_representsBurst;
/*!
 *  @brief 是否支持编辑  编辑内容： 1. 删除 2. 内容 3. 属性
 */
@property (nonatomic,assign) BOOL   mode_canEdit;

/*!
 *  @brief 将获取到的asset资源转化到 模型类
 *
 *  @param asset 获取到的一个资源
 *
 *  @return 返回一个资源mode 对象
 */
+ (PHAssetMode *)manager_TransformAssetToAssetMode:(PHAsset *)asset;

- (void)handleCallBackTheLocalFilePathWithAsset:(PHAsset *)assetFile withCompletionBlock:(HandleFilePathCompletion)handleBlock;

@end
