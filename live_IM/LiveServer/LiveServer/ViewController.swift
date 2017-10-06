//
//  ViewController.swift
//  LiveServer
//
//  Created by 焦英博 on 2017/10/6.
//  Copyright © 2017年 jyb. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var label: NSTextField!
    fileprivate lazy var serverMgr: ServerManager = ServerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startClick(_ sender: NSButton) {
        serverMgr.startRunning()
        label.stringValue = "服务器已经开启ing"
    }

    @IBAction func stopClick(_ sender: NSButton) {
        serverMgr.stopRunning()
        label.stringValue = "服务器未开启"
    }

}

