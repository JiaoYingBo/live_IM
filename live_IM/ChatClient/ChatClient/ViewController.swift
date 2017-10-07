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
        }
    }

    /*
     进入房间 = 0
     离开房间 = 1
     文本 = 2
     礼物 = 3
     */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1.获取消息长度
        let userInfo = UserInfo.Builder()
        userInfo.name = "小明"
        userInfo.level = 20
        userInfo.iconUrl = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1507961381&di=8705ff62b8d0e0e3564880556613da24&imgtype=jpg&er=1&src=http%3A%2F%2Ff.hiphotos.baidu.com%2Fzhidao%2Fpic%2Fitem%2F8b82b9014a90f60326b707453b12b31bb051eda9.jpg"
        
        let msgData = (try! userInfo.build()).data()
        
        // 2.将消息长度写入到data
        var length = msgData.count
        let headerData = Data(bytes: &length, count: 4)
        
        // 3.消息类型
        var type = 0
        let typeData = Data(bytes: &type, count: 2)
        
        // 3.发送消息（Swift中Data是结构体，属于值，所以能相加，跟String同理）
        let totalData = headerData + typeData + msgData
        socket.sendMsg(data: totalData)
    }
}

