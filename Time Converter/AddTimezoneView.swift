//
//  AddTimezoneView.swift
//  Time Converter
//
//  Created by Amy C on 2/8/24.
//

import SwiftUI

struct AddTimezoneView: View {
    @State var AllTimeZones = [UserTimezone]()
    @State var SearchText: String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var filteredTimeZones: [UserTimezone] {
        guard !SearchText.isEmpty else { return AllTimeZones }
        return AllTimeZones.filter { tz in
            formattedWithCountryIdentifier(timezone: tz).lowercased().contains(SearchText.lowercased())
        }
    }
    var body: some View {
        VStack {
            List {
                ForEach(filteredTimeZones) { tz in
                    ZStack {
                        HStack {
                            Text("\(formattedWithCountryIdentifier(timezone: tz))")
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            Button("Add Timezone", systemImage: "plus") {
                                addTimeZone(timezone: tz)
                                self.presentationMode.wrappedValue.dismiss()
                            }.labelStyle(.iconOnly)
                        }
                    }
                }
            }
        }
        .searchable(text: $SearchText, placement: .navigationBarDrawer(displayMode: .always))
        .task {
            AllTimeZones = getAllTimeZones()
        }
    }
}

#Preview {
    AddTimezoneView()
}
