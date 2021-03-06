//
//  ViewController.swift
//  UUChatTableViewSwift
//
//  Created by XcodeYang on 8/13/15.
//  Copyright © 2015 XcodeYang. All rights reserved.
//

import UIKit

private let leftCellId = "UUChatLeftMessageCell"
private let rightCellId = "UUChatRightMessageCell"

class ChatTableViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var chatTableView: UITableView!
    var inputBackView: UUInputView!
    var dataArray: [AnyObject]!
    var inputViewConstraint: NSLayoutConstraint? = nil
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardFrameChanged:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    //TODO: This method seems like would fix the problem of cells layout when Orientation changed.
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        //chatTableView.reloadData()
        self.view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataArray = UUChatModel.creatRandomArray(count: 10)
        
        initBaseViews()
        
        
        chatTableView.registerClass(UUChatLeftMessageCell.classForKeyedArchiver(), forCellReuseIdentifier: leftCellId)
        chatTableView.registerClass(UUChatRightMessageCell.classForKeyedArchiver(), forCellReuseIdentifier: rightCellId)
        chatTableView.estimatedRowHeight = 100
        
    }
    
    func initBaseViews() {
        
        self.title = "UUChat - Swift2"
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .Stop, target: self, action: Selector("backAction"))
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .Search, target: self, action: nil)
        
        
        
        inputBackView = UUInputView()
        self.view.addSubview(inputBackView)
        
        //TODO: I don't know how to get constraint from snapkit's methods.
        //It doesn't works.     why.why.why...
        //https://github.com/SnapKit/SnapKit/tree/feature/protocol-api#1-references
        //inputViewConstraint = make.bottom.equalTo(view).constraint
        
        // temporary method
        inputViewConstraint = NSLayoutConstraint(
            item: inputBackView,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1.0,
            constant: 0
        )
        inputBackView.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.equalTo(self.view)
        }
        view.addConstraint(inputViewConstraint!)
        inputBackView.sendMessage(
            imageBlock: { [weak self](image:UIImage, textView:UITextView) -> Void in
                self!.dataArray.append(UUChatModel.creatMessageFromMeByImage(image))
                self!.chatTableView.reloadData()
                self!.chatTableView.scrollToBottom(animation: true)
            },
            textBlock: { [weak self](text:String, textView:UITextView) -> Void in
                self!.dataArray.append(UUChatModel.creatMessageFromMeByText(text))
                self!.chatTableView.reloadData()
                self!.chatTableView.scrollToBottom(animation: true)
            },
            voiceBlock: { [weak self](voice:NSData, textView:UITextView) -> Void in
                
        })
        
        
        
        chatTableView = UITableView.init(frame: CGRectZero, style: .Plain)
        chatTableView.dataSource = self
        chatTableView.delegate = self
        chatTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        chatTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        chatTableView.estimatedRowHeight = 60
        self.view.addSubview(chatTableView)
        chatTableView.snp_makeConstraints { (make) -> Void in
            make.top.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(inputBackView.snp_top)
        }
        chatTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        
    }
    
    // private method
    
    func backAction(){
        if navigationController?.viewControllers.count>1 {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @objc func keyboardFrameChanged(notification: NSNotification) {
        
        let dict = NSDictionary(dictionary: notification.userInfo!)
        let keyboardValue = dict.objectForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let bottomDistance = mainScreenSize().height - keyboardValue.CGRectValue().origin.y
        let duration = Double(dict.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as! NSNumber)
        
        UIView.animateWithDuration(duration, animations: {
            self.inputViewConstraint!.constant = -bottomDistance
            self.view.layoutIfNeeded()
            }, completion: {
                (value: Bool) in
                self.chatTableView.scrollToBottom(animation: true)
        })
    }
    
    private func mainScreenSize() -> CGSize {
        return UIScreen.mainScreen().bounds.size
    }
    
    // tableview delegate & dataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = dataArray[indexPath.row] as! UUChatModel
        if model.from == .Me {
            let cell:UUChatRightMessageCell = tableView.dequeueReusableCellWithIdentifier(rightCellId) as! UUChatRightMessageCell
            cell.configUIWithModel(model)
            return cell
        }
        else {
            let cell:UUChatLeftMessageCell = tableView.dequeueReusableCellWithIdentifier(leftCellId) as! UUChatLeftMessageCell
            cell.configUIWithModel(model)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
    }
    
    // action
    
    @IBAction func sendImage(btn:UIButton) {
        self.view.endEditing(true)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let libraryAction = UIAlertAction(title: "本地相册", style: .Default) { (action:UIAlertAction) -> Void in
            
        }
        let takePhotoAction = UIAlertAction(title: "拍照", style: .Default) { (action:UIAlertAction) -> Void in
            
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(cancelAction)
        alert.addAction(libraryAction)
        alert.addAction(takePhotoAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
}


