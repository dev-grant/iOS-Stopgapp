//
//  CameraOverlay.swift
//  Stopgapp
//
//  Created by Grant on 12/30/14.
//  Copyright (c) 2014 GRANTGOLDEN. All rights reserved.
//

import UIKit

protocol CameraDelegate{
    func takePhoto()
    func cancelCamera()
}

class CameraOverlay: UIView {

    var view: UIView!
    var nibName: String = "CameraOverlay"
    var delegate: CameraDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        if let cDeg = delegate{
            cDeg.cancelCamera()
        }
    }
    
    @IBAction func takePhotoButtonPressedUp(sender: AnyObject) {
        if let cDeg = delegate{
            cDeg.takePhoto()
        }
    }
    
    func setup(){
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as UIView
        
        return view
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
