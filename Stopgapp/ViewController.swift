//
//  ViewController.swift
//  Stopgapp
//
//  Created by Grant on 12/21/14.
//  Copyright (c) 2014 GRANTGOLDEN. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, NSURLConnectionDataDelegate{
    @IBOutlet weak var tableView: UITableView!
    
    let AWSRadiusInMeter = 16000

    var postsArray: [Post] = [Post]()
    
    var locationManager:CLLocationManager?
    
    var lat: Double?
    var long: Double?
    
    var queryData: NSMutableData?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()
    
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControllerFired:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func refreshControllerFired(refreshControl: UIRefreshControl){
        self.queryArea()
        
        refreshControl.endRefreshing()
    }

    func queryArea(){
        
        var requestDictionary: NSDictionary = [
            "action" : "query-radius",
            "request" : [
                "lat" : NSNumber(double: lat!),
                "lng" : NSNumber(double: long!),
                "radiusInMeter" : NSNumber(integer: AWSRadiusInMeter)
            ]
        ];
        
        self.sendRequest(requestDictionary)
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
        
        
        let e = NSErrorPointer()
        
        var resultDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(self.queryData!, options: NSJSONReadingOptions.allZeros, error: e) as NSDictionary
        
        let action: NSString = resultDictionary.objectForKey("action") as NSString
        
        
        
        if action.isEqualToString("query"){
            postsArray.removeAll(keepCapacity: false)
            
            let ddb: AWSDynamoDB = AWSDynamoDB.defaultDynamoDB()
            
            for jsonDic in resultDictionary.objectForKey("result") as NSArray{
                let postID: NSString = (jsonDic.objectForKey("rangeKey") as NSString)
                
                self.postObjectFromPostID(postID, ddb: ddb)
            }
            self.tableView.reloadData()
        }
        /*
        NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:self.data
            options:kNilOptions
            error:nil];
        NSLog(@"Response:\n%@", resultDictionary);
        
        NSString *action = [resultDictionary objectForKey:@"action"];
        if([action isEqualToString:@"query"]) {
            [self.mapView removeAnnotations:self.mapView.annotations];
            
            for (NSDictionary *jsonDic in [resultDictionary objectForKey:@"result"]) {
                AWSPointAnnotation *annotation = [AWSPointAnnotation new];
                annotation.coordinate = CLLocationCoordinate2DMake([[jsonDic objectForKey:@"latitude"] doubleValue],
                [[jsonDic objectForKey:@"longitude"] doubleValue]);
                annotation.title = [jsonDic objectForKey:@"schoolName"];
                annotation.rangeKey = [jsonDic objectForKey:@"rangeKey"];
                [self.mapView addAnnotation:annotation];
            }
        }*/
    }
    
    func postObjectFromPostID(postID:NSString, ddb: AWSDynamoDB){
        
        var itemInput: AWSDynamoDBGetItemInput = AWSDynamoDBGetItemInput()
        itemInput.tableName = "posts"
        let pID = AWSDynamoDBAttributeValue()
        pID.S = postID
        itemInput.key = ["PostID": pID]
        
        var newPost: Post = Post()
        
        

        ddb.getItem(itemInput).continueWithSuccessBlock({ [unowned self]
            task -> AnyObject in
            
            
            if(task.error != nil){
                NSLog("%@", task.error);
            }else{ // success
                let result:AWSDynamoDBGetItemOutput = task.result as AWSDynamoDBGetItemOutput
                newPost.title = (result.item["Title"] as AWSDynamoDBAttributeValue).S
                newPost.score = (result.item["Score"] as AWSDynamoDBAttributeValue).N.toInt()!
                newPost.thumbnailURL = "ImageUnavailable.png"
                newPost.mediaURL = "https://s3.amazonaws.com/stopgappaws/" + postID + ".jpeg"
                newPost.numComments = 0
                newPost.postID = postID
                
                NSLog(newPost.title)
                
                self.postsArray.append(newPost)
                self.tableView.reloadData()
            }
            
            return "all done";
        })
        
        
        /*
        DynamoDBGetItemRequest *getItemRequest = [DynamoDBGetItemRequest new];
        getItemRequest.tableName = @"UserTableExample";
        
        // Need to specify the key of our item, which is an NSDictionary of our primary key attribute(s)
        DynamoDBAttributeValue *userId = [[DynamoDBAttributeValue alloc] initWithN:@"1234"];
        DynamoDBAttributeValue *recordId = [[DynamoDBAttributeValue alloc] initWithS:@"name"];
        getItemRequest.key = [NSMutableDictionary dictionaryWithObjectsAndKeys:userId, @"UserId", recordId, @"RecordId", nil];
        
        DynamoDBGetItemResponse *getItemResponse = [self.ddb getItem:getItemRequest];
        
        // The item is an NSDictionary of DynamoDBAttributeValue keyed by the attribute name
        DynamoDBAttributeValue  *name = [getItemResponse.item valueForKey:@"Data"];
        
        // The name is a string, so its stored value will be in the s property as an NSString
        NSLog(@"name = '%@'", name.s);
*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let currentLocation = locations.last as CLLocation
        lat = currentLocation.coordinate.latitude
        long = currentLocation.coordinate.longitude
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("Location Manager error: " + error.description)
    }

    func setupTestPosts(){
        var post1 = Post(title: "Test post 1", mediaURL: "ImageUnavailable.png", thumbnailURL: "ImageUnavailable.png")
        var post2 = Post(title: "Test post 2", mediaURL: "ImageUnavailable.png", thumbnailURL: "ImageUnavailable.png")
        
        postsArray.append(post1)
        postsArray.append(post2)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return postsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell:PicVoteTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell") as PicVoteTableViewCell
        
        let post = postsArray[indexPath.row]
        
        cell.setCell(post)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let post = postsArray[indexPath.row]
        
        var detailViewController: DetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as DetailViewController
    }
    
    @IBAction func unwindToHomeView(segue: UIStoryboardSegue) {
        if segue.identifier == "postMadeSegue"{
            //reload table
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let post = postsArray[indexPath.row] as Post
                (segue.destinationViewController as DetailViewController).detailPost = post
            }
        }else if segue.identifier == "presentCamera"{
            (segue.destinationViewController as CameraViewController).lat = lat
            (segue.destinationViewController as CameraViewController).long = long
        }
    }
    
}

