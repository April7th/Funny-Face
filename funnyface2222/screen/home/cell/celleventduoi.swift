//
//  celleventduoi.swift
//  funnyface2222
//
//  Created by quocanhppp on 24/01/2024.
//

import UIKit

class celleventduoi: UICollectionViewCell {
    @IBOutlet weak var lablenamesk:UILabel!
    @IBOutlet weak var lablenamesk2:UILabel!
    @IBOutlet weak var lablenamesk3:UILabel!
    @IBOutlet weak var lablenamesk4:UILabel!
    @IBOutlet weak var lablenamesk5:UILabel!
    @IBOutlet weak var labelUserName:UILabel!
    @IBOutlet weak var imageUserAvatar:UIImageView!
    var profile:ProfileModel = ProfileModel()
    override func awakeFromNib() {
        super.awakeFromNib()
        imageUserAvatar.layer.cornerRadius = imageUserAvatar.bounds.width / 2
        imageUserAvatar.clipsToBounds = true
        // Initialization code
        
        setupUI()
    }
    
    private func setupUI() {
        labelUserName.font = .quickSandBold(size: 14)
        lablenamesk2.font = .quickSandSemiBold(size: 12)
        lablenamesk3.font = .quickSandBold(size: 12)
        lablenamesk4.font = .quickSandBold(size: 12)
        lablenamesk5.font = .quickSandBold(size: 12)
        lablenamesk.font = .starBorn(size: 20)

    }
    
    

}
