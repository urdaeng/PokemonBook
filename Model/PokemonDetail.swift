//
//  PokemonDetail.swift
//  PokemonBook
//
//  Created by 강유정 on 8/5/24.
//

import Foundation

struct PokemonDetailResponse: Codable {
    
    let results: [PokemonDetail]
    // results는 안에 [PokemonDetail]이라는 타입이 들어오도록.
}

// 구조체 생성
struct PokemonDetail: Codable {
    
    // 원하는 데이터 가져오기
    let id : Int?               // 아이디
    let types: String?          // 타입
    let height: Double?         // 키
    let weight: Double?         // 몸무게
    
}
