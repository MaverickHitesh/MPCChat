//
//  ContentView.swift
//  MPC chat
//
//  Created by Hitesh Singh on 24/06/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel.shared

    var body: some View {
        NavigationView {
            VStack {
                DeviceListView()
                ChatView()
            }
            .onAppear {
                viewModel.fetchMessages()
            }
            .navigationBarTitle("MPC Chat")
        }
    }
}

#Preview {
    ContentView()
}
