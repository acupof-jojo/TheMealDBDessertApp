//
//  ListView.swift
//  MenuDBApp
//
//  Created by JoJo M on 1/8/24.
//

import Foundation
import SwiftUI

struct DessertListView: View {
    @ObservedObject var viewModel: ListViewModel
    let sortByLetters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    
    /// Sorts recipes alphabetically
    var sortedRecipes: [Meal] {
        return viewModel.recipes.sorted { (meal1, meal2) in
            return meal1.strMeal < meal2.strMeal
        }
    }

    var body: some View {
        NavigationView {
            ScrollViewReader { scrollViewProxy in
                List {
                    /// For each letter in sortByLetters, create a list of recipes starting with that letter
                    ForEach(sortByLetters, id: \.self) { letter in
                        /// If no recipes start with that letter, the letter is skipped and doesn't show up
                        let strStartWith = sortedRecipes.filter { $0.strMeal.starts(with: String(letter)) }
                        if strStartWith.count > 0 {
                            Section(header: Text(String(letter))) {
                                ForEach(strStartWith, id: \.idMeal) { recipe in
                                    /// a NavigationLink is created for each recipe, when tapped screen will change to the RecipeView
                                    /// and pass the dessert ID
                                    NavigationLink(destination: RecipeView(dessertId: recipe.idMeal)) {
                                        Text(recipe.strMeal.capitalized)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .onAppear {
                    Task {
                        await viewModel.populateCategories()
                    }
                }
            }
            .navigationBarTitle("TheMealDB: Dessert Recipes", displayMode: .inline)
        }
    }
}

