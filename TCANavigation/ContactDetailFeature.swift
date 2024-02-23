//
//  ContactDetailFeature.swift
//  TCANavigation
//
//  Created by Andrii Kvashuk on 23/02/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ContactDetailFeature {
    
    @ObservableState
      struct State: Equatable {
        let contact: Contact
      }
    
      enum Action {
     
      }
    
      var body: some ReducerOf<Self> {
        Reduce { state, action in
          switch action {
          }
        }
      }
}

struct ContactDetailView: View {
    let store: StoreOf<ContactDetailFeature>
    
    var body: some View {
        Form {
        }
        .navigationBarTitle(Text(store.contact.name))
    }
}

#Preview {
  NavigationStack {
    ContactDetailView(
      store: Store(
        initialState: ContactDetailFeature.State(
          contact: Contact(id: UUID(), name: "Blob")
        )
      ) {
        ContactDetailFeature()
      }
    )
  }
}
