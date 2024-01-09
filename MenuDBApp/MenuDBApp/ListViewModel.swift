//
//  ListViewModel.swift
//  MenuDBApp
//
//  Created by JoJo M on 1/8/24.
//

import Foundation
import SwiftUI

@MainActor
class ListViewModel: ObservableObject {
    @Published var recipes: [Meal] = []
    @Published var selectedDessert: Meal?
    var recipeViewModel: RecipeViewModel
    
    var webservice: Webservice
    init(webservice: Webservice = Webservice()) {
        self.webservice = webservice
        recipeViewModel = RecipeViewModel(dessertId: "")
    }

    // Fetches list of desserts from the API using a webservice
    func populateCategories(using webservice: Webservice? = nil) async {
        let fetchWebService = webservice ?? self.webservice

        do {
            let urlString = "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert"
            let response = try await fetchWebService.get(url: URL(string: urlString)!) { data in
                return try? JSONDecoder().decode(ListResponse.self, from: data)
            }

            // Update recipes var with received dessert list
            recipes = response.meals ?? []
        } catch {
            print(error)
        }
    }

    // Create instance of RecipeViewModel using the selected dessert's ID
    func selectDessert(_ dessert: Meal) {
        selectedDessert = dessert
        recipeViewModel = RecipeViewModel(dessertId: dessert.idMeal)
    }

}
