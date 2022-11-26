//
//  TransactionDetailView.swift
//  Loan Shark
//
//  Created by Ethan Lim on 15/11/22.
// ...

import SwiftUI
import UIKit

struct TransactionDetailView: View {
    
    @ObservedObject var manager: TransactionManager
    @Binding var transaction: Transaction
    @State var presentEditTransactionSheet = false
    @State var showDeleteAlert = false
    @State var reload = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                if transaction.transactionType == .loan {
                    HStack {
                        Button {
                            transaction.isNotificationEnabled.toggle()
                            reload.toggle()
                            transaction.isNotificationEnabled ? removeNotification(for: transaction) : addNotification(for: transaction)
                            manageNotification(for: transaction)
                        } label: {
                            Image(systemName: transaction.isNotificationEnabled ? "bell.fill" : "bell.slash")
                                .foregroundColor(transaction.isNotificationEnabled ? Color("AccentColor")  :Color("AccentColor2"))
                        }
                        Text("Loan")
                        Spacer()
                        Text("$" + String(format: "%.2f", transaction.totalMoney))
                    }
                    .padding(.horizontal)
                } else if transaction.transactionType == .billSplitSync {
                    HStack {
                        Button {
                            transaction.isNotificationEnabled.toggle()
                            reload.toggle()
                            transaction.isNotificationEnabled ? removeNotification(for: transaction) : addNotification(for: transaction)
                            manageNotification(for: transaction)
                        } label: {
                            Image(systemName: transaction.isNotificationEnabled ? "bell.fill" : "bell.slash")
                                .foregroundColor(transaction.isNotificationEnabled ? Color("AccentColor")  :Color("AccentColor2"))
                        }
                        Text("Bill split, synchronised")
                        Spacer()
                        Text("$" + String(format: "%.2f", transaction.totalMoney))
                    }
                    .padding(.horizontal)
                } else if transaction.transactionType == .billSplitNoSync {
                    HStack {
                        Button {
                            transaction.isNotificationEnabled.toggle()
                            reload.toggle()
                            transaction.isNotificationEnabled ? removeNotification(for: transaction) : addNotification(for: transaction)
                            manageNotification(for: transaction)
                        } label: {
                            Image(systemName: transaction.isNotificationEnabled ? "bell.fill" : "bell.slash")
                                .foregroundColor(transaction.isNotificationEnabled ? Color("AccentColor")  :Color("AccentColor2"))
                        }
                        Text("Bill split, unsynchronised")
                        Spacer()
                        Text("$" + String(format: "%.2f", transaction.totalMoney))
                    }
                    .padding(.horizontal)
                }
            }
            
            List {
                Section("UNPAID") {
                    ForEach($transaction.people) { $person in
                        if !person.hasPaid {
                            VStack {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(person.name ?? "No one Selected")
                                            .bold()
                                            .foregroundColor(Color("PrimaryTextColor"))
                                            .font(.title3)
                                        HStack(alignment: .center, spacing: 0) {
                                            Text(transaction.transactionStatus == .overdue ? "Due " : "Due in ")
                                                .foregroundColor(Color("SecondaryTextColor"))
                                            Text(person.dueDate!, style: .relative)
                                                .foregroundColor(Color("SecondaryTextColor"))
                                            if transaction.transactionStatus == .overdue {
                                                Text(" ago")
                                                    .foregroundColor(Color("SecondaryTextColor"))
                                            }
                                        }
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("$ \(String(format: "%.2f", person.money!))")
                                        .foregroundColor(transaction.transactionStatus == .overdue ? Color("RadRed") : Color("PrimaryTextColor"))
                                        .font(.title2)
                                        .foregroundColor(Color("PrimaryTextColor"))
                                }
                                .padding(.top, 5)
                                HStack(alignment: .top){
                                    SendMessageButton(transaction: transaction, person: person)
                                    Spacer()
                                    Button {
                                        withAnimation {
                                            person.hasPaid.toggle()
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "banknote")
                                            Text("Mark as paid")
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(Color("AccentColor"))
                                .padding(5)
                            }
                        }
                    }
                }
                Section("PAID") {
                    ForEach($transaction.people) { $person in
                        if person.hasPaid {
                            VStack {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(person.name ?? "No one Selected")
                                            .bold()
                                            .foregroundColor(Color("PrimaryTextColor"))
                                            .font(.title3)
                                    }
                                    Spacer()
                                    Text("$ \(String(format: "%.2f", person.money!))")
                                        .foregroundStyle(.secondary)
                                        .foregroundColor(Color("PrimaryTextColor"))
                                        .font(.title2)
                                }
                                .padding(.top, 5)
                                HStack(alignment: .top){
                                    Button {
                                        withAnimation {
                                            person.hasPaid.toggle()
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "banknote")
                                            Text("Mark as unpaid")
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundColor(Color("AccentColor"))
                                    .padding(5)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(transaction.name)
            .toolbar {
                Button {
                    presentEditTransactionSheet.toggle()
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                    }
                }
                .foregroundColor(Color("AccentColor"))
                .sheet(isPresented: $presentEditTransactionSheet) {
                    EditTransactionView(transaction: $transaction)
                }
                Button {
                    showDeleteAlert = true
                } label: {
                    HStack{
                        Image(systemName: "trash.fill")
                    }
                    .foregroundColor(Color("RadRed"))
                    .alert("Are you sure you want to delete this transaction?", isPresented: $showDeleteAlert, actions: {
                        Button(role: .cancel) {
                            
                        } label: {
                            Text("Cancel")
                        }
                        
                        Button(role: .destructive) {
                            if let transactionIndex = manager.allTransactions.firstIndex(where: {
                                $0.id == transaction.id
                            }) {
                                manager.allTransactions.remove(at: transactionIndex)
                            }
                        } label: {
                            Text("Delete")
                        }
                    }, message: {
                        Text("This action cannot be undone.")
                    })
                }
            }
        }
    }
    func manageNotification(for transaction: Transaction) {
        if transaction.isNotificationEnabled == true {
            addNotification(for: transaction)
        } else if transaction.isNotificationEnabled == false {
            try? removeNotification(for: transaction)
        }
    }
}
