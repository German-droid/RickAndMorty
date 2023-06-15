//
//  Service.swift
//  Rick&Morty
//
//  Created by German Fuentes Ripoll on 11/6/23.
//

import Foundation
import CoreData
import UIKit

enum ServiceError: Error {
    case ServiceErrorResponse
    case ServiceErrorURL
    case ServiceErrorParsing
    case ServiceErrorImage
    case ServiceErrorSaveToCoreData
    case ServiceErrorRetrieveFromCoreData
}

class Service {
    
    static let shared = Service()
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let BASE_URL = "https://rickandmortyapi.com/api/character"

    //MARK: - Api methods
    
    func fetchAllFromApiToCoreData(completion: @escaping (Result<Void, Error>) -> Void) {
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
                            // Once all characters are retrieved
                            
                            self.saveToCoreData(characters: allCharacters) { result in
                                
                                switch result {
                                    case .success:
                                        completion(.success(()))
                                    case .failure(let error):
                                    completion(.failure(error))
                                }
                                
                            }
                            
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
    
    //MARK: - Core Data methods
    
    private func saveToCoreData(characters: [Character], completion: @escaping (Result<Void, Error>) -> ()) {
        
        for character in characters {
            let savedCharacter = CoreCharacter(context: managedContext)
            
            savedCharacter.setValue(character.id, forKey: "id")
            savedCharacter.setValue(character.name, forKey: "name")
            savedCharacter.setValue(character.status, forKey: "status")
            savedCharacter.setValue(character.species, forKey: "species")
            savedCharacter.setValue(character.type, forKey: "type")
            savedCharacter.setValue(character.gender, forKey: "gender")
            savedCharacter.setValue(character.origin.name, forKey: "origin")
            savedCharacter.setValue(character.location.name, forKey: "location")
            savedCharacter.setValue(character.imageData ?? Data(), forKey: "image")
            savedCharacter.setValue(character.episode[0], forKey: "debut")
            
            do {
                try self.managedContext.save()
            } catch let error as NSError {
                print("Could not save \(character.name). \(error)")
                completion(.failure(ServiceError.ServiceErrorSaveToCoreData))
            }
            
        }
        completion(.success(()))
    }
    
    func retrieveFromCoreData(completion: @escaping (Result<[CoreCharacter], Error>) -> ()) {

        do {
            let allSavedCharacters = try managedContext.fetch(CoreCharacter.fetchRequest())
            
            completion(.success(allSavedCharacters))
        } catch let error {
            print("No se pudieron obtener los datos de Core Data. \(error.localizedDescription)")
            completion(.failure(ServiceError.ServiceErrorRetrieveFromCoreData))
        }
        
    }
    
    func checkIfItemExist() -> Bool {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CoreCharacter")

        do {
            let count = try managedContext.count(for: fetchRequest)
            if count > 0 {
                return true
            }else {
                return false
            }
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
    }
    
    func deleteFromPersistent() {
        do {
            let allSaved = try managedContext.fetch(CoreCharacter.fetchRequest())
            
            for character in allSaved {
                self.managedContext.delete(character)
            }
            try managedContext.save()
        } catch let error {
            print("No se puedieron borrar los datos de CoreData. \(error.localizedDescription)")
        }
    }
}
