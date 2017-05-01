//
//  SHOMainViewController.m
//  demo-semaphore
//
//  Created by shoshino21 on 5/1/17.
//  Copyright © 2017 shoshino21. All rights reserved.
//

#import "SHOMainViewController.h"
#import "NSArray+SafeObject.h"

#define kScreenBounds [UIScreen mainScreen].bounds
#define kScreenWidth kScreenBounds.size.width
#define kScreenHeight kScreenBounds.size.height
#define kStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

static NSInteger const kImgCount = 5;
static CGFloat const kImgHeight = 250.f;

static NSString *const kImgUrl1 = @"http://i.imgur.com/TmTEeEb.jpg";
static NSString *const kImgUrl2 = @"http://i.imgur.com/EsxPnqN.jpg";
static NSString *const kImgUrl3 = @"http://i.imgur.com/S8AuciE.jpg";
static NSString *const kImgUrl4 = @"http://i.imgur.com/oHHVWzJ.jpg";
static NSString *const kImgUrl5 = @"http://i.imgur.com/puQAK9R.jpg";

@interface SHOMainViewController () <UITableViewDataSource, UITableViewDelegate> {
  UITableView *mainTableView;
  NSMutableArray<UIImage *> *imagesMutArr;
  NSArray<NSString *> *imageUrlsArr;

  dispatch_semaphore_t semaphore;
}

@end

@implementation SHOMainViewController

#pragma mark - UI

- (void)viewDidLoad {
  [super viewDidLoad];

  imagesMutArr = [NSMutableArray new];
  imageUrlsArr = @[ kImgUrl1, kImgUrl2, kImgUrl3, kImgUrl4, kImgUrl5 ];
  semaphore = dispatch_semaphore_create(0);

  [self initUI];

  [self fetchAllImages];
}

- (void)initUI {
  mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                kStatusBarHeight,
                                                                kScreenWidth,
                                                                kScreenHeight - kStatusBarHeight)];
  mainTableView.dataSource = self;
  mainTableView.delegate = self;
  mainTableView.allowsSelection = NO;
  [self.view addSubview:mainTableView];
}

#pragma mark - Fetching

- (void)fetchAllImages {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    for (NSInteger i = 0; i < kImgCount; i++) {
      UIImage *fetchedImage = [self fetchImageAtIndex:i];

      if (fetchedImage) {
        [imagesMutArr addObject:fetchedImage];

        dispatch_async(dispatch_get_main_queue(), ^{
          [mainTableView reloadData];
        });
      }
    }
  });
}

- (UIImage *)fetchImageAtIndex:(NSUInteger)index {
  __block UIImage *fetchedImage;
  NSURL *imageUrl = [NSURL URLWithString:[imageUrlsArr sho_safeObjectAtIndex:index]];

  NSURLSessionDownloadTask *downloadImageTask =
  [[NSURLSession sharedSession] downloadTaskWithURL:imageUrl
                                  completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
  {
    fetchedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
    dispatch_semaphore_signal(semaphore);
  }];

  [downloadImageTask resume];

  dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

  return fetchedImage;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return kImgCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifierStr;
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierStr];

  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierStr];
  }

  UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kImgHeight)];
  imageView.contentMode = UIViewContentModeScaleAspectFit;

  UIImage *image = [imagesMutArr sho_safeObjectAtIndex:indexPath.row];
  if ([image isKindOfClass:[UIImage class]]) {
    imageView.image = image;
  }

  [cell addSubview:imageView];

  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return kImgHeight;
}

@end
