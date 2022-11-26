//
//  PRESIRIVE.swift
//  Loan Shark
//
//  Created by Chan Yap Tong on 5/11/22.
//

import Foundation
import SwiftUI
import Contacts
import StringMetric

class TransactionManager: ObservableObject {
    @Published var allTransactions: [Transaction] = [] {
        didSet {
            save()
        }
    }
    
    @Published var selectedSortMethod = SortingMethods.alphabetically
    
    @Published var searchTerm = ""
    @Published var contactsList: [Contact] = []
    
    var sortedTransactions: [Transaction] {
        get {
            sort(transactions: (searchResults.isEmpty ? allTransactions : searchResults), by: selectedSortMethod)
        }
        
        set {
            for transaction in newValue {
                let transactionIndex = allTransactions.firstIndex(where: { $0.id == transaction.id })!
                allTransactions[transactionIndex] = transaction
            }
        }
    }

    var searchResults: [Transaction] {
        allTransactions.filter({ transaction in
            transaction.name.lowercased().contains(searchTerm.lowercased())
        })
    }
    
    let sampleTransactions: [Transaction] = []
    
    init() {
        load()
        loadContacts()
        print(getArchiveURL())
    }
    
    func getArchiveURL() -> URL {
        let plistName = "transactions.plist"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        return documentsDirectory.appendingPathComponent(plistName)
    }
    
    func save() {
        let archiveURL = getArchiveURL()
        let propertyListEncoder = PropertyListEncoder()
        let encodedTransactions = try? propertyListEncoder.encode(allTransactions)
        try? encodedTransactions?.write(to: archiveURL, options: .noFileProtection)
    }
    
    func load() {
        let archiveURL = getArchiveURL()
        let propertyListDecoder = PropertyListDecoder()
        
        var finalTransactions: [Transaction]!
        
        if let retrievedTransactionsData = try? Data(contentsOf: archiveURL),
           let decodedTransactions = try? propertyListDecoder.decode([Transaction].self, from: retrievedTransactionsData) {
            finalTransactions = decodedTransactions
        } else {
            finalTransactions = sampleTransactions
        }
        
        allTransactions = finalTransactions
    }
    
    func loadContacts() {
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
            if granted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        var contacts: [Contact] = []
                        
                        try store.enumerateContacts(with: request) { (contact, _) in
                            contacts.append(Contact(id: contact.identifier))
                        }
                        
                        DispatchQueue.main.async {
                            self.contactsList = contacts
                        }
                    } catch let error {
                        print("Failed to enumerate contact", error)
                    }
                }
            } else {
                print("access denied")
            }
        }
    }
    
    func sort(transactions: [Transaction], by sortingMethod: SortingMethods) -> [Transaction] {
        switch sortingMethod {
        case .timeDue:
            return transactions.sorted { firstTransaction, secondTransaction in
                firstTransaction.dueDate < secondTransaction.dueDate
            }
        case .amount:
            return transactions.sorted { firstTransaction, secondTransaction in
                firstTransaction.totalMoney < secondTransaction.totalMoney
            }
        case .alphabetically:
            return transactions.sorted { firstTransaction, secondTransaction in
                firstTransaction.name < secondTransaction.name
            }
        }
    }
}
