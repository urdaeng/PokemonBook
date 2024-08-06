//
//  Pokemon.swift
//  PokemonBook
//
//  Created by 강유정 on 8/5/24.
//

import Foundation

struct PokemonResponse: Codable {
    
    let results: [Pokemon]
    // results는 안에 [Pokemon]이라는 타입이 들어오도록.
}

// 구조체 생성
struct Pokemon: Codable {
    
    // 원하는 데이터 가져오기
    let name: String?          // 포켓몬 이름
    let url: String?           // 포켓몬 상세 정보를 얻기 위한 URL
    
    var id: Int? {
        // URL에서 Pokemon ID 추출
        guard let urlString = url else { return 0 }
        let components = urlString.split(separator: "/")
        return Int(components[components.count - 1]) ?? 0
    }
}
