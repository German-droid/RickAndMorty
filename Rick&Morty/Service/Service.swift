//
//  Service.swift
//  Rick&Morty
//
//  Created by German Fuentes Ripoll on 11/6/23.
//

import Foundation

enum ServiceError: Error {
    case ServiceErrorResponse
    case ServiceErrorURL
    case ServiceErrorParsing
    case ServiceErrorImage
}

class Service {
    
    static let shared = Service()
    let BASE_URL = "https://rickandmortyapi.com/api/character"

    func fetchAllFromApiToCoredata(completion: @escaping (Result<[Character], Error>) -> Void) {
        var allCharacters: [Character] = []
        var nextURL: String? = BASE_URL
        
        func fetchNextPage() {
            guard let url = nextURL else {
                completion(.failure(ServiceError.ServiceErrorURL))
                return
            }
            
            obtainPaginatedInfo(url: url) { result, nextPage in
                switch result {
                case .success(let characters):
                    allCharacters.append(contentsOf: characters)
                    
                    if nextPage == "" {
                        
                        let group = DispatchGroup()
                        for (index,character) in allCharacters.enumerated() {
                            group.enter()
                            self.fetchCharacterImage(imageUrl: character.image) { imageResult in
                                switch imageResult {
                                    case .success(let imageData):
                                        var characterWithImage = character
                                        characterWithImage.imageData = imageData
                                    allCharacters[index] = characterWithImage
                                            
                                    case .failure(let error):
                                        completion(.failure(error))
                                }
                                        
                                group.leave()
                            }
                        }
                                
                        group.notify(queue: DispatchQueue.main) {
                            completion(.success(allCharacters))
                        }
                        
                    } else {
                        nextURL = nextPage
                        fetchNextPage() // Llama recursivamente para obtener la siguiente página
                    }
                    
                case .failure(let error):
                    // Manejar el error en la obtención de los personajes
                    completion(.failure(error))
                }
            }
        }
        
        fetchNextPage() // Inicia el proceso de obtener la primera página
    }

    func obtainPaginatedInfo(url: String, completion: @escaping (Result<[Character], Error>, String ) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(ServiceError.ServiceErrorURL), "")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(ServiceError.ServiceErrorResponse), "")
                return
            }
            
            guard let data = data else {
                completion(.failure(ServiceError.ServiceErrorResponse), "")
                return
            }
            
            do {
                let pageResult = try JSONDecoder().decode(CharacterList.self, from: data)
                
                completion(.success(pageResult.results), pageResult.info.next ?? "")
            } catch {
                completion(.failure(ServiceError.ServiceErrorParsing), "")
            }
            
        }.resume()
    }
    
    func fetchCharacterImage(imageUrl: String, completion: @escaping (Result<Data, Error>) -> ()) {
        guard let url = URL(string: imageUrl) else {
            completion(.failure(ServiceError.ServiceErrorImage))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                completion(.failure(ServiceError.ServiceErrorImage))
                return
            }
                
            guard let data = data else {
                completion(.failure(ServiceError.ServiceErrorImage))
                return
            }
            completion(.success(data))
        }.resume()
    }
    
    
    
    
}
