import UIKit

class GospelViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCollectionView()
        collectionView.backgroundColor = .clear
        titleLabel.text = "The 7 Facts You Have to Know".localized()
        
    }
    
    
    func addCollectionView() {
        let layout = CarouselLayout()
        
        layout.itemSize = CGSize(width: self.collectionView.frame.size.width*0.9, height: self.collectionView.frame.size.height*0.85)
        
        layout.sideItemScale = 170/251
        layout.spacing = -197
        layout.isPagingEnabled = true
        layout.sideItemAlpha = 0.5
        
        self.collectionView.collectionViewLayout = layout
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        
        self.collectionView?.register(UINib(nibName: "GospelCell", bundle: nil), forCellWithReuseIdentifier: "GospelCell")
    }

}


extension GospelViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GospelCell", for: indexPath) as! GospelCell
        
//        cell.titleLabel.text = gospelTitle[indexPath.row]
//        cell.titleLabel.textColor = .white
        cell.backgroundColor = UIColor(red: 0.363, green: 0.363, blue: 0.376, alpha: 1)
        cell.titleLabel.text = gospelTitle[indexPath.row].localized()
        cell.txtLabel.text = gospelTxt[indexPath.row].localized()
        cell.wordLabel.text = gospelWords[indexPath.row].localized()
        cell.titleLabel.textColor = .white
        cell.txtLabel.textColor = .white
        cell.wordLabel.textColor = .white
        cell.layer.cornerRadius = 12
//        cell.customView.backgroundColor = .sectionColor
//        UIColor(red: 0.363, green: 0.363, blue: 0.376, alpha: 1)
//        print(indexPath.row)
        return cell
    }
    
}
