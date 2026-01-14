//
//  ContentView.swift
//  Percify
//
//  Created by 松本知大 on 2025/10/07.
//

import SwiftUI

enum TabIdentifier: Hashable {
    case home
    case messages
    case profile
    case discover
    case calendar
    case percify
}

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var selectedTab: TabIdentifier = .discover

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: TabIdentifier.home) {
                NavigationStack {
                    HomeView()
                }
            } label: {
                Label {
                    Text("ホーム")
                } icon: {
                    Image("home.fill")
                }
            }
           //Tab(value: TabIdentifier.calendar) {
                //NavigationStack {
                    //CalendarView()
                //}
            //} label: {
                //Label("カレンダー", systemImage: "calendar")
            //}
            
            Tab(value: TabIdentifier.discover) {
                NavigationStack {
                    DiscoverView()
                }
                //.searchable(text: $searchText)
            } label: {
                Label("さがす", systemImage: "rectangle.portrait.on.rectangle.portrait.angled.fill")
            }
            
            Tab(value: TabIdentifier.messages) {
                NavigationStack {
                    MessagesView()
                }
            } label: {
                Label("メッセージ", systemImage: "envelope.fill")
            }
            .badge(3)

            Tab(value: TabIdentifier.profile, role: .search) {
                NavigationStack {
                    ProfileView()
                }
            } label: {
                Label("マイページ", systemImage: "person.crop.circle.fill")
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
