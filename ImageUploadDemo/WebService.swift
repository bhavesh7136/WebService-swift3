//
//  Webservice.swift
//  ImageUploadDemo
//
//  Created by Pragnesh Dixit on 14/03/17.
//  Copyright © 2017 Pragnesh Dixit. All rights reserved.
//

import UIKit
let WEBSERVICE_URL = "http://google.com"

typealias ResponseReceivedSuccessfully = (_ dict:Dictionary<String, Any>?)->Void
typealias ResponseFail = (_ error:NSError?)->Void
typealias DataRateProgress = (_ progressInPercent:Float)->Void

class WebService: NSObject ,URLSessionDelegate,URLSessionDataDelegate,URLSessionTaskDelegate {
    private  var responseSuccessful:ResponseReceivedSuccessfully?
    private  var responseFail:ResponseFail?
    private  var progressblock:DataRateProgress?
    public  var mutableData:NSMutableData?
    private var expectedContentLength: Int64?
    public var Busy:Bool!
    private var encryptionOn:Bool!;
    
    func callGetWebServiceUsingURL(url:NSURL,onSuccessfulResponse:@escaping (_ dict:Dictionary<String, Any>?)->(),onFailResponse:@escaping (_ error:NSError?)->()){
        
        self.cancelWebservice();
        responseSuccessful = onSuccessfulResponse;
        responseFail = onFailResponse;
        Busy = true;
        mutableData = NSMutableData();
        let configration = URLSessionConfiguration.default
        let session = URLSession(configuration: configration, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: url as URL)
        task.resume()
        encryptionOn = false;
        
        
        let newSession = URLSession.shared
        let newTask = newSession.dataTask(with: url as URL) { (data,response, error) in
            if error != nil {
                print(error?.localizedDescription ?? "no description found")
                
                
            } else {
                
                
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                //                print(dataString as Any)
                let dict:  [String: Any] = self.getJsonDictFromString(text: dataString! as String)! as [String: Any]
                self.responseSuccessful!(dict)
            }
        }
        newTask.resume()
        
    }
    func callJSONMethod_WithData(method: String, parametar: NSMutableDictionary, imageData: Data,attachmentKey:NSString,filename:NSString,isEncrpyted:Bool,onSuccessfulResponse:@escaping (_ dict:Dictionary<String, Any>?)->(),onFailResponse:@escaping (_ error:NSError?)->(),onProgressResponse:@escaping (_ progressInPercent:Float)->())->Void {
        
        Busy = true;
        self.cancelWebservice()
        responseSuccessful=onSuccessfulResponse;
        responseFail=onFailResponse;
        progressblock=onProgressResponse;
        encryptionOn=isEncrpyted;
        var url = URL(string:WEBSERVICE_URL )!
        if(encryptionOn  == false){
            url = URL(string:WEBSERVICE_URL )!
        }
        else
        {
            
        }
        let body:NSMutableData=NSMutableData()
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let boundry:NSString="---------------------------14737809831466499882746641449"
        let contentType:NSString=NSString(format: "multipart/form-data; boundary=%@", boundry)
        request .setValue(contentType as String, forHTTPHeaderField: "Content-Type")
        //====
        let requestDict = NSMutableDictionary()
        requestDict["method_name"] = method
        requestDict["body"] = parametar
        
        let jsonString:NSString=self.getJsonFromDictionary(dictData: requestDict)
        //=========
        var strRequest:NSString=NSString()
        strRequest = jsonString;
        print(strRequest )
        
        let data=strRequest.data(using: String.Encoding.utf8.rawValue)
        body.append(NSString(format:"--%@\r\n", boundry).data(using: String.Encoding.utf8.rawValue)!)
        let paramsFormat:NSString = NSString(format:"Content-Disposition: form-data; name=\"%@\"\r\n\r\n","json")
        body.append(paramsFormat.data(using: String.Encoding.utf8.rawValue)!)
        body.append(data!)
        body.append(NSString(format:"\r\n").data(using: String.Encoding.utf8.rawValue)!)
        
        // file
        body.append(NSString(format:"--%@\r\n", boundry).data(using: String.Encoding.utf8.rawValue)!)
        //        body.append(NSString(format:"Content-Disposition: attachment; name=\"pi_uploaded_image\"; filename=\"temp.png\"\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"Content-Disposition: attachment; name=\"%@\"; filename=\"%@\"\r\n",attachmentKey,filename).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"Content-Type: application/octet-stream\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSData(data: imageData as Data) as Data)
        body.append(NSString(format:"\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"--%@--\r\n",boundry).data(using: String.Encoding.utf8.rawValue)!)
        
        request.httpBody=body as Data
        mutableData = NSMutableData();
        
        let configration = URLSessionConfiguration.default
        let session = URLSession(configuration: configration, delegate: self, delegateQueue: OperationQueue.main)
//        let task = session.dataTask(with: request as URLRequest)
//        task.resume()
        
//        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response, error == nil else {
                print("*****error")
                self.responseFail!(error as NSError?)
                return
            }
            
            DispatchQueue.main.async {
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                if dataString is String{
                    //                    print(dataString as Any)
                    //                    let dict:  [String: Any] = self.getJsonDictFromString(text: dataString! as String)! as [String: Any]
                    //                    self.responseSuccessful!(dict)
                    
                    var returnString=NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)
                    returnString = returnString?.replacingOccurrences(of: "__u0022__", with: "''") as NSString?
                    returnString = returnString?.replacingOccurrences(of: "__u0026__", with: "&") as NSString?
                    returnString = returnString?.replacingOccurrences(of: "__u000a__", with: "\\n") as NSString?
                    
                    print("========")
                    print(returnString as Any)
                    print("========")
                    var obj:AnyObject?
                    let dict:  [String: Any]?
                    //        let dict:  [String: Any] = self.getJsonDictFromString(text: returnString! as String)! as [String: Any]
                    obj = self.getJsonDictFromString(text: returnString! as String) as AnyObject?
                    if(obj is Dictionary<String, Any>){
                                    dict = (obj as! NSDictionary) as? [String : Any]
                      
                    }
                    else{
                        dict = Dictionary<String,Any>()
                    }
                    //        let dictnew =  instanc
                    if ((self.mutableData) != nil){
                        self.mutableData = nil;
                        self.mutableData?.length=0;
                    }
                    //        if((conn) != nil){
                    //            conn?.cancel()
                    //            conn = nil;
                    //        }
                    self.responseSuccessful!(dict)
                }
                
            }
        }
        task.resume()
    }

    func callJSONMethod_WithData(method: String, parametar: NSMutableDictionary, imageData: Data,videoData: Data,attachmentKey:NSString,filename:NSString,isEncrpyted:Bool,onSuccessfulResponse:@escaping (_ dict:Dictionary<String, Any>?)->(),onFailResponse:@escaping (_ error:NSError?)->(),onProgressResponse:@escaping (_ progressInPercent:Float)->())->Void {
        
        Busy = true;
        self.cancelWebservice()
        responseSuccessful=onSuccessfulResponse;
        responseFail=onFailResponse;
        progressblock=onProgressResponse;
        encryptionOn=isEncrpyted;
        var url = URL(string:WEBSERVICE_URL )!
        if(encryptionOn  == false){
            url = URL(string:WEBSERVICE_URL )!
        }
        else
        {
            
        }
        let body:NSMutableData=NSMutableData()
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let boundry:NSString="---------------------------14737809831466499882746641449"
        let contentType:NSString=NSString(format: "multipart/form-data; boundary=%@", boundry)
        request .setValue(contentType as String, forHTTPHeaderField: "Content-Type")
        //====
        let requestDict = NSMutableDictionary()
        requestDict["method_name"] = method
        requestDict["body"] = parametar
        
        let jsonString:NSString=self.getJsonFromDictionary(dictData: requestDict)
        //=========
        var strRequest:NSString=NSString()
        strRequest = jsonString;
        print(strRequest )
        
        let data=strRequest.data(using: String.Encoding.utf8.rawValue)
        body.append(NSString(format:"--%@\r\n", boundry).data(using: String.Encoding.utf8.rawValue)!)
        let paramsFormat:NSString = NSString(format:"Content-Disposition: form-data; name=\"%@\"\r\n\r\n","json")
        body.append(paramsFormat.data(using: String.Encoding.utf8.rawValue)!)
        body.append(data!)
        body.append(NSString(format:"\r\n").data(using: String.Encoding.utf8.rawValue)!)
        
        if ((imageData) != nil) {
            
            // Image file
            body.append(NSString(format:"--%@\r\n", boundry).data(using: String.Encoding.utf8.rawValue)!)
            body.append(NSString(format:"Content-Disposition: form-data; filetype=\"image/png\"; name=\"%@\"; filename=\"temp.png\"\r\n",attachmentKey).data(using: String.Encoding.utf8.rawValue)!)
            
            body.append(NSString(format:"Content-Type: application/octet-stream\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
            body.append(NSData(data: imageData as Data) as Data)
            body.append(NSString(format:"\r\n").data(using: String.Encoding.utf8.rawValue)!)
            
        }
        
        if ((videoData) != nil) {
            
            // Video file
            body.append(NSString(format:"--%@\r\n", boundry).data(using: String.Encoding.utf8.rawValue)!)
            body.append(NSString(format:"Content-Disposition: form-data;filetype=\"video/mp4\"; name=\"pi_uploaded_Video\"; filename=\"temp.mp4\"\r\n").data(using: String.Encoding.utf8.rawValue)!)
            body.append(NSString(format:"Content-Type: application/octet-stream\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
            body.append(NSData(data: videoData as Data) as Data)
            body.append(NSString(format:"\r\n").data(using: String.Encoding.utf8.rawValue)!)
            
        }
        
        
        
        body.append(NSString(format:"--%@--\r\n",boundry).data(using: String.Encoding.utf8.rawValue)!)
        
        request.httpBody=body as Data
        mutableData = NSMutableData();
        
        let configration = URLSessionConfiguration.default
        let session = URLSession(configuration: configration, delegate: self, delegateQueue: OperationQueue.main)
//
//        let task = session.dataTask(with: request as URLRequest)
//        task.resume()
//        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response, error == nil else {
                print("*****error")
                self.responseFail!(error as NSError?)
                return
            }
            
            DispatchQueue.main.async {
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                if dataString is String{
                    //                    print(dataString as Any)
                    //                    let dict:  [String: Any] = self.getJsonDictFromString(text: dataString! as String)! as [String: Any]
                    //                    self.responseSuccessful!(dict)
                    
                    var returnString=NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)
                    returnString = returnString?.replacingOccurrences(of: "__u0022__", with: "''") as NSString?
                    returnString = returnString?.replacingOccurrences(of: "__u0026__", with: "&") as NSString?
                    returnString = returnString?.replacingOccurrences(of: "__u000a__", with: "\\n") as NSString?
                    
                    print("========")
                    print(returnString as Any)
                    print("========")
                    var obj:AnyObject?
                    let dict:  [String: Any]?
                    //        let dict:  [String: Any] = self.getJsonDictFromString(text: returnString! as String)! as [String: Any]
                    obj = self.getJsonDictFromString(text: returnString! as String) as AnyObject?
                    if(obj is Dictionary<String, Any>){
                                    dict = (obj as! NSDictionary) as? [String : Any]
                       
                    }
                    else{
                        dict = Dictionary<String,Any>()
                    }
                    //        let dictnew =  instanc
                    if ((self.mutableData) != nil){
                        self.mutableData = nil;
                        self.mutableData?.length=0;
                    }
                    //        if((conn) != nil){
                    //            conn?.cancel()
                    //            conn = nil;
                    //        }
                    self.responseSuccessful!(dict)
                }
                
            }
        }
        task.resume()
    }

    func callJSONMethod(method: String, parametar: NSMutableDictionary,isEncrpyted:Bool,onSuccessfulResponse:@escaping (_ dict:Dictionary<String, Any>?)->(),onFailResponse:@escaping (_ error:NSError?)->())->Void {
        
        Busy = true;
        self.cancelWebservice()
        responseSuccessful=onSuccessfulResponse;
        responseFail=onFailResponse;
        encryptionOn=isEncrpyted;
        var url = URL(string:WEBSERVICE_URL )!
        if(encryptionOn  == false){
            url = URL(string:WEBSERVICE_URL )!
        }
        else
        {
            
        }
        let body:NSMutableData=NSMutableData()
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let boundry:NSString="---------------------------14737809831466499882746641449"
        let contentType:NSString=NSString(format: "multipart/form-data; boundary=%@", boundry)
        request .setValue(contentType as String, forHTTPHeaderField: "Content-Type")
        //====
        let requestDict = NSMutableDictionary()
        requestDict["method_name"] = method
        requestDict["body"] = parametar
        
        let jsonString:NSString=self.getJsonFromDictionary(dictData: requestDict)
        //=========
        var strRequest:NSString=NSString()
        strRequest = jsonString;
        print(strRequest )
        
        let data=strRequest.data(using: String.Encoding.utf8.rawValue)
        body.append(NSString(format:"--%@\r\n", boundry).data(using: String.Encoding.utf8.rawValue)!)
        let paramsFormat:NSString = NSString(format:"Content-Disposition: form-data; name=\"%@\"\r\n\r\n","json")
        body.append(paramsFormat.data(using: String.Encoding.utf8.rawValue)!)
        body.append(data!)
        body.append(NSString(format:"\r\n").data(using: String.Encoding.utf8.rawValue)!)
        request.httpBody=body as Data
        mutableData = NSMutableData();
        
        let configration = URLSessionConfiguration.default
        let session = URLSession(configuration: configration, delegate: self, delegateQueue: OperationQueue.main)
//        let task = session.dataTask(with: request as URLRequest)
//        task.resume()
//        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response, error == nil else {
                print("*****error")
                self.responseFail!(error as NSError?)
                return
            }
            
            DispatchQueue.main.async {
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                if dataString is String{
//                    print(dataString as Any)
//                    let dict:  [String: Any] = self.getJsonDictFromString(text: dataString! as String)! as [String: Any]
//                    self.responseSuccessful!(dict)
            
                    var returnString=NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)
                    returnString = returnString?.replacingOccurrences(of: "__u0022__", with: "''") as NSString?
                    returnString = returnString?.replacingOccurrences(of: "__u0026__", with: "&") as NSString?
                    returnString = returnString?.replacingOccurrences(of: "__u000a__", with: "\\n") as NSString?
                    
                    print("========")
                    print(returnString as Any)
                    print("========")
                    var obj:AnyObject?
                    let dict:  [String: Any]?
                    //        let dict:  [String: Any] = self.getJsonDictFromString(text: returnString! as String)! as [String: Any]
                    obj = self.getJsonDictFromString(text: returnString! as String) as AnyObject?
                    if(obj is Dictionary<String, Any>){
                                    dict = (obj as! NSDictionary) as? [String : Any]
                        
                    }
                    else{
                        dict = Dictionary<String,Any>()
                    }
                    //        let dictnew =  instanc
                    if ((self.mutableData) != nil){
                        self.mutableData = nil;
                        self.mutableData?.length=0;
                    }
                    //        if((conn) != nil){
                    //            conn?.cancel()
                    //            conn = nil;
                    //        }
                    self.responseSuccessful!(dict)
                }
                
            }
        }
        task.resume()
        
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Busy = false;
        if ((mutableData) != nil){
            mutableData?.length=0;
            mutableData = nil;
        }
        //        if((conn) != nil){
        //            conn?.cancel()
        //            conn = nil;
        //        }
        print(error)
        responseFail!(error as NSError?)
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64){
        if (self.progressblock != nil) {
            let uploadbyte = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
            //        self.progressView.progress = uploadbyte
            let percent = (Float(uploadbyte * 100))
            self.progressblock!(Float(percent))
        }
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void){
        
        let disposition: URLSession.ResponseDisposition = .allow
        expectedContentLength = response.expectedContentLength
        completionHandler(disposition)
        
        
    }
    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Swift.Void) {
        print("rep: \(response)")
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data){
        mutableData?.append(data as Data);
        print(mutableData?.length as Any)
        if ((mutableData?.length) != nil) {
            let returnString = NSString(data: mutableData! as Data, encoding: String.Encoding.utf8.rawValue)
            print(returnString as Any)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void){
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if ("www.estatemate.co.za" == challenge.protectionSpace.host) {
                challenge.sender?.use(URLCredential(trust: challenge.protectionSpace.serverTrust!), for: challenge)
            }
        }
        challenge.sender?.continueWithoutCredential(for: challenge)
    }
    
    
//    optional public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Swift.Void)
    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    willCacheResponse proposedResponse: CachedURLResponse,
                    completionHandler: @escaping (CachedURLResponse?) -> Swift.Void){
        if ((mutableData?.length) != nil) {
            Busy = false;
            var returnString=NSString(data: mutableData! as Data, encoding: String.Encoding.utf8.rawValue)
            returnString = returnString?.replacingOccurrences(of: "__u0022__", with: "''") as NSString?
            returnString = returnString?.replacingOccurrences(of: "__u0026__", with: "&") as NSString?
            returnString = returnString?.replacingOccurrences(of: "__u000a__", with: "\\n") as NSString?
            
            print("========")
            print(returnString as Any)
            print("========")
            var obj:AnyObject?
            let dict:  [String: Any]?
            //        let dict:  [String: Any] = self.getJsonDictFromString(text: returnString! as String)! as [String: Any]
            obj = self.getJsonDictFromString(text: returnString! as String) as AnyObject?
            if(obj is Dictionary<String, Any>){
                            dict = (obj as! NSDictionary) as? [String : Any]
          
            }
            else{
                dict = Dictionary<String,Any>()
            }
            //        let dictnew =  instanc
            if ((mutableData) != nil){
                mutableData = nil;
                mutableData?.length=0;
            }
            //        if((conn) != nil){
            //            conn?.cancel()
            //            conn = nil;
            //        }
            responseSuccessful!(dict)
        }
       
    }
    func cancelWebservice() ->Void{
        Busy = false;
        if ((mutableData) != nil){
            mutableData?.length=0;
            mutableData = nil;
        }
        //        if((conn) != nil){
        //            conn?.cancel()
        //            conn = nil;
        //        }
    }
    
    deinit {
        if ((mutableData) != nil){
            mutableData?.length=0;
            mutableData = nil;
        }
        //        if((conn) != nil){
        //            conn?.cancel()
        //            conn = nil;
        //        }
    }
    
    func getJsonDictFromString(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    func getJsonFromDictionary(dictData:NSDictionary)->NSString{
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictData, options: .prettyPrinted)
            
            if let json = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
                return json
            }
            else
            {
                return "Not Found"
            }
        } catch {
            print(error.localizedDescription)
            return "Error"
        }
    }
    // MARK: - Recability Method
//    func isConnectedToNetwork() -> Bool {
//        
//        if (currentReachabilityStatus == ReachabilityStatus.reachableViaWiFi)
//        {
//            return true
//        }
//        else if (currentReachabilityStatus == ReachabilityStatus.reachableViaWWAN)
//        {
//            return true
//        }
//        else
//        {
//            return false
//        }
//    }
//    func showNoNetworkAlert() -> Void {
//        let alertWarning = UIAlertView(title: Constant.APP_NAME, message: "Please check internet connection." , delegate: nil, cancelButtonTitle: "Ok")
//        alertWarning.show()
//    }
}
