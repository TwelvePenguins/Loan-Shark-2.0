//
//  NewTransactionSheet.swift
//  Loan Shark
//
//  Created by Yuhan Du Du Du Du on 6/11/22.
//
// Duhan Du Du Du

import SwiftUI

struct NewTransactionSheet: View {
    
    @StateObject var manager = TransactionManager()
    @State var isDetailSyncronised: Bool = false
    @State var dueDate = Date()
    @State var transactionType = ""
    @State var fieldsUnfilled = true
    var transactionTypes = ["Select", "Loan", "Bill split"]
    @Environment(\.dismiss) var dismiss
    
    var decimalNumberFormat: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.allowsFloats = true
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = "$"
        return numberFormatter
    }
    
    @State var newTransaction = Transaction(name: "", people: [Person(name: "", money: 0, dueDate: Date.now)], transactionType: .unselected)
    @Binding var transactions: [Transaction]
    
    @State private var numberOfPeople = 0
    @State var hasOtherPeople = false
    @State private var refreshScreen = false
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Transaction details")) {
                        HStack {
                            Text("Title")
                            TextField("Title", text: $newTransaction.name)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.trailing)
                        }
                        Picker("Transaction type", selection: $transactionType) {
                            ForEach(transactionTypes, id: \.self) {
                                Text($0)
                            }
                        }
                        
                        if transactionType == "Bill split" {
                            Toggle(isOn: $isDetailSyncronised){
                                Text("Syncronise details")}
                        }
                    }
                    if transactionType == "Loan" {
                        NavigationLink {
                            PeopleSelectorView(manager: manager, peopleSelected: $newTransaction.people, isMultiSelect: false)
                        } label: {
                            Text("Person")
                        }
                        HStack {
                            Text("Amount of money")
                            TextField("Amount", value: $newTransaction.people[0].money, formatter: NumberFormatter())
                            TextField("Amount", value: $newTransaction.people[0].money, formatter: NumberFormatter())
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                        }
                        DatePicker("Due by", selection: $dueDate, in: Date.now..., displayedComponents: .date)
                    }
                    else if transactionType == "Bill split" && !isDetailSyncronised {
                        if hasOtherPeople == true {
                            ForEach(0...numberOfPeople-1, id: \.self) { i in
                                Section(header: Text("Person \(i+1)")) {
                                    NavigationLink {
                                        PeopleSelectorView(manager: manager, peopleSelected: $newTransaction.people, isMultiSelect: false)
                                    } label: {
                                        Text("Person")
                                    }
                                    HStack {
                                        Text("Total amount")
                                        TextField("Amount", value: $newTransaction.people[i].money, formatter: NumberFormatter())
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.trailing)
                                            .keyboardType(.decimalPad)
                                    }
                                    DatePicker("Due by", selection: $dueDate, in: Date.now..., displayedComponents: .date)
                                }
                            }
                        }
                        
                        Section {
                            Button {
                                withAnimation {
                                    numberOfPeople += 1
                                }
                                hasOtherPeople = true
                                newTransaction.people.append(Person(name: "", money: 0.0, dueDate: Date()))
                            } label: {
                                Text("Add contacts")
                            }
                            if hasOtherPeople {
                                Button {
                                    withAnimation{
                                        numberOfPeople -= 1
                                    }
                                    if numberOfPeople <= 1 {
                                        hasOtherPeople = false
                                    }
                                    newTransaction.people.remove(at: newTransaction.people.count - 1)
                                } label: {
                                    Text("Remove contact")
                                }
                            }
                        }
                        
                    } else if transactionType == "Bill split" && isDetailSyncronised {
                        NavigationLink {
                            PeopleSelectorView(manager: manager, peopleSelected: $newTransaction.people, isMultiSelect: true)
                        } label: {
                            Text("People")
                        }
                        HStack {
                            Text("Amount")
                            TextField("Amount each", value: $newTransaction.people[0].money, formatter: NumberFormatter())
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                        }
                        DatePicker("Due by", selection: $dueDate, in: Date.now..., displayedComponents: .date)
                    }
                }
                
                Button {
                    transactions.append(newTransaction)
                    dismiss()
                } label: {
                    Text("Save")
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .opacity(fieldsUnfilled ? 0.5 : 1)
                }
                .disabled(fieldsUnfilled)
                .padding(.horizontal)
            }
            .navigationTitle("New transaction")
            .onChange(of: numberOfPeople) { _ in
                refreshScreen.toggle()
            }
            .onAppear() {
                print(numberOfPeople)
            }
        }
    }
}




struct NewTransactionSheet_Previews: PreviewProvider {
    static var previews: some View {
        NewTransactionSheet(transactions: .constant([]))
    }
}

//TODO: App freezes if title field is filled in, and sheet is dismissed

