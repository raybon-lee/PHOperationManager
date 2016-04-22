//
//  PHAssetMode.m
//  PHOperationManager
//
//  Created by Dinotech on 16/4/15.
//  Copyright © 2016年 Raybon. All rights reserved.
//

#import "PHAssetMode.h"

@implementation PHAssetMode

+ (PHAssetMode *)manager_TransformAssetToAssetMode:(PHAsset *)asset{

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
    mode_asset.mode_sourceType      = asset.sourceType;
    mode_asset.mode_MediaSubType    = asset.mediaSubtypes;
    mode_asset.mode_burstIdentifer  = asset.burstIdentifier;
    mode_asset.mode_representsBurst = asset.representsBurst;
    mode_asset.mode_burstSelectionType = asset.burstSelectionTypes;
    if (asset.mediaType & PHAssetMediaTypeImage) {
        PHContentEditingInputRequestOptions * editOperations = [[PHContentEditingInputRequestOptions alloc]init];
//        editOperations.networkAccessAllowed = NO;
//
//        editOperations.canHandleAdjustmentData =^BOOL(PHAdjustmentData * data){
//            return NO;
//        };

            //TODO: 问题？ 使用PHAsset  会出现阻塞UI的问题，没找到答案，下面这个请求
            //需要获取图片的URL，但是这个请求是同步形式的阻塞队列
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        dispatch_group_t group = dispatch_group_create();
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [asset requestContentEditingInputWithOptions:editOperations completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
                if (asset.mediaType & PHAssetMediaTypeImage) {
                    BOOL  isDownLoading = ![info objectForKey:PHImageCancelledKey]
                    && ![info objectForKey:PHImageErrorKey] && ![info objectForKey:PHImageResultIsDegradedKey];
                    if (isDownLoading) {
                        mode_asset.mode_fileUrl = [contentEditingInput.fullSizeImageURL absoluteString];
                        mode_asset.mode_UTI = contentEditingInput.fullSizeImageURL.pathExtension;
                        mode_asset.mode_fileName = contentEditingInput.fullSizeImageURL.lastPathComponent;
                    }
                    if (mode_asset.mode_filePathBlock) {
                        mode_asset.mode_filePathBlock(mode_asset);
                    }


                }
                    //                dispatch_group_leave(group);
                
                    //                dispatch_semaphore_signal(sema);
                
            }];
        });






//        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

//        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    }
    if (asset.mediaType & PHAssetMediaTypeVideo) {
        PHVideoRequestOptions * videoOperations = [[PHVideoRequestOptions alloc]init];
        videoOperations.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        videoOperations.networkAccessAllowed = NO;
        [mode_asset.mode_imageManager requestAVAssetForVideo:asset options:videoOperations resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            NSLog(@"=====");

        }];


    }


    if (asset.mediaType & PHAssetMediaTypeVideo) {
        UIImage * bageLivePhoto = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
        mode_asset.mode_livePhotoImage = bageLivePhoto;
        

    }else{

        [mode_asset.mode_imageManager requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//            NSLog(@"resuilt = %@",result);
            mode_asset.mode_assetImage = result;


        }];


    }
    return mode_asset;

}
- (void)handleCallBackTheLocalFilePathWithAsset:(PHAsset *)assetFile withCompletionBlock:(HandleFilePathCompletion)handleBlock{
    self.mode_filePathBlock = handleBlock;

}
- (PHImageManager *)mode_imageManager{
    if (!_mode_imageManager) {
        _mode_imageManager = [PHImageManager defaultManager];
    }
    return _mode_imageManager;
}
- (NSString *)description{
    return [NSString stringWithFormat:@"fileurl = %@ image = %@",self.mode_fileUrl,self.mode_assetImage];
    
}
@end
