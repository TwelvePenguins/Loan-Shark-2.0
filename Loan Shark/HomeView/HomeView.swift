//
//  HomeView.swift
//  Loan Shark
//
//  Created by Ethan Lim on 30/10/22.
// ...
import SwiftUI
import UIKit
import UserNotifications

enum EditButtons {
    case delete
    case cancel
    case save (Transaction)
}

struct HomeView: View {
    
    @ObservedObject var manager: TransactionManager
    
    @State var showNewTransactionSheet = false
    @State var reload = false
    @State var showDeleteAlert = false
    @State var addTransactionNotification = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Overdue")) {
                    ForEach($manager.sortedTransactions) { $transaction in
                        if transaction.transactionStatus == .overdue {
                            TransactionRowView(manager: manager, transaction: $transaction)
                                .swipeActions {
                                    Button {
                                        showDeleteAlert = true
                                    } label: {
                                        HStack{
                                            Image(systemName: "trash")
                                        }
                                    }
                                    .tint(Color("RadRed"))
                                }
                                .alert("Are you sure you want to delete this transaction?", isPresented: $showDeleteAlert, actions: {
                                    Button(role: .cancel) {
                                        print("CanCeLLeD")
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
                
                Section(header: Text("Due in 7 days")) {
                    ForEach($manager.sortedTransactions) { $transaction in
                        if transaction.transactionStatus == .dueInOneWeek {
                            TransactionRowView(manager: manager, transaction: $transaction)
                                .swipeActions {
                                    Button {
                                        showDeleteAlert = true
                                    } label: {
                                        HStack{
                                            Image(systemName: "trash")
                                        }
                                    }
                                    .tint(Color("RadRed"))
                                }
                                .alert("Are you sure you want to delete this transaction?", isPresented: $showDeleteAlert, actions: {
                                    Button(role: .cancel) {
                                        print("CanCeLLeD")
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
                Section(header: Text("Others")) {
                    ForEach($manager.sortedTransactions) { $transaction in
                        if transaction.transactionStatus == .unpaid {
                            TransactionRowView(manager: manager, transaction: $transaction)
                                .swipeActions {
                                    Button {
                                        showDeleteAlert = true
                                    } label: {
                                        HStack{
                                            Image(systemName: "trash")
                                        }
                                    }
                                    .tint(Color("RadRed"))
                                }
                                .alert("Are you sure you want to delete this transaction?", isPresented: $showDeleteAlert, actions: {
                                    Button(role: .cancel) {
                                        print("CanCeLLeD")
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
                Section(header: Text("Completed")) {
                    ForEach($manager.sortedTransactions) { $transaction in
                        if transaction.transactionStatus == .paidOff {
                            TransactionRowView(manager: manager, transaction: $transaction)
                                .swipeActions {
                                    Button {
                                        showDeleteAlert = true
                                    } label: {
                                        HStack{
                                            Image(systemName: "trash")
                                        }
                                    }
                                    .tint(Color("RadRed"))
                                }
                                .alert("Are you sure you want to delete this transaction?", isPresented: $showDeleteAlert, actions: {
                                    Button(role: .cancel) {
                                        print("CanCeLLeD")
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
            .navigationTitle("Home")
            .searchable(text: $manager.searchTerm, prompt: Text("Search for a transaction"))
            .toolbar {
                Button {
                    showNewTransactionSheet = true
                } label: {
                    Image(systemName: "plus.app")
                }
                .sheet(isPresented: $showNewTransactionSheet) {
                    NewTransactionSheet(manager: manager, transactions: $manager.allTransactions)
                }
                Picker(selection: $manager.selectedSortMethod) {
                    Label("Time Due", systemImage: "clock")
                        .tag(SortingMethods.timeDue)
                    Label("Amount Due", systemImage: "dollarsign.circle")
                        .tag(SortingMethods.amount)
                    Label("Alphabetically", systemImage: "line.3.horizontal.decrease.circle")
                        .tag(SortingMethods.alphabetically)
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
}


