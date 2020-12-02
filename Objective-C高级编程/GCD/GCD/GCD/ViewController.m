//
//  ViewController.m
//  GCD
//
//  Created by CNTP on 2020/11/27.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemTealColor];
//    [self function];
    [self function8];
    NSLog(@"----%@---",NSHomeDirectory());
}

- (void)function{

    // 串行队列的创建方法
    dispatch_queue_t serialDispatchQueue = dispatch_queue_create("com.example.gcd.serial", DISPATCH_QUEUE_SERIAL);
    // 并发队列的创建方法
    dispatch_queue_t concurrentDispatchQueue = dispatch_queue_create("com.example.gcd.concurrent", DISPATCH_QUEUE_CONCURRENT);

    dispatch_sync(serialDispatchQueue, ^{

    });

    dispatch_async(concurrentDispatchQueue, ^{

    });


    //各种 Dispatch Queue的获取方法

    /*
     * Main Dispatch Queue 的获取方法
     */
    dispatch_queue_t mainDispatchQueue = dispatch_get_main_queue();

    /*
     * Global Dispatch Queue (高优先级)的获取方法
     */
    dispatch_queue_t globalDispatchQueueHigh = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

    /*
     * Global Dispatch Queue (默认优先级)的获取方法
     */
    dispatch_queue_t globalDispatchQueueDefault = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    /*
     * Global Dispatch Queue (低优先级)的获取方法
     */
    dispatch_queue_t globalDispatchQueueLow = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);

    /*
     * Global Dispatch Queue (后台优先级)的获取方法
     */
    dispatch_queue_t globalDispatchQueueBackground = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);


}

- (void)testTargetQueue {
    //1.创建目标队列
    dispatch_queue_t targetQueue = dispatch_queue_create("test.target.queue", DISPATCH_QUEUE_SERIAL);

    //2.创建3个串行队列
    dispatch_queue_t queue1 = dispatch_queue_create("test.1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("test.2", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue3 = dispatch_queue_create("test.3", DISPATCH_QUEUE_SERIAL);

    //3.将3个串行队列分别添加到目标队列
    dispatch_set_target_queue(queue1, targetQueue);
    dispatch_set_target_queue(queue2, targetQueue);
    dispatch_set_target_queue(queue3, targetQueue);


    dispatch_async(queue1, ^{
        NSLog(@"1 in");
        [NSThread sleepForTimeInterval:3.f];
        NSLog(@"1 out");
    });

    dispatch_async(queue2, ^{
        NSLog(@"2 in");
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"2 out");
    });
    dispatch_async(queue3, ^{
        NSLog(@"3 in");
        [NSThread sleepForTimeInterval:1.f];
        NSLog(@"3 out");
    });

    dispatch_queue_t mySerialDispatchQueue = dispatch_queue_create("com.example.gcd.mySerialDispatchQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t globalDispatchQueueBackground = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_set_target_queue(mySerialDispatchQueue, globalDispatchQueueBackground);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"--- 延迟3秒后执行的操作 ---");
    });

    //或

//    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC));
//    dispatch_after(time, dispatch_get_main_queue(), ^{
//        NSLog(@"--- 延迟3秒后执行的操作 ---");
//    });


    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_async(group, queue, ^{
        NSLog(@"---blk1---");
    });

    dispatch_group_async(group, queue, ^{
        NSLog(@"---blk2---");
    });

    dispatch_group_async(group, queue, ^{
        NSLog(@"---blk3---");
    });

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        NSLog(@"---done---");
//    });

    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)1 * NSEC_PER_SEC);
    long result = dispatch_group_wait(group, time);
    if (result == 0) {
        //属于 Dispatch Group 的全部处理执行结束
    }else{
        //属于 Dispatch Group 的某一个处理还在执行中
    }

}

- (void)function1{
    dispatch_queue_t queue = dispatch_queue_create("com.example.gcd.barrier", DISPATCH_QUEUE_CONCURRENT);

    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"dispatch_async1");
    });

    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"dispatch_async2");
    });

    //等待前面的任务执行完毕后自己才执行，后面的任务需等待它完成之后才执行
    dispatch_barrier_async(queue, ^{
        NSLog(@"dispatch_barrier_async");
        [NSThread sleepForTimeInterval:4];
        NSLog(@"四秒后：dispatch_barrier_async");
    });

    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"dispatch_async3");
    });

    dispatch_async(queue, ^{
        NSLog(@"dispatch_async4");
    });
}

- (void)function2{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        /*
         * 处理
         */
    });
}

- (void)function3{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"---%zu---",index);
    });
}

- (void)function4{
    dispatch_queue_t queue = dispatch_queue_create("com.example.gcd.suspend", DISPATCH_QUEUE_CONCURRENT);
    dispatch_suspend(queue);
    dispatch_async(queue, ^{
        dispatch_apply(5, queue, ^(size_t index) {
            NSLog(@"---%ld---1----",index);
        });
    });
    sleep(1);
    NSLog(@"---2---");
    dispatch_resume(queue);
}

- (void)function5{

    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.example.gcd.queue", DISPATCH_QUEUE_CONCURRENT);

    dispatch_group_async(dispatchGroup, queue, ^{
        //接口1
        sleep(2);
        NSLog(@"---接口1---");
    });

    dispatch_group_async(dispatchGroup, queue, ^{
        //接口2
        sleep(1);
        NSLog(@"---接口2---");
    });

    dispatch_group_notify(dispatchGroup, queue, ^{
        //结束
        NSLog(@"---结束---");
    });

}

- (void)function6{

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    dispatch_async(dispatch_queue_create("com.example.gcd.queue", DISPATCH_QUEUE_CONCURRENT), ^{
        sleep(2);
        NSLog(@"---1---");
        dispatch_semaphore_signal(semaphore);
    });

    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t) 1 * NSEC_PER_SEC);
    long result = dispatch_semaphore_wait(semaphore, time);
    if (result == 0) {
        /*
         * 由于Dispatch Semaphore 的计数值达到大于等于1
         * 或者在待机中的指定时间内
         * Dispatch Semaphore 的计数值达到大于等于1
         *
         * 可执行需要进行排他控制的处理
         */
        NSLog(@"---2---");
    }else{
        /*
         * 由于 Dispatch Semaphore 的计数值为0
         * 因此再达到指定时间为止待机
         */
        NSLog(@"---3---");
    }
}

+ (instancetype)shareManager{
    static ViewController *vc = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vc = [ViewController new];
    });
    return vc;
}

#pragma mark --- 异步串行读取文件 ---
- (void)function7{
    NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"/test/Linux Shell脚本攻略.pdf"];
    dispatch_queue_t queue = dispatch_queue_create("com.example.gcd.serial", DISPATCH_QUEUE_SERIAL);

    /** 文件描述符 */
    dispatch_fd_t fd = open(path.UTF8String, O_RDONLY, 0);
    /** 创建一个调度I/O通道，并将其与指定的文件描述符关联 */
    dispatch_io_t io_t = dispatch_io_create(DISPATCH_IO_RANDOM, fd, queue, ^(int error) {
        close(fd);
    });
    size_t water = 1024*1024;
    /** 设置一次读取的最小字节大小 */
    dispatch_io_set_low_water(io_t, water);
    /** 设置一次读取的最大字节 */
    dispatch_io_set_high_water(io_t, water);
    long long fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
    NSMutableData *totalData = [[NSMutableData alloc] init];
    /** 进行文件读取 */
    dispatch_io_read(io_t, 0, fileSize, queue, ^(bool done, dispatch_data_t  _Nullable data, int error) {
        if (error == 0) {
            size_t len = dispatch_data_get_size(data);
            if (len > 0) {
                [totalData appendData:(NSData *)data];
            }
        }
        if (done) {
            //将读取的文件存到沙盒中
            NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/shell.pdf"];
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:totalData attributes:nil];
        }
    });
}

#pragma mark --- 异步并行读取文件 ---
- (void)function8{

    NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"/test/Linux Shell脚本攻略.pdf"];
    dispatch_queue_t queue = dispatch_queue_create("com.example.gcd.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();

    dispatch_fd_t fd = open(path.UTF8String, O_RDONLY);
    dispatch_io_t io = dispatch_io_create(DISPATCH_IO_RANDOM, fd, queue, ^(int error) {
        close(fd);
    });

    long long fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
    size_t offset = 1024*1024;

    NSMutableData *totalData = [[NSMutableData alloc] initWithLength:fileSize];

    for (size_t currentSize = 0; currentSize <= fileSize; currentSize += offset) {
        dispatch_group_enter(group);
        NSLog(@"---1---:%@---",@(currentSize));
        dispatch_io_read(io, currentSize, offset, queue, ^(bool done, dispatch_data_t  _Nullable data, int error) {
            if (error == 0) {
                size_t len = dispatch_data_get_size(data);
                if (len > 0) {
                    const void *bytes = NULL;
                    (void)dispatch_data_create_map(data, (const void **)&bytes, &len);
                    [totalData replaceBytesInRange:NSMakeRange(currentSize, len) withBytes:bytes length:len];
                    NSLog(@"---2---:%@---",@(currentSize));
                }
            }
            if (done) {
                dispatch_group_leave(group);
            }
        });
    }
    dispatch_group_notify(group, queue, ^{
        NSLog(@"---开始存---");
        //将读取的文件存到沙盒中
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/linx_shell.pdf"];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:totalData attributes:nil];
    });
}

@end
