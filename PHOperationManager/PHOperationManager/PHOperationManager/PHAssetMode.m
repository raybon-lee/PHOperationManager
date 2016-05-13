//
//  PHAssetMode.m
//  PHOperationManager
//
//  Created by Dinotech on 16/4/15.
//  Copyright © 2016年 Raybon. All rights reserved.
//

#import "PHAssetMode.h"

@implementation PHAssetMode
+ (void)entryThreadPoint:(id) __unused obj{
    @autoreleasepool {
        [[NSThread currentThread] setName:@"raybon"];
      NSRunLoop * runloop =   [NSRunLoop currentRunLoop] ;
        [runloop  addPort:[NSPort port] forMode:NSRunLoopCommonModes];
        [runloop run];
    }
}
+ (NSThread *)newThread{
    static NSThread * newThread;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        newThread = [[NSThread alloc]initWithTarget:self selector:@selector(entryThreadPoint:) object:nil];
        [newThread start];

    });
    return newThread;
}
/*!
 *  @brief 添加一个图片请求参数，设置图片的质量
 *
 *  @return <#return value description#>
 */
extern   PHImageRequestOptions  * CreateImageOperation(){
    static PHImageRequestOptions * imageOperations;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageOperations = [[PHImageRequestOptions alloc]init];
        imageOperations.networkAccessAllowed = NO;
        
        imageOperations.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        imageOperations.version   = PHImageRequestOptionsVersionCurrent;
        imageOperations.resizeMode = PHImageRequestOptionsResizeModeFast;

    });
    return imageOperations;
}
/*!
 *  @brief 创建一个图片管理对象
 *
 *  @return <#return value description#>
 */
extern PHImageManager  * CreateImageManager(){
    return [PHImageManager defaultManager];
}
static inline PHVideoRequestOptions  * CreateVideoRequestOpreations(){
    static PHVideoRequestOptions * __videoOpreaions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __videoOpreaions = [[PHVideoRequestOptions alloc]init];
        __videoOpreaions.networkAccessAllowed = NO;
        __videoOpreaions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        __videoOpreaions.version = PHImageRequestOptionsVersionCurrent;

    });
    return __videoOpreaions;
}
+ (PHAssetMode *)manager_TransformAssetToAssetMode:(PHAsset *)asset{
    dispatch_semaphore_wait(CreateSmea(), DISPATCH_TIME_FOREVER);
    NSTimeInterval  modeBeginTime = CFAbsoluteTimeGetCurrent();

    PHAssetMode * mode_asset = [[PHAssetMode alloc]init];
    mode_asset.mode_asset           = asset;
    mode_asset.mode_hidden          = asset.hidden;
    mode_asset.mode_canEdit         = [asset canPerformEditOperation:PHAssetEditOperationDelete |
        PHAssetEditOperationContent |
        PHAssetEditOperationProperties];

    mode_asset.mode_duration        = asset.duration;
    mode_asset.mode_location        = asset.location;
    mode_asset.mode_localIdentifer  = asset.localIdentifier;
    mode_asset.mode_favorite        = asset.favorite;
    mode_asset.mode_MediaType       = asset.mediaType;
    mode_asset.mode_pixsWidth       = asset.pixelWidth;
    mode_asset.mode_pixsHeight      = asset.pixelHeight;
    mode_asset.mode_createDate      = asset.creationDate;
    mode_asset.mode_modificationDate= asset.modificationDate;
        //该属性必须用在9.0 之后
    if (CHECK_IOS_VERSION_NUMBER_9_0()) {
        mode_asset.mode_sourceType      = asset.sourceType;
    }
    if (CHECK_IOS_VERSION_NUMBER_8_0()) {
        NSLog(@"## 设备当前在8.0运行 ###");
    }
    mode_asset.mode_MediaSubType    = asset.mediaSubtypes;
    mode_asset.mode_burstIdentifer  = asset.burstIdentifier;
    mode_asset.mode_representsBurst = asset.representsBurst;
    mode_asset.mode_burstSelectionType = asset.burstSelectionTypes;

    if (asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
        NSLog(@"##PHAssetMediaSubtypePhotoLive  获取到livePhoto  ## ");
        UIImage * bageLivePhoto = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
        mode_asset.mode_livePhotoImage = bageLivePhoto;
    }

    if (asset.mediaType & PHAssetMediaTypeVideo) {

        NSLog(@"##  查询得到视频资源  ##");
//        [CreateImageManager() requestPlayerItemForVideo:asset options:CreateVideoRequestOpreations() resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
//            
//        }];
//        UIImage * video_image = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
//        mode_asset.mode_livePhotoImage = video_image;

//        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
//        [CreateImageManager() requestAVAssetForVideo:asset options:CreateVideoRequestOpreations() resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
////            NSLog(@"开始查找视频");
//             AVURLAsset * urlAVAsset = (AVURLAsset *)asset;
//            mode_asset.mode_CMTime = urlAVAsset.duration;
//            mode_asset.mode_fileUrl = urlAVAsset.URL.absoluteString;
//            mode_asset.mode_fileName = urlAVAsset.URL.absoluteString.lastPathComponent;
//            
////            NSLog(@"info = %@",urlAVAsset.URL.absoluteString);
////            dispatch_semaphore_signal(sema);
//
//        }];
//        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

//         NSLog(@"我是视频查找结束");
    }
  NSTimeInterval modeEndTime = CFAbsoluteTimeGetCurrent();
    if (asset.mediaType & PHAssetMediaTypeImage) {

        dispatch_group_t group  = dispatch_group_create();
//        dispatch_group_enter(group);
//      PHCachingImageManager * manager =   [[PHCachingImageManager  alloc]init];
//       [ manager startCachingImagesForAssets:@[asset] targetSize:(CGSize){200,200} contentMode:PHImageContentModeAspectFill options:nil];
        NSTimeInterval reqtime = CFAbsoluteTimeGetCurrent();
        [CreateImageManager() requestImageForAsset:asset targetSize:(CGSize){200,200} contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            NSLog(@"### asset 图片资源请求完毕   ###");
            mode_asset.mode_assetImage = result;

        }];
        NSTimeInterval reqendTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"## requestimage time = %f ##",reqendTime-reqtime);
        

//        [CreateImageManager() requestImageDataForAsset:asset options:CreateImageOperation() resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//            if (dataUTI) {
//                NSURL * fileurl = [info objectForKey:@"PHImageFileURLKey"];
//                mode_asset.mode_fileUrl = fileurl.absoluteString;
//                mode_asset.mode_UTI = dataUTI;
//                mode_asset.mode_fileName = fileurl.lastPathComponent;
//                mode_asset.mode_assetImage = [UIImage imageWithData:imageData];
//                mode_asset.mode_ImageData = imageData;
//                
////                NSLog(@"fileurl = %@ last = %@",fileurl.absoluteString ,fileurl.lastPathComponent);
//
//            }
////            NSLog(@"我先执行");
////            NSLog(@"info = %@ uti = %@",info,dataUTI);
//
//            dispatch_group_leave(group);
//        }];
//        
//        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    }
//       NSLog(@"我是最后执行");

    NSLog(@"####  PHAssetMode exc time = %f",modeEndTime-modeBeginTime);
    dispatch_semaphore_signal(CreateSmea());
    NSLog(@"## 单资源查询完毕 ##3");
    return mode_asset;

}
- (void)runBackAsset:(PHAssetMode  *)mode_asset{
    PHContentEditingInputRequestOptions * editOperations = [[PHContentEditingInputRequestOptions alloc]init];
    editOperations.networkAccessAllowed = NO;

    editOperations.canHandleAdjustmentData =^BOOL(PHAdjustmentData * data){
        return NO;
    };
    [PHCachingImageManager defaultManager];
    [mode_asset.mode_asset requestContentEditingInputWithOptions:editOperations completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
//        NSLog(@"-----获取到图片----");
//        if (mode_asset.mode_asset.mediaType & PHAssetMediaTypeImage) {
//            BOOL  isDownLoading = ![info objectForKey:PHImageCancelledKey]
//            && ![info objectForKey:PHImageErrorKey] && ![info objectForKey:PHImageResultIsDegradedKey];
//            if (isDownLoading) {
//                mode_asset.mode_fileUrl = [contentEditingInput.fullSizeImageURL absoluteString];
//                mode_asset.mode_UTI = contentEditingInput.fullSizeImageURL.pathExtension;
//                mode_asset.mode_fileName = contentEditingInput.fullSizeImageURL.lastPathComponent;
//            }
//            if (mode_asset.mode_filePathBlock) {
//                mode_asset.mode_filePathBlock(mode_asset);
//            }
//
//
//        }
            //                dispatch_group_leave(group);

            //                dispatch_semaphore_signal(sema);

    }];



}
- (void)handleCallBackTheLocalFilePathWithAsset:(PHAsset *)assetFile withCompletionBlock:(HandleFilePathCompletion)handleBlock{
    self.mode_filePathBlock = handleBlock;

}

static inline dispatch_semaphore_t  CreateSmea(){
    static dispatch_semaphore_t sema ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sema = dispatch_semaphore_create(1);
    });
    return sema;
}
- (PHImageManager *)mode_imageManager{
    if (!_mode_imageManager) {
        _mode_imageManager = [PHImageManager defaultManager];
    }
    return _mode_imageManager;
}
//- (NSString *)description{
//    return DEBUG?[NSString stringWithFormat:@"fileurl = %@ image = %@  liveiamge = %@",self.mode_fileUrl,self.mode_assetImage,self.mode_livePhotoImage]:nil;
//    
//}
@end
