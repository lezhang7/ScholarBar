import Foundation
import UserNotifications
import ServiceManagement

@MainActor
final class CitationStore: ObservableObject {
    // MARK: - Stats
    @Published var totalCitations: Int = 0
    @Published var hIndex: Int = 0
    @Published var i10Index: Int = 0
    @Published var userName: String = ""
    @Published var lastUpdated: Date? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var hasNewCitations = false
    @Published var newCitationsDiff: Int = 0

    // MARK: - Settings
    @Published var scholarUserID: String = "" {
        didSet {
            UserDefaults.standard.set(scholarUserID, forKey: Keys.scholarUserID)
            if !scholarUserID.isEmpty && scholarUserID != oldValue {
                Task { await refresh() }
            }
        }
    }

    @Published var refreshInterval: TimeInterval = 1800 {
        didSet {
            UserDefaults.standard.set(refreshInterval, forKey: Keys.refreshInterval)
            restartTimer()
        }
    }

    @Published var launchAtLogin: Bool = false {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: Keys.launchAtLogin)
            updateLaunchAtLogin()
        }
    }

    @Published var notificationsEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }

    private let fetcher = ScholarFetcher()
    private var timer: Timer?

    private enum Keys {
        static let totalCitations = "totalCitations"
        static let hIndex = "hIndex"
        static let i10Index = "i10Index"
        static let userName = "userName"
        static let lastUpdated = "lastUpdatedDate"
        static let scholarUserID = "scholarUserID"
        static let refreshInterval = "refreshInterval"
        static let launchAtLogin = "launchAtLogin"
        static let notificationsEnabled = "notificationsEnabled"
    }

    var lastUpdatedText: String {
        guard let date = lastUpdated else { return "从未更新" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    var scholarURL: URL? {
        guard !scholarUserID.isEmpty else { return nil }
        return URL(string: "https://scholar.google.com/citations?user=\(scholarUserID)")
    }

    var isConfigured: Bool { !scholarUserID.isEmpty }

    func dismissBadge() {
        hasNewCitations = false
        newCitationsDiff = 0
    }

    var refreshIntervalMinutes: Int {
        get { Int(refreshInterval / 60) }
        set { refreshInterval = TimeInterval(newValue * 60) }
    }

    // MARK: - Init

    init() {
        let defaults = UserDefaults.standard

        totalCitations = defaults.integer(forKey: Keys.totalCitations)
        hIndex = defaults.integer(forKey: Keys.hIndex)
        i10Index = defaults.integer(forKey: Keys.i10Index)
        userName = defaults.string(forKey: Keys.userName) ?? ""
        scholarUserID = defaults.string(forKey: Keys.scholarUserID) ?? ""
        notificationsEnabled = defaults.object(forKey: Keys.notificationsEnabled) as? Bool ?? true
        launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)

        let storedInterval = defaults.double(forKey: Keys.refreshInterval)
        refreshInterval = storedInterval > 0 ? storedInterval : 1800

        if let ts = defaults.object(forKey: Keys.lastUpdated) as? Date {
            lastUpdated = ts
        }

        requestNotificationPermission()
        restartTimer()

        if isConfigured {
            Task { await refresh() }
        }
    }

    // MARK: - Refresh

    func refresh() async {
        guard !scholarUserID.isEmpty else {
            errorMessage = "请先设置 Scholar User ID"
            return
        }

        isLoading = true
        errorMessage = nil
        do {
            let data = try await fetcher.fetch(userID: scholarUserID)
            applyUpdate(data)
        } catch {
            errorMessage = "获取失败: \(error.localizedDescription)"
        }
        isLoading = false
    }

    private func applyUpdate(_ data: ScholarData) {
        let oldCitations = totalCitations

        totalCitations = data.totalCitations
        hIndex = data.hIndex
        i10Index = data.i10Index
        userName = data.userName
        lastUpdated = Date()

        let defaults = UserDefaults.standard
        defaults.set(data.totalCitations, forKey: Keys.totalCitations)
        defaults.set(data.hIndex, forKey: Keys.hIndex)
        defaults.set(data.i10Index, forKey: Keys.i10Index)
        defaults.set(data.userName, forKey: Keys.userName)
        defaults.set(Date(), forKey: Keys.lastUpdated)

        if notificationsEnabled && oldCitations > 0 && data.totalCitations > oldCitations {
            let diff = data.totalCitations - oldCitations
            newCitationsDiff = diff
            hasNewCitations = true
            sendNotification(diff: diff, total: data.totalCitations)
        }
    }

    // MARK: - Timer

    private func restartTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.refresh()
            }
        }
    }

    // MARK: - Launch at Login

    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // SMAppService may fail in non-sandboxed SPM builds; silently ignore
        }
    }

    // MARK: - Notifications

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func sendNotification(diff: Int, total: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Scholar 引用数增长!"
        content.body = "新增 \(diff) 次引用，总计 \(total) 次"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
