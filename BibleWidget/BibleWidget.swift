//
//  BibleWidget.swift
//  BibleWidget
//
//  Created by 장하림 on 9/26/24.
//

import WidgetKit
import SwiftUI

// 앱에 들어가지 않아도 데이터 출력
struct Provider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> BibleEntry {
        BibleEntry(date: Date(), address: "말씀주소", word: "말씀구절")
    }

    // 위젯 갤러리에서 샘플로 보여질 부분
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> BibleEntry {
        Provider.getSmallWidgetData()
    }
    
    // 정의한 타임라인에 맞게 업데이트해서 보여질 부분
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<BibleEntry> {
        var entries: [BibleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()

        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = Provider.getSmallWidgetData()
            entries.append(entry)
        }
        WidgetCenter.shared.reloadAllTimelines()
        
        return Timeline(entries: entries, policy: .after(currentDate.addingTimeInterval(3600)))
    }
    
    public static func getSmallWidgetData() -> BibleEntry {
        let sharedDefaults = UserDefaults(suiteName: "group.com.Harim.Lordwords")
        let addressData = (sharedDefaults?.string(forKey: "smallWidgetAddress"))!
        let wordData = sharedDefaults?.string(forKey: "smallWidgetWord")
        return BibleEntry(date: Date(), address: addressData, word: wordData!)
    }
    
//    public static func getLargeWidgetData() -> [StarEntry] {
//        let sharedDefaults = UserDefaults(suiteName: "group.com.Harim.Lordwords")
//        if let jsonString = sharedDefaults?.string(forKey: "largeWidgetList") {
//            let jsonData = jsonString.data(using: .utf8)!
//            do {
//                let starEntries = try JSONDecoder().decode([StarEntry].self, from: jsonData)
//                print("inside of widget: \(starEntries[1].address)")
//                return starEntries
//            } catch {
//                print("JSON 디코딩 실패: \(error)")
//                return []
//            }
//        } else {
//            return []
//        }
//    }
//    
//    public static func getPhoto() -> (UIImage, String) {
//        
//    }
}

struct Provider2: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> BibleEntry {
        BibleEntry(date: Date(), address: "성경 주소", word: "구절")
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> BibleEntry {
        Provider2.getSecondWidgetData()
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<BibleEntry> {
        var entries: [BibleEntry] = []
        let currentDate = Date()

        // Generate a timeline consisting of five entries an hour apart.
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = Provider2.getSecondWidgetData() // Adjust to get second widget data
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .after(currentDate.addingTimeInterval(3600)))
    }
    
    public static func getSecondWidgetData() -> BibleEntry {
        let sharedDefaults = UserDefaults(suiteName: "group.com.Harim.Lordwords")
        let addressData = sharedDefaults?.string(forKey: "secondWidgetAddress") ?? "암송할 메시지를 선택해주세요"
        let wordData = sharedDefaults?.string(forKey: "secondWidgetWord") ?? "(어플 내에서 설정할 수 있습니다.)"
        return BibleEntry(date: Date(), address: addressData, word: wordData)
    }
}

struct BibleEntry: TimelineEntry {
    let date: Date
    let address: String
    let word: String
}

struct StarEntry: Codable {
    let address: String
    let chapter: String
    let verse: String
    let word: String
    var isStar: Bool
}

// app 꾸미기
struct BibleWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    
//    let largeDatas = Provider.getLargeWidgetData()

    var body: some View {
        switch self.family {
            case .systemSmall:
                VStack {
                    Text(Provider.getSmallWidgetData().address).lineLimit(1).bold().padding(.bottom, 7).frame(alignment: .leading)
                    Text(Provider.getSmallWidgetData().word).font(.footnote)
                }
                .containerBackground(for: .widget) {
                    Color("lockscreenbackground").opacity(0.5)
                }
            case .systemMedium:
                VStack(alignment: .leading) {
                    Text(Provider.getSmallWidgetData().address).lineLimit(1).truncationMode(.tail).bold().padding(.bottom, 9)
                    Text(Provider.getSmallWidgetData().word).lineLimit(5).truncationMode(.tail).font(.subheadline)
                }
                .containerBackground(for: .widget) {
                    Color("lockscreenbackground").opacity(0.5)
                }.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                
            case .accessoryRectangular:
                VStack(spacing: 5) {
                    Text(Provider.getSmallWidgetData().address).bold().font(.callout)
                    Text(Provider.getSmallWidgetData().word).font(.caption)
                }.containerBackground(for: .widget) {
                    Color("lockscreenbackground").opacity(0.9)
                }
            
            case .accessoryCircular:
                ZStack {
                    AccessoryWidgetBackground().edgesIgnoringSafeArea(.all)
                    VStack(spacing: 5) {
                        Text("✝️")
                    }.containerBackground(for: .widget) {
                        Color("lockscreenbackground").opacity(0.9)
                    }
                }
                

            @unknown default:
              Text("출력이 불가능합니다")
            }
    }
}

struct BibleSecondWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider2.Entry
    
//    let largeDatas = Provider.getLargeWidgetData()
    
    var body: some View {
        switch self.family {
            
            case .systemSmall:
                VStack {
                    Text("⭐️ \(Provider2.getSecondWidgetData().address)").lineLimit(1).bold().padding(.bottom, 7).frame(alignment: .leading)
                    Text(Provider2.getSecondWidgetData().word).font(.footnote)
                }
                .containerBackground(for: .widget) {
                    Color("lockscreenbackground").opacity(0.9)
                }
            
            case .systemMedium:
                VStack(alignment: .leading) {
                    Text("⭐️ \(Provider2.getSecondWidgetData().address)").lineLimit(1).truncationMode(.tail).bold().padding(.bottom, 9)
                    Text(Provider2.getSecondWidgetData().word).lineLimit(5).truncationMode(.tail).font(.subheadline)
                }
                .containerBackground(for: .widget) {
                    Color("lockscreenbackground").opacity(0.5)
                }.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                
            case .accessoryRectangular:
                VStack(spacing: 5) {
                    Text("⭐️ \(Provider2.getSecondWidgetData().address)").bold().font(.callout)
                    Text(Provider2.getSecondWidgetData().word).font(.caption)
                }.containerBackground(for: .widget) {
                    Color("lockscreenbackground").opacity(0.5)
                }.widgetURL(URL(string: "Bible://WordsViewController"))
            case .accessoryCircular:
                ZStack {
                    AccessoryWidgetBackground().edgesIgnoringSafeArea(.all)
                    VStack(spacing: 5) {
                        Text("✝️")
                    }.containerBackground(for: .widget) {
                        Color("lockscreenbackground").opacity(0.5)
                    }
                }

            @unknown default:
              Text("출력이 불가능합니다")
            }
        
        
    }
}


struct BibleWidget: Widget {
    let kind: String = "BibleWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()) { entry in
                
            if #available(iOS 16.0, *) {
                BibleWidgetEntryView(entry: entry)
//                        .containerBackground(.fill.tertiary, for: .widget)
            } else {
                BibleWidgetEntryView(entry: entry).padding()
            }
                
        }
        .configurationDisplayName("오늘의 말씀")
        .description("매일 말씀 묵상해보세요 :)")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryCircular])
        
    }
}


struct BibleWidget2: Widget {
    let kind: String = "BibleWidget2"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider2()) { entry in
                if #available(iOS 16.0, *) {
                    BibleSecondWidgetEntryView(entry: entry)
//                        .containerBackground(.fill.tertiary, for: .widget)
                } else {
                    BibleSecondWidgetEntryView(entry: entry).padding()
                }
        }
            .configurationDisplayName("성경 암송")
            .description("원하는 말씀을 암송해보세요 :)")
            .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryCircular])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🩵"
        return intent
    }
}
