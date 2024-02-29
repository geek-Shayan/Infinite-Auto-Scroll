//  ViewController.swift
//
//  Infinite Auto Scroll
//
//  Created by MD. SHAYANUL HAQ SADI on 17/8/23.
//

import UIKit

protocol InfiniteAutoScrollViewDelegate: AnyObject {
    func didTapItem(_ collectionView: UICollectionView, selectedItem item:Int)
}

class ViewController: UIViewController {
    
    static let identifier = "ViewController"
    
    // MARK: - Properties
    weak var delegate: InfiniteAutoScrollViewDelegate?
    var collectionView: UICollectionView!
    var pageControl: UIPageControl!
    var currentFrame: CGRect!
    var autoScrollTimer: Timer!
    var currentAutoScrollIndex = 1
   
    var cells: [String] = [ "Icon-20", "Icon-29", "Icon-40", "Icon-60" ]

    var contentArray = [AnyObject]() {
        didSet {
            if contentArray.count > 1 {
                /// Modify it to be like [C, A, B, C, A] to make infinite effect
                contentArray.insert(contentArray.last!, at: 0)
//                contentArray.insert(contentsOf: contentArray, at: 0)
                contentArray.append(contentArray[1])
//                contentArray.append(contentsOf: contentArray)
            }
            
            if collectionView != nil {
                collectionView.reloadData()
                collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)
                addPageControl()
            }
        }
    }
    
    /// Default is false
    var isAutoScrollEnabled = false {
        didSet {
            if  collectionView != nil && isAutoScrollEnabled == true {
                configAutoScroll()
            }
        }
    }
    
    /// Time interval for auto scroll
    var timeInterval = 1.0 {
        didSet {
            if collectionView != nil && isAutoScrollEnabled == true {
                configAutoScroll()
            }
        }
    }
    
    /// Default is true
    var isPageControlShown = true {
        didSet {
            if pageControl != nil && isPageControlShown == false {
                pageControl.isHidden = true
            }
        }
    }
    
    /// Current page color for UIPageControl
    var currentPageControlColor: UIColor? {
        didSet {
            if collectionView != nil && pageControl != nil  {
                pageControl.currentPageIndicatorTintColor = currentPageControlColor
            }
        }
    }
    
    /// Other page color for UIPageControl
    var pageControlTintColor: UIColor? {
        didSet {
            if collectionView != nil && pageControl != nil {
                pageControl.pageIndicatorTintColor = pageControlTintColor
//                pageControl.pageIndicatorTintColor = .blue
            }
        }
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        createCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        contentArray = cells as [AnyObject]
        
        var dataArray = [String?]()
        for i in 0..<cells.count {
            dataArray.append(cells[i])
//            dataArray.append(UIImage(named: "photo_\(i+1)") ?? nil)
        }
        
        contentArray = dataArray as [AnyObject]
        isAutoScrollEnabled = true
        timeInterval = 2.0
        isPageControlShown = true
        currentPageControlColor = .orange
        pageControlTintColor = .darkGray
        delegate = self

    }

    private func setupView() {
        
    }
        

    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            if sectionNumber == 0 {
                print("first carossel")
                return self.createCarosselSection()
            }
            else if sectionNumber == 1 {
                print("second")
                return self.createSecondSection()
            }
            else {
                print("third")
                return self.createHorizontalScrollLayoutSection()
            }
        }
        return layout
    }

    
    
    private func createCollectionView() {
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.register(UINib(nibName: "CarosselCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CarosselCollectionViewCell.identifier)

        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .gray
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

 
        view.addSubview(collectionView)
        
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(pullDownToRefresh), for: .valueChanged)
        
        if isPageControlShown {
            addPageControl()
        }
    }
    
    
    func addPageControl() {
//        pageControl = UIPageControl(frame: CGRect(x: self.view.frame.origin.x,
//                                                  y: self.collectionView.frame.origin.y + self.view.frame.height,
//                                                  width: self.view.frame.size.width,
//                                                  height: 40.0))
        
        pageControl = UIPageControl(frame: view.bounds)
        pageControl.numberOfPages = contentArray.count - 2
        pageControl.currentPageIndicatorTintColor = currentPageControlColor
        pageControl.pageIndicatorTintColor = pageControlTintColor
//        pageControl.pageIndicatorTintColor = .red
        pageControl.addTarget(self, action: #selector(changePage(_:)), for: .valueChanged)
        view.addSubview(pageControl)
    }
    
    @objc func changePage(_ sender: UIPageControl) {
        collectionView.scrollToItem(at: IndexPath(item: sender.currentPage + 1, section: 0), at: .left, animated: true)
    }
    
    
    private func createCarosselSection() -> NSCollectionLayoutSection {
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

    
    private func createSecondSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        item.contentInsets.trailing = 16
        item.contentInsets.bottom = 8
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(150)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets.leading = 16
        return section
    }
    
    
    private func createHorizontalScrollLayoutSection() -> NSCollectionLayoutSection {
        let itemInset = 5.0
        let sectionMargin = 15.0

        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: itemInset, bottom: 0, trailing: itemInset)
        
        // Group
        let pageWidth = collectionView.bounds.width - sectionMargin * 2
        print("pageWidth = \(collectionView.bounds.width)")
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
        print("self.frame.height = \(self.view.frame.height)")
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        // Section
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        
        /// When we use orthogonalScrollingBehavior, scrollViewDidScroll(_:) and scrollViewDidEndDecelerating(_:) won't be fired
        /// visibleItemsInvalidationHandler will be fired when user scroll
        layoutSection.visibleItemsInvalidationHandler = { visibleItems, point, environment in
            if var page = Int(exactly: (point.x + sectionMargin) / pageWidth) {
                let maxIndex = self.contentArray.indices.max()!
                self.currentAutoScrollIndex = page
                
                /// Setup for infinite scroll; we had modify the data array to be [C, A, B, C, A]
                if page == maxIndex {
                    /// When at last item, need to change to array[1], so it can continue to scroll right or left
                    page = 1
                    self.currentAutoScrollIndex = page
                } else if page == 0 {
                    /// When at fist item, need to change to array[3], so it can continue to scroll right or left
                    page = maxIndex - 1
                    self.currentAutoScrollIndex = page
                }
                
                /// Because we add a data in array
                let realPage = page - 1

                /// Update page control and cell only when page changed
                if self.pageControl.currentPage != realPage {
                    self.pageControl.currentPage = realPage
                    self.collectionView.scrollToItem(at: IndexPath(item: page, section: 0), at: .left, animated: false)
                }
                
                if self.isAutoScrollEnabled {
                    self.configAutoScroll()
                }
            }
        }
        
        return layoutSection
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
        return 3
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentArray.count
//        return 1000
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        print("Cell indexPath row, section, item", indexPath.row, indexPath.section, indexPath.item)
                
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarosselCollectionViewCell.identifier, for: indexPath) as! CarosselCollectionViewCell
        cell.setup(image: contentArray[indexPath.item] as! String, label: contentArray[indexPath.item] as! String)
//        cell.setup(image: cells[indexPath.item % cells.count], label: String(indexPath.item))
        
        cell.backgroundColor = .yellow
        
//        let content = contentArray[indexPath.item]
//
//        if let realContent = content as? String {
//            cell.cImageView.image = UIImage(named: realContent)
//        }
        cell.delegate = self
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let vc = UIViewController()
//        vc.view.backgroundColor = indexPath.section == 0 ? .yellow : indexPath.section == 1 ? .blue : .orange
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didTapItem(collectionView, selectedItem: indexPath.item)
    }
}




// MARK: - Auto Scroll Methods
extension ViewController {
    
    func configAutoScroll() {
        resetAutoScrollTimer()
        if contentArray.count > 1 {
            setupAutoScrollTimer()
        }
    }
    
    func resetAutoScrollTimer() {
        if autoScrollTimer != nil {
            autoScrollTimer.invalidate()
            autoScrollTimer = nil
        }
    }
    
    func setupAutoScrollTimer() {
        autoScrollTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(autoScrollAction(timer:)), userInfo: nil, repeats: true)
        RunLoop.main.add(autoScrollTimer, forMode: RunLoop.Mode.common)
    }

    @objc func autoScrollAction(timer: Timer) {
//        if self.window != nil {
            currentAutoScrollIndex += 1
            if currentAutoScrollIndex >= contentArray.count {
                currentAutoScrollIndex = currentAutoScrollIndex % contentArray.count
            }
            collectionView.scrollToItem(at: IndexPath(item: currentAutoScrollIndex, section: 0), at: .left, animated: true)
//        }
    }
}



// MARK: - InfiniteAutoScrollViewCellDelegate
extension ViewController: InfiniteAutoScrollViewCellDelegate {
    
    func invalidateTimer() {
        if autoScrollTimer != nil {
            autoScrollTimer.invalidate()
            autoScrollTimer = nil
        }
    }
}



// MARK: - InfiniteAutoScrollViewDelegate
extension ViewController: InfiniteAutoScrollViewDelegate {
    
    func didTapItem(_ collectionView: UICollectionView, selectedItem item: Int) {
        if collectionView == collectionView {
            print("🥑 🥑 DemoView Item \(item) is tapped")
        } else {
            print("🥑 Other \(item) is tapped")
        }
    }
}
