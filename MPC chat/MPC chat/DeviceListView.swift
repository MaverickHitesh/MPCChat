//
//  DeviceListView.swift
//  MPC chat
//
//  Created by Hitesh Singh on 26/06/24.
//

import SwiftUI

struct DeviceListView: View {
    @ObservedObject var mpcManager = MPCManager.shared

    var body: some View {
        List(mpcManager.connectedPeers, id: \.self) { peer in
//            Text(peer.displayName)
            NavigationLink(peer.displayName, destination: ChatView.init(peer: peer))
//            NavigationLink(peer.displayName, value: peer.displayName)
        }
        
//        List(mpcManager.connectedPeers, id: \.self) { peer in
//            Text(peer.displayName)
//            NavigationLink(peer, value: peer)
//        }
//        .navigationDestination(for: String.self, destination: ChatView.init)
//        .navigationTitle("chat")
    }
}

