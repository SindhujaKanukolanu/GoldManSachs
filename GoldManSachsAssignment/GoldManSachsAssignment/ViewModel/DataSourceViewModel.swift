//
//  DataSourceViewModel.swift
//  GoldManSachsAssignment
//
//  Created by Sri Sai Sindhuja, Kanukolanu on 19/03/22.
//

import Foundation
import Combine
import UIKit

enum NetworkError: Error {
    case Success
    case Failure
}

class DataSourceViewModel {
    
    var cards = [SectionModel]()
    var dataImage = UIImage()
    private var cancellable: AnyCancellable?
    var jsonObject = [String:AnyObject]()
    var allCancellable = Set<AnyCancellable>()
    var models = [SectionModel]()


    
    init() {
        getResponseData()
    }
        
    func getResponseData() {
        if let urlString = URL(string: "https://api.nasa.gov/planetary/apod?api_key=Te4UhAuy3ku57E8MSGicDc6JrV1eGRb0s4Ut7Kjq") {
            let jsonPublisher =  URLSession.shared.dataTaskPublisher(for: urlString)
                .tryMap ({ (data, response) -> Data in
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 400 {
                            print("unauthorized")
                        }
                    }
                    return data
                }).decode(type: Model.self, decoder: JSONDecoder()).eraseToAnyPublisher()
                
           // consume the value to Upadte the model
            jsonPublisher.sink { (completion) in
                switch(completion) {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("sink finished sucessfullhy")
                }
            } receiveValue: {(details: Model) in
                self.updateSectionModel(models: details)
            }.store(in: &allCancellable)
        }
    }
    
    func updateSectionModel(models:Model) {
        let cardModel = SectionModel(title: models.title, rows: [DataModel(date: models.date, image: UIImage(), explanation: models.explanation, title: models.title)])
        dataImage = fetchImage(imageURL: models.url)
        cards.append(cardModel)
    }
    
    func fetchCards() -> AnyPublisher<[SectionModel], NetworkError> {
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 30) { [weak self] in
                guard let updatedCards = self?.cards else {
                    promise(.failure(.Failure))
                    return
                }
                promise(.success(updatedCards))
            }
        }.eraseToAnyPublisher()
    }

    func fetchImage(imageURL: String) -> UIImage {
        if let urlString = URL(string: imageURL) {
            if let data = try? Data(contentsOf: urlString) {
                // Create Image and Update Image View
                guard let image =  UIImage(data: data) else {
                    return UIImage()
                }
                dataImage = image
                return dataImage
            }
        }
        return dataImage
    }
}
