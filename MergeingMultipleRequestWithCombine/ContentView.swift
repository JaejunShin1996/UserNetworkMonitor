//
//  ContentView.swift
//  MergeingMultipleRequestWithCombine
//
//  Created by Jaejun Shin on 7/11/2022.
//

import Combine
import SwiftUI

enum FetchStatus {
    case loading, loaded
}

struct Message: Decodable, Identifiable {
    var id: Int
    var from: String
    var message: String
}

struct ContentView: View {
    @State private var requests = Set<AnyCancellable>()
    @State private var messages = [Message]()
    @State private var favorites = Set<Int>()

    @State private var fetchStatus = FetchStatus.loading

    var body: some View {
        NavigationView {
            ZStack {
                switch fetchStatus {
                case .loading :
                    ProgressView()
                case .loaded :
                    List(messages) { message in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(message.from)
                                    .font(.headline)

                                Text(message.message)
                                    .foregroundColor(.secondary)
                            }

                            if favorites.contains(message.id) {
                                Spacer()

                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Messages")
        }
        .onAppear {
            let messagesURL = URL(string: "https://www.hackingwithswift.com/samples/user-messages.json")!
            let messagesTask = fetch(messagesURL, defaultValue: [Message]())

            let favoritesURL = URL(string: "https://www.hackingwithswift.com/samples/user-favorites.json")!
            let favoritesTask = fetch(favoritesURL, defaultValue: Set<Int>())

            let combined = Publishers.Zip(messagesTask, favoritesTask)

            combined.sink { loadedMessages, loadedFavorites in
                messages = loadedMessages
                favorites = loadedFavorites
            }
            .store(in: &requests)
        }
        .onChange(of: favorites) { newValue in
            fetchStatus = .loaded
        }
    }

    func fetch<T: Decodable>(_ url: URL, defaultValue: T, completion: @escaping (T) -> Void) {
        let decoder = JSONDecoder()

        URLSession.shared.dataTaskPublisher(for: url)
            .retry(1)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .replaceError(with: defaultValue)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
            .store(in: &requests)
    }

    func fetch<T: Decodable>(_ url: URL, defaultValue: T) -> AnyPublisher<T, Never> {
        let decoder = JSONDecoder()

        return URLSession.shared.dataTaskPublisher(for: url)
            .retry(1)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .replaceError(with: defaultValue)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
