//
//  ImagePreferencesViewController.swift
//  imageUpload
//
//  Created by Pro.chen on 16/7/8.
//  Copyright © 2016年 chenxt. All rights reserved.
//

import Cocoa
import MASPreferences

class ImagePreferencesViewController: NSViewController, MASPreferencesViewController {
	
	override var identifier: String? { get { return "image" } set { super.identifier = newValue } }
	var toolbarItemLabel: String? { get { return "图床" } }
	var toolbarItemImage: NSImage? { get { return NSImage(named: NSImageNameUser) } }
	var window: NSWindow?
	@IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var urlLabel: NSTextField!
	@IBOutlet weak var accessKeyTextField: NSTextField!
	@IBOutlet weak var secretKeyTextField: NSTextField!
	@IBOutlet weak var bucketTextField: NSTextField!
	@IBOutlet weak var urlPrefixTextField: NSTextField!
	@IBOutlet weak var checkButton: NSButton!
    @IBOutlet weak var suffixTextField: NSTextField!
    @IBOutlet weak var prefixTextField: NSTextField!
    
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
        if let configDic =  AppCache.shared.getQNUseConfig() {
            accessKeyTextField.cell?.title = configDic["accessKey"]!
            secretKeyTextField.cell?.title = configDic["secretKey"]!
            bucketTextField.cell?.title = configDic["scope"]!
            urlPrefixTextField.cell?.title = configDic["picUrlPrefix"]!
            prefixTextField.cell?.title = configDic["prefix"] ?? ""
            suffixTextField.cell?.title = configDic["suffix"] ?? ""
        }
        
        updateStatusLabel()
		
	}
	@IBAction func setDefault(_ sender: AnyObject) {
		AppCache.shared.useDefServer = true
		updateStatusLabel()
	}
	
	@IBAction func setQiniuConfig(_ sender: AnyObject) {
		if (accessKeyTextField.cell?.title.characters.count == 0 ||
			secretKeyTextField.cell?.title.characters.count == 0 ||
			bucketTextField.cell?.title.characters.count == 0 ||
			urlPrefixTextField.cell?.title.characters.count == 0) {
				showAlert("有配置信息未填写", informative: "请仔细填写")
				return
		}
		
		urlPrefixTextField.cell?.title = (urlPrefixTextField.cell?.title.replacingOccurrences(of: " ", with: ""))!
		
		if !(urlPrefixTextField.cell?.title.hasPrefix("http://"))! && !(urlPrefixTextField.cell?.title.hasPrefix("https://"))! {
			urlPrefixTextField.cell?.title = "http://" + (urlPrefixTextField.cell?.title)!
		}
		
		if !(urlPrefixTextField.cell?.title.hasSuffix("/"))! {
			urlPrefixTextField.cell?.title = (urlPrefixTextField.cell?.title)! + "/"
		}
		
		let ack = (accessKeyTextField.cell?.title)!
		let sek = (secretKeyTextField.cell?.title)!
		let bck = (bucketTextField.cell?.title)!
		
		checkButton.title = "验证中"
		checkButton.isEnabled = false
        ImageServer.shared.register(configDic: ["accessKey":ack,"secretKey":sek,"scope":bck])
        ImageServer.shared.createToken()
        ImageServer.shared.verifyQNConfig {[weak self] (result) in
            self?.checkButton.isEnabled = true
            self?.checkButton.title = "验证配置"
            result.Success(success: {_ in
                self?.showAlert("验证成功", informative: "配置成功。")
                let QN_Config = [
                    "picUrlPrefix"  : (self?.urlPrefixTextField.cell?.title)!,
                    "accessKey"     : (self?.accessKeyTextField.cell?.title)!,
                    "scope"         : (self?.bucketTextField.cell?.title)!,
                    "secretKey"     : (self?.secretKeyTextField.cell?.title)!,
                    "prefix"        : (self?.prefixTextField.cell?.title)!,
                    "suffix"        : (self?.suffixTextField.cell?.title)!
                ]
                AppCache.shared.setQNConfig(configDic: QN_Config);
                AppCache.shared.useDefServer = false
                self?.updateStatusLabel()
                
            }).Failure(failure: { _ in
                self?.showAlert("验证失败", informative: "验证失败，请仔细填写信息。")
            })
        }
	}
	
	func showAlert(_ message: String, informative: String) {
		let arlert = NSAlert()
		arlert.messageText = message
		arlert.informativeText = informative
		arlert.addButton(withTitle: "确定")
		if message == "验证成功" {
			arlert.icon = NSImage(named: "Icon_32x32")
		}
		else {
			arlert.icon = NSImage(named: "Failure")
		}
		arlert.beginSheetModal(for: self.window!, completionHandler: { (response) in
			
		})
	}
	
    func updateStatusLabel() {
        if !AppCache.shared.useDefServer {
            statusLabel.cell?.title = "目前使用自定义图床"
            statusLabel.textColor = .magenta
            urlLabel.cell?.title = AppCache.shared.getQNConfig()["picUrlPrefix"]! + (AppCache.shared.getQNConfig()["prefix"] ?? "") + "name" + (AppCache.shared.getQNConfig()["suffix"] ?? "")
        } else {
            statusLabel.cell?.title = "目前使用默认图床"
            statusLabel.textColor = .red
            urlLabel.cell?.title = ""
        }
    }
}
