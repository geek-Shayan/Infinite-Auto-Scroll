//  ViewController.swift
//
//  Infinite Auto Scroll
//
//  Created by MD. SHAYANUL HAQ SADI on 17/8/23.
//

import UIKit

class ViewController: UIViewController {
    
    static let identifier = "ViewController"
    
    // MARK: - Properties
    var collectionView: UICollectionView!
    
    var cells: [String] = [ "Icon-20", "Icon-29", "Icon-40", "Icon-60" ]


    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        createCollectionView()
    }

    private func setupView() {
        
    }
        

    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            if sectionNumber == 0 {
                print("first carossel")
                return self.carosselSection()
            }
            else {
                print("second")
                return self.secondSection()
            }
        }
        return layout
    }

    
    
    private func createCollectionView() {
        let layout = createCollectionViewLayout()
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UINib(nibName: "CarosselCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CarosselCollectionViewCell.identifier)

        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .gray
 
        view.addSubview(collectionView)
        
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(pullDownToRefresh), for: .valueChanged)
    }
    
    
    private func carosselSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        //                item.contentInsets.trailing = 2
        //                item.contentInsets.bottom = 8
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(400)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets.bottom = 16
        
        section.visibleItemsInvalidationHandler = { (items, scrollOffset, environment) in
            items.forEach { item in
                let distanceFromCenter = abs((item.frame.midX - scrollOffset.x) - environment.container.contentSize.width / 2.0)
                let minScale: CGFloat = 0.8
                let maxScale: CGFloat = 1.0 - (distanceFromCenter / environment.container.contentSize.width)
                let scale = max(maxScale, minScale)
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        return section
    }

    
    private func secondSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        item.contentInsets.trailing = 16
        item.contentInsets.bottom = 8
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(150)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets.leading = 16
        return section
    }
    

    override func viewDidLayoutSubviews() {
        collectionView.frame = view.bounds
    }
    

    @objc private func pullDownToRefresh() {
        print("Refresh")
        
//        sectionData0 = []
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.collectionView.reloadData()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
}


extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        print("Cell indexPath row, section, item", indexPath.row, indexPath.section, indexPath.item)
                
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarosselCollectionViewCell.identifier, for: indexPath) as! CarosselCollectionViewCell
        cell.setup(image: cells[indexPath.item], label: String(indexPath.item))
        return cell
    }
}


extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIViewController()
        
        vc.view.backgroundColor = indexPath.section == 0 ? .yellow : indexPath.section == 1 ? .blue : .orange
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
