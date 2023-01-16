//
//  calendarWidget.swift
//  calendarWidget
//
//  Created by Aarif Shaikh on 2023/01/16.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startDate = Calendar.current.startOfDay(for: entryDate)
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct calendarWidgetEntryView : View {
    var entry: SimpleEntry
    var config: MonthConfig
    init(entry: SimpleEntry) {
        self.entry = entry
        self.config = MonthConfig.determineConfig(from: entry.date)
    }
    var body: some View {
        ZStack{
            ContainerRelativeShape().fill(config.backgroundColor.gradient)
            VStack{
                HStack(spacing: 4){
                    Text(config.emojiText).font(.title)
                    Text(entry.date.weekdayDisplayFormat).font(.title3).fontWeight(.bold).minimumScaleFactor(0.7).foregroundColor(config.weekdayTextColor.opacity(0.8))
                    Spacer()
                }
                Text(entry.date.dayDisplayFormat).font(.system(size: 80, weight: .heavy)).foregroundColor(config.dayTextColor.opacity(0.6))
            }.padding()
        }
    }
}

struct calendarWidget: Widget {
    let kind: String = "calendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            calendarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Monthly widget")
        .description("This is a widget with different themes every month.").supportedFamilies([.systemSmall])
    }
}

struct calendarWidget_Previews: PreviewProvider {
    static var previews: some View {
        calendarWidgetEntryView(entry: SimpleEntry(date: dateToDisplay(year: 2023, month: 2, day: 16)))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
    
    static func dateToDisplay(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(calendar: Calendar.current, year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
}

extension Date {
    var weekdayDisplayFormat: String {
        self.formatted(.dateTime.weekday(.wide))
    }
    
    var dayDisplayFormat: String {
        self.formatted(.dateTime.day())
    }
}
