//
//  EditPostViewController.swift
//  Stopgapp
//
//  Created by Grant on 12/31/14.
//  Copyright (c) 2014 GRANTGOLDEN. All rights reserved.
//

import UIKit
import CoreLocation

class EditPostViewController: UIViewController, UIAlertViewDelegate, NSURLConnectionDataDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    var queryData: NSMutableData?
    
    var lat: Double?
    var long: Double?
    
    
    func configureView(){
        if let pImage = image{
            imageView.image = pImage
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
        
        // Do any additional setup after loading the view.
    }

    @IBAction func postButtonPressed(sender: AnyObject) {
        if objc_getClass("UIAlertController") != nil { //ios 8

            let alert = UIAlertController(title: "Error", message: "Enter data in Text fields", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            //make and use a UIAlertController
            
        }else { //ios 7
            let alert = UIAlertView()
            alert.title = "Set Title"
            alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
            alert.addButtonWithTitle("Cancel")
            alert.addButtonWithTitle("Post")
            alert.delegate = self
            alert.show()
            //make and use a UIAlertView
        }
        
    }
    
    //ios 7
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        let s = alertView.buttonTitleAtIndex(buttonIndex)
        
        if s == "Post"{
            let t = alertView.textFieldAtIndex(0)?.text
            self.makePost(t!)
        }
    }
    
    func makePost(title: String){
        let postID = AWShelper.uploadPhoto(image)
        
        var requestDictionary:NSDictionary = [
            "action" : "put-point",
            "request" : [
                "lat" : NSNumber(double: lat!),
                "lng" : NSNumber(double: long!),
                "rangeKey" : postID
            ]
        ];
        self.sendRequest(requestDictionary)
        
        self.createDynamoEntry(postID, title: title)
        
        self.performSegueWithIdentifier("postMadeSegue", sender: self)

        //let post = Post(title: <#String#>, mediaURL: <#String#>, thumbnailURL: <#String#>)
    }
    
    func createDynamoEntry(postID: NSString, title: NSString){
        let dynamoDB: AWSDynamoDB = AWSDynamoDB.defaultDynamoDB()
        /*
@property (nonatomic, assign) NSString *PostID;
@property (nonatomic, strong) NSString *Time;
@property (nonatomic, strong) NSNumber *Score;
@property (nonatomic, strong) NSString *UserID;
@property (nonatomic, strong) NSString *Title;
*/
        
        let time = AWShelper.currentTime()
        
        var newTableRow: DDBTableRow = DDBTableRow()
        newTableRow.PostID = postID
        newTableRow.Time = time
        newTableRow.Score = NSNumber(integer: 1)
        newTableRow.Title = title
        newTableRow.UserID = "grant"
        
        let objectMapper: AWSDynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        objectMapper.save(newTableRow).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock:{ [unowned self]
            task -> AnyObject in
            
            
            if(task.error != nil){
                NSLog("%@", task.error);
            }else{
                NSLog("success");
            }

            return "done";
        })
    }
    
    func sendRequest(requestDictionary: NSDictionary){

        var url:NSURL = NSURL(string: AWSElasticBeanstalkEndpoint)!
        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 120.0)
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestDictionary, options: NSJSONWritingOptions.allZeros, error: nil)
        request.HTTPMethod = "POST"
        let conn = NSURLConnection(request: request, delegate: self)!
        
        self.queryData = NSMutableData()
        
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.queryData?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
