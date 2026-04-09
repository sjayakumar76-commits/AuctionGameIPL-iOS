import Combine
import Foundation

struct RemoteRow: Identifiable, Hashable {
    let id = UUID()
    let leading: String?
    let title: String
    let trailing: String?
}

struct RemoteListConfig: Hashable {
    enum Endpoint: String {
        case primary = "https://script.google.com/macros/s/AKfycbzhnjeL9u1wgHEo4f51TQ2QQJPpZ7b2SkLq7lvUo0kNyAsxYlO43kZ87mVV8AhleMIN/exec?action=getItems"
        case secondary = "https://script.google.com/macros/s/AKfycbyi9pWNA37ext30L8-hNZfv02wZNoO3ABEuC6ALsPwyFofGv5afaSsDLl65fLfHMizX/exec?action=getItems"
    }

    enum LayoutStyle: Hashable {
        case standard
        case rankedColumns
    }

    let title: String
    let loadingMessage: String
    let endpoint: Endpoint
    let layoutStyle: LayoutStyle
    let highlightedRowIndices: Set<Int>
    let transform: ([[String: Any]]) -> [RemoteRow]

    init(
        title: String,
        loadingMessage: String,
        endpoint: Endpoint,
        layoutStyle: LayoutStyle = .standard,
        highlightedRowIndices: Set<Int> = [],
        transform: @escaping ([[String: Any]]) -> [RemoteRow]
    ) {
        self.title = title
        self.loadingMessage = loadingMessage
        self.endpoint = endpoint
        self.layoutStyle = layoutStyle
        self.highlightedRowIndices = highlightedRowIndices
        self.transform = transform
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(loadingMessage)
        hasher.combine(endpoint)
        hasher.combine(layoutStyle)
        hasher.combine(highlightedRowIndices)
    }

    static func == (lhs: RemoteListConfig, rhs: RemoteListConfig) -> Bool {
        lhs.title == rhs.title &&
        lhs.loadingMessage == rhs.loadingMessage &&
        lhs.endpoint == rhs.endpoint &&
        lhs.layoutStyle == rhs.layoutStyle &&
        lhs.highlightedRowIndices == rhs.highlightedRowIndices
    }
}

@MainActor
final class RemoteRowsViewModel: ObservableObject {
    @Published private(set) var rows: [RemoteRow] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let config: RemoteListConfig
    private var hasLoaded = false

    init(config: RemoteListConfig) {
        self.config = config
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await reload()
    }

    func reload() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let payload = try await RemoteAPI.fetchItems(from: config.endpoint)
            rows = config.transform(payload)
            hasLoaded = true
        } catch {
            rows = []
            errorMessage = error.localizedDescription
        }
    }
}

enum RemoteAPI {
    static func fetchItems(from endpoint: RemoteListConfig.Endpoint) async throws -> [[String: Any]] {
        guard let url = URL(string: endpoint.rawValue) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let object = try JSONSerialization.jsonObject(with: data)
        guard
            let payload = object as? [String: Any],
            let items = payload["items"] as? [[String: Any]]
        else {
            throw CocoaError(.coderReadCorrupt)
        }

        return items
    }
}

extension RemoteListConfig {
    static let leaderboard = RemoteListConfig(
        title: "Leaderboard",
        loadingMessage: "Loading overall points...",
        endpoint: .primary,
        layoutStyle: .rankedColumns
    ) { items in
        items.prefix(10).enumerated().map { index, item in
            RemoteRow(
                leading: index == 0 ? "Rank" : "\(index)",
                title: value("LBName", in: item),
                trailing: value("LBPoints", in: item)
            )
        }
    }

    static let fixedSix = RemoteListConfig(
        title: "Fixed 6",
        loadingMessage: "Loading fixed points...",
        endpoint: .primary,
        layoutStyle: .rankedColumns
    ) { items in
        Array(items.prefix(21)).enumerated().compactMap { index, item in
            guard index > 10 else { return nil }
            let rankLabel = index == 11 ? "Rank" : "\(index - 11)"
            return RemoteRow(
                leading: rankLabel,
                title: value("LBName", in: item),
                trailing: value("LBPoints", in: item)
            )
        }
    }

    static let teamJay = teamConfig(title: "Jay", nameKey: "JayName", pointsKey: "JayPoints")
    static let teamSG = teamConfig(title: "SG Universe", nameKey: "SGName", pointsKey: "SGPoints")
    static let teamRaul = teamConfig(title: "Raulavante Game", nameKey: "RaulName", pointsKey: "RaulPoints")
    static let teamPandu = teamConfig(title: "Tabellenfuhrer", nameKey: "PanduName", pointsKey: "PanduPoints")
    static let teamBadri = teamConfig(title: "Classic CSK 3.0", nameKey: "BadriName", pointsKey: "BadriPoints")
    static let teamNaveen = teamConfig(title: "Team G.O.A.T", nameKey: "NaveenName", pointsKey: "NaveenPoints")
    static let teamHemanth = teamConfig(title: "MG Squad", nameKey: "HemanthName", pointsKey: "HemanthPoints")
    static let teamGanesh = teamConfig(title: "AK 47", nameKey: "GaneshName", pointsKey: "GaneshPoints")
    static let teamSathish = teamConfig(title: "Team RAM", nameKey: "SathishName", pointsKey: "SathishPoints")

    static let week1 = weekConfig(title: "Week 1")
    static let week2 = weekConfig(title: "Week 2")
    static let week3 = weekConfig(title: "Week 3")
    static let week4 = weekConfig(title: "Week 4")
    static let week5 = weekConfig(title: "Week 5")
    static let week6 = weekConfig(title: "Week 6")
    static let week7 = weekConfig(title: "Week 7")
    static let week8 = weekConfig(title: "Week 8")
    static let week9 = weekConfig(title: "Week 9")

    static let weekWin = RemoteListConfig(
        title: "Weekly Winners",
        loadingMessage: "Loading weekly winners...",
        endpoint: .primary
    ) { items in
        filtered(items, upperBound: 47, threshold: 21).map {
            RemoteRow(
                leading: nil,
                title: value("JayName", in: $0),
                trailing: value("JayPoints", in: $0)
            )
        }
    }

    static let auctionRules = RemoteListConfig(
        title: "Auction Rules",
        loadingMessage: "Loading auction rules...",
        endpoint: .primary
    ) { items in
        filtered(items, upperBound: 35, threshold: 21).map {
            RemoteRow(
                leading: nil,
                title: value("BadriName", in: $0),
                trailing: nil
            )
        }
    }

    static let prizes = RemoteListConfig(
        title: "Winning Prizes",
        loadingMessage: "Loading prizes...",
        endpoint: .primary
    ) { items in
        filtered(items, upperBound: 58, threshold: 35).map {
            RemoteRow(
                leading: nil,
                title: value("BadriName", in: $0),
                trailing: value("BadriPoints", in: $0)
            )
        }
    }

    private static func teamConfig(title: String, nameKey: String, pointsKey: String) -> RemoteListConfig {
        RemoteListConfig(
            title: title,
            loadingMessage: "Loading team...",
            endpoint: .primary,
            highlightedRowIndices: [0, 7, 19]
        ) { items in
            items.prefix(20).map {
                RemoteRow(
                    leading: nil,
                    title: value(nameKey, in: $0),
                    trailing: value(pointsKey, in: $0)
                )
            }
        }
    }

    private static func weekConfig(title: String) -> RemoteListConfig {
        RemoteListConfig(
            title: title,
            loadingMessage: "Loading week data...",
            endpoint: .primary,
            layoutStyle: .rankedColumns
        ) { items in
            filtered(items, upperBound: 33, threshold: 22).map {
                RemoteRow(
                    leading: value("SGName", in: $0),
                    title: value("RaulName", in: $0),
                    trailing: value("SGPoints", in: $0)
                )
            }
        }
    }

    private static func filtered(_ items: [[String: Any]], upperBound: Int, threshold: Int) -> [[String: Any]] {
        Array(items.prefix(min(items.count, upperBound + 1)).enumerated().compactMap { index, item in
            index > threshold ? item : nil
        })
    }

    private static func value(_ key: String, in item: [String: Any]) -> String {
        if let stringValue = item[key] as? String {
            return stringValue
        }
        if let numberValue = item[key] {
            return String(describing: numberValue)
        }
        return ""
    }
}
