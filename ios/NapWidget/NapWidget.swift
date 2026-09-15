import SwiftUI
import WidgetKit

/// Must match `napWidgetAppGroupId` in
/// lib/features/nap/services/nap_timer_service.dart and the App Group
/// configured on both this extension's and Runner's entitlements.
private let appGroupId = "group.com.example.natalIq.nap"

struct NapEntry: TimelineEntry {
    let date: Date
    let isRunning: Bool
    let startDate: Date?
}

struct NapTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> NapEntry {
        NapEntry(date: Date(), isRunning: false, startDate: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (NapEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NapEntry>) -> Void) {
        // No further reloads are scheduled here — the Flutter app calls
        // WidgetCenter.reloadTimelines (via home_widget's HomeWidget.updateWidget)
        // whenever a nap starts or stops, which is the only time this changes.
        completion(Timeline(entries: [currentEntry()], policy: .never))
    }

    private func currentEntry() -> NapEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let isRunning = defaults?.bool(forKey: "nap_is_running") ?? false
        let startIso = defaults?.string(forKey: "nap_start_iso")
        let startDate = startIso.flatMap { ISO8601DateFormatter().date(from: $0) }
        return NapEntry(date: Date(), isRunning: isRunning, startDate: startDate)
    }
}

struct NapWidgetView: View {
    var entry: NapEntry

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("NAP TIMER")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(red: 0.494, green: 0.380, blue: 0.357))
            if entry.isRunning, let start = entry.startDate {
                Text("Napping since \(Self.timeFormatter.string(from: start))")
                    .font(.system(size: 15, weight: .bold))
                    .lineLimit(2)
            } else {
                Text("Not napping")
                    .font(.system(size: 15, weight: .bold))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        // Tapping the widget opens the app straight to the nap screen — see
        // the `HomeWidget.widgetClicked` listener in main.dart. Interactive
        // start/stop buttons would need iOS 17+ AppIntents, out of scope here.
        .widgetURL(URL(string: "napwidget://nap"))
    }
}

struct NapWidget: Widget {
    let kind: String = "NapWidget" // Must match `iOSName: 'NapWidget'` passed to HomeWidget.updateWidget in Dart.

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NapTimelineProvider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                NapWidgetView(entry: entry)
                    .containerBackground(.white, for: .widget)
            } else {
                NapWidgetView(entry: entry)
                    .background(Color.white)
            }
        }
        .configurationDisplayName("Nap Timer")
        .description("Shows whether a nap is currently in progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
