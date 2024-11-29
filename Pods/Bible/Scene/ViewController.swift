import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var todayWord: UILabel!
    @IBOutlet weak var todayWordText: UILabel!
    @IBOutlet weak var starTableView: UITableView! {
        didSet {
            starTableView.delegate = self
            starTableView.dataSource = self
        }
    }
    
    
    private var starList = [StarBible]() {
        didSet {
            self.saveStarList()         // starList의 배열의 성경구절이 추가되거나 변경이 일어날 때마다 userDefaults에 저장됨
        }
    }
    private var ref: DatabaseReference!
    private let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
//    let notification = NotificationCenter.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 처음 앱 깔았을 때 실행되도록(
        if launchedBefore == false {
            let sheet = UIAlertController(title: "Essential".localized(), message: "Thank you for using our app:) Please select the default Bible version first.".localized(), preferredStyle: UIAlertController.Style.alert)
            let KJVKorean = UIAlertAction(title: "KJV흠정역".localized(), style: .destructive, handler: { _ in
                setBibleVersion.append(BibleVersion(type: "KJV흠정역"))
                UserDefaults.standard.set(true, forKey: "launchedBefore")
            })
            KJVKorean.setValue(UIColor.sectionColor, forKey: "titleTextColor")
            let KJV = UIAlertAction(title: "KJV", style: .destructive, handler: { _ in
                setBibleVersion.append(BibleVersion(type: "KJV"))
                UserDefaults.standard.set(true, forKey: "launchedBefore")
            })
            KJV.setValue(UIColor.sectionColor, forKey: "titleTextColor")
            let NIVKorean = UIAlertAction(title: "개역개정", style: .destructive, handler: { _ in
                setBibleVersion.append(BibleVersion(type: "개역개정"))
                UserDefaults.standard.set(true, forKey: "launchedBefore")
            })
            NIVKorean.setValue(UIColor.sectionColor, forKey: "titleTextColor")
            let NIV = UIAlertAction(title: "NIV", style: .destructive, handler: { _ in
                setBibleVersion.append(BibleVersion(type: "NIV"))
                UserDefaults.standard.set(true, forKey: "launchedBefore")
            })
            NIV.setValue(UIColor.sectionColor, forKey: "titleTextColor")
            sheet.addAction(KJVKorean)
            sheet.addAction(KJV)
            sheet.addAction(NIVKorean)
            sheet.addAction(NIV)
            present(sheet, animated: true)
        }
        let barViewControllers = self.tabBarController?.viewControllers![1] as! UINavigationController
        let svc = barViewControllers.topViewController as! WordsViewController
        svc.delegate = self
        
        self.starTableView.backgroundColor = .backgroundColor
        self.todayWord.textColor = .textLabelColor
        self.todayWordText.textColor = .textLabelColor
        self.loadStarList()
        
        ref = Database.database().reference()
        loadBibleVersion()
        if !setBibleVersion.isEmpty {
            self.getRandomWord(type: "\(setBibleVersion[0].type)")
        }
//        notification.generateNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBibleVersion()
        self.loadStarList()
        self.starTableView.reloadData()
        if !setBibleVersion.isEmpty {
            self.getRandomWord(type: "\(setBibleVersion[0].type)")
        }
        
    }
    
    private func saveStarList() {
        let star = self.starList.map {
            [
                "address": $0.address,
                "chapter": $0.chapter,
                "verse": $0.verse,
                "word": $0.word,
                "isStar": $0.isStar
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(star, forKey: "starList")
    }
    
    private func loadStarList() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "starList") as? [[String: Any]] else { return }
        self.starList = data.compactMap {
            guard let address = $0["address"] as? String else { return nil }
            guard let chapter = $0["chapter"] as? String else { return nil }
            guard let verse = $0["verse"] as? String else { return nil }
            guard let word = $0["word"] as? String else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            return StarBible(address: address, chapter: chapter, verse: verse, word: word, isStar: isStar)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "starDetail" {
            let cell = sender as! UITableViewCell
            let indexPath = self.starTableView.indexPath(for: cell)
            let starView = segue.destination as! StarDetailViewController
            starView.receiveItem(self.starList[indexPath!.row])
        }
    }
    
    func getRandomWord(type: String) {
//        ref.child("randomWord").child(type).observe(.value) { [weak self] snapshot in
//            guard let value = snapshot.value as? [NSDictionary] else { return }
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: value)
//                let bibleData = try JSONDecoder().decode([RandomBible].self, from: jsonData)
//                if let random = bibleData.randomElement() {
//                    wordAddress = "\(random.address.localized()) \(random.chapter):\(random.verse)"
//                    wordText = "\(random.word)"
//                    self?.todayWord.text = "\(random.address.localized()) \(random.chapter):\(random.verse)"
//                    self?.todayWordText.text = "\(random.word)\n(\(type))"
//                }
//            } catch let error {
//                print("Error JSON parsing: \(error.localizedDescription)")
//            }
//        }
        let date = Date()
        let month = Calendar.current.dateComponents([.month], from: date)
        let day = Calendar.current.dateComponents([.day], from: date)
        
        ref.child("randomWord").child("KJV흠정역").child("\(month.month! - 1)").child("\(day.day!)").observe(.value) { [weak self] snapshot in
            guard let value = snapshot.value as? NSDictionary else { return }
//            print("\(value["address"]!) \(value["chapter"]!):\(value["verse"]!)")
//            print("\(value["word"]!)")
            self?.todayWord.text = "\((value["address"]! as! String).localized()) \(value["chapter"]!):\(value["verse"]!)"
            self?.todayWordText.text = "\(value["word"]!)\n(\("KJV흠정역"))"
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.starList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StarCell", for: indexPath) as? StarCell else { return UITableViewCell() }
        let star = self.starList[indexPath.row]
        cell.starWord.text = "\(star.address.localized()) \(star.chapter):\(star.verse)"
        cell.starWordText.text = "\(star.word)"
        cell.starWord.textColor = .textLabelColor
        cell.starWordText.textColor = .textLabelColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.starList.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        self.starTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete".localized()
    }
}

extension ViewController: WordsViewDelegate {
    func didSelect(starBible: [StarBible]) {
        // highlight로 선택한 구절들이 이미 userDefaults에 들어가있는지 없는지 확인하고 추가
        var list: [StarBible] = []
        for i in starBible {
            var strVerse = i.verse
            if !self.starList.contains(where: {
                $0.address == i.address && $0.chapter == i.chapter && $0.verse == i.verse
            }) {
                self.starList.append(i)
                let alert = UIAlertController(title: "Notice".localized(), message: "Saved to Favorite Words.".localized(), preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "OK".localized(), style: .default)
                alert.addAction(okAction)
                present(alert, animated: false, completion: nil)
                print(i)
            }
        }
        self.starTableView.reloadData()
    }
}
