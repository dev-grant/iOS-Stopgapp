//
//  PicVoteTableViewCell.swift
//  Stopgapp
//
//  Created by Grant on 12/21/14.
//  Copyright (c) 2014 GRANTGOLDEN. All rights reserved.
//

import UIKit

class PicVoteTableViewCell: UITableViewCell {

    required init(coder aDecoder: NSCoder) {
        
        cellPost = Post()
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var thumbNail: UIImageView!
    @IBOutlet weak var numCommentsButton: UIButton!
   

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var downvoteButton: UIButton!
    
    var cellPost:Post

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func upvotePressed(sender: AnyObject) {
        
        changeScore(true)
        
        var currentScore = scoreLabel.text?.toInt()
        
        currentScore = currentScore! + 1
        self.scoreLabel.text = currentScore?.description
    }
    
    @IBAction func downvotePressed(sender: AnyObject) {
        
        changeScore(false)	
        
        var currentScore = scoreLabel.text?.toInt()
        
        currentScore = currentScore! - 1
        scoreLabel.text = currentScore?.description
    }
    
    func changeScore(upVote:Bool){
        
        let ddb: AWSDynamoDB = AWSDynamoDB.defaultDynamoDB()
        
        var itemInput:AWSDynamoDBUpdateItemInput = AWSDynamoDBUpdateItemInput()
        itemInput.tableName = "posts"
        
        let pID = AWSDynamoDBAttributeValue()
        pID.S = cellPost.postID
        itemInput.key = ["PostID": pID]
        
        let addValue = AWSDynamoDBAttributeValue()
        
        if upVote {
            addValue.N = "1"
        }else{
            addValue.N = "-1"
        }
        
        let update = AWSDynamoDBAttributeValueUpdate()
        update.value = addValue
        update.action = AWSDynamoDBAttributeAction.Add
        
        itemInput.attributeUpdates = ["Score": update]
        
        ddb.updateItem(itemInput)
    }
    
    func setCell(post: Post){
        cellPost = post
        self.titleLabel.text = cellPost.title
        self.numCommentsButton.setTitle(String(cellPost.numComments) + " comments", forState: UIControlState.Normal)
        self.scoreLabel.text = String(cellPost.score)
        self.thumbNail.image = UIImage(named: cellPost.thumbnailURL)
    }

}
