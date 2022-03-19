//
//  DataModel.swift
//  GoldManSachsAssignment
//
//  Created by Sri Sai Sindhuja, Kanukolanu on 19/03/22.
//

import Foundation
import UIKit

struct DataModel:Hashable {
    
    static func == (lhs: DataModel, rhs: DataModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    var date        : String
    var image       : UIImage
    var explanation : String
    var title       : String
}
