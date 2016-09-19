//
//  DetailViewController.swift
//  Stopgapp
//
//  Created by Grant on 12/21/14.
//  Copyright (c) 2014 GRANTGOLDEN. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    var detailPost: Post?{
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        

        if let i = imageView{
            let imgPath = detailPost?.mediaURL
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                
                var getImage: UIImage?
                
                if let path = imgPath{
                    getImage =  UIImage(data: NSData(contentsOfURL: NSURL(string: imgPath!)!)!)
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    i.image = getImage
                    return
                }
            }
            
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView(){
        self.title = detailPost?.title
    }
    
    func postComment(){
        let dynamoDB: AWSDynamoDB = AWSDynamoDB.defaultDynamoDB()
        
        let time = AWShelper.currentTime()
        
        var newTableRow: DDBCommentRow = DDBCommentRow()
        newTableRow.PostID = detailPost?.postID
        newTableRow.CommentID = AWShelper.generateUuidString()
        newTableRow.Time = time
        newTableRow.Score = NSNumber(integer: 1)
        newTableRow.Content = "comment"
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
