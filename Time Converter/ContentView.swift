//
//  ContentView.swift
//  Time Converter
//
//  Created by Amy C on 2/4/24.
//

import SwiftUI

struct ContentView: View {
    @State var TimeZoneList = [UserTimezone]()
    @State var offset : Date = Date()
    @State var tzOffset : String = "\(TimeZone.current.identifier)-Current"
    @State var inCustomTime : Bool = false
    @State var nickname = ""
    @State var showNickPopup = false
    @State var currentTimezone: String? = nil
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach($TimeZoneList) { $tz in
                        ZStack {
                            HStack {
                                Text("\(formattedIdentifier(timezone: tz))")
                                Spacer()
                            }
                            HStack {
                                Spacer()
                                Text("\(formattedDateForTimezone(timezone: tz, sinceDate: offset, offsetTz: tzOffset))").monospacedDigit()
                            }
                        }.swipeActions(edge: .leading) {
                            Button("Copy") {
                                let pasteboard = UIPasteboard.general
                                pasteboard.string = "\(formattedDateForTimezone(timezone: tz, sinceDate: offset, offsetTz: tzOffset)) in \(formattedIdentifier(timezone: tz, noNick: true))"
                            }.tint(.brown)
                            Button("Rename") {
                                self.currentTimezone = tz.timezone.identifier
                                self.nickname = tz.nickname ?? ""
                                self.showNickPopup = true
                            }.tint(.blue)
                        }.alert("Enter nickname for timezone", isPresented: $showNickPopup) {
                            TextField("Enter", text: $nickname)
                            Button("Confirm", role: .cancel) {
                                var newTimezoneList: [UserTimezone] = TimeZoneList
                                if let currenttz = self.currentTimezone {
                                    let newTz = changeNicknameForTimezone(tzIdentifier: currenttz, nickname: self.nickname)
                                    newTimezoneList = replaceUserTimezoneInstance(timezones: TimeZoneList, timezone: newTz)
                                }
                                setUserTimeZones(timezones: newTimezoneList)
                                TimeZoneList = getUserTimeZones()
                                self.nickname = ""
                            }
                        }
                    }.onDelete(perform: { offsets in
                        TimeZoneList.remove(atOffsets: offsets)
                        setUserTimeZones(timezones: TimeZoneList)
                    })
                }
                ZStack {
                    HStack {
                        Button("Copy", systemImage: "doc.on.clipboard") {
                            let pasteboard = UIPasteboard.general
                            if self.tzOffset.contains("-Current") {
                                pasteboard.string = "<t:\(Int(dateForTimezone(timezone: UserTimezone(timezone: TimeZone.current), sinceDate: self.offset).timeIntervalSince1970)):t>"
                            } else {
                                let time = formattedDateForTimezone(timezone: UserTimezone(timezone: TimeZone(identifier: tzOffset)!), sinceDate: offset, offsetTz: tzOffset)
                                let name = formattedIdentifier(timezone: UserTimezone(timezone: TimeZone(identifier: tzOffset)!), noNick: true)
                                pasteboard.string = "\(time) in \(name)"
                            }
                        }.labelStyle(.iconOnly).padding([.leading])
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Picker("Timezone", selection: $tzOffset) {
                            Text("Current Location").tag("\(TimeZone.current.identifier)-Current")
                            ForEach(TimeZoneList) { tz in
                                Text(formattedWithCountryIdentifier(timezone: tz)).tag(tz.timezone.identifier)
                            }
                        }
                        DatePicker("Please enter the time offset.", selection: $offset, displayedComponents: .hourAndMinute).labelsHidden()
                        Button("Reset Offset", systemImage: "arrow.clockwise.circle") {
                            self.offset = Date()
                            inCustomTime = false
                            self.tzOffset = "\(TimeZone.current.identifier)-Current"
                        }.labelStyle(.iconOnly).opacity(inCustomTime ? 1 : 0).padding([.trailing])
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddTimezoneView()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Text("Time Converter").bold()
                }
            }
            .task {
                TimeZoneList = getUserTimeZones()
            }
            .onChange(of: offset, initial: false) { oldVal, newVal in
                inCustomTime = abs(newVal.timeIntervalSince(Date())) > 60 || !self.tzOffset.contains("-Current")
                TimeZoneList = getUserTimeZones()
            }
            .onChange(of: tzOffset, initial: false) { oldVal, newVal in
                inCustomTime = !newVal.contains("-Current") || abs(self.offset.timeIntervalSince(Date())) > 60
                self.offset = dateForTimezone(timezone: UserTimezone(timezone: TimeZone(identifier: String(self.tzOffset.split(separator: "-").first!))!))
                TimeZoneList = getUserTimeZones()
            }
        }
    }
}

#Preview {
    ContentView()
}
