//
//  NextViewController.swift
//  GCD
//
//  Created by CNTP on 2020/12/3.
//

import UIKit

class NextViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBlue
//        function7()
        let button = UIButton.init(frame: CGRect.init(x: self.view.center.x - 50, y: self.view.center.y - 50, width: 100, height: 100))
        button.backgroundColor = .white
        self.view.addSubview(button)
        button.addTarget(self, action:#selector(self.buttonAction), for: .touchUpInside)
    }

    @objc func buttonAction()  {
        print("按钮点击")
    }

    func function() {

        //串行队列的创建方法
        let serialDispatch = DispatchQueue.init(label: "com.example.gcd.serial")
        //并发队列的创建方法
        let concurrentDispatchQueue = DispatchQueue.init(label: "com.example.gcd.concurrent", attributes: .concurrent)

        //同步
        serialDispatch.sync {

        }

        //异步
        concurrentDispatchQueue.async {

        }

        /* --- 各种 Dispatch Queue的获取方法 --- */
        /*
         相应参数说明：
         label : 队列的标识
         qos(服务质量)： .default 默认   .background 后台   .unspecified 不指定   .userInitiated 用户发起
         attributes: 不指定的情况下是串行队列    .concurrent 并行队列
         autoreleaseFrequency: 自动释放的频率  .inherit 继承     .workItem工作组    .never 从不
         let dispatchQueue = DispatchQueue.init(label: String, qos: DispatchQoS, attributes: DispatchQueue.Attributes, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency, target: DispatchQueue?)
         */

        /*
         * Main Dispatch Queue 的获取方法
         */
        let mainDispatchQueue = DispatchQueue.main
        
    }

    func function1() {
        let queue = DispatchQueue.init(label: "com.example.gcd.barrier", attributes: .concurrent)
        queue.async {
            sleep(2)
            print("dispatch_async1")
        }

        queue.async {
            sleep(1)
            print("dispatch_async2")
        }

        //等待前面的任务执行完毕后自己才执行，后面的任务需等待它完成之后才执行
        queue.async(flags: .barrier){
            sleep(4)
            print("四秒后：dispatch_barrier_async")
        }

        queue.async {
            sleep(1)
            print("dispatch_async3")
        }

        queue.async {
            print("dispatch_async4")
        }

    }

    func function2() {
        // 全局并行队列
        let queue = DispatchQueue.global(qos: .default)
        queue.sync {
            /*
             * 处理
             */
        }
    }

    func function3() {
        /*
         dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
         dispatch_apply(10, queue, ^(size_t index) {
             NSLog(@"---%zu---",index);
         });
         */
        let queue = DispatchQueue.global(qos: .default)
    }

    func function4() {
        /*
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
         */
        let queue = DispatchQueue.init(label: "com.example.gcd.suspend", attributes: .concurrent)
        queue.suspend()
        queue.async {
            print("------1----")
        }
        sleep(1)
        print("---2---")
        queue.resume()
    }

    func function5() {
        /*
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
         */
        let dispatchGroup = DispatchGroup.init()
        let queue = DispatchQueue.init(label: "com.example.gcd.queue", attributes: .concurrent)

        dispatchGroup.enter()
        queue.async {
            print("---1---")
            sleep(1)
            print("---2---")
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: queue){
            print("---3---")
        }
    }

    func function6() {
        /*

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
         */

        let semaphore = DispatchSemaphore.init(value: 0)

        DispatchQueue.init(label: "com.example.gcd.queue",attributes: .concurrent).async {
            sleep(2)
            print("---1---")
            semaphore.signal()
        }
        print("---2---")
//        semaphore.wait()
        let time = DispatchTime.init(uptimeNanoseconds: 1)
        let result = semaphore.wait(timeout: time)

        if result == DispatchTimeoutResult.success {
            print("---3---")
        }else{
            print("---4---")
        }

    }

    func function7() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: 2)){
            print("---延迟2秒执行---")
        }
        print("---1---")
    }

    //单例
    class shareManager {
        static let shareManager = NextViewController()
        private init(){}
    }
}
