//
//  ContentView.swift
//  Collaborative Cinematic Storytelling
//
//  Created by Hasan Tahir on 26/04/2022.
//

import SwiftUI
import CoreData

struct ContentView: View {

    var body: some View {
            StoryView(viewModel: StoryViewModel())
    }


}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
