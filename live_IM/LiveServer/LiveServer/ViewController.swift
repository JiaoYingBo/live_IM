//
//  ViewController.swift
//  LiveServer
//
//  Created by 焦英博 on 2017/10/6.
//  Copyright © 2017年 jyb. All rights reserved.
//

/**
 MACOS工程中不能使用cocoapods，只能手动添加第三方。
 先去https://github.com/alexeyxo/protobuf-swift下载代码，
 然后将ProtocolBuffers.xcodeproj拖入此工程，
 选中ProtocolBuffers进行编译，编译完成后选中此工程Target，
 在Linked Frameworks and Libraries 中添加ProtocolBuffers的静态库。
 之后即可导入ProtocolBuffers头文件并使用
 */

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var label: NSTextField!
    fileprivate lazy var serverMgr: ServerManager = ServerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startClick(_ sender: NSButton) {
        serverMgr.startRunning()
        label.stringValue = "服务器已开启"
    }

    @IBAction func stopClick(_ sender: NSButton) {
        serverMgr.stopRunning()
        label.stringValue = "服务器已关闭"
    }

}

