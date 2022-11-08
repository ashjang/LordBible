import UIKit
import MessageUI

class SettingViewController: UIViewController {
    @IBOutlet weak var gospelView: UIView!
    @IBOutlet weak var gospelLabel: UILabel!
    @IBOutlet weak var readView: UIStackView!
    @IBOutlet weak var readLaabel: UILabel!
    @IBOutlet weak var iconGospel: UILabel!
    @IBOutlet weak var iconRead: UILabel!
    @IBOutlet weak var setBibleVerLabel: UITextField!
    
    private var temp = ReadBible(address: "", chapter: "")

    private var initialBool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barViewControllers = self.tabBarController?.viewControllers![1] as! UINavigationController
        let svc = barViewControllers.topViewController as! WordsViewController
//        print(svc)
        svc.delegate2 = self
        [gospelView, readView].forEach {
            setView(view: $0)
        }
        gospelLabel.text = "Gospel".localized()
        readLaabel.text = "Reading Bible".localized()
        
        setIcon(label: self.iconGospel, systemString: "lightbulb.fill")
        setIcon(label: self.iconRead, systemString: "book.fill")
        
        self.readLaabel.adjustsFontSizeToFitWidth = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (self.GospelTap(_:)))
        self.gospelView.addGestureRecognizer(tapGesture)
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector (self.ReadBibleTap(_:)))
        self.readView.addGestureRecognizer(tapGesture2)
        
        self.navigationController?.navigationBar.tintColor = UIColor.textLabelColor
        createPickerView()
        loadBibleVersion()
        setBibleVerLabel.text = "\(setBibleVersion[0].type)".localized() + " >"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBibleVersion()
    }
    
    func setView(view: UIView) {
        view.layer.cornerRadius = 10
        view.layer.shadowOpacity = 0.1
        view.layer.shadowColor = UIColor.textLabelColor?.cgColor
        view.layer.masksToBounds = false
    }

    @objc func GospelTap(_ sender: UITapGestureRecognizer) {
        let pushVC = self.storyboard?.instantiateViewController(withIdentifier: "GospelViewController")
        pushVC?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(pushVC!, animated: true)
    }
    
    @objc func ReadBibleTap(_ sender: UITapGestureRecognizer) {
        let pushVC = self.storyboard?.instantiateViewController(withIdentifier: "ReadBibleViewController") as? ReadBibleViewController
        pushVC?.hidesBottomBarWhenPushed = true
        pushVC?.readBibleRecord = self.temp
        self.navigationController?.pushViewController(pushVC!, animated: true)
    }
    
    func setIcon(label: UILabel, systemString: String) {
        if let text = label.text {
            let attributedString = NSMutableAttributedString(string:text)
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: systemString)?.withTintColor(.lightGray)
            attributedString.append(NSAttributedString(attachment: imageAttachment))
            label.attributedText = attributedString
        }
    }
    
    @IBAction func contactBtn(_ sender: UIButton) {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["lordbibleapp@gmail.com"])
        composer.setMessageBody("If you have any questions or inconveniences while using it, please send us an email. Thank you :)".localized(), isHTML: false)
        
        present(composer, animated: true)
    }
    
    
    
    // picker view
    private func createPickerView() {
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: Int((UIScreen.main.bounds.height-20)/3)))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.reloadAllComponents()
        setBibleVerLabel.tintColor = .clear
        setBibleVerLabel.inputView = pickerView
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let btnDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onPickerDone))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(onPickerCancel))
        toolBar.setItems([btnCancel,space,btnDone], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        setBibleVerLabel.inputView = pickerView
        setBibleVerLabel.inputAccessoryView = toolBar
    }
    
    @objc func onPickerDone() {
        // 피커뷰 내림
        setBibleVerLabel.resignFirstResponder()
        setBibleVerLabel.text = "\(setBibleVersion[0].type)".localized() + " >"
        changeBibleVersion = true
    }
    
    @objc func onPickerCancel() {
        setBibleVerLabel.resignFirstResponder()
    }
    
}

extension SettingViewController: SettingViewDelegate {
    func sendReadRecord(readBible: ReadBible) {
        print("readBible")
        self.temp = readBible
    }
}

/*
 Picker view
*/
extension SettingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return type[row].localized()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setBibleVersion[0].type = type[pickerView.selectedRow(inComponent: 0)]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 35
    }
}


extension SettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
    }
}
