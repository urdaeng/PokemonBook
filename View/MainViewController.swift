//
//  ViewController.swift
//  PokemonBook
//
//  Created by 강유정 on 8/2/24.
//

import UIKit
import RxSwift
import SnapKit

class MainViewController: UIViewController {
    
    //ViewController가 바라볼 viewModel을 선언
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    private var pokemonSubject = [Pokemon]()
    
    private let logo: UIImageView = {
        let logo = UIImageView()
        logo.image = .pokemonBall
        logo.contentMode = .scaleAspectFill
        return logo
    }()
    
    // 컬렉션뷰를 한번 만들어 볼 거다.
    private lazy var collectionView: UICollectionView = {
        // 여기 lazy로 선언했던 이유는 안에서 self 키워들 사용하기 위해서.
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        // 이따가 만들어서 여기다가 넣어주도록 할거다.
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.id)
        // 컬렉션뷰셀을 등록.
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(red: 120/255, green: 30/255, blue: 30/255, alpha: 1.0)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureUI()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        // 아이템의 사이즈를 선언
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3.0), // 전체 너비의 1/3
            heightDimension: .fractionalHeight(1.0)
        )
        
        // 설정한 것으로 아이템 지정
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // 아이템 간의 간격 설정
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5) // 좌우 간격을 설정
        
        // 그룹 사이즈 설정
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.33) // 그룹의 높이를 화면 너비의 1/3으로 설정
        )
        
        // 설정한 것으로 그룹 지정
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item, item, item] // 한 줄에 3개의 아이템
        )
        
        // 섹션 설정
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none // 수평 스크롤 비활성화
        
        // Compositional Layout 반환
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // viewModel과 ViewController를 연결하는 데이터 바인딩 메서드
    private func bind() {
        viewModel.pokemonSubject
        // pokemonSubject 구독
            .observe(on: MainScheduler.instance) //메인 스레드에서 동작해라 라고 명시.
            .subscribe(onNext: { [weak self] pokemon in
                self?.pokemonSubject = pokemon
                // 들어온 pokemon 데이터를 pokemonSubject에다가 넣어주도록.
                self?.collectionView.reloadData()
                // pokemon을 넣어준 다음에 CollectionView에 반영.
            }, onError: { error in
                print("에러 발생: \(error)")
            }).disposed(by: disposeBag)
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor(red: 190/255, green: 30/255, blue: 40/255, alpha: 1.0)
        [
            logo,
            collectionView
        ].forEach {view.addSubview($0)}
        
        logo.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-20)
            // 휴대폰 기기와 상관없이 안정적으로 레이아웃을 보여줄 수 있는 영역을 safeArea
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(110)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(logo.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // 섹션당 아이템의 수를 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemonSubject.count
    }
    
    // 특정 인덱스 패스에 해당하는 셀을 반환
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.id, for: indexPath) as! CollectionViewCell
        
        // 데이터 모델에서 Pokemon 객체를 가져와서 셀에 설정
        let pokemon = pokemonSubject[indexPath.item]
        cell.configure(with: pokemon)
        
        return cell
    }
    
    // 셀을 눌렀을 때 동작 지정
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailViewController = DetailViewController()
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
