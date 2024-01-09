//
//  ContentView.swift
//  MenuDBApp
//
//  Created by JoJo M on 1/4/24.
//

import SwiftUI

struct ListScreen: View {
    @StateObject var viewModel = ListViewModel()

    var body: some View {
        NavigationView {
            DessertListView(viewModel: viewModel)
                .task {
                    await viewModel.populateCategories()
                }
        }
    }
}

struct DessertListScreen_Previews: PreviewProvider {
    static var previews: some View {
        ListScreen()
    }
}
