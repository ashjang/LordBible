import Foundation
import UIKit


let name: Array<String> = ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth", "1Samuel", "2Samuel", "1Kings", "2Kings", "1Chronicles", "2Chronicles", "Ezra", "Nehemiah", "Esther", "Job", "Psalms", "Proverbs", "Ecclesiastes", "SongofSongs", "Isaiah", "Jeremiah", "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos", "Obadiah", "Jonah", "Micah", "Nahum" ,"Habakkuk", "Zephaniah", "Haggai", "Zechariah", "Malachi", "Matthew", "Mark", "Luke", "John", "Acts", "Romans", "1Corinthians", "2Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians", "1Thessalonians", "2Thessalonians", "1Timothy", "2Timothy", "Titus", "Philemon", "Hebrews", "James", "1Peter", "2Peter", "1John", "2John", "3John", "Jude", "Revelation"]

let address_chapterNum: Array<Int> = [
        50,40,27,36,34,24,
        21,4,31,24,22,25,
        29,36,10,13,10,42,
        150,31,12,8,66,52,
        5,48,12,14,3,9,
        1,4,7,3,3,3,
        2,14,4,28,16,24,
        21,28,16,16,13,6,
        6,4,4,5,3,6,
        4,3,1,13,5,5,
        3,5,1,1,1,22]

let type: Array<String> = [
    "KJV흠정역", "KJV", "개역개정", "NIV"
]

struct Verse: Codable {
    let chapter: String
    let id: String
    let verse: String
    let word: String
}

struct RandomBible: Codable {
    let address: String
    let chapter: String
    let verse: String
    let word: String
}

struct BibleVersion: Codable {
    var type: String
}

var setBibleVersion = [BibleVersion]() {
    didSet {
        saveBibleVersion()
    }
}

var changeBibleVersion: Bool = false

// bible version 설정을 userDefaults에 저장 및 사용
func saveBibleVersion() {
    let version = setBibleVersion.map {
        [
            "type": $0.type
        ]
    }
    let userDefaults = UserDefaults.standard
    userDefaults.set(version, forKey: "bibleVersion")
}

func loadBibleVersion() {
    let userDefaults = UserDefaults.standard
    guard let data = userDefaults.object(forKey: "bibleVersion") as? [[String: Any]] else { return }
    setBibleVersion = data.compactMap {
        guard let type = $0["type"] as? String else { return nil
    }
    return BibleVersion(type: type)
    }
}

var wordAddress: String?
var wordText: String?
