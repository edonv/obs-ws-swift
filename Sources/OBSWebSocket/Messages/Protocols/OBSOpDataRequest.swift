//
//  OBSOpDataRequest.swift
//  obs-ws-swift
//
//  Created by Edon Valdman on 6/3/26.
//

import Foundation
import JSONValue

public protocol OBSOpDataRequest: Codable {
    var type: OBSWS.Requests.AllTypes { get }
    var data: JSONValue? { get }
}
