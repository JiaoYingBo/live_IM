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
    
    init(tcpClient: TCPClient) {
        self.tcpClient = tcpClient
    }
}

extension ClientManager {
    func startReadMsg() {
        isClientConnected = true
        
        let timer = Timer(timeInterval: 10.0, target: self, selector: #selector(checkHeartBeat), userInfo: nil, repeats: true)
        // timer加入当前线程，当前为分线程
        RunLoop.current.add(timer, forMode: .commonModes)
        
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
                
                /*
                switch type {
                case 0,1:
                    let user = try! UserInfo.parseFrom(data: msgData)
                    print("==>\(user.name) \(user.level) \(user.iconUrl)")
                default:
                    print("未知的类型")
                }
                */
                
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
        if !revHeartBeat {
            tcpClient.close()
            delegate?.removeClient(self)
        } else {
            revHeartBeat = false
        }
    }
}
