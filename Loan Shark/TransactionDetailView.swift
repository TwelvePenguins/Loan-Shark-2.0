//
//  TransactionDetailView.swift
//  Loan Shark
//
//  Created by Ethan Lim on 15/11/22.
//

import SwiftUI
import UIKit

struct TransactionDetailView: View {
    
    @StateObject var manager = TransactionManager()
    @Binding var transaction: Transaction
    @State var presentEditTransactionSheet = false
    let pasteboard = UIPasteboard.general

    
    var body: some View {
        VStack(alignment: .leading){
            if transaction.transactionType == .loan {
                Text("Loan")
                    .font(.title2)
                    .padding(.horizontal)
            } else if transaction.transactionType == .billSplitSync {
                Text("Bill split, syncronised")
            } else if transaction.transactionType == .billSplitNoSync {
                Text("Bill split, unsyncronised")
            }
            List {
                ForEach(transaction.people) { person in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.white)
                        VStack{
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(person.name)
                                        .bold()
                                        .font(.title3)
                                    HStack(alignment: .center, spacing: 0) {
                                        Text(transaction.transactionStatus == .overdue ? "Due " : "Due in ")
                                        Text(transaction.dueDate, style: .relative)
                                        
                                        if transaction.transactionStatus == .overdue {
                                            Text(" ago")
                                        }
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("$ \(String(format: "%.2f", person.money))")
                                    .foregroundColor(transaction.transactionStatus == .overdue ? Color(red: 0.8, green: 0, blue: 0) : Color(.black))
                                    .font(.title2)
                            }
                            .padding(.top, 10)
                            HStack(alignment: .top){
                                Button {
                                    pasteboard.string = "Hello, world!"
                                } label: {
                                    HStack {
                                        Image(systemName: "message")
                                        Text("Send reminder")
                                    }
                                }
                                Spacer()
                                Button {
                                    person.hasPaid = true
                                } label: {
                                    HStack {
                                        Image(systemName: "banknote")
                                        Text("Mark as paid")
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.blue)
                            .padding(10)
                        }
                    }
                }
            }
        .navigationTitle(transaction.name)
        .toolbar {
            Button {
                presentEditTransactionSheet.toggle()
            } label: { Image(systemName: "pencil")}
                .sheet(isPresented: $presentEditTransactionSheet) {
                    NewTransactionSheet(transactions: $manager.allTransactions)
                }
            }
        }
    }
}

struct TransactionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionDetailView(transaction: .constant(Transaction(name: "Transaction name", people: [Person(name: "Person", money: 69, dueDate: "2023-12-25"), Person(name: "Person 2", money: 96, dueDate: "2023-12-25")], transactionType: .loan)))
    }
}
