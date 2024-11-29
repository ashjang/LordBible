//
//  BibleWidgetLiveActivity.swift
//  BibleWidget
//
//  Created by 장하림 on 9/26/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BibleWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct BibleWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BibleWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension BibleWidgetAttributes {
    fileprivate static var preview: BibleWidgetAttributes {
        BibleWidgetAttributes(name: "World")
    }
}

extension BibleWidgetAttributes.ContentState {
    fileprivate static var smiley: BibleWidgetAttributes.ContentState {
        BibleWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: BibleWidgetAttributes.ContentState {
         BibleWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: BibleWidgetAttributes.preview) {
   BibleWidgetLiveActivity()
} contentStates: {
    BibleWidgetAttributes.ContentState.smiley
    BibleWidgetAttributes.ContentState.starEyes
}
