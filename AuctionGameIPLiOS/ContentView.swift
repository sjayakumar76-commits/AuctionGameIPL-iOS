import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
    }
}

private struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeroCard()

                Text("Leaderboard")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                VStack(spacing: 14) {
                    NavigationLink(value: AppDestination.franchises) {
                        MenuButton(title: "Franchise", subtitle: "Team lineups and points", color: Color(red: 0.91, green: 0.17, blue: 0.38))
                    }
                    NavigationLink(value: AppDestination.remote(.leaderboard)) {
                        MenuButton(title: "Squad", subtitle: "Overall standings", color: Color(red: 0.17, green: 0.36, blue: 0.89))
                    }
                    NavigationLink(value: AppDestination.fixedSix) {
                        MenuButton(title: "Fixed 6", subtitle: "Fixed points table", color: Color(red: 0.98, green: 0.62, blue: 0.16))
                    }
                    NavigationLink(value: AppDestination.freeHit) {
                        MenuButton(title: "Freehit", subtitle: "Weekly winners", color: Color(red: 0.08, green: 0.62, blue: 0.47))
                    }
                    NavigationLink(value: AppDestination.rules) {
                        MenuButton(title: "Rules & Prizes", subtitle: "Auction rules and payouts", color: Color(red: 0.55, green: 0.29, blue: 0.84))
                    }
                }
            }
            .padding(20)
        }
        .background(
            LinearGradient(
                colors: [Color(red: 0.16, green: 0.05, blue: 0.16), Color(red: 0.55, green: 0.11, blue: 0.36)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("AuctionGameIPL")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AppDestination.self) { destination in
            switch destination {
            case .franchises:
                FranchiseMenuView()
            case .fixedSix:
                RemoteRowsView(config: .fixedSix)
            case .freeHit:
                FreeHitMenuView()
            case .rules:
                RulesMenuView()
            case .remote(let config):
                RemoteRowsView(config: config)
            }
        }
    }
}

private struct HeroCard: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("Hero")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .clipped()

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.82)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Auction Leaderboard")
                    .font(.system(size: 32, weight: .black, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(20)
        }
        .frame(height: 280)
        .background(Color.black.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.28), radius: 18, y: 10)
    }
}

private struct FranchiseMenuView: View {
    private let entries: [(String, RemoteListConfig, Color)] = [
        ("Jay", .teamJay, Color(red: 0.91, green: 0.17, blue: 0.38)),
        ("SG Universe", .teamSG, Color(red: 0.98, green: 0.82, blue: 0.22)),
        ("Raulavante Game", .teamRaul, Color(red: 0.96, green: 0.38, blue: 0.20)),
        ("Tabellenfuhrer", .teamPandu, Color(red: 0.72, green: 0.44, blue: 0.85)),
        ("Classic CSK 3.0", .teamBadri, Color(red: 0.89, green: 0.12, blue: 0.37)),
        ("Team G.O.A.T", .teamNaveen, Color(red: 0.22, green: 0.31, blue: 0.72)),
        ("MG Squad", .teamHemanth, Color(red: 0.86, green: 0.18, blue: 0.45)),
        ("AK 47", .teamGanesh, Color(red: 0.97, green: 0.53, blue: 0.08)),
        ("Team RAM", .teamSathish, Color(red: 0.24, green: 0.46, blue: 0.89))
    ]

    var body: some View {
        List {
            Section("Team Lineup & Points") {
                ForEach(entries, id: \.0) { entry in
                    NavigationLink(value: AppDestination.remote(entry.1)) {
                        Label {
                            Text(entry.0)
                                .font(.headline)
                        } icon: {
                            Circle()
                                .fill(entry.2.gradient)
                                .frame(width: 14, height: 14)
                        }
                    }
                }
            }
        }
        .navigationTitle("Franchise")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FreeHitMenuView: View {
    private let entries: [(String, RemoteListConfig)] = [
        ("Week 1", .week1),
        ("Week 2", .week2),
        ("Week 3", .week3),
        ("Week 4", .week4),
        ("Week 5", .week5),
        ("Week 6", .week6),
        ("Week 7", .week7),
        ("Week 8", .week8),
        ("Week 9", .week9),
        ("Weekly Winners", .weekWin)
    ]

    var body: some View {
        List {
            Section("Freehit Winners") {
                ForEach(entries, id: \.0) { entry in
                    NavigationLink(value: AppDestination.remote(entry.1)) {
                        Text(entry.0)
                            .font(.headline)
                    }
                }
            }
        }
        .navigationTitle("Freehit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct RulesMenuView: View {
    var body: some View {
        List {
            Section("Rules & Prizes") {
                NavigationLink(value: AppDestination.remote(.auctionRules)) {
                    Text("Auction Rules")
                        .font(.headline)
                }
                NavigationLink(value: AppDestination.remote(.prizes)) {
                    Text("Winning Prizes")
                        .font(.headline)
                }
            }
        }
        .navigationTitle("Rules")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MenuButton: View {
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.gradient)
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "chevron.right")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white.opacity(0.92))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.76))
            }

            Spacer()
        }
        .padding(18)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct RemoteRowsView: View {
    let config: RemoteListConfig
    @StateObject private var viewModel: RemoteRowsViewModel

    init(config: RemoteListConfig) {
        self.config = config
        _viewModel = StateObject(wrappedValue: RemoteRowsViewModel(config: config))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView(config.loadingMessage)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text("Unable to Load")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.rows) { row in
                    RowCard(row: row, layoutStyle: config.layoutStyle)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationTitle(config.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadIfNeeded()
        }
        .refreshable {
            await viewModel.reload()
        }
    }
}

private struct RowCard: View {
    let row: RemoteRow
    let layoutStyle: RemoteListConfig.LayoutStyle

    var body: some View {
        HStack(spacing: 12) {
            if let leading = row.leading {
                leadingView(for: leading)
                    .frame(width: leadingColumnWidth, alignment: .leading)
            }

            Text(row.title)
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: middleColumnAlignment)

            if let trailing = row.trailing {
                Text(trailing)
                    .font(.callout.weight(.bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.trailing)
                    .frame(minWidth: trailingColumnWidth, alignment: .trailing)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }

    @ViewBuilder
    private func leadingView(for value: String) -> some View {
        switch value {
        case "1":
            Text("🥇")
                .font(.title3)
        case "2":
            Text("🥈")
                .font(.title3)
        case "3":
            Text("🥉")
                .font(.title3)
        default:
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.secondary)
        }
    }

    private var leadingColumnWidth: CGFloat {
        switch layoutStyle {
        case .standard:
            44
        case .rankedColumns:
            58
        }
    }

    private var trailingColumnWidth: CGFloat {
        switch layoutStyle {
        case .standard:
            0
        case .rankedColumns:
            92
        }
    }

    private var middleColumnAlignment: Alignment {
        switch layoutStyle {
        case .standard:
            .leading
        case .rankedColumns:
            .center
        }
    }
}

enum AppDestination: Hashable {
    case franchises
    case fixedSix
    case freeHit
    case rules
    case remote(RemoteListConfig)
}
