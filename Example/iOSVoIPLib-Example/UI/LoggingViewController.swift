//
//  LoggingViewController.swift
//  iOSVoIPLib_Example
//
//  Created by Chris Kontos on 21/04/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import iOSVoIPLib

protocol LoggingViewDelegate {
    func onUpdate(log: NSMutableAttributedString)
}

class LoggingViewController: UIViewController, LoggingViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
            
    // MARK: Lifecircle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let log = appDelegate.logManager.log
        updateText(log: log)
        
        appDelegate.logManager.loggingViewDelegate = self
    }
    
    // MARK: UI
    
    func updateText(log: NSMutableAttributedString){
        DispatchQueue.main.async {
            self.textView.attributedText = log
        }
    }
    
    // MARK: LoggingViewDelegate
    
    func onUpdate(log: NSMutableAttributedString){
        updateText(log: log)
    }
    
}
