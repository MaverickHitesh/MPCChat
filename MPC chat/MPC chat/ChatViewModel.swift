//
//  ChatViewModel.swift
//  MPC chat
//
//  Created by Hitesh Singh on 24/06/24.
//

import Foundation
import Combine
import CoreData

class ChatViewModel: ObservableObject {
    static let shared = ChatViewModel()

    @Published var messages: [Message] = []
    @Published var messageText: String = ""

//    private var cancellables = Set<AnyCancellable>()
    private let context = PersistenceController.shared.container.viewContext

    init() {
        loadMessages()
    }

    func sendMessage() {
        let message = messageText
        if let data = message.data(using: .utf8) {
            do {
                try MPCManager.shared.session.send(data, toPeers: MPCManager.shared.session.connectedPeers, with: .reliable)
            } catch {
                print("Error: Unable to send message")
            }
            saveMessage(content: message, sender: "Me")
            messageText = ""
        }
    }

    func receiveMessage(_ message: String, from sender: String) {
        saveMessage(content: message, sender: sender)
    }

    private func saveMessage(content: String, sender: String) {
        let newMessage = Message(context: context)
        newMessage.content = content
        newMessage.timestamp = Date()
        newMessage.sender = sender

        do {
            try context.save()
            loadMessages()
        } catch {
            print("Failed to save message: \(error.localizedDescription)")
        }
    }

    private func loadMessages() {
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        print(Thread.isMainThread)
        do {
            messages = try context.fetch(request)
        } catch {
            print("Failed to load messages: \(error.localizedDescription)")
        }
    }
}

