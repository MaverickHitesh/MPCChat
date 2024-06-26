//
//  ChatView.swift
//  MPC chat
//
//  Created by Hitesh Singh on 26/06/24.
//

import SwiftUI
import MultipeerConnectivity

struct ChatView: View {
    @State private var messageText = ""
    @ObservedObject var viewModel = ChatViewModel.shared
    var peer: MCPeerID?
    
    init(peer: MCPeerID? = nil) {
        self.peer = peer
    }
    
    var body: some View {
        VStack {
            let messages = getMessages()
            
            List(messages) { message in
                HStack {
                    if message.isSentByCurrentUser {
                        Spacer()
                        let msg = "Me: \(message.content ?? "")"
                        Text(msg)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    } else {
                        let msg = "\(message.sender ?? ""): \(message.content ?? "")"
                        Text(msg)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(10)
                            .foregroundColor(.black)
                        Spacer()
                    }
                }
            }
            HStack {
                TextField("Enter message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    if !messageText.isEmpty {
                        if MPCManager.shared.connectedPeers.count > 0 {
                            viewModel.sendMessage(messageText, peer: self.peer)
                            messageText = ""
                        }
                    } else {
                        print("message empty")
                    }
                }) {
                    Text("Send")
                }
            }
            .padding()
        }
    }
    
    private func getMessages() -> [Message] {
        if let displayName = self.peer?.displayName {
            let x = viewModel.messages.filter { msg in
                msg.sender == displayName || msg.isSentByCurrentUser
            }
            return x
        }
        return viewModel.messages
    }
}

