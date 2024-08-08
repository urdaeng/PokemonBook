//
//  PokemonDetail.swift
//  PokemonBook
//
//  Created by 강유정 on 8/5/24.
//

import Foundation

// 구조체 생성
struct PokemonDetail: Codable {
    let order: Int?                 // 아이디
    let name: String?               // 이름
    let types: [Types]?             // 타입
    let height: Double?             // 키
    let weight: Double?             // 몸무게
    
    struct Types: Codable {
        let type: TypesName
        
        struct TypesName: Codable {
            let name: String
        }
    }
}
