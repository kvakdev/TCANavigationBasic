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
        @Presents var alert: AlertState<Action.Alert>?
        var contacts: IdentifiedArrayOf<Contact> = []
    }
    
    enum Action {
        case addButtonTapped
        case addContact(PresentationAction<AddContactsFeature.Action>)
        case deleteButtonTapped(id: Contact.ID)
        case alert(PresentationAction<Alert>)
        
        enum Alert {
            case confirmDeletion(id: Contact.ID)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.addContact = AddContactsFeature.State(contact: Contact(id: UUID(), name: "Bob"))
                return .none
       
            case .addContact(.presented(.delegate(.saveContact(let contact)))):
                state.contacts.append(contact)
                
                return .none
            
            case .addContact:
                return .none
            
            case let .deleteButtonTapped(id: id):
                state.alert = AlertState {
                    TextState("Are you sure?")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                        TextState("Delete")
                    }
                }
                return .none
                
            case let .alert(.presented(.confirmDeletion(id: id))):
                state.contacts.remove(id: id)
                
                return .none
                
            case .alert(.dismiss):
                return .none
            }
        }
        .ifLet(\.$addContact, action: \.addContact) {
            AddContactsFeature()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

struct ContactsView: View {
  @Bindable var store: StoreOf<ContactsFeature>
  
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.contacts) { contact in
                    HStack {
                        Text(contact.name)
                        Spacer()
                        Button {
                            store.send(.deleteButtonTapped(id: contact.id))
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
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
        .alert(store: store.scope(state: \.$alert, action: \.alert))
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
