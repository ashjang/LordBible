//
//  ChapterCell.swift
//  Bible
//
//  Created by 장하림 on 2022/10/19.
//

import UIKit

class ChapterCell: UITableViewCell {

    @IBOutlet weak var verseLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
