//
//  Router.swift
//  SumDU
//
//  Created by Yura Voevodin on 12/7/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Alamofire
import Foundation

/// Request router
enum Router: URLRequestConvertible {
  
  case schedule([String: String])
  case scheduleCalendar([String: String])
  case updateListsOfAuditoriumsGroupsTeachers
  
  /// Main URL for schedule requests
  static let baseURL = "http://schedule.sumdu.edu.ua"
  
  /// Returns HTTP method for each request
  var method: HTTPMethod {
    switch self {
    case .schedule:
      return .post
    case .scheduleCalendar:
      return .get
    case .updateListsOfAuditoriumsGroupsTeachers:
      return .get
    }
  }
  
  /// Returns relative path to each API endpoint
  var path: String {
    switch self {
    case .schedule:
      return "/index/json"
    case .scheduleCalendar:
      return "/index/ical"
    case .updateListsOfAuditoriumsGroupsTeachers:
      return ""
    }
  }
  
  // MARK: - URLRequestConvertible
  
  func asURLRequest() throws -> URLRequest {
    let url = try Router.baseURL.asURL()
    
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    urlRequest.httpMethod = method.rawValue
    
    switch self {
    case .schedule(let params):
      urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
    case .scheduleCalendar(let params):
      urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
    case .updateListsOfAuditoriumsGroupsTeachers:
      urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
    }
    
    return urlRequest
  }
  
}
