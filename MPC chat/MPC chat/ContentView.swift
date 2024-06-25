//
//  ContentView.swift
//  MPC chat
//
//  Created by Hitesh Singh on 24/06/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ChatViewModel()

    var body: some View {
        
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Messages")) {
                        ForEach(viewModel.messages, id: \.self) { message in
                            Text("\(message.sender ?? ""): \(message.content ?? "")")
                        }
                    }
                    Section(header: Text("Available Peers")) {
                        ForEach(MPCManager.shared.availablePeers, id: \.self) { peer in
                            Text(peer.displayName)
                        }
                    }
                    Section(header: Text("Connected Peers")) {
                        ForEach(MPCManager.shared.connectedPeers, id: \.self) { peer in
                            Text(peer.displayName)
                        }
                    }
                }
                HStack {
                    TextField("Enter message", text: $viewModel.messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(minHeight: CGFloat(30))
                    Button(action: {
                        viewModel.sendMessage()
                    }) {
                        Text("Send")
                    }
                }.padding()
            }
            .navigationBarTitle("MPC Chat")
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}


#Preview {
    ContentView()//.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
