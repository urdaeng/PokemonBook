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
    private var currentPage = 0
    private var isLoading = false   // 현재 데이터 로딩이 진행 중인 상태인지 아닌지
    private var hasMoreData = true  // 데이터가 더 있는지 여부
    
    // View가 구독할 Subject.
    // 여기서 MVVM의 데이터 바인딩이 일어나는 거고 옵저버 패턴 활용.
    let pokemonSubject = BehaviorSubject(value: [Pokemon]())
    // 초기값이 있는 subject, 초기값은 빈 포켓몬 배열
    
    init() {
        fetchPokemon()
    }
    
    // ViewModel에서 수행해야 할 비즈니스 로직.
    func fetchPokemon() {
        
        // 이미 로딩 중인 경우 중복 요청 방지
        guard !isLoading else { return }
        isLoading = true  // 로딩 상태로 설정
        
        // 서버 통신할 url
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(currentPage)") else {
            pokemonSubject.onError(NetworkError.invalidurl)
            isLoading = false
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (pokemonResponse: PokemonResponse) in
                // 순환 참조를 방지.
                guard let self = self else { return }
                
                // 현재 Subject에서 기존의 포켓몬 리스트를 가져오기.
                guard let currentPokemons = try? self.pokemonSubject.value() else {
                    self.pokemonSubject.onError(NetworkError.dataFetchFail)
                    return
                }
                
                let newPokemons = pokemonResponse.results       // 네트워크 호출로 받아온 새로운 포켓몬 리스트
                let allPokemons = currentPokemons + newPokemons // 기존의 포켓몬 리스트와 결합
                self.pokemonSubject.onNext(allPokemons)         // 결합된 포켓몬 리스트를 Subject에 전달하여 View에서 업데이트
                self.currentPage += self.limit                  // 페이지 증가

                self.isLoading = false  // 데이터 로딩이 완료되었으므로 false로 설정
                
            }, onFailure: { [weak self] error in
                // 네트워크 요청이 실패한 경우, 에러를 Subject에 전달하여 View에서 처리할 수 있도록.
                self?.pokemonSubject.onError(error)
                
                // 실패한 경우에도 데이터 로딩 상태를 `false`로 설정
                self?.isLoading = false
            }).disposed(by: disposeBag)
    }
}
