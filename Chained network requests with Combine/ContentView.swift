//
//  ContentView.swift
//  Chained network requests with Combine
//
//  Created by Jaejun Shin on 8/11/2022.
//

import Combine
import SwiftUI

struct NewsItem: Decodable, Identifiable {
    let id: Int
    let title: String
    let strap: String
    let url: URL
    let main_image: String
    let published_date: Date
}

struct ContentView: View {
    @State private var requests = Set<AnyCancellable>()
    @State private var items = [NewsItem]()

    var body: some View {
        NavigationView {
            VStack {
                Button("Fetch news") {
                    // fetch the news!
                    let url = URL(string: "https://www.hackingwithswift.com/samples/news.json")!

                    fetch(url, defaultValue: [URL]())
                        .flatMap { urls in
                            urls.publisher.flatMap { url in
                                fetch(url, defaultValue: [NewsItem]())
                            }
                        }
                        .collect()
                        .sink { values in
                            let allItems = values.joined()
                            items = allItems.sorted { $0.id > $1.id }
                        }
                        .store(in: &requests)
                }

                List(items) { item in
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.headline)
                        Text(item.strap)
                            .foregroundColor(.secondary)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Hacking with Swift")
        }
    }

    func fetch<T: Decodable>(_ url: URL, defaultValue: T) -> AnyPublisher<T, Never> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

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
