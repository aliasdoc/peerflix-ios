//
//  SearchResult.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import Freddy

struct SearchResult {
    let engine: String
    let query: String
    let torrents: [Torrent]
    let success: Bool

    struct Torrent {
        let name : String
        let size : String
        let seeders : Int
        let leechers : Int
        let URL : NSURL?
    }
    
    static let error = SearchResult(engine: "", query: "", torrents: [], success: false)
}

extension SearchResult: JSONDecodable {
    init(json: JSON) throws {
        self.engine = try json.string("engine", ifNotFound: true) ?? ""
        self.query = try json.string("query", ifNotFound: true) ?? ""
        self.success = try json.bool("success")
        self.torrents = try json.arrayOf("torrents", type: Torrent.self)
    }
}

extension SearchResult.Torrent: JSONDecodable {
    init(json: JSON) throws {
        self.name = try json.string("name", ifNotFound: true) ?? ""
        
        do {
            self.size = try json.string("size") ?? ""
        } catch _ as JSON.Error {
            // todo: change the kickass search engine parser which will return Int size instead of String
            let size = try json.int("size")
            self.size = formatFileSize(Double(size)) + " M"
        }
        
        self.seeders = try json.int("seeders", ifNotFound: true) ?? 0
        self.leechers = try json.int("leechers", ifNotFound: true) ?? 0
        self.URL = try json.string("link", ifNotFound: true).flatMap({ NSURL(string: $0) })
    }
}

extension SearchResult.Torrent: Equatable {
}

func==(lhs: SearchResult.Torrent, rhs: SearchResult.Torrent) -> Bool {
    return lhs.URL == rhs.URL
}