import UIKit

class ReadBibleViewController: UIViewController  {
    
    @IBOutlet weak var readTimeLabel: UILabel!
    @IBOutlet weak var bookNameTxt: UITextField!
    @IBOutlet weak var chapterCollectionView: UICollectionView! {
        didSet {
            chapterCollectionView.delegate = self
            chapterCollectionView.dataSource = self
        }
    }
    
    
    var pikAddressName: String?
    private var chapter = 0
    private var tempAddress = "Genesis"
    private var readList = [ReadBible]() {
        didSet {
            self.saveReadList()         // readList의 배열의 읽은 권,장들이 추가되거나 변경이 일어날 때마다 userDefaults에 저장됨
        }
    }
    
    private var readTimes = [ReadTimes(time: 0, totalChap: 0)] {
        didSet {
            self.saveTimesOfReading()
        }
    }
    
    var readBibleRecord: ReadBible?
    private var isAllRead: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pikAddressName = "Genesis"
        bookNameTxt.text = "Genesis".localized()
//        bookNameTxt.layer.borderWidth = 2.0
        bookNameTxt.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 8.0, height: 0.0))
        readTimeLabel.text = "0 " + "times".localized()
        bookNameTxt.layer.borderColor = UIColor.lightGray.cgColor
        bookNameTxt.layer.borderWidth = 1.2
        bookNameTxt.layer.cornerRadius = 10
        bookNameTxt.leftViewMode = .always
        createPickerView()
        loadReadList()
        loadTimesOfReading()
        
        readTimeLabel.text = "\(readTimes[0].time) " + "times".localized()
        receiveItemFromSetting()
        
        if let index = self.readList.firstIndex(where: {
            $0.address == "" && $0.chapter == ""
        }) {
            self.readList.remove(at: index)
        }
        print(self.readList)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadReadList()
        loadTimesOfReading()
        self.chapterCollectionView.reloadData()
        receiveItemFromSetting()
    }
    
    // 피커뷰 설정
    private func createPickerView() {
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: Int((UIScreen.main.bounds.height-20)/3)))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.reloadAllComponents()
        bookNameTxt.tintColor = .clear
        bookNameTxt.inputView = pickerView
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let btnDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onPickerDone))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(onPickerCancel))
        toolBar.setItems([btnCancel,space,btnDone], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        bookNameTxt.inputView = pickerView
        bookNameTxt.inputAccessoryView = toolBar
    }
    
    @objc func onPickerDone() {
        // 피커뷰 내림
        bookNameTxt.resignFirstResponder()
        bookNameTxt.text = "\(pikAddressName!)".localized()
        print("\(pikAddressName!)".localized() + " 선택됨")
        // view갱신
        self.chapterCollectionView.reloadData()
    }
    
    @objc func onPickerCancel() {
        bookNameTxt.resignFirstResponder()
    }
    
    // UserDefaults에 저장
    private func saveReadList() {
        let read = self.readList.map {
            [
                "address": $0.address,
                "chapter": $0.chapter
            ]
        }
//        print(read)
        let userDefaults = UserDefaults.standard
        userDefaults.set(read, forKey: "readList")
    }
    
    // UserDefaults에 저장된 읽기완료된 목록 로드
    private func loadReadList() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "readList") as? [[String: Any]] else { return }
        self.readList = data.compactMap {
            guard let address = $0["address"] as? String else { return nil }
            guard let chapter = $0["chapter"] as? String else { return nil }
            return ReadBible(address: address, chapter: chapter)
        }
    }
    
    private func saveTimesOfReading() {
        let time = self.readTimes.map {
            [
                "time": $0.time,
                "totalChap": $0.totalChap
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(time, forKey: "timesOfReading")
    }
    
    private func loadTimesOfReading() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "timesOfReading") as? [[String: Any]] else { return }
        self.readTimes = data.compactMap {
            guard let time = $0["time"] as? Int else { return nil }
            guard let totalChap = $0["totalChap"] as? Int else { return nil }
            return ReadTimes(time: time, totalChap: totalChap)
        }
    }
    
    func receiveItemFromSetting() {
        if self.readList.count == 1189 {
            self.isAllRead = true
            self.readList.removeAll()
            print("self.readListRemove: \(self.readList)")
            self.readTimes[0].time = self.readTimes[0].time + 1
            self.readTimeLabel.text = "\(readTimes[0].time) " + "times".localized()
        } else {
            if !self.readList.contains(where: {
                $0.address == self.readBibleRecord!.address && $0.chapter == self.readBibleRecord!.chapter
            }) {
                self.readList.append(self.readBibleRecord!)
    //            print("들어감")
            }
        }
        self.chapterCollectionView.reloadData()
    }
}

/*
    PickerView
*/
extension ReadBibleViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return name.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return name[row].localized()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pikAddressName = name[pickerView.selectedRow(inComponent: 0)]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 35
    }
}

/*
    CollectionView
*/
extension ReadBibleViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let index = name.firstIndex(of: self.pikAddressName!)
        return address_chapterNum[index!]
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReadCell", for: indexPath) as? ReadCell else { return UICollectionViewCell() }
        
        let chap = String(indexPath.row + 1)
        // readList에 읽기완료버튼으로 이미 존재한다면 색 변경
        if !self.isAllRead {
            if self.readList.contains(where: {
                $0.address == self.pikAddressName! && $0.chapter == chap
            }) {
                cell.chapterNumLabel.text = chap
                cell.contentView.backgroundColor = .lightGray
                return cell
            }
            cell.chapterNumLabel.text = chap
            return cell
        } else {
            cell.chapterNumLabel.text = chap
            self.isAllRead = false
            return cell
        }
        // 성경 총 장수는 1189

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 4) - 50, height: (UIScreen.main.bounds.width / 4) - 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard var cell = collectionView.cellForItem(at: indexPath) as? ReadCell else { fatalError() }
        print("didSelectItemAt")
        print(indexPath.row)
        let chap = String(indexPath.row + 1)
        if let index = self.readList.firstIndex(where: {
            $0.address == self.pikAddressName! && $0.chapter == chap
        }) {
            self.readList.remove(at: index)
            cell.contentView.backgroundColor = .clear
        }
        print(self.readList)
    }
}
