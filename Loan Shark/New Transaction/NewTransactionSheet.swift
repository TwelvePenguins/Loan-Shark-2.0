//
//
//  NewTransactionSheet.swift
//  Loan Shark
//
//  Created by Yuhan Du Du Du Du on 6/11/22.
//
//
//

import SwiftUI

var decimalNumberFormat: NumberFormatter {
    let numberFormatter = NumberFormatter()
    numberFormatter.allowsFloats = true
    numberFormatter.numberStyle = .currency
    numberFormatter.currencySymbol = ""
    return numberFormatter
}

struct NewTransactionSheet: View {
    
    var manager: TransactionManager
    @State var isDetailSynchronised: Bool = false
    @State var dueDate = Date()
    @State var money = 0.0
    @State var transactionType = "Select"
    @State var enableNotifs = false
    @Environment(\.dismiss) var dismiss
    
    var insufficientPeople: Bool {
        if transactionType == "Bill split" {
            return people.filter({ $0.contact != nil }).count < 2
        } else {
            return false
        }
    }
    
    var blankMoney: Bool {
        return !people.filter { $0.contact != nil }.allSatisfy { $0.money != nil }
    }
    
    var fieldsUnfilled: Bool {
        name.isEmpty || transactionType == "Select" || people.filter({ $0.contact != nil }).count < 1 || insufficientPeople || blankMoney
    }
    
    var transactionTypes = ["Select", "Loan", "Bill split"]
    
    @State var name = ""
    @State var people: [Person] = [Person(contact: nil, money: 0, dueDate: .now, hasPaid: false)]
    
    @Binding var transactions: [Transaction]
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Transaction details")) {
                        HStack {
                            Text("Title")
                                .foregroundColor(Color("PrimaryTextColor"))
                            TextField("Title", text: $name)
                                .foregroundColor(Color("SecondaryTextColor"))
                                .multilineTextAlignment(.trailing)
                        }
                        Picker("Transaction type", selection: $transactionType) {
                            ForEach(transactionTypes, id: \.self) {
                                Text($0)
                            }
                        }
                        .foregroundColor(Color("PrimaryTextColor"))
                    }
                    Section {
                        Toggle(isOn: $enableNotifs ) {
                            Text("Enable notifications")
                        }
                    } footer: {
                        Text("Enable this to allow Money Rush to automatically send you notifications to remind you to collect your money back.")
                    }
                    
                    if transactionType == "Bill split" {
                        Section {
                            Toggle(isOn: $isDetailSynchronised) {
                                Text("Synchronise details")
                                    .foregroundColor(Color("PrimaryTextColor"))
                            }
                        } footer: {
                            Text("Toggle this to distribute the total amount of the transaction equally between all selected contacts, and for the same due date to apply for all. ")
                                .foregroundColor(Color("SecondaryTextColor"))
                        }
                    }
                    
                    if transactionType == "Loan" {
                        let contactBinding = Binding {
                            if let firstPereson = people.first {
                                return firstPereson.contact
                            }
                            return nil
                        } set: { contact in
                            people = [Person(contact: contact, money: people[0].money ?? 0, dueDate: people[0].dueDate ?? .now, hasPaid: false)]
                        }
                        
                        NavigationLink {
                            PeopleSelectorView(manager: manager, selectedContact: contactBinding)
                        } label: {
                            HStack {
                                Text("People")
                                    .foregroundColor(Color("PrimaryTextColor"))
                                Spacer()
                                Text(people[0].name ?? "No contact selected")
                                    .foregroundColor(Color("SecondaryTextColor"))
                            }
                        }
                        let bindingMoney = Binding {
                            people[0].money ?? 0
                        } set: { newValue in
                            people[0].money = newValue
                        }
                        HStack {
                            Text("Amount")
                                .foregroundColor(Color("PrimaryTextColor"))
                            Spacer()
                            Text("$")
                                .foregroundColor(Color("SecondaryTextColor"))
                            DecimalTextField(amount: bindingMoney, hint: "Amount")
                                .foregroundColor(Color("SecondaryTextColor"))
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 70)
                        }
                        
                        let bindingDate = Binding {
                            people[0].dueDate ?? .now
                        } set: { newValue in
                            people[0].dueDate = newValue
                        }
                        
                        DatePicker("Due by", selection: bindingDate, in: Date.now..., displayedComponents: .date)
                            .foregroundColor(Color("PrimaryTextColor"))
                        
                    } else if transactionType == "Bill split" && !isDetailSynchronised {
                        if !people.isEmpty {
                            let excludedContacts = people.compactMap({
                                $0.contact
                            })
                            ForEach($people, id: \.name) { $person in
                                Section(header: Text(person.name ?? "No contact selected")) {
                                    NavigationLink {
                                        PeopleSelectorView(manager: manager, selectedContact: $person.contact, excludedContacts: excludedContacts)
                                    } label: {
                                        HStack {
                                            Text("Person")
                                                .foregroundColor(Color("PrimaryTextColor"))
                                            Spacer()
                                            Text(person.name ?? "No contact selected")
                                                .foregroundColor(Color("SecondaryTextColor"))
                                        }
                                    }
                                    let bindingMoney = Binding {
                                        person.money ?? 0
                                    } set: { newValue in
                                        person.money = newValue
                                    }
                                    HStack {
                                        Text("Amount")
                                            .foregroundColor(Color("PrimaryTextColor"))
                                        Spacer()
                                        Text("$")
                                            .foregroundColor(Color("SecondaryTextColor"))
                                        DecimalTextField(amount: bindingMoney, hint: "Amount")
                                            .foregroundColor(Color("SecondaryTextColor"))
                                            .multilineTextAlignment(.trailing)
                                            .frame(maxWidth: 70)
                                    }
                                    
                                    let BindingDate = Binding {
                                        person.dueDate ?? Date.now
                                    } set: { newValue in
                                        person.dueDate = newValue
                                    }
                                    
                                    DatePicker("Due by", selection: BindingDate, in: Date.now..., displayedComponents: .date)
                                        .foregroundColor(Color("PrimaryTextColor"))
                                }
                            }
                        }
                        Section {
                            if !people.contains(where: {
                                $0.contact == nil
                            }) {
                                Button {
                                    withAnimation {
                                        people.append(Person(contact: nil, money: 0, dueDate: .now, hasPaid: false))
                                    }
                                } label: {
                                    Text("Add contacts")
                                }
                            }
                            
                            if !people.isEmpty {
                                Button {
                                    withAnimation {
                                        _ = people.removeLast()
                                    }
                                } label: {
                                    Text("Remove contact")
                                }
                            }
                        }
                    }
                    else if transactionType == "Bill split" && isDetailSynchronised {
                        
                        let contactsBinding = Binding {
                            people.compactMap {
                                $0.contact
                            }
                        } set: { newValue in
                            let money = people[0].money
                            let dueDate = people[0].dueDate
                            
                            if newValue.isEmpty {
                                people = [Person(contact: nil, money: money!, dueDate: dueDate!)]
                            } else {
                                people = newValue.map({ contact in
                                    Person(contact: contact, money: money!, dueDate: dueDate!)
                                })
                            }
                        }
                        
                        NavigationLink {
                            MultiplePeopleSelectorView(manager: manager, selectedContacts: contactsBinding)
                        } label: {
                            VStack(alignment: .leading) {
                                Text("People")
                                let names = people
                                    .compactMap {
                                        $0.name
                                    }
                                    .joined(separator: ", ")
                                
                                if !names.isEmpty {
                                    Text(names)
                                        .font(.caption)
                                        .foregroundColor(Color("SecondaryTextColor"))
                                } else {
                                    Text("No contact selected")
                                        .font(.caption)
                                        .foregroundColor(Color("SecondaryTextColor"))
                                }
                            }
                        }
                        let bindingMoney = Binding {
                            people[0].money ?? 0
                        } set: { newValue in
                            for peopleIndex in 0..<people.count {
                                people[peopleIndex].money = newValue
                            }
                        }
                        
                        HStack {
                            Text("Amount each")
                                .foregroundColor(Color("PrimaryTextColor"))
                            Spacer()
                            Text("$")
                                .foregroundColor(Color("SecondaryTextColor"))
                            DecimalTextField(amount: bindingMoney, hint: "Amount")
                                .foregroundColor(Color("SecondaryTextColor"))
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 70)
                        }
                        
                        let bindingDate = Binding {
                            people[0].dueDate ?? .now
                        } set: { newValue in
                            for peopleIndex in 0..<people.count {
                                people[peopleIndex].dueDate = newValue
                            }
                        }
                        DatePicker("Due by", selection: bindingDate, in: Date.now..., displayedComponents: .date)
                            .foregroundColor(Color("PrimaryTextColor"))
                    }
                }
                HStack {
                    Button {
                        guard people.first?.money != nil else { return }
                        let transactionTypeItem: TransactionTypes = {
                            switch transactionType {
                            case "Loan":
                                return .loan
                            case "Bill split":
                                return isDetailSynchronised ? .billSplitSync : .billSplitNoSync
                            default: return .unselected
                            }
                        }()
                        let transaction = Transaction(name: name, people: people.filter({
                            $0.contact != nil
                        }), transactionType: transactionTypeItem)
                        manageNotification(for: transaction)
                        transactions.append(transaction)
                        
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Save")
                                .frame(height: 50)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .background(Color("AccentColor"))
                        .opacity(fieldsUnfilled ? 0.5 : 1)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                    .disabled(fieldsUnfilled)
                    .padding(.leading, 20)
                    
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "clear")
                            Text("Cancel")
                                .frame(height: 50)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .background(Color("RadRed"))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                    .padding(.trailing, 20)
                }
            }
            .navigationTitle("New transaction")
            .onChange(of: transactionType) { newValue in
                people = [Person(contact: nil, money: 0, dueDate: .now, hasPaid: false)]
            }
            .onChange(of: isDetailSynchronised) { newValue in
                people = [Person(contact: nil, money: 0, dueDate: .now, hasPaid: false)]
            }
            .interactiveDismissDisabled()
        }
    }
    func manageNotification(for transaction: Transaction) {
        if transaction.isNotificationEnabled == true {
            addNotification(for: transaction)
        } else if transaction.isNotificationEnabled == false {
            removeNotification(for: transaction)
        }
    }
}
