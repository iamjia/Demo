//
//  MasterViewController.m
//  TestDemo
//
//  Created by Jia on 2018/11/27.
//  Copyright © 2018年 Jia. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "YYImage.h"

@interface MasterViewController ()

@property NSArray *objects;
@property (nonatomic, strong) UISegmentedControl *seg;
@end

@implementation MasterViewController
{
@private
    NSArray *_audios;
    NSArray *_videos;
    NSArray *_images;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Photos" style:UIBarButtonItemStylePlain target:self action:@selector(saveUsePhotos)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"AssetsLibrary" style:UIBarButtonItemStylePlain target:self action:@selector(saveUseALibrary)];
    
    _seg = [[UISegmentedControl alloc] initWithItems:@[@"图片", @"音频", @"视频"]];
    _seg.selectedSegmentIndex = 0;
    self.navigationItem.titleView = _seg;
    [_seg addTarget:self action:@selector(segValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self fetchData];
    _objects = _audios;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveUsePhotos
{
    for (NSURL *URL in self.objects) {
        [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
            if (nil == [PHAssetChangeRequest creationRequestForAssetFromImage:[UIImage imageWithContentsOfFile:URL.path]]) {
                NSLog(@"xxx");
            }
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            NSLog(@"%@ %@", URL ,success ? @"成功": @"失败");
        }];
    }

}

- (void)saveUseALibrary
{
    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSURL *URL in wSelf.objects) {
            @autoreleasepool {
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                if (2 == wSelf.seg.selectedSegmentIndex) {
                    [library writeVideoAtPathToSavedPhotosAlbum:URL completionBlock:^(NSURL *assetURL, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"%@ %@", URL ,nil != assetURL ? @"成功": @"失败");
                        });
                    }];
                } else {
//                    YYImage *image = [YYImage imageWithContentsOfFile:URL.path];
//                    [image yy_saveToAlbumWithCompletionBlock:^(NSURL * _Nullable assetURL, NSError * _Nullable error) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            NSLog(@"%@ %@", URL ,nil != assetURL ? @"成功": @"失败");
//                        });
//                    }];

                    NSData *data = [NSData dataWithContentsOfURL:URL];
                    [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"%@ %@", URL ,nil != assetURL ? @"成功": @"失败");
                        });
                    }];
                }
            }
        }
    });
}

- (void)fetchData
{
    _audios = [self fetchContents:@"Sample Audio"];
    _videos = [self fetchContents:@"Sample Video"];
    _images = [self fetchContents:@"Sample Image"];
}

- (NSArray *)fetchContents:(NSString *)path
{
    NSURL *dir = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:path isDirectory:YES];
    NSArray<NSString *> *contents = [NSFileManager.defaultManager contentsOfDirectoryAtPath:dir.path error:NULL];
    NSMutableArray *arry = NSMutableArray.array;
    for (NSString *name in contents) {
        NSURL *url = [dir URLByAppendingPathComponent:name];
        [arry addObject:url];
    }
    return arry;
}

- (void)segValueChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            _objects = _images;
            break;
        
        case 1:
            _objects = _audios;
            break;
            
        case 2:
            _objects = _videos;
            break;
            
        default:
            break;
    }
    [self.tableView reloadData];
}

- (void)ctrler:(UIViewController *)ctrler presentActivityVCWithItems:(NSArray *)items actitvities:(NSArray *)activities willShow:(void (^)(UIPopoverPresentationController *popCtrler))willshow after:(void (^)(void))after
{
//    if (items.count == 1 && [items.firstObject isKindOfClass:NSURL.class] && [items.firstObject isFileURL] && activities.count < 1) {
//        UIDocumentInteractionController *docCtrler = [UIDocumentInteractionController interactionControllerWithURL:items.firstObject];
//        docCtrler.delegate = (id<UIDocumentInteractionControllerDelegate>)self;
//        UIPopoverPresentationController *popup = [[UIPopoverPresentationController alloc] initWithPresentedViewController:ctrler presentingViewController:nil];
//        if (nil != willshow) {
//            willshow(popup);
//        }
//        if (nil != popup.barButtonItem) {
//            [docCtrler presentOptionsMenuFromBarButtonItem:popup.barButtonItem animated:YES];
//        } else if (nil != popup.sourceView) {
//            [docCtrler presentOptionsMenuFromRect:popup.sourceRect inView:popup.sourceView animated:YES];
//        }
//        return;
//    }
    
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:activities];
    if (nil != willshow) {
        willshow(activity.popoverPresentationController);
    }
    [ctrler presentViewController:activity animated:YES completion:after];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSURL *url =self.objects[indexPath.row];
    cell.textLabel.text = [url lastPathComponent];
    cell.imageView.image = [UIImage imageWithContentsOfFile:url.path];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *object = self.objects[indexPath.row];
    [self ctrler:self presentActivityVCWithItems:@[object] actitvities:nil willShow:^(UIPopoverPresentationController *popCtrler) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        popCtrler.sourceView = cell;
        popCtrler.sourceRect = cell.frame;
    } after:nil];
}

@end
