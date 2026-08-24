//
//  ShazamCloneApp.swift
//  ShazamClone
//
//  Created by Emmanuel Kehinde on 03/07/2021.
//

import StoreKit
import SwiftUI

@main
struct ShazamCloneApp: App {
    init() {
        if SKCloudServiceController.authorizationStatus() == .notDetermined {
            SKCloudServiceController.requestAuthorization { _ in }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
