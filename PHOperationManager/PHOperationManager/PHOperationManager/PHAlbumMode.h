//
//  PHAlbumMode.h
//  PHOperationManager
//
//  Created by Dinotech on 16/4/15.
//  Copyright © 2016年 Raybon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
typedef NS_ENUM(NSInteger,RYAlbumType) {
    /*!
     *  @brief 获取系统智能相册下的所有资源
     *
     *  @since <#1.0#>
     */
    RYAlbumType_SmartAlbumCollection,
    /*!
     *  @brief 获取用户自己的相册资源
     *
     *  @since <#1.0#>
     */
    RYAlbumType_TopUserLevelCollection,
    /*!
     *  @brief 获取图库下的所有资源
     *
     *  @since <#1.0#>
     */
    RYAlbumType_FetchAllResources,

};
@interface PHAlbumMode : NSObject
/*!
 *  @author Raybon.Lee, 16-04-15 14:04:24
 *
 *  @brief 相册名字
 *
 *  @since <#1.0#>
 */
@property (nonatomic, strong) NSString * album_name;
/*!
 *  @brief 对相册资源保存一份，方便后面的获取
 */
@property (nonatomic, strong) PHAssetCollection * mode_Collection;
/*!
 *  @brief  获取单个相册下的图片资源， 查询结果是一个 PHFetchResult  
 */
@property (nonatomic, strong) PHFetchResult * mode_AssetsOfCollections;

/*!
 *  @brief 当前相册是否支持编辑，编辑操作详情可以查看 ：PHCollectionEditOperation  枚举类型
 *
 *  @since <#1.0#>
 */
@property (nonatomic, assign) BOOL       isCanEdit;
/*!
 *  @brief 相册开始时间
 *
 *  @since <#1.0#>
 */
@property (nonatomic, strong) NSDate    * startDate;
/*!
 *  @brief 相册结束时间
 *
 *  @since <#1.0#>
 */
@property (nonatomic, strong) NSDate    * endDate;
/*!
 *  @brief 获取相册创建的地理位置，有可能为nil,如果 手机开启了 定位，才会有数据
 *
 *  @since <#1.0#>
 */
@property (nonatomic, strong) CLLocation * album_location;
/*!
 *  @brief 获取当前相册下的所有相册的地理位置名字
 *
 *  @since <#1.0#>
 */
@property (nonatomic, strong) NSArray <NSString *> *localLocationAlbumsName;


/*!
 *  @brief 将 PHCollection 智能相册转化成  相册模型
 *
 *  @param collectionList 相册类，包含相册信息
 *
 *  @return 返回一个相册类对象
 *
 *  @since <#1.0#>
 */
+ (PHAlbumMode *)transformToAlbumModeFromCollection:(PHCollection *)collectionList  album_Type:(RYAlbumType )type;
@end
