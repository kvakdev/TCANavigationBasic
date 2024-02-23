//
//  ContactsFeatureTests.swift
//  TCANavigationTests
//
//  Created by Andrii Kvashuk on 23/02/2024.
//

import ComposableArchitecture
import XCTest
@testable import TCANavigation


@MainActor
final class ContactsFeatureTests: XCTestCase {
  func testAddFlow() async {
      let store = TestStore(initialState: ContactsFeature.State.init(),
                            reducer: { ContactsFeature() },
                            withDependencies:  { $0.uuid = .incrementing })
      
      await store.send(.addButtonTapped) {
          $0.destination = .addContact(.init(contact: Contact(id: UUID(0), name: "")))
      }
      
      await store.send(.destination(.presented(.addContact(.setName("Blob Jr."))))) {
          $0.$destination[case: \.addContact]?.contact.name = "Blob Jr."
      }
      
      await store.send(.destination(.presented(.addContact(.saveButtonTapped))))
      
      await store.receive(
            \.destination.addContact.delegate.saveContact,
            Contact(id: UUID(0), name: "Blob Jr.")
          ) {
            $0.contacts = [
              Contact(id: UUID(0), name: "Blob Jr.")
            ]
          }
      await store.receive(\.destination.dismiss) {
          $0.destination = nil
      }
  }
    
    func testAddFlow_non_exaustive() async {
        let store = TestStore(initialState: ContactsFeature.State.init(),
                              reducer: { ContactsFeature() },
                              withDependencies:  { $0.uuid = .incrementing })
        store.exhaustivity = .off
        await store.send(.addButtonTapped)
        await store.send(.destination(.presented(.addContact(.setName("Blob Jr.")))))
        await store.send(.destination(.presented(.addContact(.saveButtonTapped))))
        await store.skipReceivedActions()
        
        store.assert { state in
            state.contacts = [
                Contact(id: UUID(0), name: "Blob Jr.")
            ]
            state.destination = nil
        }
    }
}
