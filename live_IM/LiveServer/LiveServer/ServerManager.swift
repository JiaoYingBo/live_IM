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
    fileprivate lazy var clientMrgs: [ClientManager] = [ClientManager]()
}

extension ServerManager {
    func startRunning() {
        // 开启监听
        serverSocket.listen()
        isServerRunning = true
        
        // 开始接收客户端
        DispatchQueue.global().async {
            // 需要心跳包保活
            
            // 1.当前线程在这里会死循环（导致只能处理一个客户端，不能处理多个）
            while self.isServerRunning {
                if let client = self.serverSocket.accept() {
                    // 2.所以再开启一条线程处理
                    DispatchQueue.global().async {
                        self.handlerClient(client)
                    }
                }
            }
        }
    }
    
    func stopRunning() {
        // 关闭监听
        isServerRunning = false
    }
}

extension ServerManager {
    fileprivate func handlerClient(_ client: TCPClient) {
        // 创建一个ClientManager来管理TCPClient
        let mgr = ClientManager(tcpClient: client)
        
        mgr.delegate = self
        
        clientMrgs.append(mgr)
        
        mgr.startReadMsg()
    }
}

extension ServerManager: ClientManagerDelegate {
    func sendMsgToClient(_ data: Data) {
        for client in clientMrgs {
            client.tcpClient.send(data: data)
        }
    }
}
