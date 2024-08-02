//
//  NetworkManager.swift
//  PokemonBook
//
//  Created by 강유정 on 8/2/24.
//

import Foundation
import RxSwift

// 직접 커스텀 에러 선언
enum NetworkError: Error {
    case invalidurl // 잘못된 url이 들어왔을 때
    case dataFetchFail // 데이터 패치가 일반적으로 실패했을 때
    case decodingFail // 디코딩이 실패했을 때
}

class NetworkManager {
    
    static let shared = NetworkManager() // 싱글톤
    
    private init() {}
    
    // 여러 군데에서 재활용할 수 있는 서버로부터 네트워크 통신을 하는 일반적인 코드.
    func fetch<T: Decodable>(url: URL) -> Single<T> {
        // 싱글 타입으로 리턴 / Single은 옵저버블 중에서 단 한번만 이벤트를 방출하는 친구
        
        return Single.create { observer in
            let session = URLSession(configuration: .default)
            session.dataTask(with: URLRequest(url: url)) { data, response, error in
                if let error = error {
                    // 만약에 에러가 있다고 하면 옵저버블 싱글 failure 에러를 뱉도록.
                    observer(.failure(NetworkError.dataFetchFail))
                    return
                    // 에러 방출했으면 그대로 이 함수를 종료.
                }
                
                // 그게 아니라면
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      // data와 response를 HTTPURLResponse로 타입 캐스팅
                      (200..<300).contains(response.statusCode) else {
                    // 거기 있는 status 값이 200과 300 사이에 들면 성공 범주
                    
                    // 아니라면 이 타입의 에러를 싱글에다가 방출
                    observer(.failure(NetworkError.dataFetchFail))
                    return
                }
                
                do {
                    // 데이터를 잘 받아왔으면 이 data를 T.self 타입으로 Josn 디코딩을 try
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    // 성공을 했다면 그제서야 succes에다가 디코딩된 데이터를 방출.
                    observer(.success(decodedData))
                }catch {
                    // 이게 실패히면 catch 문으로 빠져서, obeserver에 failure를 뱉어주기.
                    observer(.failure(NetworkError.decodingFail))
                }
            }.resume()
            
            return Disposables.create()
        }
    }
}
