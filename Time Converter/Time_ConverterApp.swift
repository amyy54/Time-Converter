//
//  Time_ConverterApp.swift
//  Time Converter
//
//  Created by Amy C on 2/4/24.
//

import SwiftUI

@main
struct Time_ConverterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct UserTimezone: Identifiable {
    let id = UUID()
    let timezone: TimeZone
    var nickname: String? = nil
}

func getAllTimeZones() -> [UserTimezone] {
    var res = [UserTimezone]()
    for timezone in TimeZone.knownTimeZoneIdentifiers {
        let tz = TimeZone(identifier: timezone)
        if let tz_view = tz {
            res.append(UserTimezone(timezone: tz_view))
        }
    }
    return res
}

func getUserTimeZones() -> [UserTimezone] {
    let defaults = UserDefaults.standard
    var res = [UserTimezone]()
    var config: [String] = []
    if let configArr = defaults.array(forKey: "timezones") {
        config = configArr as! [String]
    }
    for timezone in config {
        let tzarr = timezone.split(separator: "|")
        let tzname = String(tzarr.first!)
        let nick = tzarr.last ?? ""
        if nick == "" || nick == tzname {
            res.append(UserTimezone(timezone: TimeZone(identifier: tzname)!))
        } else {
            res.append(UserTimezone(timezone: TimeZone(identifier: tzname)!, nickname: String(nick)))
        }
    }
    res.sort(by: {$0.timezone.secondsFromGMT() < $1.timezone.secondsFromGMT()})
    return res
}

func setUserTimeZones(timezones: [UserTimezone]) {
    let defaults = UserDefaults.standard
    var res = [String]()
    for timezone in timezones {
        res.append("\(timezone.timezone.identifier)|\(timezone.nickname ?? "")")
    }
    defaults.set(res, forKey: "timezones")
}

@discardableResult
func addTimeZone(timezone: UserTimezone) -> [UserTimezone] {
    var timezones = getUserTimeZones()
    if timezones.filter({ $0.timezone.identifier == timezone.timezone.identifier }).isEmpty {
        timezones.append(timezone)
        setUserTimeZones(timezones: timezones)
    }
    return timezones
}

@discardableResult
func removeTimeZone(timezone: UserTimezone) -> [UserTimezone] {
    let timezones = getUserTimeZones()
    let newTimeZones = timezones.filter { $0.timezone.identifier != timezone.timezone.identifier }
    setUserTimeZones(timezones: newTimeZones)
    return newTimeZones
}

func changeNicknameForTimezone(tzIdentifier: String, nickname: String) -> UserTimezone {
    return UserTimezone(timezone: TimeZone(identifier: tzIdentifier)!, nickname: nickname != "" ? nickname : nil)
}

func replaceUserTimezoneInstance(timezones: [UserTimezone], timezone: UserTimezone) -> [UserTimezone] {
    var newTimeZones = timezones.filter { $0.timezone.identifier != timezone.timezone.identifier}
    newTimeZones.append(timezone)
    return newTimeZones
}

func secondsFromOffset(timezone: UserTimezone, offsetTimezone: TimeZone = TimeZone.current) -> Int {
    return timezone.timezone.secondsFromGMT() - offsetTimezone.secondsFromGMT()
}

func dateForTimezone(timezone: UserTimezone, sinceDate: Date = Date(), offsetTz: String = TimeZone.current.identifier) -> Date {
    let newTzString = String(offsetTz.split(separator: "-").first!)
    var seconds: Int = 0
    if let newOffset = TimeZone(identifier: newTzString) {
        seconds = secondsFromOffset(timezone: timezone, offsetTimezone: newOffset)
    } else {
        seconds = secondsFromOffset(timezone: timezone)
    }
    return Date(timeInterval: Double(seconds), since: sinceDate)
}

func formattedDateForTimezone(timezone: UserTimezone, sinceDate: Date = Date(), offsetTz: String = TimeZone.current.identifier) -> String {
    let date = dateForTimezone(timezone: timezone, sinceDate: sinceDate, offsetTz: offsetTz)
    let datefmt = date.formatted(date: .omitted, time: .standard)
    var amPmString = ""
    if datefmt.contains("AM") {
        amPmString = " AM"
    } else if datefmt.contains("PM") {
        amPmString = " PM"
    }
    return datefmt.split(separator: ":").prefix(2).joined(separator: ":") + amPmString
}

func formattedIdentifier(timezone: UserTimezone, noNick: Bool = false) -> String {
    let formatCity = String(timezone.timezone.identifier.split(separator: "/").last!).replacingOccurrences(of: "_", with: " ")
    let res = noNick ? formatCity : (timezone.nickname ?? formatCity)
    return res
}

func formattedWithCountryIdentifier(timezone: UserTimezone, noNick: Bool = false) -> String {
    let country = String(timezone.timezone.identifier.split(separator: "/").first!)
    if let nick = timezone.nickname {
        if !noNick {
            return nick
        }
    }
    let city = String(timezone.timezone.identifier.split(separator: "/").last!).replacingOccurrences(of: "_", with: " ")
    return "\(country) - \(city)"
}
