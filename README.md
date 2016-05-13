# PHOperationManager


==========

### 使用方法

    1. 导入 `#import  PHOperationManager.h` 头文件

    采用单利对象模式请求系统资源

###  基本使用方法介绍

   
1. 获取用户权限
    
   
```
    //用户授权请求，检测用户是否已授权

    [[PHOperationManager shareOperationManager] requestAuthorizationStatus:^(RYAuthorizationStatus authorStatus) {
    if (RYAuthorizationStatus_Authorized ==authorStatus) {
    NSLog(@"auth 用户已授权");

    }

    }];

```
  
=================

2. 查询相册列表


```
    //查询相册列表
    [[PHOperationManager shareOperationManager] managerQueryThePHAssetCollectionsFromSmartAlbumsHandleWithCompletion:^(NSArray<PHAlbumMode  *> * _Nonnull collectionAlbums) {
    [collectionAlbums enumerateObjectsUsingBlock:^(PHAlbumMode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    NSLog(@" %@",obj.album_name);
    }];
    [self.resultArray addObjectsFromArray:collectionAlbums];
    [self.tableView reloadData];

    }];
    
```
####  保存系统资源到APP沙盒内

```
/*!
*  @brief 主要处理单个的资源文件 ，用于获取文件的的真实地址，保存到本地tmp 目录内临时缓存目录
*        图片的写入采用的是异步安全模式，每次保证单个文件的写入，资源的获取是异步并发队列
*  @param items       单个的assetMode  的资源 传入 PHAssetMode
*  @param handleBlock 用于处理完毕的回调
*/
- (void)managerSavePhotosToLocalPathWithDataItems:(id)items  handleCompletion:(void (^)(BOOL isSuccess,NSArray <NSString * >* localPath ,NSString * fileName))handleBlock;
/*!
*  @brief API 用于查询本地沙盒中的tmp  文件夹 内的路径 返回一个数组 此地址是可以供开发者上传到服务器
*  注： tmp 文件夹中的资源，会在设备重启之后就会移除，所以不必担心资源的占用问题
*  @param completeBlock 用于查询完毕的回调处理
*/
- (void)managerQueryLocalFileSubPathsWithTmpPathWithCompleteHanle:(void (^)(NSArray <NSString *>* localPath,NSArray <NSString *> * fileNameArray))completeBlock;

```

###  按月进行分类查询

###  按年进行分类查询