//
//  ContentView.swift
//  UserNetworkMonitor
//
//  Created by Jaejun Shin on 7/11/2022.
//
import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")

    var isActive = false
    var isExpensive = false
    var isConstrained = false
    var connectionType = NWInterface.InterfaceType.other

    init() {
        monitor.pathUpdateHandler = { path in
            self.isActive = path.status == .satisfied
            self.isExpensive = path.isExpensive
            self.isConstrained = path.isConstrained

            let connectionTypes: [NWInterface.InterfaceType] = [.cellular, .wifi, .wiredEthernet]

            guard path.usesInterfaceType(.wifi) else {
                self.connectionType = .other
                return
            }
            self.connectionType = connectionTypes.first(where: path.usesInterfaceType) ?? .other

            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }

        monitor.start(queue: queue)
    }

    func stopWorking() {
        monitor.cancel()
    }
}

struct ContentView: View {
    @EnvironmentObject var network: NetworkMonitor

    var body: some View {
        VStack {
            Text(verbatim: """
                Active: \(network.isActive)
                Expensive: \(network.isExpensive)
                Constrained: \(network.isConstrained)
                ConnectionType: \(network.connectionType)
            """)

            Button("Fetch data", action: makeRequest)

            Button("Stop working", action: network.stopWorking)
        }
    }

    func makeRequest() {
        let config = URLSessionConfiguration.default
        config.allowsExpensiveNetworkAccess = false
        config.allowsConstrainedNetworkAccess = false
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData

        let session = URLSession(configuration: config)
        let url = URL(string: "https://www.hackingwithswift.com")!

        session.dataTask(with: url) { data, response, error in
            print(data)
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
