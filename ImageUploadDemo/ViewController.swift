//
//  ViewController.swift
//  ImageUploadDemo
//
//  Created by Pragnesh Dixit on 11/03/17.
//  Copyright © 2017 Pragnesh Dixit. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var btnUpload: UIButton!
    @IBOutlet weak var ivUpload: UIImageView!
    
    var service = WebService()
    //============
    
    //    private var totalBytesReceived: Int64 = 0
    //    private var mutableData: Data
    
    
    
    // MARK: Lifecycle
    
    
    
    
    //============
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dictParam = NSMutableDictionary()
        dictParam["login_with"] = "1"
        dictParam["deviceToken"] = ""
        let imgData = NSData()
        service.callJSONMethod_WithData(method: "login", parametar: dictParam, imageData: imgData as Data, attachmentKey: "image_url", filename: "temp.png",isEncrpyted: false, onSuccessfulResponse: {(_ dict :Dictionary<String, Any>?) in
            //            self.hideActivityView()
            if !(dict?.isEmpty)! {
                if dict?["status"] as! String == "1" {
                    let dictData = dict?["data"] as! NSDictionary
                    let dictMutable = NSMutableDictionary.init(dictionary: dictData)
                    for (_, element) in dictMutable.allKeys.enumerated() {
                        let tmpValue = dictMutable[element]
                        if (tmpValue is NSNull) {
                            dictMutable[element] = ""
                        }
                    }
                    
                }
                
            }
            
        }, onFailResponse: { (_ error : NSError?) in
            
            //            self.hideActivityView()
            //            Constant.showAlertWithOkButton(strMsg: error?.localizedDescription)
            
        }, onProgressResponse: { (_ flt : Float) in
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnUploadAction(_ sender: Any) {
        let imagepicker = UIImagePickerController()
        imagepicker.delegate = self
        imagepicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagepicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.ivUpload.image = info[UIImagePickerControllerOriginalImage
            ] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        let imagedata = UIImageJPEGRepresentation(ivUpload.image!, 1)
        if imagedata == nil {
            return
        }
        
        let dict = NSMutableDictionary()
        dict["repairImg"] = "repairImg"
        // Do any additional setup after loading the view, typically from a nib.
        
        service.callJSONMethod_WithData(method: "uploadVehicleRepairImg", parametar: dict, imageData: imagedata!, attachmentKey: "repairImg", filename: "temp.png",isEncrpyted: false, onSuccessfulResponse: {(_ dict :Dictionary<String, Any>?) in
            if !(dict?.isEmpty)! {
                if dict?["status"] as! String == "1" {
                    let dictData = dict?["data"] as! Dictionary<String,Any>
                    print(dictData)
                }
            }
        }, onFailResponse: {(_ err: NSError?) -> () in
            //            let alertWarning = UIAlertView(title: APP_NAME, message: err?.localizedDescription , delegate: nil, cancelButtonTitle: "OK")
            //            alertWarning.show()
        }, onProgressResponse: { (_ progress:Float?) in
            print("uploading ==",progress ?? "")
        })
        
        //        self.uploadImage(method: "getVehicleInformation", parametar: dict, imageData: imagedata!, attachmentKey: "pi_uploaded_image", filename: "temp.png")
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
}

