//
//  MyPillWidgetLiveActivity.swift
//  MyPillWidget
//
//  Created by 박윤수 on 3/18/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MyPillWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MyPillWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MyPillWidgetAttributes.self) { context in
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

extension MyPillWidgetAttributes {
    fileprivate static var preview: MyPillWidgetAttributes {
        MyPillWidgetAttributes(name: "World")
    }
}

extension MyPillWidgetAttributes.ContentState {
    fileprivate static var smiley: MyPillWidgetAttributes.ContentState {
        MyPillWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MyPillWidgetAttributes.ContentState {
         MyPillWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MyPillWidgetAttributes.preview) {
   MyPillWidgetLiveActivity()
} contentStates: {
    MyPillWidgetAttributes.ContentState.smiley
    MyPillWidgetAttributes.ContentState.starEyes
}
