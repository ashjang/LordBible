import UIKit
import FirebaseDatabase

class StarDetailViewController: UIViewController {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var kjv_kor_label: UILabel!
    @IBOutlet weak var niv_kor_label: UILabel!
    @IBOutlet weak var kjv_label: UILabel!
    @IBOutlet weak var niv_label: UILabel!
    
    private var ref: DatabaseReference!
    private var receiveStarBible: StarBible?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = "<\(self.receiveStarBible!.address.localized()) \(self.receiveStarBible!.chapter):\(self.receiveStarBible!.verse)>"
        ref = Database.database().reference()
        
        getStarWord(type: "KJV흠정역", label: self.kjv_kor_label)
        getStarWord(type: "개역개정", label: self.niv_kor_label)
        getStarWord(type: "KJV", label: self.kjv_label)
        getStarWord(type: "NIV", label: self.niv_label)
    }

    func receiveItem(_ item: StarBible) {
        receiveStarBible = item
    }
    
    func getStarWord(type: String, label: UILabel) {
        let verseIndex: Int = Int(self.receiveStarBible!.verse)! - 1
        ref.child(type).child(self.receiveStarBible!.address).child(self.receiveStarBible!.chapter).observe(.value) { [weak self] snapshot in
            guard let value = snapshot.value as? [NSDictionary] else { return }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value)
                let bibleData = try JSONDecoder().decode([Verse].self, from: jsonData)
                label.text = bibleData[verseIndex].word
            } catch let error {
                print("Error JSON parsing: \(error.localizedDescription)")
            }
        }
    }
}
