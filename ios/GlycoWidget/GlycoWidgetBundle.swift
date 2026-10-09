//
//  GlycoWidgetBundle.swift
//  GlycoWidget
//
//  Created by Martim Nunes on 09/10/2026.
//

import WidgetKit
import SwiftUI

struct GlycoWidgetBundle: WidgetBundle {
    var body: some Widget {
        GlycoWidget()
        GlycoWidgetControl()
        GlycoWidgetLiveActivity()
    }
}
