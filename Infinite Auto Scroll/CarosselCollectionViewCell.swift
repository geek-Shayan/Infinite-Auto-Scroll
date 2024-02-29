//
//  CarosselCollectionViewCell.swift
//  Infinite Auto Scroll
//
//  Created by MD. SHAYANUL HAQ SADI on 17/8/23.
//

import UIKit

protocol InfiniteAutoScrollViewCellDelegate: AnyObject {
    func invalidateTimer()
}

class CarosselCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: InfiniteAutoScrollViewCellDelegate?

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
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        // Invalidate timer when user pan on cell
        delegate?.invalidateTimer()
    }

    
    func setup(image: String, label: String) {
        cImageView.image = UIImage(named: image)
        cLabel.text = label
    }

}



// MARK: - UIGestureRecognizerDelegate
extension CarosselCollectionViewCell: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
