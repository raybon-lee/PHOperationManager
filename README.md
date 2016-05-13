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

###  按月进行分类查询

###  按年进行分类查询