//
//  orderDetail.m
//  O2O_Communication_seller
//
//  Created by zzl on 15/11/2.
//  Copyright © 2015年 zongyoutec.com. All rights reserved.
//

#import "orderDetail.h"
#import "UILabel+myLabel.h"
#import "ordergoodscell.h"
#import <MapKit/MapKit.h>
#import "ReplyView.h"
#import "selectPeopleVC.h"

@interface orderDetail ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation orderDetail
{
    NSMutableArray* _allgoodsinfo;
}

- (void)viewDidLoad {
    self.hiddenTabBar = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.Title = self.mPageName = @"订单详情";
 
    
    CGRect ff = self.mwarper.frame;
    ff.size.height = DEVICE_Height - 64 - 68;
    self.mwarper.frame = ff;
    
    [self.monewaper viewWithTag:1].layer.cornerRadius = 3;
    [self.monewaper viewWithTag:1].layer.borderColor = [UIColor whiteColor].CGColor;
    [self.monewaper viewWithTag:1].layer.borderWidth = 1;
    
    
    _allgoodsinfo = NSMutableArray.new;
    
    UINib * nib = [UINib nibWithNibName:@"ordergoodscell" bundle:nil];
    [self.mgoodtable registerNib:nib  forCellReuseIdentifier:@"cell"];

    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeClear];
    [self.mtagOrder getDetail:^(SResBase *resb) {
        if( resb.msuccess )
        {
            [SVProgressHUD dismiss];
            [self updatePage];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
            [self performSelector:@selector(leftBtnTouched:) withObject:nil afterDelay:0.75f];
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateOrderSendInfo
{//配送信息
    self.msendwarper.layer.cornerRadius = 2;
    self.msendwarper.layer.borderWidth = 1;
    self.msendwarper.layer.borderColor = [UIColor colorWithRed:225/255.0f green:224/255.0f blue:223/255.0f alpha:1].CGColor;
    
    NSString* str = [NSString stringWithFormat:@"%@ %@",self.mtagOrder.mName,self.mtagOrder.mMobile];
    NSMutableAttributedString* attrstr = [[NSMutableAttributedString alloc]initWithString:str];
    [attrstr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:225/255.0f green:224/255.0f blue:223/255.0f alpha:1] range:[str rangeOfString:self.mtagOrder.mMobile]];
    self.mnametel.attributedText = attrstr;
    
    self.mdist.text = self.mtagOrder.mDistStr;
    self.maddr.text = self.mtagOrder.mAddress;
    [self.maddr autoResizeHeightForContent:CGFLOAT_MAX];
    [Util autoExtendH:self.maddr.superview blow:self.maddr dif:10.0f];
    
    self.mtagOrder.mBuyerFinishTime = @"2015-12 22:22:00";
    
    if( self.mtagOrder.mBuyerFinishTime.length )
    {
        self.msendtime.hidden = NO;
        if( self.mtagOrder.mOrderType == 1 )
        {
            self.msendtime.text = [NSString stringWithFormat:@"送达时间:%@",self.mtagOrder.mBuyerFinishTime];
        }
        else
        {
            self.msendtime.text = [NSString stringWithFormat:@"完成时间:%@",self.mtagOrder.mBuyerFinishTime];
        }
        [Util relPosUI:self.maddrwaper dif:15 tag:self.msendtime tagatdic:E_dic_b];
        [Util autoExtendH:self.msendwarper blow:self.msendtime dif:15];
    }
    else
    {
        self.msendtime.hidden = YES;
        [Util autoExtendH:self.msendwarper blow:self.maddrwaper dif:0];
    }
    
}
-(void)updateOrderGoodInfo
{
    [Util relPosUI:self.msendwarper dif:8 tag:self.mgoodsinfowaper tagatdic:E_dic_b];
    
    self.mgoodtable.layer.cornerRadius = 2;
    self.mgoodtable.layer.borderWidth = 1;
    self.mgoodtable.layer.borderColor = [UIColor colorWithRed:225/255.0f green:224/255.0f blue:223/255.0f alpha:1].CGColor;
    
    //购买商品详细信息
    [_allgoodsinfo removeAllObjects];
    int     k = 0;
    float   pp = 0.0f;
    for( SOrderGoods*one in self.mtagOrder.mOrderGoods )
    {
        NSString* n = one.mGoodsName;
        NSString* c = [NSString stringWithFormat:@"X%d",one.mNum];
        NSString* p = [NSString stringWithFormat:@"￥%.2f",one.mPrice*one.mNum];
        NSMutableArray* tttt  = NSMutableArray.new;
        [tttt addObject:n];
        [tttt addObject:c];
        [tttt addObject:p];
        [_allgoodsinfo addObject:tttt];
        k   += one.mNum;
        pp  += (one.mPrice*one.mNum);
    }
    [_allgoodsinfo addObject:@[@"配送费",@"",[NSString stringWithFormat:@"￥%.2f",self.mtagOrder.mFreight] ]];
    [_allgoodsinfo addObject:@[@"合 计",[NSString stringWithFormat:@"X%d",k],[NSString stringWithFormat:@"￥%.2f",self.mtagOrder.mTotalFee] ]];
    
    CGFloat h = _allgoodsinfo.count*44.0f;
    CGRect f = self.mgoodtable.frame;
    f.size.height = h;
    self.mgoodtable.frame = f;
    
    self.mgoodtable.delegate = self;
    self.mgoodtable.dataSource = self;
    [self.mgoodtable reloadData];
    
    [Util autoExtendH:self.mgoodtable.superview blow:self.mgoodtable dif:0];
    
}
-(void)updateOrderInfo
{
    [Util relPosUI:self.mgoodsinfowaper dif:8 tag:self.morderinfowaper tagatdic:E_dic_b];
    
    self.mordersubwaper.layer.cornerRadius =2;
    self.mordersubwaper.layer.borderWidth = 1;
    self.mordersubwaper.layer.borderColor = [UIColor colorWithRed:225/255.0f green:224/255.0f blue:223/255.0f alpha:1].CGColor;
    
    self.mpaytype.text = [NSString stringWithFormat:@"支付方式:%@",self.mtagOrder.mPayType];
    self.nordersn.text = [NSString stringWithFormat:@"订单编号:%@",self.mtagOrder.mSn];
    self.msellername.text  = [NSString stringWithFormat:@"店铺:%@",self.mtagOrder.mShopName];
    self.mcreatetime.text = [NSString stringWithFormat:@"顾客下单时间:%@",self.mtagOrder.mCreateTime];
    self.mapptime.text = [NSString stringWithFormat:@"预约到达时间:%@",self.mtagOrder.mAppTime];
    
    if( self.mtagOrder.mBuyRemark.length )
    {
        self.mremark.hidden = NO;
        self.mremark.text = [NSString stringWithFormat:@"备注:%@",self.mtagOrder.mBuyRemark];
        [self.mremark autoResizeHeightForContent:CGFLOAT_MAX];
        [Util relPosUI:self.mremark dif:10 tag:self.msenderwaper tagatdic:E_dic_b];
    }
    else
    {
        self.mremark.hidden = YES;
        [Util relPosUI:self.mapptime dif:10 tag:self.msenderwaper tagatdic:E_dic_b];
    }
    
    NSString* ssa = @"";
    if( self.mtagOrder.mStaff )
    {
        if( self.mtagOrder.mOrderType == 1 )
            ssa = [NSString stringWithFormat:@"配送员:%@",self.mtagOrder.mStaff.mName];
        else
            ssa = [NSString stringWithFormat:@"服务人员:%@",self.mtagOrder.mStaff.mName];
        self.msendername.text = ssa;
        self.msendertel.text = self.mtagOrder.mStaff.mMobile;
        self.mtelicon.image = [UIImage imageNamed:@"redtel"];
    }
    else
    {
        if( self.mtagOrder.mOrderType == 1 )
            ssa = @"请选择配送员";
        else
            ssa = @"请选择服务人员";
        self.msendername.text = ssa;
        self.mtelicon.image = [UIImage imageNamed:@"dp_youjiantou"];
    }
    
    [Util autoExtendH:self.msenderwaper.superview blow:self.msenderwaper dif:7];
}
-(void)updateOrderOpInfo
{
    
    NSMutableArray* tttName = NSMutableArray.new;
    SEL tttSEL[10];
    int selindex = 0;
    
    [tttName addObject:@"导航"];
    tttSEL[selindex] = @selector(callnav:);
    selindex++;
    
    
    if( self.mtagOrder.mIsCanCancel )
    {
        if( [[SUser currentUser] isSeller] )
        {
            [tttName addObject:@"取消订单"];
            tttSEL[selindex] = @selector(callcancle:);
            selindex++;
        }
    }
    if( self.mtagOrder.mIsCanAccept )
    {
        if( [[SUser currentUser] isSeller] )
        {
            [tttName addObject:@"确认订单"];
            tttSEL[selindex] = @selector(callconfirm:);
            selindex++;
        }
    }
    if( self.mtagOrder.mIsCanFinish )
    {
        if( [[SUser currentUser] isSender] || [[SUser currentUser] isServicer]  )
        {
            [tttName addObject:@"订单完成"];
            tttSEL[selindex] = @selector(callconfirm:);
            selindex++;
        }
    }
    if( self.mtagOrder.mIsCanStartService )
    {
        if( self.mtagOrder.mOrderType == 1 )
        {
            [tttName addObject:@"开始配送"];
            tttSEL[selindex] = @selector(callstartsrv:);
            selindex++;
        }else
            if( self.mtagOrder.mOrderType == 2 )
            {
                [tttName addObject:@"开始服务"];
                tttSEL[selindex] = @selector(callstartsrv:);
                selindex++;
            }
            else
            {
                NSLog(@"what's the fuck order type");
            }
    }
    
    NSArray* ttt = @[ UIView.new, self.monewaper,self.mtwowaper,self.mthreewaper ];
    
    
    if( tttName.count > 3 )
    {
        CGRect ff = self.mwarper.frame;
        ff.size.height = DEVICE_Height - 64;
        self.mwarper.frame = ff;
        for ( UIView* one in ttt ) {
            one.hidden = YES;
        }
    }
    else
    {
        UIView* tagwaper = ttt[ tttName.count ];
        for ( int j  = 0 ;j < tttName.count; j ++) {
            UIButton* onebt = (UIButton*)[tagwaper viewWithTag:j+1];
            [onebt setTitle:tttName[j] forState:UIControlStateNormal];
            [onebt addTarget:self action:tttSEL[j] forControlEvents:UIControlEventTouchUpInside];
        }
        for ( UIView* one in ttt ) {
            if( one != tagwaper )
                one.hidden = YES;
            else
                one.hidden = NO;
        }
        
        CGRect fffft = tagwaper.frame;
        fffft.origin.y = DEVICE_Height - fffft.size.height;
        tagwaper.frame = fffft;
     
        CGRect ff = self.mwarper.frame;
        ff.size.height = DEVICE_Height - 64 - fffft.size.height;
        self.mwarper.frame = ff;
    }
}
- (IBAction)callbuyertel:(id)sender {

    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",self.mtagOrder.mMobile];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
}

- (IBAction)callsendertel:(id)sender {
    
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",self.mtagOrder.mStaff.mMobile];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
}


-(void)updatePage
{
    self.morderstatus.text = self.mtagOrder.mOrderStatusStr;
    [self updateOrderSendInfo];
    [self updateOrderGoodInfo];
    [self updateOrderInfo];
    
    CGSize ss = self.mwarper.contentSize;
    ss.height = self.morderinfowaper.frame.origin.y + self.morderinfowaper.frame.size.height;
    self.mwarper.contentSize = ss;
    
    [self updateOrderOpInfo];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _allgoodsinfo.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ordergoodscell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray* t = [_allgoodsinfo objectAtIndex:indexPath.row];
    
    cell.mA.text = t[0];
    cell.mB.text = t[1];
    cell.mC.text = t[2];
    
    return cell;
}


- (IBAction)calltel:(id)sender {
    
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",self.mtagOrder.mStaff.mMobile];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
}

- (IBAction)callcomp:(id)sender {
    
    if( self.mtagOrder == nil ) return;
    [SVProgressHUD showWithStatus:@"操作中..." maskType:SVProgressHUDMaskTypeClear];
    [self.mtagOrder completeThis:^(SResBase *resb) {
       
        if( resb.msuccess )
        {
            [SVProgressHUD dismiss];
            [self updatePage];
        }
        else
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
    }];
}

- (IBAction)callnav:(id)sender {
    
    if( self.mtagOrder == nil ) return;
    //跳转到高德地图
    NSString* ampurl = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=yz_cm_seller&lat=%.7f&lon=%.7f&dev=0&style=0",[Util getAPPName],self.mtagOrder.mLat,self.mtagOrder.mLongit];
    
    if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:ampurl]] )
    {//
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ampurl]];
    }
    else
    {//ioS map
        
        CLLocationCoordinate2D to;
        to.latitude =  self.mtagOrder.mLat;
        to.longitude =  self.mtagOrder.mLongit;
        
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil] ];
        toLocation.name = self.mtagOrder.mAddress;
        [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                       launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                                                 forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
    }
}

- (IBAction)callconfirm:(id)sender {
    if( self.mtagOrder == nil ) return;
    [SVProgressHUD showWithStatus:@"操作中..." maskType:SVProgressHUDMaskTypeClear];
    [self.mtagOrder confirmThis:^(SResBase *resb) {
        
        if( resb.msuccess )
        {
            [SVProgressHUD dismiss];
            [self updatePage];
        }
        else
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
    }];
    
}
-(void)callcancle:(id)sender
{
    
    
    if( self.mtagOrder == nil ) return;
    
    [ReplyView showInVC:self block:^(NSString *text) {
        
         [SVProgressHUD showWithStatus:@"操作中..." maskType:SVProgressHUDMaskTypeClear];
         [self.mtagOrder cancleThis:text block:^(SResBase *resb) {
             
             if( resb.msuccess )
             {
                 [SVProgressHUD dismiss];
                 [self updatePage];
             }
             else
                 [SVProgressHUD showErrorWithStatus:resb.mmsg];
         }];
        
    }];
   
}

- (IBAction)changepeople:(id)sender {
    
    selectPeopleVC* vc = [[selectPeopleVC alloc]init];
    vc.mTagOrder = self.mtagOrder;
    vc.mitblock = ^(int staffid )
    {
        if( -1 != staffid )
        {
            [self updatePage];
        }
    };
    [self pushViewController:vc];
    
}
-(void)callstartsrv:(id)sender
{
    if( self.mtagOrder == nil ) return;
    [SVProgressHUD showWithStatus:@"操作中..." maskType:SVProgressHUDMaskTypeClear];
    [self.mtagOrder startThis:^(SResBase *resb) {
        if( resb.msuccess )
        {
            [SVProgressHUD dismiss];
            [self updatePage];
        }
        else
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
    }];
}







/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
