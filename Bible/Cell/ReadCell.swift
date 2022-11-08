//
//  ReadCell.swift
//  Bible
//
//  Created by 장하림 on 2022/10/25.
//

import UIKit

class ReadCell: UICollectionViewCell {
    @IBOutlet weak var chapterNumLabel: UILabel!
    
    required init?(coder: NSCoder) {            // cell의 디자인 설정
        super.init(coder: coder)
        self.contentView.layer.cornerRadius = 9.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.backgroundColor = .clear
    }
}
