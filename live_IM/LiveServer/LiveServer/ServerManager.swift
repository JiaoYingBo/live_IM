//
//  ServerManager.swift
//  LiveServer
//
//  Created by 焦英博 on 2017/10/6.
//  Copyright © 2017年 jyb. All rights reserved.
//

import Cocoa

class ServerManager: NSObject {
    fileprivate lazy var serverSocket: TCPServer = TCPServer(addr: "0.0.0.0", port: 7878)
    fileprivate var isServerRunning: Bool = false
    fileprivate lazy var clientMrgs: Any = [Any]()
}

extension ServerManager {
    func startRunning() {
        // 开启监听
        serverSocket.listen()
        isServerRunning = true
        
        // 开始接收客户端
        DispatchQueue.global().async {
            while self.isServerRunning {
                if let client = self.serverSocket.accept() {
                    DispatchQueue.global().async {
                        <#code#>
                    }
                }
            }
        }
    }
    
    func stopRunning() {
        //
    }
}
