//
//  ViewController.swift
//  ChatClient
//
//  Created by 焦英博 on 2017/10/6.
//  Copyright © 2017年 jyb. All rights reserved.
//

/**
 1> 获取到服务器对应的IP/端口号
 2> 使用Socket，通过IP/端口号和服务器建立连接
 3> 开启定时器，实时让服务器发送心跳包
 4> 通过sendMsg，给服务器发送消息：字节流 --> 消息长度 + 消息类型 + 真正的消息
 5> 读取从服务器传过来的消息(开启子线程)
 */

import UIKit
import ProtocolBuffers

class ViewController: UIViewController {

    fileprivate lazy var socket: STSocket = STSocket(addr: "0.0.0.0", port: 7878)
    
    fileprivate var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if socket.connectServer() {
            print("已连接上服务器")
            socket.startReadMsg()
            
            // 心跳包
            timer = Timer(fireAt: Date(), interval: 9, target: self, selector: #selector(sendHeartBeat), userInfo: nil, repeats: true)
            timer.fire()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // RunLoop会强引用定时器，定时器强引用self造成self无法释放，所以不能在dealloc方法中释放timer
        timer.invalidate()
    }

    /*
     进入房间 = 0
     离开房间 = 1
     文本 = 2
     礼物 = 3
     */
    @IBAction func btnClick(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            socket.sendJoinRoom()
        case 1:
            socket.sendLeaveRoom()
        case 2:
            socket.sendTextMsg(msg: "发送一条文本消息")
        case 3:
            socket.sendGiftMsg(giftName: "火箭", giftURL: "www.baidu.com", giftCount: 2)
        default:
            return
        }
    }
}

extension ViewController {
    @objc fileprivate func sendHeartBeat() {
        socket.sendHeartBeat()
    }
}

