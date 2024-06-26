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
        startAdvertising()
        startBrowsing()
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
        print("Connected state for: \(peerID) --- \(state.rawValue)")
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("Connected: \(peerID)")
                self.connectedPeers.append(peerID)
                self.stopBrowsing()
                self.stopAdvertising()
            case .connecting:
                print("Connecting: \(peerID)")
                break
            case .notConnected:
                print("not Connected: \(peerID)")
                self.connectedPeers.removeAll { $0 == peerID }
            @unknown default:
                fatalError()
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("DID receive message from \(peerID)")
        if let message = String(data: data, encoding: .utf8) {
            print("DID receive message from \(peerID) ----- \(message)")
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
        print("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
}

extension MPCManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        // Handle error
        print("ServiceBrowser didNotStartBrowsingForPeers: \(String(describing: error))")
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("ServiceBrowser found peer: \(peerID)")
        DispatchQueue.main.async {
            self.availablePeers.append(peerID)
        }
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("ServiceBrowser lost peer: \(peerID)")
        DispatchQueue.main.async {
            self.availablePeers.removeAll { $0 == peerID }
        }
    }
}

