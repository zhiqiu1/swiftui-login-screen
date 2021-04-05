//
//  ContentView.swift
//  project
//
//  Created by vm on 4/3/21.
//

import SwiftUI
import CoreData

//struct ContentView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
//
//    var body: some View {
//        List {
//            ForEach(items) { item in
//                Text("Item at \(item.timestamp!, formatter: itemFormatter)")
//            }
//            .onDelete(perform: deleteItems)
//        }
//        .toolbar {
//            #if os(iOS)
//            EditButton()
//            #endif
//
//            Button(action: addItem) {
//                Label("Add Item", systemImage: "plus")
//            }
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//}
//
//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()
//



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selected = 0
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var status = ""
    @State private var successStatus = false
    @State private var displayStatusAfterPickerChange = false
    
    var body: some View {
        VStack {
            Text("Welcome")
                .font(.largeTitle)
            Picker(selection: $selected, label: Text(""), content: {
                Text("Sign in").tag(0)
                Text("Sign up").tag(1)
                Text("Forget password").tag(2)
            }).pickerStyle(SegmentedPickerStyle())
            .onChange(of: selected, perform: { _ in
                if displayStatusAfterPickerChange {
                    displayStatusAfterPickerChange.toggle()
                } else {
                    setStatus("", success: false)
                }
            })
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
            
            switch selected {
            case 0:
                SecureField("Password", text: $password)
                Text(status)
                    .foregroundColor(successStatus ? .black : .red)
                Button(action: signIn) {
                    Text("Sign in")
                }
            case 1:
                SecureField("Password", text: $password)
                SecureField("Confirm Password", text: $confirmPassword)
                Text(status)
                    .foregroundColor(successStatus ? .black : .red)
                Button(action: signUp) {
                    Text("Sign up")
                }
            default:
                SecureField("New Password", text: $password)
                SecureField("Confirm New Password", text: $confirmPassword)
                Text(status)
                    .foregroundColor(successStatus ? .black : .red)
                Button(action: resetPassword) {
                    Text("Reset Password")
                }
            }
        }
    }
    private func signIn() {
        if isValidEmail(email) {
            if email == "1@com.com" {
                if true {
                    status = "Success"
                } else {
                    status = "Wrong password"
                }
            } else if true {
                setStatus("This email is not registered. Please sign up.", success: false)
                selected = 1
                displayStatusAfterPickerChange = true
            }
        } else {
            setStatus("Please enter a valid email address", success: false)
        }
    }
    
    private func signUp() {
        if isValidEmail(email) && password != "" {
            if true {
                let newAccount = Account(context: viewContext)
                newAccount.email = email
                newAccount.password = password
                do {
                    try viewContext.save()
                } catch {
                    
                }
                setStatus("Thank you for signing up!", success: true)
                selected = 0
                displayStatusAfterPickerChange = true
                print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")
            } else {
                setStatus("This email is already registered. Please Sign in.", success: false)
                selected = 0
                displayStatusAfterPickerChange = true
            }
        } else if true {
            status = "This email is already registered."
        }
    }
    
    private func resetPassword() {
        if true {
            setStatus("Success", success: true)
        } else if true {
            setStatus("This email is not registered.", success: false)
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func setStatus(_ message: String, success: Bool) {
        status = message
        successStatus = success
    }
    
    private func changPickerAndDisplayMessage(_ message: String, success: Bool) {
        status = message
        successStatus = success
    }
}
