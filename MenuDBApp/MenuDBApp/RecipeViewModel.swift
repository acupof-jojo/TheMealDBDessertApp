//
//  RecipeView.swift
//  MenuDBApp
//
//  Created by JoJo M on 1/8/24.
//

import Foundation

let baseUrl = "https://www.themealdb.com/api/json/v1/1/"

/// Returns the URL for retrieving recipe details for a specific meal.
 func recipeDetailsUrl(for mealId: String) -> URL {
    let urlString = "\(baseUrl)lookup.php?i=\(mealId)"
    return URL(string: urlString)!
}

class Webservice {

    /// Performs an asynchronous network request to fetch data from a URL
    /// - Parameters:
    ///   - url: The URL to fetch the data from
    ///   - parse: A closure that parses the received data and returns the result
    /// - Returns: The parsed result of type `T`
    func get<T: Decodable>(url: URL, parse: @escaping (Data) throws -> T?) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw NetworkError.badRequest
        }
        
        guard let result = try parse(data) else {
            throw NetworkError.decodingError
        }
        
        return result
    }
    
    /// Enumeration representing network-related errors
    enum NetworkError: Error {
        //case invalidURL
        case badRequest
        case decodingError
    }

}

/// A view model class responsible for fetching and managing dessert recipe details
class RecipeViewModel: ObservableObject {
    @Published var recipeDetail: RecipeDetail?
    @Published var error: Error?
    
    /// Represents an ingredient and its corresponding measurement.
    struct IngredientMeasurement: Identifiable {
        let id = UUID()
        let ingredient: String
        let measurement: String
    }
    
    internal let dessertId: String
    
    /// Initializes the view model with a dessert ID
    init(dessertId: String = "") {
        self.dessertId = dessertId
    }
    
    /// Fetches the recipe details from the API using web service
    func fetchRecipeDetails(using webservice: Webservice = Webservice()) async {
        let url = recipeDetailsUrl(for: dessertId)
        
        do {
            self.recipeDetail = try await webservice.get(url: url, parse: { data in
                let decoder = JSONDecoder()
                let response = try decoder.decode(RecipeResponse.self, from: data)
                return response.meals?.first
            })
            print("Recipe details fetched successfully")
            
        } catch {
            self.error = error
            print("Failed to fetch recipe details: \(error)")

        }
    }
}
