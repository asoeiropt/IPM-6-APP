//
//  GlycoWidgetLiveActivity.swift
//  GlycoWidget
//
//  Created by Martim Nunes on 09/10/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct GlycoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct GlycoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GlycoWidgetAttributes.self) { context in
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

extension GlycoWidgetAttributes {
    fileprivate static var preview: GlycoWidgetAttributes {
        GlycoWidgetAttributes(name: "World")
    }
}

extension GlycoWidgetAttributes.ContentState {
    fileprivate static var smiley: GlycoWidgetAttributes.ContentState {
        GlycoWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: GlycoWidgetAttributes.ContentState {
         GlycoWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: GlycoWidgetAttributes.preview) {
   GlycoWidgetLiveActivity()
} contentStates: {
    GlycoWidgetAttributes.ContentState.smiley
    GlycoWidgetAttributes.ContentState.starEyes
}
