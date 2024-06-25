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
    private var serviceAdvertiser: MCNearbyServiceAdvertiser
    private var serviceBrowser: MCNearbyServiceBrowser

    @Published var connectedPeers: [MCPeerID] = []
    @Published var availablePeers: [MCPeerID] = []

    var session: MCSession

    override init() {
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)

        super.init()

        self.session.delegate = self
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
    }

    func startAdvertising() {
        self.serviceAdvertiser.startAdvertisingPeer()
    }

    func stopAdvertising() {
        self.serviceAdvertiser.stopAdvertisingPeer()
    }

    func startBrowsing() {
        self.serviceBrowser.startBrowsingForPeers()
    }

    func stopBrowsing() {
        self.serviceBrowser.stopBrowsingForPeers()
    }
}

extension MPCManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.connectedPeers.append(peerID)
            case .connecting:
                break
            case .notConnected:
                self.connectedPeers.removeAll { $0 == peerID }
            @unknown default:
                fatalError()
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                ChatViewModel.shared.receiveMessage(message, from: peerID.displayName)
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

extension MPCManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        // Handle error
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }
}

extension MPCManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        // Handle error
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            self.availablePeers.append(peerID)
        }
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.availablePeers.removeAll { $0 == peerID }
        }
    }
}

