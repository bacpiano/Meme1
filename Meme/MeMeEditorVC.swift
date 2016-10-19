//
//  MeMeEditorVC.swift
//  Meme
//
//  Created by Adrian Borcea on 06/09/2016.
//  Copyright © 2016 Adrian Borcea. All rights reserved.
//

import UIKit


class MeMeEditorVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {

    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var txtTop: UITextField!
    @IBOutlet weak var btnShare: UIBarButtonItem!
    @IBOutlet weak var txtBottom: UITextField!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnAlbum: UIBarButtonItem!
    @IBOutlet weak var btnCamera: UIBarButtonItem!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let style = NSMutableParagraphStyle()
        style.alignment = .Center
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 25)!,
            NSStrokeWidthAttributeName :-1.0,
            NSParagraphStyleAttributeName:style
        ]
        
        txtTop.defaultTextAttributes=memeTextAttributes
        txtBottom.defaultTextAttributes=memeTextAttributes
        btnShare.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        
         btnCamera.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        addNotificationForKeyboard()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        removeKeyboardNotifications()
        super.viewWillDisappear(animated)
    }

    func addNotificationForKeyboard() -> Void {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MeMeEditorVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MeMeEditorVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotifications() -> Void {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) -> Void {
        
    
        if txtBottom.isFirstResponder() {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
        
    }
    func keyboardWillHide(notification: NSNotification) -> Void {
        
        if txtBottom.isFirstResponder() {
            view.frame.origin.y = 0
        }
        
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        
        let userinfo = notification.userInfo
        let keyboardSize = userinfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }

    @IBAction func pickImageFromPhoto(sender: AnyObject) {
        
        pickImage(false)
    }
    
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        
        pickImage(true)
    }
    
    func pickImage(isCamera: Bool) -> Void {
        
        let picker=UIImagePickerController()
        picker.delegate = self
        
        if isCamera {
            
            picker.sourceType = UIImagePickerControllerSourceType.Camera
        }
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
           if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imgView.image = image
            btnShare.enabled = true
            dismissViewControllerAnimated(true, completion: nil)
           }
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        let defaultText:String
        
        if textField == txtTop {
            
            defaultText="TOP"
        }else{
            
            defaultText="BOTTOM"
        }
        
        if let text = textField.text where text == defaultText {
            
            textField.text=""
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func save() {
        
        let memedImage = generateMemedImage()
        let meme = MeMe(topText: txtTop.text! , bottomText:txtBottom.text!, originalImage: imgView.image!, memedImage: memedImage)
        print("\(meme)")
        
    }
    
    func generateMemedImage() -> UIImage
    {
        
        bottomToolBar.hidden = true
        navigationController?.navigationBar.hidden = true
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame,
                                     afterScreenUpdates: true)
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        bottomToolBar.hidden = false
        navigationController?.navigationBar.hidden = false
        
        return memedImage
    }

    @IBAction func shareBtnPressed(sender: AnyObject) {
        
        let memedImage = generateMemedImage()
        
        let objectsToShare = [memedImage]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = {
            (activity, success, items, error) in
           
            if success{
                self.save()
            }
            
        }
        activityVC.popoverPresentationController?.sourceView = sender as? UIButton
        presentViewController(activityVC, animated: true, completion: nil)
    }
}

