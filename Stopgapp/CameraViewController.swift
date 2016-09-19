//
//  CameraViewController.swift
//  Stopgapp
//
//  Created by Grant on 12/22/14.
//  Copyright (c) 2014 GRANTGOLDEN. All rights reserved.
//


import UIKit
import AVFoundation

class CameraViewController: UIViewController, CameraDelegate {

    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var stillImageOutput: AVCaptureStillImageOutput?
    
    var pickedImage: UIImage?
    
    var lat: Double?
    var long: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        captureSession.sessionPreset = AVCaptureSessionPresetLow//AVCaptureSessionPresetHigh//
        
        let devices = AVCaptureDevice.devices()
        for device in devices{
            if(device.hasMediaType(AVMediaTypeVideo) && device.position == AVCaptureDevicePosition.Back){
                captureDevice = device as? AVCaptureDevice
            }
        }
        
        if(captureDevice != nil){
            var err : NSError?
            captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
            
            if err != nil {
                println("error: \(err?.localizedDescription)")
            }
            
            stillImageOutput = AVCaptureStillImageOutput()
           
            if(captureSession.canAddOutput(stillImageOutput)){
                captureSession.addOutput(stillImageOutput)
            }

            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
   
            self.view.layer.addSublayer(previewLayer)
            previewLayer.frame = self.view.layer.frame
            captureSession.startRunning()
        }
        
        let cameraOverlay = CameraOverlay(frame: self.view.layer.frame)
        
        cameraOverlay.delegate = self
        
        self.view.addSubview(cameraOverlay)
        
    }
    
    func cancelCamera(){
        self.performSegueWithIdentifier("unwindToHomeView", sender: self)
    }
    
    func takePhoto(){
        
        if let stillOutput = stillImageOutput{
            
            var videoConnection: AVCaptureConnection?
            
            for connection in stillOutput.connections{
                for port in connection.inputPorts!{
                    if port.mediaType == AVMediaTypeVideo{
                        videoConnection = connection as? AVCaptureConnection
                        break
                    }
                }
                
                if videoConnection != nil{
                    break
                }
            }
            
            if videoConnection != nil{

                stillOutput.captureStillImageAsynchronouslyFromConnection(videoConnection){
                    (imageSampleBuffer : CMSampleBuffer!, _) in
                    
                    let imageDataJpeg = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                    self.pickedImage = UIImage(data: imageDataJpeg)!
                    
                    self.performSegueWithIdentifier("showEditPost", sender: self)
                    
                    //let scaledImage:UIImage = self.squareImageFromImage(pickedImage, newSize: 320.0)
                    //let scaledImage = self.imageWithImage(pickedImage, scaledToSize: CGSizeMake(320, 320))
                    
                    //let imageData = UIImagePNGRepresentation(scaledImage)
                    //var imageFile:PFFile = PFFile(data: imageData)
                    
                    /*
                    var userPost = PFObject(className:"UserPost")
                    
                    userPost["imageFile"] = imageFile
                    userPost["from"] = PFUser.currentUser()
                    userPost.saveInBackground()
                    */
                    
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEditPost" {
            if let pImage = pickedImage{
                ((segue.destinationViewController as UINavigationController).viewControllers[0] as EditPostViewController).image = pImage
                
            }
            
            ((segue.destinationViewController as UINavigationController).viewControllers[0] as EditPostViewController).lat = lat
            ((segue.destinationViewController as UINavigationController).viewControllers[0] as EditPostViewController).long = long
            
            /*if let indexPath = self.tableView.indexPathForSelectedRow() {
                let post = postsArray[indexPath.row] as Post
                (segue.destinationViewController as DetailViewController).detailPost = post
            }*/
        }
    }
    
    @IBAction func unwindToCameraView(segue: UIStoryboardSegue) {
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
