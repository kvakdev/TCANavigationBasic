//
//  AddContactsFeature.swift
//  TCANavigation
//
//  Created by Andrii Kvashuk on 21/02/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct AddContactsFeature {
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State: Equatable {
        var contact: Contact
        
        init(contact: Contact) {
            self.contact = contact
        }
    }
    
    enum Action {
        case setName(String)
        case delegate(Delegate)
        case saveButtonTapped
        case cancelButtonTapped
        
        enum Delegate: Equatable {
            case cancel
            case saveContact(Contact)
        }
    }

    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
          switch action {
          
          case .delegate:
            return .none
            
          case let .setName(name):
            state.contact.name = name
            return .none
          case .cancelButtonTapped:
              return .run { _ in await self.dismiss() }
          case .saveButtonTapped:
              return .run { [contact = state.contact] send in
                  await send(.delegate(.saveContact(contact)))
                  await self.dismiss()
              }
          }
        }
      }
}

struct AddContactsView: View {
    @Bindable var store: StoreOf<AddContactsFeature>
    
    var body: some View {
        Form {
             TextField("Name", text: $store.contact.name.sending(\.setName))
             Button("Save") {
                 store.send(.saveButtonTapped)
             }
           }
           .toolbar {
             ToolbarItem {
               Button("Cancel") {
                   store.send(.cancelButtonTapped)
               }
             }
           }
    }
}

#Preview {
    NavigationStack {
        AddContactsView(store:
                            Store(initialState: .init(
                                contact: Contact(id: UUID(),
                                                 name: "")),
                                  reducer: { AddContactsFeature() }))
    }
}
