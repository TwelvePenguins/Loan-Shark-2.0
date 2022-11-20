//
//  PersonDetailView.swift
//  Loan Shark
//
//  Created by Ethan Lim on 1/11/22.
//
import SwiftUI

struct PersonDetailView: View {
    
    @ObservedObject var manager: TransactionManager
    @State var showTransactionDetailSheet = false
    var person : Person
    var userTransactions: [Transaction] {
        manager.allTransactions.filter {
            $0.people.contains(where: { people in
                person.name == people.name
            })
        }
    }
    // New code
    var body: some View {
        NavigationView{
            List {
                Section(header: Text("ONGOING TRANSACTIONS")) {

                    ForEach(userTransactions.filter { $0.transactionStatus == .unpaid || $0.transactionStatus == .overdue || $0.transactionStatus == .dueInOneWeek}) { transaction in
                        Button {
                            showTransactionDetailSheet = true
                        } label: {
                            HStack{
                                VStack{
                                    Text(transaction.name)
                                    Text("Due in \(Date.now...transaction.dueDate) days")
                                }
                                Spacer()
                                Text("$" + String(format: "%.2f", transaction.totalMoney()))
                                    .foregroundColor(.secondary)
                                    .font(.title2)
                            }
                        }

                    }
                }
                Section(header: Text("TRANSACTION HISTORY")) {
                    ForEach(userTransactions.filter { $0.transactionStatus == .paidOff }) { transaction in
                        Button {
                            showTransactionDetailSheet = true
                        } label: {
                            HStack{
                                VStack{
                                    Text(transaction.name)
                                    Text("Due in \(Date.now...transaction.dueDate) days")
                                }
                                Spacer()
                                Text("$" + String(format: "%.2f", transaction.totalMoney()))
                                    .foregroundColor(Color(red: 0.8, green: 0, blue: 0))
                                    .font(.title2)
                            }
                        }
                    }
                }

            }
        }
        .navigationTitle(person.name)
    }
    
// Old code
//    var body: some View {
//        NavigationView{
//            List {
//                Section(header: Text("ONGOING TRANSACTIONS")) {
//
//                    ForEach(userTransactions.filter { $0.transactionStatus == .unpaid || $0.transactionStatus == .overdue || $0.transactionStatus == .dueInOneWeek}) { transaction in
//                        Button {
//                            showTransactionDetailSheet = true
//                        } label: {
//                            HStack{
//                                VStack{
//                                    Text(transaction.name)
//                                    Text("Due in \(Date.now...transaction.dueDate) days")
//
//                                }
//                                Spacer()
//                                HStack {
//                                    Text("$")
//                                    Text(String(transaction.totalMoney()))
//                                }
//                                .foregroundColor(.secondary)
//                                .font(.title2)
//                            }
//                        }
//
//                    }
//                }
//                Section(header: Text("TRANSACTION HISTORY")) {
//                    ForEach(userTransactions.filter { $0.transactionStatus == .paidOff }) { transaction in
//                        Button {
//                            showTransactionDetailSheet = true
//                        } label: {
//                            HStack{
//                                VStack{
//                                    Text(transaction.name)
//                                    Text("Due in \(Date.now...transaction.dueDate) days")
//                                }
//                                Spacer()
//                                HStack {
//                                    Text("$")
//                                    Text(String(transaction.totalMoney()))
//                                }                                }
//                            .foregroundColor(Color(red: 0.8, green: 0, blue: 0))
//                            .font(.title2)
//                        }
//                    }
//                }
//            }
//
//        }
//        .navigationTitle(person.name)
//    }
}



//struct contactDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        PersonDetailView(person: Person(name: "Jeremy"))
//    }
//}
