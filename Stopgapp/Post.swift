//
//  Post.swift
//  Stopgapp
//
//  Created by Grant on 12/21/14.
//  Copyright (c) 2014 GRANTGOLDEN. All rights reserved.
//

import Foundation

enum PostType{
    case Picture
    case Video
}

class Post{
    var title = "blank"
    var numComments = 0
    var score = 0
    var thumbnailURL = "blank"
    var mediaURL = "blank"
    var postID = "blank"
    
    var commentsArray : [Comment] = [Comment]()
    
    init(){
        self.numComments = -1
    }
    
    init(title: String, mediaURL:String, thumbnailURL: String){
        self.title = title
        self.numComments = 0
        self.score = 1
        self.mediaURL = mediaURL
        self.thumbnailURL = thumbnailURL
    }
}