//
//  Comment.swift
//  Stopgapp
//
//  Created by Grant on 12/21/14.
//  Copyright (c) 2014 GRANTGOLDEN. All rights reserved.
//

import Foundation

class Comment{
    var content = "blank"
    var score = 0;
    var commentID = "blank"
    var parentID = "blank"
    //some user ID?
    
    init(content:String, score:Int){
        self.content = content
        self.score = score
    }
}