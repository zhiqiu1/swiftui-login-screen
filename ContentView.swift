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
    @State private var message = ""
    
    // isASuccessMessage determines message color
    @State private var isASuccessMessage = false
    
    @State private var displaysMessageAfterPickerChange = false
    
    var body: some View {
        VStack {
            Text("Welcome")
                .font(.largeTitle)
            Picker(selection: $selected, label: Text(""), content: {
                Text("Sign in").tag(0)
                Text("Sign up").tag(1)
            }).pickerStyle(SegmentedPickerStyle())
            
            // After mannually changing picker, message is reset
            // If picker is changed by the app, it won't reset until manually switching
            .onChange(of: selected, perform: { _ in
                if displaysMessageAfterPickerChange {
                    displaysMessageAfterPickerChange.toggle()
                } else {
                    setMessage("", success: false)
                }
            })
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            switch selected {
            
            // Sign in
            case 0:
                SecureField("Password", text: $password)
                Text(message)
                    .foregroundColor(isASuccessMessage ? .black : .red)
                Button("Sign In", action: signIn)
                Button("Forgot Password?", action: {selected = 2})
                    .buttonStyle(DefaultButtonStyle())
                    .foregroundColor(.gray)
                
            // Sign up
            case 1:
                SecureField("Password", text: $password)
                SecureField("Confirm Password", text: $confirmPassword)
                Text(message)
                    .foregroundColor(isASuccessMessage ? .black : .red)
                Button("Sign Up", action: signUp)
                
            // Reset password
            default:
                SecureField("New Password", text: $password)
                SecureField("Confirm New Password", text: $confirmPassword)
                Text(message)
                    .foregroundColor(isASuccessMessage ? .black : .red)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Reset Password", action: resetPassword)
            }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .buttonStyle(RoundedRectangleButtonStyle())
        .padding(20)
    }
    
    struct RoundedRectangleButtonStyle: ButtonStyle {
      func makeBody(configuration: Configuration) -> some View {
        Button(action: {}, label: {
          HStack {
            Spacer()
            configuration.label.foregroundColor(.black)
            Spacer()
          }
        })
        // 👇🏻 makes all taps go to the the original button
        .allowsHitTesting(false)
        .padding()
        .background(Color.gray.cornerRadius(8))
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
      }
    }
    
    private func signIn() {
        if isValidEmail(email) {
            do {
                let record = try viewContext.fetch(getEmailFetchRequest(email: email))
                
                // If email is registered
                if record.count == 1 {
                    if record[0].password == password {
                        setMessage("Sign in success!", success: true)
                    } else {
                        setMessage("Wrong password", success: false)
                    }
                } else {
                    
                    // Jump to sign up UI and show the message if not registered
                    setMessage("This email is not registered. Please sign up.", success: false)
                    switchPickerAndDisplayMessage(selection: 1)
                    
                }
            } catch {
                
            }
        } else {
            setMessage("Please enter a valid email address", success: false)
        }
    }
    
    private func signUp() {
        if isValidEmail(email) {
            do {
                let record = try viewContext.fetch(getEmailFetchRequest(email: email))
                
                // If the account is not registered
                if record.count == 0 {
                    if (password == "") {
                        setMessage("Password cannot be empty", success: false)
                    } else if (password != confirmPassword) {
                        setMessage("Passwords do not match", success: false)
                    } else {
                        
                        // Save account info to Core Data
                        let newAccount = Account(context: viewContext)
                        newAccount.email = email.lowercased()
                        newAccount.password = password
                        try viewContext.save()
                        
                        // Jump to sign in UI and show the success message after registration
                        setMessage("Thank you for signing up!", success: true)
                        switchPickerAndDisplayMessage(selection: 0)
                        
                        confirmPassword = ""
                    }
                } else {
                    setMessage("This email is already registered. Please Sign in.", success: false)
                    switchPickerAndDisplayMessage(selection: 0)
                }
            } catch {
                
            }
        } else {
            setMessage("Please enter a valid email address", success: false)
        }
    }
    
    private func resetPassword() {
        if isValidEmail(email) {
            do {
                let record = try viewContext.fetch(getEmailFetchRequest(email: email))
                if record.count == 1 {
                    if (password == "") {
                        setMessage("Password cannot be empty", success: false)
                    } else if (password != confirmPassword) {
                        setMessage("Passwords do not match", success: false)
                    } else {
                        
                        record[0].password = password
                        try viewContext.save()
                        
                        setMessage("Success", success: true)
                        switchPickerAndDisplayMessage(selection: 0)
                        confirmPassword = ""
                    }
                } else {
                    setMessage("This email is not registered", success: false)
                }
            } catch {
                
            }
        } else {
            setMessage("Please enter a valid email address", success: false)
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // A fetchRequest that is used to check whether specified email is registered
    private func getEmailFetchRequest(email: String) -> NSFetchRequest<Account> {
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email = %@", email.lowercased())
        return fetchRequest
    }
    
    private func setMessage(_ newMessage: String, success: Bool) {
        message = newMessage
        isASuccessMessage = success
    }
    
    private func switchPickerAndDisplayMessage(selection: Int) {
        selected = selection
        displaysMessageAfterPickerChange = true
    }
}
