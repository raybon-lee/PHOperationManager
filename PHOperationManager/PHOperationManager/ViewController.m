//
//  ViewController.m
//  PHOperationManager
//
//  Created by Dinotech on 16/4/15.
//  Copyright © 2016年 Raybon. All rights reserved.
//

#import "ViewController.h"
#import "PHOperationManager.h"
#import "PHAssetMode.h"
#import "UtilTools.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView  * tableView;

@property (nonatomic,strong) NSMutableArray    *  resultArray;
@property (nonatomic,strong) NSArray  * monthList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.resultArray =[NSMutableArray array];
    
    self.tableView  = ({
        UITableView * table = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellid"];
        table.delegate = self;
        table.dataSource = self;
        table.rowHeight = 100;

        table;

    });
    [self.view addSubview:self.tableView];

        //用户授权请求，检测用户是否已授权
    [[PHOperationManager shareOperationManager] requestAuthorizationStatus:^(RYAuthorizationStatus authorStatus) {
        if (RYAuthorizationStatus_Authorized ==authorStatus) {
            NSLog(@"auth 用户已授权");
        }


    }];
    [[PHOperationManager shareOperationManager] managerQueryThePHAssetCollectionsFromSmartAlbumsHandleWithCompletion:^(NSArray<PHAlbumMode  *> * _Nonnull collectionAlbums) {
        [collectionAlbums enumerateObjectsUsingBlock:^(PHAlbumMode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             NSLog(@" %@",obj.album_name);
        }];
        [self.resultArray addObjectsFromArray:collectionAlbums];
        [self.tableView reloadData];


        
    }];
    [[PHOperationManager shareOperationManager] managerRequestTopLevelUserCollectionWithCompletion:^(NSArray<PHAlbumMode *> * _Nonnull user_Albums) {
        [user_Albums enumerateObjectsUsingBlock:^(PHAlbumMode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@" %@",obj.album_name);
        }];

        NSLog(@"result = %d",self.resultArray.count);
        [self.resultArray addObjectsFromArray:user_Albums];
        [self.tableView reloadData];


    }];
    [[PHOperationManager shareOperationManager]managerRequestAllPhotosWithCompletion:^(NSArray * _Nonnull assetArray) {
//        self.resultArray = assetArray;
//        [self.tableView reloadData];

//        NSLog(@"allphotos = %@",assetArray);

    }];
    NSString  * tool = [UtilTools returnTheFirstDateAndLastDateByDate:[NSDate date]];
    NSLog(@"tool = %@",tool);
    [[PHOperationManager shareOperationManager] managerRequestMonthAssetsListOfTotalResource:^(NSArray<NSDictionary *> * _Nonnull monthArrayList) {

        [self querySortedPhotoAssetsWithArray:monthArrayList];
    }];


}
- (void)querySortedPhotoAssetsWithArray:(NSArray *)monthArrayList{
    self.monthList = monthArrayList;
    NSMutableArray * keysArray = [NSMutableArray array];

    NSMutableArray * lastModelArray = [NSMutableArray array];
    for (NSDictionary * monthDic in monthArrayList) {

        for (NSString * allkey in [monthDic allKeys]) {

            NSDictionary   * dict = monthDic[allkey];
            NSArray * arr = [[dict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {

                return [obj2 compare:obj1 options:NSNumericSearch]==NSOrderedAscending;
            }];

            for (NSString   * subdicKey  in arr) {
//                [keysArray addObject:[NSString stringWithFormat:@"%@-%@",allkey,subdicKey]];
                 NSMutableDictionary * allDict  =[NSMutableDictionary dictionary];
                [allDict setObject:[dict objectForKey:subdicKey] forKey:[NSString stringWithFormat:@"%@-%@",allkey,subdicKey]];
                [keysArray addObject:allDict];
//                NSLog(@"allkeys subdic  =%@ ",keysArray);
                NSLog(@"values = %@",subdicKey);

            }


        }
    }
    NSLog(@"keysarray = %@",keysArray);


}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.resultArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellid" forIndexPath:indexPath];
    PHAlbumMode * mode = self.resultArray[indexPath.row];
//    cell.imageView.image = mode.album_name;
    cell.textLabel.text = mode.album_name;

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PHAlbumMode * modeindex = self.resultArray[indexPath.row];
    [[PHOperationManager shareOperationManager]managerRequestUnitAssetsOfAssetCollections:modeindex.mode_Collection allAssetsWithCompletion:^(NSArray * _Nonnull assetArray) {
        NSLog(@"assetcount = %d",assetArray.count);
        
    }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
