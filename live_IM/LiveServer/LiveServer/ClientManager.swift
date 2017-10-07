//
//  ClientManager.swift
//  LiveServer
//
//  Created by 焦英博 on 2017/10/6.
//  Copyright © 2017年 jyb. All rights reserved.
//

import Cocoa

protocol ClientManagerDelegate: class {
    func sendMsgToClient(_ data: Data)
}

class ClientManager: NSObject {
    var tcpClient: TCPClient
    
    weak var delegate: ClientManagerDelegate?
    
    fileprivate var isClientConnected: Bool = false
    
    init(tcpClient: TCPClient) {
        self.tcpClient = tcpClient
    }
}

extension ClientManager {
    func startReadMsg() {
        isClientConnected = true
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
                    print("")
                    let user = try! UserInfo.parseFrom(data: msgData)
                    print("==>\(user.name) \(user.level) \(user.iconUrl)")
                default:
                    print("未知的类型")
                }
                */
                
                let totalData = headData + typeData + msgData
                delegate?.sendMsgToClient(totalData)
                
            } else {
                isClientConnected = false
                print("客户端断开了连接")
            }
        }
    }
}