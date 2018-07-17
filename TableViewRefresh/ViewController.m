//
//  ViewController.m
//  TableViewRefresh
//
//  Created by Likee on 2018/7/11.
//  Copyright © 2018年 懒懒的猫鼬鼠. All rights reserved.
//
//获取设备的物理高度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
//获取设备的物理宽度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#import "ViewController.h"
#import "UITextView+WZB.h"


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>
@property(nonatomic,strong)UITableView *tableview;
@property(nonatomic,strong)NSMutableDictionary *dicHeight;//高度

@end

@implementation ViewController


-(NSMutableDictionary *)dicHeight{
    if (!_dicHeight) {
        _dicHeight = [NSMutableDictionary dictionary];
    }
    return _dicHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    // Do any additional setup after loading the view, typically from a nib.
}

-(UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
    }
    return _tableview;
}

#pragma mark - UITableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *identifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行",indexPath.row];
    
    if (![cell.contentView viewWithTag:1000 + indexPath.row]) {
        UITextView *view = [UITextView new];
        view.backgroundColor = [UIColor redColor];
        view.delegate = self;
        view.frame = CGRectMake(ScreenWidth *0.3,0 , ScreenWidth *0.5, 44);
        view.tag = 1000 + indexPath.row;
        [cell.contentView addSubview:view];
    }
    [self tableViewCellAutoHeight:indexPath cell:cell];
    
       
    return cell;
    
}

#pragma mark -自动改变行高
- (void)tableViewCellAutoHeight:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell{
    UITextView *textView =  [cell.contentView viewWithTag:1000 + indexPath.row];
    __weak typeof (self)WeakSelf = self;
    __weak typeof (textView)WeakTextView = textView;
    // 最大高度为300 改变高度的 block
    [textView wzb_autoHeightWithMaxHeight:300 textViewHeightDidChanged:^(CGFloat currentTextViewHeight) {
        CGRect frame = WeakTextView.frame;
        frame.size.height = currentTextViewHeight;
        [UIView animateWithDuration:0.2 animations:^{
            WeakTextView.frame = frame;
            
        } completion:^(BOOL finished) {
        }];
        
        NSString *key = [NSString stringWithFormat:@"%@",indexPath];
        NSNumber *height = [NSNumber numberWithFloat:currentTextViewHeight];
        if (self.dicHeight[key]) {
            NSNumber *oldHeight = self.dicHeight[key];
            if (oldHeight.floatValue != height.floatValue) {
                [self.dicHeight setObject:height forKey:key];
            }
        }
        else{
            [self.dicHeight setObject:height forKey:key];
            
        }
        
        [WeakSelf.tableview beginUpdates];
        [WeakSelf.tableview endUpdates];
        
    }];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key = [NSString stringWithFormat:@"%@",indexPath];

    if(self.dicHeight[key]){
        NSNumber *number = self.dicHeight[key];
        if (number.floatValue > 44) {
            return number.floatValue;
        }
    }
    return 44;
}


//模拟数据刷新
-(void)textViewDidChange:(UITextView *)textView{
    
    //1.reloadData
//    [self.tableview reloadData];
    
    
    //2.reloadindexpath
//    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableview reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationTop];
    
    
    //3.beginupdate & endupdate
//    [self.tableview beginUpdates];
//    [self.tableview endUpdates];
    
}





- (void)creatUI{
    [self.view addSubview:self.tableview];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
