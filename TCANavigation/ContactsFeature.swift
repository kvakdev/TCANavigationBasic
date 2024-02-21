//
//  ContactsFeature.swift
//  TCANavigation
//
//  Created by Andrii Kvashuk on 21/02/2024.
//

import SwiftUI
import ComposableArchitecture

struct Contact: Identifiable, Equatable {
    let id: UUID
    var name: String
}

@Reducer
struct ContactsFeature {
    
    @ObservableState
    struct State {
        @Presents var addContact: AddContactsFeature.State?
        var contacts: IdentifiedArrayOf<Contact> = []
    }
    
    enum Action {
        case addButtonTapped
        case addContact(PresentationAction<AddContactsFeature.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.addContact = AddContactsFeature.State(contact: Contact(id: UUID(), name: "Bob"))
                return .none
       
            case .addContact(.presented(.delegate(let addContactAction))):
                switch addContactAction {
                case .cancel:
                    state.addContact = nil
                    
                    return .none
                case .saveContact(let contact):
                    state.contacts.append(contact)
                    state.addContact = nil
                    
                    return .none
                }
            case .addContact:
                return .none
            }
        }
        .ifLet(\.$addContact, action: \.addContact) {
            AddContactsFeature()
        }
    }
}

struct ContactsView: View {
  @Bindable var store: StoreOf<ContactsFeature>
  
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.contacts) { contact in
                    Text(contact.name)
                }
            }
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem {
                    Button {
                        store.send(.addButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(item: $store.scope(state: \.addContact,
                                  action: \.addContact)) { store in
            NavigationStack {
                AddContactsView(store: store)
            }
        }
  }
}

#Preview {
  ContactsView(
    store: Store(
      initialState: ContactsFeature.State(
        contacts: [
          Contact(id: UUID(), name: "Blob"),
          Contact(id: UUID(), name: "Blob Jr"),
          Contact(id: UUID(), name: "Blob Sr"),
        ]
      )
    ) {
      ContactsFeature()
    }
  )
}
