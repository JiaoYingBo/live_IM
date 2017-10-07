//
//  ViewController.swift
//  ChatClient
//
//  Created by 焦英博 on 2017/10/6.
//  Copyright © 2017年 jyb. All rights reserved.
//

import UIKit
import ProtocolBuffers

class ViewController: UIViewController {

    fileprivate lazy var socket: STSocket = STSocket(addr: "0.0.0.0", port: 7878)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if socket.connectServer() {
            print("已连接上服务器")
            socket.startReadMsg()
        }
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

