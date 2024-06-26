//
//  ChatViewModel.swift
//  MPC chat
//
//  Created by Hitesh Singh on 24/06/24.
//

import Foundation
import SwiftUI
import CoreData
import MultipeerConnectivity

class ChatViewModel: ObservableObject {
    static let shared = ChatViewModel()

    @Published var messages: [Message] = []

    func sendMessage(_ message: String, peer: MCPeerID? = nil) {
        MPCManager.shared.send(message: message, peer: peer)
        saveMessage(content: message, isSentByCurrentUser: true)
    }

    func receiveMessage(_ message: String, from peer: String) {
        saveMessage(content: message, isSentByCurrentUser: false, sender: peer)
    }

    private func saveMessage(content: String, isSentByCurrentUser: Bool, sender: String = UIDevice.current.name) {
        let context = NSManagedObjectContext.current
        let newMessage = Message(context: context)
        newMessage.content = content
        newMessage.isSentByCurrentUser = isSentByCurrentUser
        newMessage.sender = sender
        newMessage.timestamp = Date()

        do {
            try context.save()
            messages.append(newMessage)
        } catch {
            print("Failed to save message: \(error.localizedDescription)")
        }
    }

    func fetchMessages() {
        let context = NSManagedObjectContext.current
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Message.timestamp, ascending: true)]
        
        do {
            messages = try context.fetch(request)
        } catch {
            print("Failed to fetch messages: \(error.localizedDescription)")
        }
    }
}
