//
//  MailboxViewController.swift
//  mailbox
//
//  Created by Jules Walter on 5/19/15.
//  Copyright (c) 2015 Jules Walter. All rights reserved.
//

import UIKit

class MailboxViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var feedView: UIImageView!
    @IBOutlet weak var messageView: UIImageView!
    @IBOutlet weak var rescheduleView: UIImageView!
    @IBOutlet weak var listView: UIImageView!
    @IBOutlet weak var laterIconView: UIImageView!
    @IBOutlet weak var archiveIconView: UIImageView!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var deleteIconView: UIImageView!
    @IBOutlet weak var listIconView: UIImageView!
    @IBOutlet weak var composeView: UIView!
    @IBOutlet weak var composeText: UITextField!
    @IBOutlet weak var laterView: UIView!
    @IBOutlet weak var archiveView: UIView!
    
    let yellowColor = UIColor(red: 254/255, green: 202/255, blue: 22/255, alpha: 1)
    let redColor = UIColor(red: 231/255, green: 61/255, blue: 14/255, alpha: 1)
    let greenColor = UIColor(red: 85/255, green: 213/255, blue: 80/255, alpha: 1)
    let brownColor = UIColor(red: 206/255, green: 150/255, blue: 98/255, alpha: 1)
    let grayColor = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1)
    
    var messageOrigin: CGPoint!
    var archivePosition: CGPoint!
    var laterPosition: CGPoint!
    var iconOffset: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //Set scrollview content
        scrollView.contentSize.width = feedView.image!.size.width
        scrollView.contentSize.height = feedView.image!.size.height + messageView.image!.size.height
        
        laterPosition = CGPoint(x: -320, y: self.messageView.frame.origin.y)
        archivePosition = CGPoint(x: 320, y: self.messageView.frame.origin.y)
        messageOrigin = messageView.frame.origin
        
        laterIconView.alpha = 0
        archiveIconView.alpha = 0
        listIconView.alpha = 0
        deleteIconView.alpha = 0
        laterView.alpha = 0
        archiveView.alpha = 0
        
        iconOffset = 40
        
        //edgeGesture
        var edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: "onEdgePan:")
        edgeGesture.edges = UIRectEdge.Left
        containerView.addGestureRecognizer(edgeGesture)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        println("motion detected")
        undo()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCustomPan(sender: UIPanGestureRecognizer) {
        var point = sender.locationInView(view)
        var velocity = sender.velocityInView(view)
        var translation = sender.translationInView(view)
        
        if sender.state == UIGestureRecognizerState.Began{
            
        }
        else if sender.state == UIGestureRecognizerState.Changed{
            
            messageView.frame.origin = CGPoint(x: messageOrigin.x + translation.x, y: messageView.frame.origin.y)
            
            //Swipe right
            laterIconView.frame.origin.x = messageView.frame.origin.x + messageView.frame.width - laterIconView.frame.width + iconOffset
            listIconView.frame.origin.x = messageView.frame.origin.x + messageView.frame.width - listIconView.frame.width + iconOffset
            
            //Swipe left
            archiveIconView.frame.origin.x = messageView.frame.origin.x - iconOffset
            deleteIconView.frame.origin.x = messageView.frame.origin.x - iconOffset
            
            //Swipe right
            if velocity.x > 0 {
                laterIconView.alpha = 0
                listIconView.alpha = 0
                
                if translation.x < 60 {
                    messageContainerView.backgroundColor = grayColor
                    archiveIconView.alpha = convertValue(translation.x, r1Min: 0, r1Max: 60, r2Min: 0, r2Max: 1)
                } else if translation.x >= 60 && translation.x < 260 {
                    messageContainerView.backgroundColor = greenColor
                    archiveIconView.alpha = 1
                    deleteIconView.alpha = 0
                } else if translation.x > 260{
                    messageContainerView.backgroundColor = redColor
                    archiveIconView.alpha = 0
                    deleteIconView.alpha = 1
                }
            }
                
                //Swipe left
            else if velocity.x < 0 {
                archiveIconView.alpha = 0
                deleteIconView.alpha = 0
                
                if translation.x > -60{
                    messageContainerView.backgroundColor = grayColor
                    laterIconView.alpha = convertValue(translation.x, r1Min: -60, r1Max: 0, r2Min: 1, r2Max: 0)
                } else if translation.x <= -60 && translation.x > -260 {
                    messageContainerView.backgroundColor = yellowColor
                    laterIconView.alpha = 1
                    listIconView.alpha = 0
                } else if translation.x <= -260{
                    messageContainerView.backgroundColor = brownColor
                    laterIconView.alpha = 0
                    listIconView.alpha = 1
                }
            }
        }
            
        else if sender.state == UIGestureRecognizerState.Ended {

            //Swipe right
            if velocity.x > 0 {
                if translation.x < 60{
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.messageView.frame.origin = self.messageOrigin
                })
                } else if translation.x >= 60 && translation.x < 260 {
                    archive()
                } else if translation.x >= 260 {
                    delete()
                }
            }
                
                //Swipe left
            else if velocity.x < 0 {
                if translation.x > -60 {
                    //animate back to original location
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.messageView.frame.origin = self.messageOrigin
                    })
                } else if translation.x <= -60 && translation.x > -260 {
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.messageView.frame.origin = self.laterPosition
                        self.laterIconView.frame.origin.x = self.laterPosition.x + self.iconOffset
                    }, completion: { (Bool) -> Void in
                        self.rescheduleView.alpha = 1
                        self.removeMessage()
                    })

                } else if translation.x < -260 {
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.messageView.frame.origin = self.laterPosition
                        self.listIconView.frame.origin.x = self.laterPosition.x + self.iconOffset
                        }, completion: { (Bool) -> Void in
                            self.listView.alpha = 1
                            self.removeMessage()
                    })
                }
            }
        }
    }
    
    func archive(){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.messageView.frame.origin = self.archivePosition
            self.archiveIconView.frame.origin.x = self.archivePosition.x - self.iconOffset
            }, completion: { (Bool) -> Void in
                self.removeMessage()
        })
    }
    
    func delete(){
        archive()
    }
    
    func removeMessage(){
        self.scrollView.frame.origin.y -= self.messageView.frame.height
        self.messageView.frame.origin = messageOrigin
    }
    
    @IBAction func onTap(sender: UITapGestureRecognizer){
        sender.view!.alpha = 0
    }
    
    func onEdgePan(sender: UIScreenEdgePanGestureRecognizer){
        var translation = sender.translationInView(view)
        var velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Changed{
            containerView.frame.origin = CGPoint(x: translation.x, y: containerView.frame.origin.y)
        } else if sender.state == UIGestureRecognizerState.Ended{
            if velocity.x > 0 {
                containerView.frame.origin = CGPoint(x: 280, y: containerView.frame.origin.y)
            } else if velocity.x < 0 {
                containerView.frame.origin = CGPoint(x: 0, y: containerView.frame.origin.y)
            } else if velocity.x < 0 {
                containerView.frame.origin = CGPoint(x: 0, y: containerView.frame.origin.y)
            }
            
        }
    }
    
    @IBAction func didDismissMenu(sender: UITapGestureRecognizer) {
        containerView.frame.origin = CGPoint(x: 0, y: containerView.frame.origin.y)
    }

    func undo() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.scrollView.frame.origin.y += self.messageView.frame.height
        })
    }
    
    func convertValue(value: CGFloat, r1Min: CGFloat, r1Max: CGFloat, r2Min: CGFloat, r2Max: CGFloat) -> CGFloat {
        var ratio = (r2Max - r2Min) / (r1Max - r1Min)
        return value * ratio + r2Min - r1Min * ratio
    }
    
    
    @IBAction func didcancelCompose(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //
        }
        alertController.addAction(cancelAction)
        
        let deleteDraftAction = UIAlertAction(title: "Delete Draft", style: .Default) { action -> Void in
            self.composeText.resignFirstResponder()
            self.composeView.frame.origin = CGPoint(x: 0, y: 568)
            

        }
        alertController.addAction(deleteDraftAction)
        
        let keepDraftAction = UIAlertAction(title: "Keep Draft", style: .Default) { action -> Void in
            //
        }
        alertController.addAction(keepDraftAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    @IBAction func didCompose(sender: AnyObject) {
        self.composeView.frame.origin = CGPoint(x: 0, y: -116)
        composeText.becomeFirstResponder()
    }
    
    @IBAction func goToMailbox(sender: AnyObject) {
        laterView.frame.origin.x = 320
        archiveView.frame.origin.x = -320
        laterView.alpha = 0
        archiveView.alpha = 0
    }
    
    @IBAction func goToArchive(sender: AnyObject) {
        archiveView.alpha = 1
        laterView.alpha = 0
        archiveView.frame.origin.x = 0
        laterView.frame.origin.x = 320
    }
    
    @IBAction func goToLater(sender: AnyObject) {
        laterView.alpha = 1
        archiveView.alpha = 0
        laterView.frame.origin.x = 0
        archiveView.frame.origin.x = -320
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0: goToArchive(sender)
        case 1: break;
        case 2: goToLater(sender)
        default: break;
        }
    }

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
