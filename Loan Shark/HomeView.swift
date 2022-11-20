//
//  HomeView.swift
//  Loan Shark
//
//  Created by Ethan Lim on 30/10/22.
//

import SwiftUI

enum EditButtons {
    case delete
    case cancel
    case save (Transaction)
}

struct HomeView: View {
    
    @StateObject var manager = TransactionManager()
    
    //    @State var selectedTransactionIndex: Int?
    //    @State var selectedTransaction: Transaction? = nil
    //    @State var showTransactionDetailView = false
    @State var showNewTransactionSheet = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Overdue")) {
                    ForEach($manager.overdueTransactions) { $transaction in
                        NavigationLink {
                            TransactionDetailView(transaction: $transaction)
                        } label: {
                            HStack {
                                VStack (alignment: .leading) {
                                    Text(transaction.name)
                                    ForEach(transaction.people) { person in
                                        Text(person.name)
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                }
                                Spacer()
                                Text("$" + String(format: "%.2f", transaction.totalMoney()))
                                    .foregroundColor(transaction.transactionStatus == .overdue ? .red : .black)
                            }
                        }
                    }
                }
                Section(header: Text("Due in 7 days")) {
                    ForEach($manager.dueIn7DaysTransactions) { $transaction in
                        NavigationLink {
                            TransactionDetailView(transaction: $transaction)
                        } label: {
                            HStack {
                                VStack (alignment: .leading) {
                                    Text(transaction.name)
                                    ForEach(transaction.people) { person in
                                        Text(person.name)
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                }
                                Spacer()
                                Text("$" + String(format: "%.2f", transaction.totalMoney()))
                                    .foregroundColor(transaction.transactionStatus == .overdue ? .red : .black)
                            }
                        }
                    }
                }
                Section(header: Text("Others")) {
                    ForEach($manager.otherTransactions) { $transaction in
                        NavigationLink {
                            TransactionDetailView(transaction: $transaction)
                        } label: {
                            HStack {
                                VStack (alignment: .leading) {
                                    Text(transaction.name)
                                    ForEach(transaction.people) { person in
                                        Text(person.name)
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                }
                                Spacer()
                                Text("$" + String(format: "%.2f", transaction.totalMoney()))
                                    .foregroundColor(transaction.transactionStatus == .overdue ? .red : .black)
                            }
                        }
                    }
                }
                Section(header: Text("Completed")) {
                    ForEach($manager.completedTransactions) { $transaction in
                        NavigationLink {
                            TransactionDetailView(transaction: $transaction)
                        } label: {
                            HStack {
                                VStack (alignment: .leading) {
                                    Text(transaction.name)
                                    ForEach(transaction.people) { person in
                                        Text(person.name)
                                            .font(.caption)
                                    }
                                }
                                Spacer()
                                Text("$" + String(format: "%.2f", transaction.totalMoney()))
                            }
                            .foregroundColor(.gray)
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
                    NewTransactionSheet(manager: TransactionManager(), transactions: $manager.allTransactions)
                }
                Menu {
                    Button {
                        print("Filter by time")
                    } label: {
                        Label("Time Due", systemImage: "clock")
                    }
                    
                    Button {
                        print("Filter by amount due")
                    } label: {
                        Label("Amount Due", systemImage: "dollarsign.circle")
                    }
                    Button {
                        print("Filter by date added")
                    } label: {
                        Label("Date Added", systemImage: "calendar")
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
}
    
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView()
        }
    }
