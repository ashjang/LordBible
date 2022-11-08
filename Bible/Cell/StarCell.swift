//
//  StarCell.swift
//  Bible
//
//  Created by 장하림 on 2022/10/24.
//

import UIKit

class StarCell: UITableViewCell {
    @IBOutlet weak var starWord: UILabel!
    @IBOutlet weak var starWordText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
