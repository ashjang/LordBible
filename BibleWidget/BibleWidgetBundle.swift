//
//  BibleWidgetBundle.swift
//  BibleWidget
//
//  Created by 장하림 on 9/26/24.
//

import WidgetKit
import SwiftUI

@main
struct BibleWidgetBundle: WidgetBundle {
    var body: some Widget {
        BibleWidget()
        BibleWidgetLiveActivity()
    }
}
