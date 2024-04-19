//
//  TiledCrewDemoApp.swift
//  TiledCrewDemo
//
//  Created by Grigorii Berngardt on 4/19/24.
//

import SwiftUI

@main
struct TiledCrewDemoApp: App {
    
    enum NavigaitonItem: String, CaseIterable, Identifiable {
        case example1
        case example2
        case example3
        case example4
        case example5
        
        var name: String {
            switch self {
            case .example1: return "Simple Layer"
            case .example2: return "Over the edges"
            case .example3: return "Basic ScrollView"
            case .example4: return "Zoomable ScrollView"
            case .example5: return "NightWatch"
            }
        }
        
        var id: String { rawValue }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    ForEach(NavigaitonItem.allCases) { item in
                        NavigationLink(value: item) {
                            Text(item.name)
                        }
                    }
                }
                .navigationTitle("iOS Crew #13")
                .navigationDestination(for: NavigaitonItem.self) { item in
                    switch item {
                    case .example1:
                        ContentView()
                    case .example2:
                        ContentView2()
                    case .example3:
                        ContentView3()
                    case .example4:
                        ContentView4()
                    case .example5:
                        ContentView5()
                    }
                }
            }
        }
    }
}
