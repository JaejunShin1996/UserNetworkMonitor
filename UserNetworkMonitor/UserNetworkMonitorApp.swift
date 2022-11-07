//
//  UserNetworkMonitorApp.swift
//  UserNetworkMonitor
//
//  Created by Jaejun Shin on 7/11/2022.
//

import SwiftUI

@main
struct UserNetworkMonitorApp: App {
    let monitor = NetworkMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(monitor)
        }
    }
}
