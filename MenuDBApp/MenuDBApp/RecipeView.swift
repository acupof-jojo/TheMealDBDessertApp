//
//  RecipeView.swift
//  MenuDBApp
//
//  Created by JoJo M on 1/8/24.
//

import Foundation
import SwiftUI

struct RecipeView: View {
    @StateObject private var viewModel: RecipeViewModel
    let bounds = UIScreen.main.bounds
    let dessertId: String

    init(dessertId: String) {
        self.dessertId = dessertId
        _viewModel = StateObject(wrappedValue: RecipeViewModel(dessertId: dessertId))
    }

    var body: some View {
        List {
            // Display the dessert name
            if let dessertName = viewModel.recipeDetail?.strMeal, !dessertName.isEmpty {
                Text(dessertName.capitalized)
                    .font(.title)
                    .fontWeight(.bold)
            }

            // Display the dessert image
            if let imageUrl = URL(string: viewModel.recipeDetail?.strMealThumb ?? "") {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: bounds.width * 0.6)
                        .clipped()
                        .listRowInsets(EdgeInsets())
                } placeholder: {
                    ProgressView()
                }
            }

            // Display the list of ingredients with their measurements
            if let ingredients = viewModel.recipeDetail?.ingredients,
               let measurements = viewModel.recipeDetail?.measurements {
                Section(header: Text("Ingredients").font(.title).fontWeight(.bold)) {
                    ForEach(0..<min(ingredients.count, measurements.count), id: \.self) { index in
                        let ingredient = ingredients[index]
                        let measurement = measurements[index]

                        if !ingredient.isEmpty {
                            let capitalizedIngredient = ingredient.capitalized
                            HStack {
                                Text("\(capitalizedIngredient):").font(.body)
                                Text(measurement).font(.body).italic()
                            }
                        }
                    }
                }
            }

            // Display the instructions for preparing the dessert
            if let instructions = viewModel.recipeDetail?.strInstructions, !instructions.isEmpty {
                Section(header: Text("Instructions").font(.title).fontWeight(.bold)) {
                    let steps = instructions.components(separatedBy: CharacterSet(charactersIn: ".\r\n"))
                        .filter { !$0.isEmpty }

                    ForEach(steps.indices, id: \.self) { index in
                        let step = steps[index]
                        if !step.isEmpty {
                            Text("\(index + 1). \(step.trimmingCharacters(in: .whitespaces))")
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .listRowSeparator(.hidden)
                                .padding(.bottom, 0)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("", displayMode: .inline)
        .padding(.top, -30)
        .task {
            await viewModel.fetchRecipeDetails()
        }
    }
}

