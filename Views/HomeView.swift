//
//  HomeView.swift
//  TaskManager
//
//  Created by Admin on 23/8/2026.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var session: WorkSessionState

    var body: some View {
        GeometryReader { geo in
            let contentWidth = geo.size.width - 80

            ZStack {
                ProjectPickerRuler(onSelect: { project in
                    session.select(project)
                })
                .frame(width: contentWidth)
                .position(x: geo.size.width / 2, y: geo.size.height * 0.38)

                SessionPanel(session: session)
                    .frame(width: contentWidth)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.80)
            }
        }
    }
}
