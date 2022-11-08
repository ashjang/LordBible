import UIKit
import FirebaseDatabase
import FirebaseCoreInternal

protocol WordsViewDelegate: AnyObject {
    func didSelect(starBible: [StarBible])            // highlight된 말씀을 ViewController에 전달
}

protocol SettingViewDelegate: AnyObject {
    func sendReadRecord(readBible: ReadBible)
}

class WordsViewController: UIViewController {
    
    @IBOutlet weak var btnKJV_KOR: UIButton!
    @IBOutlet weak var btnKJV: UIButton!
    @IBOutlet weak var btnNIV_KOR: UIButton!
    @IBOutlet weak var btnNIV: UIButton!
    
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var btnBefore: UIButton!
    @IBOutlet weak var btnAfter: UIButton!
    @IBOutlet weak var selectedBtnLabel: UILabel!
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var chapterTableView: UITableView! {
        didSet {
            chapterTableView.delegate = self
            chapterTableView.dataSource = self
        }
    }
    
    // for PickerView
    private var pikAddressName: String?
    private var pikChapterNum: String?
    private var com0: Int = 0
    private var com1: Int?
    private var pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: Int((UIScreen.main.bounds.height-20)/3)))
    
    // for TableView Data
    private var oneChapterList: [Verse] = []
    private var numOfVerse: Int?
    private var copyWords: [String] = []
    private var copyStarWords: [StarBible] = []
    private var staticCopyStar: [StarBible] = []
    
    // Firebase Realtime Database
    private var ref: DatabaseReference!
    
    // for button
    private var is_KJV = false
    private var is_KJV_KOR = false
    private var is_NIV = false
    private var is_NIV_KOR = false
    private var btnList: Array<String> = []
    
    weak var delegate: WordsViewDelegate?
    weak var delegate2: SettingViewDelegate?
    
    private let launchType = UserDefaults.standard.bool(forKey: "launchType")
    
    private var wordSave = [WordSave(address: "Genesis", chapter: "1")] {
        didSet {
//            self.saveTimesOfReading()
            self.saveWord()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 폰트색상
        [btnNIV, btnKJV_KOR, btnNIV, btnNIV_KOR, btnBefore, btnAfter, menuBtn].forEach {
            $0?.configuration?.baseForegroundColor = .textLabelColor
        }
        selectedBtnLabel.textColor = .sectionColor
        
        // default로 성경버전 선택
        if launchType == false {
            if "\(setBibleVersion[0].type)" == "KJV흠정역" {
                is_KJV_KOR = true
                btnColor(btn: btnKJV_KOR, isClicked: is_KJV_KOR)
                btnKJV_KOR.isEnabled = false
            } else if "\(setBibleVersion[0].type)" == "KJV" {
                is_KJV = true
                btnColor(btn: btnKJV, isClicked: is_KJV)
                btnKJV.isEnabled = false
            } else if "\(setBibleVersion[0].type)" == "NIV" {
                is_NIV = true
                btnColor(btn: btnNIV, isClicked: is_NIV)
                btnNIV.isEnabled = false
            } else if "\(setBibleVersion[0].type)" == "개역개정" {
                is_NIV_KOR = true
                btnColor(btn: btnNIV_KOR, isClicked: is_NIV_KOR)
                btnNIV_KOR.isEnabled = false
            }
            btnList.append("\(setBibleVersion[0].type)")
            UserDefaults.standard.set(true, forKey: "launchType")
            txtAddress.text = "Genesis".localized() + "   " + "1"
            pikAddressName = "Genesis"
            pikChapterNum = "1"
            createPickerView()
            self.pickerView.selectRow(0, inComponent: 0, animated: true)
        } else {
            loadBibleVersion()
            if "\(setBibleVersion[0].type)" == "KJV흠정역" {
                is_KJV_KOR = true
                btnColor(btn: btnKJV_KOR, isClicked: is_KJV_KOR)
                btnKJV_KOR.isEnabled = false
            } else if "\(setBibleVersion[0].type)" == "KJV" {
                is_KJV = true
                btnColor(btn: btnKJV, isClicked: is_KJV)
                btnKJV.isEnabled = false
            } else if "\(setBibleVersion[0].type)" == "NIV" {
                is_NIV = true
                btnColor(btn: btnNIV, isClicked: is_NIV)
                btnNIV.isEnabled = false
            } else if "\(setBibleVersion[0].type)" == "개역개정" {
                is_NIV_KOR = true
                btnColor(btn: btnNIV_KOR, isClicked: is_NIV_KOR)
                btnNIV_KOR.isEnabled = false
            }
            btnList.append("\(setBibleVersion[0].type)")
            self.loadWord()
            pikAddressName = self.wordSave[0].address
            pikChapterNum = self.wordSave[0].chapter
            txtAddress.text = "\(pikAddressName!)".localized() + "   " + "\(pikChapterNum!)"
            createPickerView()
            self.pickerView.selectRow(name.firstIndex(of: pikAddressName!)!, inComponent: 0, animated: true)
            self.pickerView.selectRow(Int("\(pikChapterNum!)")! - 1, inComponent: 1, animated: true)
        }
        
        self.selectedBtnLabel.text = "Order".localized() + ": " + "\(self.btnList)"
        self.selectedBtnLabel.adjustsFontSizeToFitWidth = true
        
        loadBibleVersion()
        
        menuBtn.tintColor = .textLabelColor
        menuBtn.setImage(UIImage(systemName: "line.horizontal.3",
                                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 21, weight: .regular, scale: .default)), for: .normal)
        self.navigationController?.navigationBar.tintColor = .textLabelColor
        
        
        chapterTableView.backgroundColor = .backgroundColor
        chapterTableView.allowsMultipleSelection = true
//        if is_KJV_KOR {
//            btnKJV_KOR.frame.size.width = 92 + 15
//            btnColor(btn: btnKJV_KOR, isClicked: is_KJV_KOR)
//        }
        
        // btn set for beforeChapter
        if Int(self.pikChapterNum!)! == 1 {
            self.btnBefore.isEnabled = false
        }
        let endChapter = name.firstIndex(of: self.pikAddressName!)
        if Int(self.pikChapterNum!) == address_chapterNum[endChapter!] {
            self.btnAfter.isEnabled = false
        }
        
        // DB
        usingDB()
        self.loadStarList()
        self.staticCopyStar = self.copyStarWords
        
        var menuItems: [UIAction] {
            return [
                UIAction(title: "Copy".localized(), image: UIImage(systemName: "doc.on.clipboard"), handler: {
                    (_) in
                    var copyText: String?
                    copyText = "\(self.pikAddressName!.localized()) \(self.pikChapterNum!)장\n"
                    for i in self.copyWords {
                        copyText = copyText! + "\(i)\n"
                    }
                    UIPasteboard.general.string = copyText
                }),
                UIAction(title: "Highlight".localized(), image: UIImage(systemName: "bookmark.fill"), handler: {
                    (_) in
                    let starWords = self.copyStarWords
                    self.delegate?.didSelect(starBible: starWords)
                }),
                UIAction(title: "Read Check".localized(), image: UIImage(systemName: "checkmark.circle.fill"), handler: {
                    (_) in
//                    self.delegate2?.sendReadRecord(readBible: ReadBible(address: self.pikAddressName!, chapter: self.pikChapterNum!))
                    let pushVC = self.storyboard?.instantiateViewController(withIdentifier: "ReadBibleViewController") as? ReadBibleViewController
                    pushVC?.hidesBottomBarWhenPushed = true
                    pushVC?.readBibleRecord = ReadBible(address: self.pikAddressName!, chapter: self.pikChapterNum!)
                    pushVC?.pikAddressName = self.pikAddressName
                    pushVC?.launchType = true
                    self.navigationController?.pushViewController(pushVC!, animated: true)
                })
            ]
        }
        
        menuBtn.menu = UIMenu(title: "Menu", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        changeVersion()
        loadBibleVersion()
        usingDB()
        
//        loadWord()
//        pikAddressName = self.wordSave[0].address
//        pikChapterNum = self.wordSave[0].chapter
//        txtAddress.text = "\(pikAddressName!)".localized() + "   " + "\(pikChapterNum!)"
        
        self.loadStarList()
        self.chapterTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func saveWord() {
        let word = self.wordSave.map {
            [
                "address": $0.address,
                "chapter": $0.chapter
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(word, forKey: "untilReading")
    }
    
    private func loadWord() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "untilReading") as? [[String: Any]] else { return }
        self.wordSave = data.compactMap {
            guard let address = $0["address"] as? String else { return nil }
            guard let chapter = $0["chapter"] as? String else { return nil }
            return WordSave(address: address, chapter: chapter)
        }
    }
    
    // setting에서 성경버전을 바꿨을 때 tableview에서 제대로 말씀,버튼이 보이도록 하는 함수
    private func changeVersion() {
        if changeBibleVersion {
            is_NIV = false
            is_KJV = false
            is_KJV_KOR = false
            is_NIV_KOR = false
            btnList.removeAll()
            btnKJV_KOR.isEnabled = true
            btnKJV.isEnabled = true
            btnNIV.isEnabled = true
            btnNIV_KOR.isEnabled = true
            btnKJV_KOR.frame.size.width = 91.5
            btnKJV.frame.size.width = 52.5
            btnNIV_KOR.frame.size.width = 76
            btnNIV.frame.size.width = 49.5
            btnColor(btn: btnKJV_KOR, isClicked: is_KJV_KOR)
            btnColor(btn: btnKJV, isClicked: is_KJV)
            btnColor(btn: btnNIV, isClicked: is_NIV)
            btnColor(btn: btnNIV_KOR, isClicked: is_NIV_KOR)
            btnList.append("\(setBibleVersion[0].type)")
            if "\(setBibleVersion[0].type)" == "KJV흠정역" {
                is_KJV_KOR = true
                btnColor(btn: btnKJV_KOR, isClicked: is_KJV_KOR)
                btnKJV_KOR.isEnabled = false
            } else if "\(setBibleVersion[0].type)" == "KJV" {
                is_KJV = true
                btnColor(btn: btnKJV, isClicked: is_KJV)
                btnKJV.isEnabled = false
            } else if "\(setBibleVersion[0].type)" == "NIV" {
                is_NIV = true
                btnColor(btn: btnNIV, isClicked: is_NIV)
                btnNIV.isEnabled = false
            } else if "\(setBibleVersion[0].type)" == "개역개정" {
                is_NIV_KOR = true
                btnColor(btn: btnNIV_KOR, isClicked: is_NIV_KOR)
                btnNIV_KOR.isEnabled = false
            }
            changeBibleVersion = false
        }
    }
    
    // 파이어베이스에 있는 말씀들 꺼내오기(type별로)
    private func usingDB() {
        // DB
        ref = Database.database().reference()
        ref.child("\(setBibleVersion[0].type)").child(pikAddressName!).child(pikChapterNum!).observe(.value) { [weak self] snapshot in
            guard let value = snapshot.value as? [NSDictionary] else { return }
            do {
                
                let jsonData = try JSONSerialization.data(withJSONObject: value)
                let bibleData = try JSONDecoder().decode([Verse].self, from: jsonData)
                self?.numOfVerse = bibleData.count
                self?.oneChapterList = bibleData
                DispatchQueue.main.async {
                    self?.chapterTableView.reloadData()
                }
            } catch let error {
                print("Error JSON parsing: \(error.localizedDescription)")
            }
        }
    }
    
    // 이미 즐겨찾는 말씀 저장되어 있는 친구들 불러와서 중복방지
    private func loadStarList() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "starList") as? [[String: Any]] else { return }
        self.copyStarWords = data.compactMap {
            guard let address = $0["address"] as? String else { return nil }
            guard let chapter = $0["chapter"] as? String else { return nil }
            guard let verse = $0["verse"] as? String else { return nil }
            guard let word = $0["word"] as? String else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            return StarBible(address: address, chapter: chapter, verse: verse, word: word, isStar: isStar)
        }
    }
    
    @IBAction func KJV_KOR(_ sender: UIButton) {
        is_KJV_KOR = !is_KJV_KOR
        if is_KJV_KOR {             // 버튼클릭일 때,
            btnKJV_KOR.frame.size.width = 92 + 15
            btnList.append("KJV흠정역")
            addWords(btnType: "KJV흠정역")
        } else {
            btnKJV_KOR.frame.size.width = 91.5
            let indexNumOfBtn = btnList.firstIndex(of: "KJV흠정역")!
            btnList = btnList.filter {
                $0 != "KJV흠정역"
            }
            eraseWords(idxNumOfBtn: indexNumOfBtn)
            self.chapterTableView.reloadData()
        }
        self.copyWords.removeAll()
        btnColor(btn: btnKJV_KOR, isClicked: is_KJV_KOR)
    }
    
    @IBAction func KJV(_ sender: UIButton) {
        is_KJV = !is_KJV
        if is_KJV {
            btnKJV.frame.size.width = 53 + 15
            btnList.append("KJV")
            addWords(btnType: "KJV")
        } else {
            btnKJV.frame.size.width = 52.5
            let indexNumOfBtn = btnList.firstIndex(of: "KJV")!
            btnList = btnList.filter {
                $0 != "KJV"
            }
            eraseWords(idxNumOfBtn: indexNumOfBtn)
            self.chapterTableView.reloadData()
        }
        self.copyWords.removeAll()
        btnColor(btn: btnKJV, isClicked: is_KJV)
    }
    
    @IBAction func NIV_KOR(_ sender: UIButton) {
        is_NIV_KOR = !is_NIV_KOR
        if is_NIV_KOR {
            btnNIV_KOR.frame.size.width = 76 + 15
            btnList.append("개역개정")
            addWords(btnType: "개역개정")
        } else {
            btnNIV_KOR.frame.size.width = 76
            let indexNumOfBtn = btnList.firstIndex(of: "개역개정")!
            btnList = btnList.filter {
                $0 != "개역개정"
            }
            eraseWords(idxNumOfBtn: indexNumOfBtn)
            self.chapterTableView.reloadData()
        }
        self.copyWords.removeAll()
        btnColor(btn: btnNIV_KOR, isClicked: is_NIV_KOR)
    }
    
    @IBAction func NIV(_ sender: UIButton) {
        is_NIV = !is_NIV
        if is_NIV {
            btnNIV.frame.size.width = 50 + 15
            btnList.append("NIV")
            addWords(btnType: "NIV")
        } else {
            btnNIV.frame.size.width = 49.5
            let indexNumOfBtn = btnList.firstIndex(of: "NIV")!
            btnList = btnList.filter {
                $0 != "NIV"
            }
            eraseWords(idxNumOfBtn: indexNumOfBtn)
            self.chapterTableView.reloadData()
        }
        self.copyWords.removeAll()
        btnColor(btn: btnNIV, isClicked: is_NIV)
    }
    
    @IBAction func beforeChap(_ sender: UIButton) {
        self.chapterTableView.backgroundColor = .backgroundColor
        self.btnAfter.isEnabled = true
        self.oneChapterList.removeAll()
        self.copyWords.removeAll()
        self.copyStarWords.removeAll()
        self.pikChapterNum = String(Int(self.pikChapterNum!)! - 1)
        for i in btnList {
            addWords(btnType: i)
        }
        self.chapterTableView.reloadData()
        
        txtAddress.text = "\(pikAddressName!)".localized() + "   " + "\(pikChapterNum!)".localized()
        self.wordSave[0].address = "\(pikAddressName!)"
        self.wordSave[0].chapter = "\(pikChapterNum!)"
        print("pickerView:", "\(pikAddressName!)".localized() + "   " + "\(pikChapterNum!)".localized(), "선택됨")
        if Int(self.pikChapterNum!)! == 1 {
            self.btnBefore.isEnabled = false
        }
    }
    
    @IBAction func afterChap(_ sender: UIButton) {
        self.chapterTableView.backgroundColor = .backgroundColor
        self.btnBefore.isEnabled = true
        self.oneChapterList.removeAll()
        self.copyWords.removeAll()
        self.copyStarWords.removeAll()
        self.pikChapterNum = String(Int(self.pikChapterNum!)! + 1)
        for i in btnList {
            addWords(btnType: i)
        }
        self.chapterTableView.reloadData()
        
        txtAddress.text = "\(pikAddressName!)".localized() + "   " + "\(pikChapterNum!)".localized()
        self.wordSave[0].address = "\(pikAddressName!)"
        self.wordSave[0].chapter = "\(pikChapterNum!)"
        print("pickerView:", "\(pikAddressName!)".localized() + "   " + "\(pikChapterNum!)".localized(), "선택됨")
        
        let endChapter = name.firstIndex(of: self.pikAddressName!)
        if Int(self.pikChapterNum!) == address_chapterNum[endChapter!] {
            self.btnAfter.isEnabled = false
        }
    }
    
    @IBAction func click_Menu(_ sender: UIButton) {
        
    }
    
    // 성경버전 버튼을 눌렀을 때, 안 눌렀을 때 디자인 설정
    func btnColor(btn: UIButton, isClicked: Bool) {
        if isClicked {
            btn.setImage(UIImage(systemName: "checkmark",
                                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold, scale: .default)), for: .normal)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            btn.configuration?.background.backgroundColor = UIColor.lightGray
            btn.configuration?.baseForegroundColor = UIColor.black
        } else {
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            btn.setImage(UIImage(), for: .normal)
            btn.configuration?.background.backgroundColor = UIColor.clear
            btn.configuration?.baseForegroundColor = .textLabelColor
        }
        self.selectedBtnLabel.text = "Order".localized() + ": " + "\(self.btnList)"
        self.selectedBtnLabel.adjustsFontSizeToFitWidth = true
        print("btnList: \(btnList)")
    }
    
    // 피커뷰생성
    func createPickerView() {
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.reloadAllComponents()
        txtAddress.tintColor = .clear
        txtAddress.inputView = pickerView
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let btnDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onPickerDone))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(onPickerCancel))
        toolBar.setItems([btnCancel,space,btnDone], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        txtAddress.inputView = pickerView
        txtAddress.inputAccessoryView = toolBar
    }
    
    @objc func onPickerDone() {
        // 피커뷰 내림
        self.chapterTableView.backgroundColor = .backgroundColor
        txtAddress.resignFirstResponder()
        txtAddress.text = "\(pikAddressName!)".localized() + "   " + "\(pikChapterNum!)".localized()
        print("pickerView:", "\(pikAddressName!)".localized() + "   " + "\(pikChapterNum!)".localized(), "선택됨")
        
        self.wordSave[0].address = "\(pikAddressName!)"
        self.wordSave[0].chapter = "\(pikChapterNum!)"
        
        // 성경말씀 갱신
        self.oneChapterList.removeAll()
        for i in btnList {
            addWords(btnType: i)
        }
        self.chapterTableView.reloadData()
        self.copyWords.removeAll()
        self.copyStarWords.removeAll()
        
        // after, before Btn 설정
        if Int(self.pikChapterNum!)! == 1 {
            self.btnBefore.isEnabled = false
        } else {
            self.btnBefore.isEnabled = true
        }
        
        let endChapter = name.firstIndex(of: self.pikAddressName!)
        if Int(self.pikChapterNum!) == address_chapterNum[endChapter!] {
            self.btnAfter.isEnabled = false
        } else {
            self.btnAfter.isEnabled = true
        }
    }
    
    @objc func onPickerCancel() {
        txtAddress.resignFirstResponder()
    }
    
}


extension WordsViewController {
    // 파이어베이스에서 피커뷰의 선택,버튼 선택,이전장,다음장 설정에 따른 말씀 가져오기
    func addWords(btnType: String) {
        ref = Database.database().reference()
        ref.child(btnType).child(pikAddressName!).child(pikChapterNum!).observe(.value) { [weak self] snapshot in
            guard let value = snapshot.value as? [NSDictionary] else { return }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value)
                let bibleData = try JSONDecoder().decode([Verse].self, from: jsonData)
                self?.numOfVerse = bibleData.count
                self?.oneChapterList.append(contentsOf: bibleData)
                self?.chapterTableView.reloadData()
            } catch let error {
                print("Error JSON parsing: \(error.localizedDescription)")
            }
        }
    }
    
    // 현재 테이블에 나와있는 말씀들이 피커뷰의 선택,버튼 선택,이전장,다음장 설정에 따른 말씀 리셋됨
    func eraseWords(idxNumOfBtn: Int) {
        let start = self.numOfVerse! * idxNumOfBtn
        let end = (self.numOfVerse! + self.numOfVerse! * idxNumOfBtn)
        oneChapterList.removeSubrange(start..<end)
    }
}


/*
    Setting for Text
*/
extension UIColor {
    static let textLabelColor = UIColor(named: "labelColor")
    static let sectionColor = UIColor(named: "SectionColor")
    static let backgroundColor = UIColor(named: "backgroundColor")
}

extension String {
    func localized(comment: String="") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}


/*
    PickerView
*/
extension WordsViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    // 열 개수(선택2개)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // 표시될 항목 개수 반환
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return name.count
        } else {
            self.com0 = name.firstIndex(of: pikAddressName!)!
            print(self.com0)
            return address_chapterNum[self.com0]
        }
    }
    
    // 각 컴포넌트의 행마다 어떤 문자열을 보여줄지
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return name[row].localized()
        }
        else {
            var arrChapterNum : [String] = []
//            let selectedAd = pickerView.selectedRow(inComponent: 0)
            let selectedAd = name.firstIndex(of: pikAddressName!)!
            let number = address_chapterNum[selectedAd]
            for i in 0...(number - 1) {
                arrChapterNum.append(String(i+1))
            }
            if arrChapterNum.indices.contains(row) {
//                print("arrChapterNum: ", arrChapterNum[row])
                return arrChapterNum[row]
            } else {
                return nil
            }
        }
    }
    
    // 피커뷰의 스크롤이 움직여서 값이 선택됐을 때 호출
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.selectRow(0, inComponent: 1, animated: false)
        }
        let addIndex = pickerView.selectedRow(inComponent: 0)
        self.com0 = addIndex
        self.pikAddressName = name[addIndex]
        let chapterIndex = pickerView.selectedRow(inComponent: 1)
//        self.pikAddressName = name[addIndex]
        self.pikChapterNum = String(chapterIndex + 1)
        print(self.pikChapterNum)
        pickerView.reloadComponent(1)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 35
    }
}

/*
    Table
*/
extension WordsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == numberOfSections(in: tableView)-1 ? 0:0.35
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section != numberOfSections(in: tableView)-1 else {
            return nil
        }
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "SeperatorTableViewFooter")
    }
    
    // number of section
    func numberOfSections(in tableView: UITableView) -> Int {
        if ((oneChapterList.isEmpty) || (btnList.count == 0)) {
            return 0
        } else {
//            return oneChapterList[0].bibleWords.count
            return oneChapterList.count / btnList.count
        }
    }
    
    // number of cell in one section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return oneChapterList.count
        return btnList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.chapterTableView.backgroundColor = .backgroundColor
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChapterCell", for: indexPath) as? ChapterCell else {
            return UITableViewCell()
        }
        let idx: Int?
        // indexPath.row는 한 section 안에서의 행
        // indexPath.section은 절의 수
        if indexPath.row == 0 {
            idx = indexPath.section
            cell.verseLabel?.text = oneChapterList[idx!].verse + "   " + oneChapterList[idx!].word
            cell.verseLabel?.textColor = .textLabelColor
        } else if indexPath.row == 1 {
            idx = indexPath.section + (oneChapterList.count/btnList.count)
            cell.verseLabel?.text = oneChapterList[idx!].verse + "   " + oneChapterList[idx!].word
            cell.verseLabel?.textColor = UIColor(red: 0.7765, green: 0.3333, blue: 0.3412, alpha: 1.0)
        } else if indexPath.row == 2 {
            idx = indexPath.section + (oneChapterList.count/btnList.count) * 2
            cell.verseLabel?.text = oneChapterList[idx!].verse + "   " + oneChapterList[idx!].word
            cell.verseLabel?.textColor = UIColor(red: 0.4667, green: 0.698, blue: 0.1882, alpha: 1.0)
        } else {
            idx = indexPath.section + (oneChapterList.count/btnList.count) * 3
            cell.verseLabel?.text = oneChapterList[idx!].verse + "   " + oneChapterList[idx!].word
            cell.verseLabel?.textColor = UIColor(red: 0.3137, green: 0.702, blue: 0.9294, alpha: 1.0)
        }
        
        self.chapterTableView.backgroundColor = .sectionColor
        return cell
    }
    
    // 선택한 row에 대해 복사하도록
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ChapterCell
        let aword: String = cell?.verseLabel.text as! String
        let index = aword.index(aword.endIndex, offsetBy: (-aword.count + 4))
        let txt = aword[index...]
        let starWord: StarBible = StarBible(address: self.pikAddressName!, chapter: self.pikChapterNum!, verse: String(indexPath.section + 1), word: String(txt), isStar: true)
        var idx: Bool = true
        // Copy - copyWords배열에 선택한 말씀이 없다면 추가
        if !self.copyWords.contains(aword) {
            self.copyWords.append(cell?.verseLabel.text as! String)
        }
        // Highlight - copyStarWords배열에 선택한 말씀이 없다면 추가
        if !self.copyStarWords.isEmpty {
            for i in 0...self.copyStarWords.count - 1 {
                if self.copyStarWords[i].verse == starWord.verse {
                    idx = false
                    break
                }
            }
        }
        
        if idx {
            self.copyStarWords.append(StarBible(address: self.pikAddressName!, chapter: self.pikChapterNum!, verse: String(indexPath.section + 1), word: String(txt), isStar: true))
        }
//        print("생성: \(self.copyStarWords)")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Copy
        let cell = tableView.cellForRow(at: indexPath) as? ChapterCell
        let aword: String = cell?.verseLabel.text as! String
        let index = aword.index(aword.endIndex, offsetBy: (-aword.count + 4))
        let txt = aword[index...]
        let starWord: StarBible = StarBible(address: self.pikAddressName!, chapter: self.pikChapterNum!, verse: String(indexPath.section + 1), word: String(txt), isStar: true)
        self.copyWords = self.copyWords.filter {
            $0 != aword
        }
        
        // Highlight
        for i in 0...self.copyStarWords.count - 1 {
            if self.copyStarWords[i].verse == starWord.verse {
                self.copyStarWords.remove(at: i)
                break
            }
        }
//        print("삭제: \(self.copyStarWords)")
    }
}
