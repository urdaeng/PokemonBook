//
//  MainViewModel.swift
//  PokemonBook
//
//  Created by 강유정 on 8/5/24.
//

import Foundation
import RxSwift

class MainViewModel {
    
    private let disposeBag = DisposeBag()
    // 구독 해제했을 때 담아줄 disposeBag
    
    private let limit = 20
    private let offset = 0
    
    // View가 구독할 Subject.
    // 여기서 MVVM의 데이터 바인딩이 일어나는 거고 옵저버 패턴 활용.
    let pokemonSubject = BehaviorSubject(value: [Pokemon]())
    // 초기값이 있는 subject, 초기값은 빈 포켓몬 배열
    
    init() {
        fetchPokemon()
    }
    
    // ViewModel 에서 수행해야 할 비즈니스로직.
    func fetchPokemon() {
        
        // 서버 통신할 url
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)") else {
            pokemonSubject.onError(NetworkError.invalidurl)
            return
        }
        
        // 네트워크 메니저를 사용
        NetworkManager.shared.fetch(url: url)
            // Success일 때 어떤 로직을 수용할 것인지 작성
            .subscribe(onSuccess: { [weak self] (pokemonResponse: PokemonResponse) in
                // Model에 있던 Pokemon 리스트를 가져오는 pokemonResponse.
                self?.pokemonSubject.onNext(pokemonResponse.results)
                // 이 url로 요청을 하고 성공을 했다면, pokemonResponse를 pokemonSubject에 전달하여 View에서 사용할 수 있도록.
            }, onFailure: { [weak self] error in
                self?.pokemonSubject.onError(error)
                // 그리고 onFailure일 때는 에러를 넣어주겠다.
            }).disposed(by: disposeBag)
    }
}
