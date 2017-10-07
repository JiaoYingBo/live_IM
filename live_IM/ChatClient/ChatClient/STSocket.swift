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
    
    init(addr: String, port: Int) {
        tcpClient = TCPClient(address: addr, port: Int32(port))
    }
}

extension STSocket {
    func connectServer() -> Bool {
        return tcpClient.connect(timeout: 5).isSuccess
    }
    
    func sendMsg(data: Data) {
        // send方法报警告，可在方法前加上@discardableResult（结果可遗弃）
        tcpClient.send(data: data)
    }
}
