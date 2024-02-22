//
//  TCANavigationApp.swift
//  TCANavigation
//
//  Created by Andrii Kvashuk on 21/02/2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCANavigationApp: App {
    var body: some Scene {
        WindowGroup {
            ContactsView(store: Store(initialState: .init(), reducer: { ContactsFeature() }))
        }
    }
}
