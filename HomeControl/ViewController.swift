//
//  ViewController.swift
//  HomeControl
//
//  Created by Hyeon chang Park on 2016. 1. 23..
//  Copyright © 2016년 BRTech. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore


class ViewController: UIViewController, DZBluetoothSerialDelegate {
    
    @IBOutlet weak var navItem : UINavigationItem!
    @IBOutlet weak var connectBarButton : UIBarButtonItem!
    @IBOutlet weak var switchControl: UIButton!
    
    var switchOn : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // init serial
        serial = DZBluetoothSerialHandler(delegate: self)
        serial.writeWithResponse = NSUserDefaults.standardUserDefaults().boolForKey(WriteWithResponseKey)
        
        reloadView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadView"), name: "reloadStartViewController", object: nil)
    

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func reloadView() {
        
        // in case we're the visible view again
        serial.delegate = self
        
        if serial.connectedPeripheral == nil {
            navItem.title = "컨트롤 패널"
            connectBarButton.title = "기기 연결"
            connectBarButton.tintColor = view.tintColor
        } else {
            navItem.title = serial.connectedPeripheral!.name
            connectBarButton.title = "연결 해제"
            connectBarButton.tintColor = UIColor.redColor()
        }
    }
    
    
    //MARK: DZBluetoothSerialDelegate
    
    func serialHandlerDidReceiveMessage(message: String) {
        // add the received text to the textView, optionally with a line break at the end
//        mainTextView.text! += serial.read()
//        let pref = NSUserDefaults.standardUserDefaults().integerForKey(ReceivedMessageOptionKey)
//        if pref == ReceivedMessageOption.Newline.rawValue { mainTextView.text! += "\n" }
//        textViewScrollToBottom()
    }
    
    func serialHandlerDidDisconnect(peripheral: CBPeripheral, error: NSError?) {
        reloadView()
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = MBProgressHUDMode.Text
        hud.labelText = "기기와의 연결해제 성공"
        hud.hide(true, afterDelay: 1.0)
    }
    
    func serialHandlerDidChangeState(newState: CBCentralManagerState) {
        if newState != .PoweredOn {
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            hud.mode = MBProgressHUDMode.Text
            hud.labelText = "블루투스가 꺼져 있습니다."
            hud.hide(true, afterDelay: 1.0)
        }
    }
    
    @IBAction func barButtonPressed(sender: AnyObject) {
        if serial.connectedPeripheral == nil {
            performSegueWithIdentifier("ShowScanner", sender: self)
        } else {
            serial.disconnect()
            reloadView()
        }
        
    }
    
    @IBAction func SwitchChanged(sender: UIButton){
        
        var msg : String
        if switchOn == true {
            switchControl.setImage(UIImage(named: "btn_off.png"), forState: UIControlState.Normal)
            msg = "hcp_turnoff";
            switchOn = false;
        } else {
            switchControl.setImage(UIImage(named: "btn_on.png"), forState: UIControlState.Normal)
            msg = "hcp_turnon";
            switchOn = true;
        }
        
        if serial.connectedPeripheral == nil {
            
            let alert = UIAlertController(title: "기기 연결 실패", message: "기기를 먼저 연결 해 주세요.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.Default, handler: { action -> Void in self.dismissViewControllerAnimated(true, completion: nil) }))
            presentViewController(alert, animated: true, completion: nil)
            
            
        }
        
        serial.sendMessageToDevice(msg)
        
    }


}

