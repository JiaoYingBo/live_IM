//
//  ClientManager.swift
//  LiveServer
//
//  Created by 焦英博 on 2017/10/6.
//  Copyright © 2017年 jyb. All rights reserved.
//

/*
 进入房间 = 0
 离开房间 = 1
 文本 = 2
 礼物 = 3
 */

import Cocoa

protocol ClientManagerDelegate: class {
    func sendMsgToClient(_ data: Data)
    func removeClient(_ client: ClientManager)
}

class ClientManager: NSObject {
    var tcpClient: TCPClient
    
    weak var delegate: ClientManagerDelegate?
    
    fileprivate var isClientConnected: Bool = false
    fileprivate var revHeartBeat: Bool = false
    
    weak var timer: Timer?
    
    init(tcpClient: TCPClient) {
        self.tcpClient = tcpClient
    }
    
    deinit {
        // block的timer不会强引用self，所以可以在这里释放
        timer?.invalidate()
    }
}

extension ClientManager {
    func startReadMsg() {
        isClientConnected = true
        
        // 调用RunLoop的run方法，就相当于在此处放置了一个while循环，后面的代码都不会继续执行了
        // 所以timer放在主线程或者单独一个线程比较合适
        // 不过这里是为每个client都创建了一个timer，很明显实际中是行不通的，因为服务器不可能开上亿条线程
        // block的Timer不会强引用self，可以在deInit中释放
        /*
        DispatchQueue.global().async {
            self.timer = Timer(timeInterval: 2.0, repeats: true, block: { (timer) in
                print("revHeartBeat")
                if !self.revHeartBeat {
                    print("revHeartBeat close")
                    self.tcpClient.close()
                    self.delegate?.removeClient(self)
                } else {
                    self.revHeartBeat = false
                }
            })
            RunLoop.current.add(self.timer!, forMode: .defaultRunLoopMode)
            RunLoop.current.run()
        }
        */
        // 在主线程创建timer也不执行。。。。真尼玛奇怪
//        DispatchQueue.main.async {
//            self.timer = Timer(timeInterval: 10.0, target: self, selector: #selector(self.checkHeartBeat), userInfo: nil, repeats: true)
//        }
        
        while isClientConnected {
            // 返回值为[UInt8]，即char类型的数组
            if let msg = tcpClient.read(4) {
                // 1.读取长度的Data，跟客户端约定好前4位表示长度
                let headData = Data(bytes: msg, count: 4)
                var length = 0
                (headData as NSData).getBytes(&length, length: 4)
                
                // 2.读取类型
                guard let typeMsg = tcpClient.read(2) else { return }
                let typeData = Data(bytes: typeMsg, count: 2)
                var type: Int = 0
                (typeData as NSData).getBytes(&type, length: 2)
                
                // 3.根据长度读取真实消息
                guard let msg = tcpClient.read(length) else { return }
                let msgData = Data(bytes: msg, count: length)
                
                
                switch type {
                case 0,1:
                    let user = try! UserInfo.parseFrom(data: msgData)
                    print("s==>\(user.name) \(user.level) \(user.iconUrl)")
                case 2:
                    let chatMsg = try! ChatMessage.parseFrom(data: msgData)
                    print("s==>\(chatMsg.text)")
                case 3:
                    let chatMsg = try! GiftMessage.parseFrom(data: msgData)
                    print("==>\(chatMsg.giftname)")
                case 100:
                    print("心跳包")
                default:
                    print("未知类型的消息")
                }
 
                
                // 如果client离开了，先把它从数组中移除，再分发消息
                if type == 1 {
                    tcpClient.close()
                    delegate?.removeClient(self)
                } else if type == 100 {
                    revHeartBeat = true
                    // 如果是心跳包，就直接进行下一次循环
                    continue
                }
                
                let totalData = headData + typeData + msgData
                delegate?.sendMsgToClient(totalData)
                
            } else {
                // 除了close掉，还需要从ServerManager中的clientMrgs数组中移除
                delegate?.removeClient(self)
                isClientConnected = false
                tcpClient.close()
                print("客户端断开了连接")
            }
        }
    }
}

extension ClientManager {
    @objc fileprivate func checkHeartBeat() {
        print("revHeartBeat")
        if !revHeartBeat {
            tcpClient.close()
            delegate?.removeClient(self)
        } else {
            revHeartBeat = false
        }
    }
}
