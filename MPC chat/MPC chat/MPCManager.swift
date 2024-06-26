//
//  MPCManager.swift
//  MPC chat
//
//  Created by Hitesh Singh on 24/06/24.
//

import Foundation
import MultipeerConnectivity

class MPCManager: NSObject, ObservableObject {
    static let shared = MPCManager()

    private let serviceType = "mpc-chat"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceBrowser: MCNearbyServiceBrowser
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private var session: MCSession!

    @Published var connectedPeers: [MCPeerID] = []

    override init() {
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)

        super.init()

        self.session.delegate = self
        self.serviceBrowser.delegate = self
        self.serviceAdvertiser.delegate = self

        self.serviceBrowser.startBrowsingForPeers()
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    
    deinit {
        self.serviceBrowser.stopBrowsingForPeers()
        self.serviceAdvertiser.stopAdvertisingPeer()
    }

    func send(message: String, peer: MCPeerID? = nil) {
        guard let data = message.data(using: .utf8) else { return }
        DispatchQueue.global(qos: .background).async {
            do {
                if let peer = peer {
                    try self.session.send(data, toPeers: [peer], with: .reliable)
                } else {
                    try self.session.send(data, toPeers: self.connectedPeers, with: .reliable)
                }
            } catch {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
}

extension MPCManager: MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("connection status: \(peerID) | \(state.rawValue)")
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.connectedPeers.append(peerID)
            case .notConnected:
                self.connectedPeers.removeAll { $0 == peerID }
            default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("receive message: \(peerID) ")
        if let message = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                ChatViewModel.shared.receiveMessage(message, from: peerID.displayName)
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Error browsing for peers: \(error.localizedDescription)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("invite peer : \(peerID) ")
        DispatchQueue.global(qos: .background).async {
            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Error advertising peer: \(error.localizedDescription)")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("invitation accepted: \(peerID) ")
        DispatchQueue.global(qos: .background).async {
            invitationHandler(true, self.session)
        }
    }
}
