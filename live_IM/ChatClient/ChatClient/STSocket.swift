//
//  STSocket.swift
//  ChatClient
//
//  Created by 焦英博 on 2017/10/6.
//  Copyright © 2017年 jyb. All rights reserved.
//

import UIKit
import SwiftSocket

class STSocket {
    fileprivate var tcpClient: TCPClient
    
    fileprivate lazy var userInfo: UserInfo.Builder = {
        let userInfo = UserInfo.Builder()
        userInfo.name = "小明\(arc4random_uniform(10))"
        userInfo.level = 20
        userInfo.iconUrl = "https://www.baidu.com"
        return userInfo
    }()
    
    init(addr: String, port: Int) {
        tcpClient = TCPClient(address: addr, port: Int32(port))
    }
}

extension STSocket {
    func connectServer() -> Bool {
        return tcpClient.connect(timeout: 5).isSuccess
    }
    
    func startReadMsg() {
        DispatchQueue.global().async {
            // 此while循环在Xcode8.3.3上会一直打印-1，贼鸡儿恶心!
            while true {
                // 以下代码跟Server中的解析代码相同
                if let lMsg = self.tcpClient.read(4) {
                    // 1.读取长度的Data，跟客户端约定好前4位表示长度
                    let headData = Data(bytes: lMsg, count: 4)
                    var length = 0
                    (headData as NSData).getBytes(&length, length: 4)
                    
                    // 2.读取类型
                    guard let typeMsg = self.tcpClient.read(2) else { return }
                    let typeData = Data(bytes: typeMsg, count: 2)
                    var type: Int = 0
                    (typeData as NSData).getBytes(&type, length: 2)
                    
                    // 3.根据长度读取真实消息
                    guard let msg = self.tcpClient.read(length) else { return }
                    let msgData = Data(bytes: msg, count: length)
                    
                    // 4.消息转发出去
                    DispatchQueue.main.async {
                        self.handleMsg(type, msgData: msgData)
                    }
                }
            }
        }
    }
    
    fileprivate func handleMsg(_ type: Int, msgData: Data) {
        switch type {
        case 0,1:
            let user = try! UserInfo.parseFrom(data: msgData)
            print("==>\(user.name) \(user.level) \(user.iconUrl)")
        case 2:
            let chatMsg = try! ChatMessage.parseFrom(data: msgData)
            print("==>\(chatMsg.text)")
        default:
            print("未知类型的消息")
        }
    }
}

extension STSocket {
    func sendJoinRoom() {
        // 1.获取消息data
        let msgData = (try! userInfo.build()).data()
        
        // 2.发送消息
        sendMsg(data: msgData, type:0)
    }
    
    func sendLeaveRoom() {
        // 1.获取消息data
        let msgData = (try! userInfo.build()).data()
        
        // 2.发送消息
        sendMsg(data: msgData, type:1)
    }
    
    func sendTextMsg(msg: String) {
        // 1.创建ChatMessage类型
        let chatMsg = ChatMessage.Builder()
        chatMsg.text = msg
        
        // 2.获取消息data
        let msgData = (try! chatMsg.build()).data()
        
        // 3.发送消息
        sendMsg(data: msgData, type:2)
    }
    
    func sendGiftMsg(giftName: String, giftURL: String, giftCount: Int) {
        // 1.创建GiftMessage类型
        let giftMsg = GiftMessage.Builder()
        giftMsg.giftname = giftName
        giftMsg.giftUrl = giftURL
        giftMsg.giftcount = Int32(giftCount)
        
        // 2.获取消息data
        let msgData = (try! giftMsg.build()).data()
        
        // 3.发送消息
        sendMsg(data: msgData, type:3)
    }
    
    fileprivate func sendMsg(data: Data, type: Int) {
        // 2.将消息长度写入到data
        var length = data.count
        let headerData = Data(bytes: &length, count: 4)
        
        // 3.消息类型
        var tempType = type
        let typeData = Data(bytes: &tempType, count: 2)
        
        // 3.发送消息（Swift中Data是结构体，属于值，所以能相加，跟String同理）
        let totalData = headerData + typeData + data
        
        // send方法报警告，可在方法前加上@discardableResult（结果可遗弃）
        tcpClient.send(data: totalData)
    }
}
