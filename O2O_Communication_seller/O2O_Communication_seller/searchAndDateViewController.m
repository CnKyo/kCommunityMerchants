//
//  searchAndDateViewController.m
//  O2O_Communication_seller
//
//  Created by 王珂 on 15/11/2.
//  Copyright © 2015年 zongyoutec.com. All rights reserved.
//

#import "searchAndDateViewController.h"
#import "wkOrderCell.h"

@interface searchAndDateViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation searchAndDateViewController
{
    UITableView *mTableView;

}
- (void)viewDidLoad {
    self.hiddenTabBar = YES;
    [super viewDidLoad];
    self.Title = self.mPageName = @"订单查询";
    self.hiddenRightBtn = YES;
    self.hiddenlll = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];


}


- (void)initView{
    
    
    mTableView = [UITableView new];
    
    self.tableView = mTableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UINib *nib = [UINib nibWithNibName:@"orderCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    self.haveHeader = YES;
    [self.tableView headerBeginRefreshing];
    
    [self.view addSubview:mTableView];
    
    
    [mTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(64);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view.bottom).offset(-50);
    }];
    
}
#pragma mark ----顶部刷新数据
- (void)headerBeganRefresh{
    
    self.page=1;
    
    [[SUser currentUser] getMyOrders:self.page status:1 date:_dateStr keywords:_searchStr block:^(SResBase *resb,SOrderPack *retobj) {
        
        [self headerEndRefresh];
        [self.tempArray removeAllObjects];
        if (resb.msuccess) {
            
            [self.tempArray addObjectsFromArray:retobj.mOrders];
            
        }
        else{
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
        if( self.tempArray.count == 0 )
        {
            [self addEmptyViewWithImg:nil];
        }
        else
        {
            [self removeEmptyView];
        }
        [self.tableView reloadData];
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tempArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 180;
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *reuseCellId = @"cell";
    
    wkOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCellId];
    if (!cell)
    {
        cell = [[wkOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.model = self.tempArray[indexPath.row];
    
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


@end
