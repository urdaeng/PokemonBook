//
//  DetailViewModel.swift
//  PokemonBook
//
//  Created by 강유정 on 8/7/24.
//

import Foundation
import RxSwift

class DetailViewModel {
    
    private let disposeBag = DisposeBag()
    // 구독 해제했을 때 담아줄 disposeBag
    
    // View가 구독할 Subject.
    // 여기서 MVVM의 데이터 바인딩이 일어나는 거고 옵저버 패턴 활용.
    let pokemonDetailSubject = PublishSubject<PokemonDetail>() // 단일 객체
    
    let pokemonId: Int
    
    init(pokemonId: Int) {
        self.pokemonId = pokemonId
        fetchPokemonDetail()
    }
    
    // ViewModel 에서 수행해야 할 비즈니스로직.
    func fetchPokemonDetail() {
        
        // 서버 통신할 url
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonId)/") else {
            pokemonDetailSubject.onError(NetworkError.invalidurl)
            return
        }
        
        // 네트워크 메니저를 사용
        NetworkManager.shared.fetch(url: url)
            // Success일 때 어떤 로직을 수용할 것인지 작성
            .subscribe(onSuccess: { [weak self] (pokemonDetail: PokemonDetail) in
                // Model에 있던 PokemonDetail을 가져오기.
                self?.pokemonDetailSubject.onNext(pokemonDetail)
                // 이 url로 요청을 하고 성공을 했다면, pokemonDetail를 pokemonDetailSubject에 전달하여 View에서 사용할 수 있도록.
            }, onFailure: { [weak self] error in
                self?.pokemonDetailSubject.onError(error)
                // 그리고 onFailure일 때는 에러를 넣어주겠다.
            }).disposed(by: disposeBag)
    }
}
