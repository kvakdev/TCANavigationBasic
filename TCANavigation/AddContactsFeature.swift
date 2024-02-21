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
          case .saveButtonTapped:
              return .send(.delegate(.saveContact(state.contact)))
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
                   store.send(.delegate(.cancel))
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
