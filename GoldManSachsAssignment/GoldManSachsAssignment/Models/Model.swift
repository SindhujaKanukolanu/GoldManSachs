//
//  Model.swift
//  GoldManSachsAssignment
//
//  Created by Sri Sai Sindhuja, Kanukolanu on 19/03/22.
//

import Foundation

struct Model: Codable {
    let date, explanation: String
    let hdurl: String
    let mediaType, serviceVersion, title: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case date, explanation, hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title, url
    }
}
