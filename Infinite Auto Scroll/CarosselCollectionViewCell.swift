//
//  CarosselCollectionViewCell.swift
//  Infinite Auto Scroll
//
//  Created by MD. SHAYANUL HAQ SADI on 17/8/23.
//

import UIKit

class CarosselCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cBackgroundView: UIView!
    
    @IBOutlet weak var cImageView: UIImageView!
    
    @IBOutlet weak var cLabel: UILabel!
    
    static let identifier = "CarosselCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupView()
    }
    
    private func setupView() {
        cBackgroundView.backgroundColor = .orange
    }
    
    func setup(image: String, label: String) {
        cImageView.image = UIImage(named: image)
        cLabel.text = label
    }

}
