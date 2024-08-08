//
//  DetailViewController.swift
//  PokemonBook
//
//  Created by 강유정 on 8/6/24.
//

import UIKit
import RxSwift
import SnapKit

class DetailViewController: UIViewController {
    
    private let detailViewModel: DetailViewModel
    private let disposeBag = DisposeBag()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let heightLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let weightLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = .darkRed
        stackView.layer.cornerRadius = 20
        stackView.spacing = 10
        return stackView
    }()
    
    private let bottomView: UIView = {
        let bottomView = UIView()
        bottomView.backgroundColor = .clear
        return bottomView
    }()
    
    init(pokemonId: Int) {
        self.detailViewModel = DetailViewModel(pokemonId: pokemonId)  // ViewModel 초기화
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainRed
        
        configureUI()
        bindViewModel()
    }
    
    // ViewModel 바인딩
    private func bindViewModel() {
        detailViewModel.pokemonDetailSubject
        // pokemonDetailSubject 구독
            .observe(on: MainScheduler.instance)    //메인 스레드에서 동작해라 라고 명시.
            .subscribe(onNext: { [weak self] detail in
                
                // 필터링하여 ID와 일치하는 정보만 추출
                guard let pokemonId = self?.detailViewModel.pokemonId else { return }
                
                if detail.order == pokemonId {
                    // UI 업데이트
                    self?.updateUI(with: detail)
                }
            }, onError: { error in
                print("에러 발생: \(error)")
            }).disposed(by: disposeBag)
    }
    
    private func updateUI(with detail: PokemonDetail) {
        //UI를 업데이트.
        self.nameLabel.text = "No.\(detail.order!)  \(detail.name!)"
        
        // `types` 배열을 문자열로 변환하여 `typeLabel`에 표시
        let types = detail.types?.map { $0.type.name }.joined(separator: ", ") ?? "Unknown"
        typeLabel.text = "Type: \(types)"
        
        let height = detail.height ?? 0
        let weight = detail.weight ?? 0
        
        // 높이와 무게를 소수점 한자리로 포맷
        heightLabel.text = String(format: "Height: %.1f m", height * 0.1)
        weightLabel.text = String(format: "Weight: %.1f kg", weight * 0.1)
        
        // 포켓몬 이미지 URL을 UIImageView에 업데이트
        if let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(detail.order ?? 0).png") {
            // URL 세션을 사용해서 이미지 데이터 가져오기
            DispatchQueue.global().async { [weak self] in
                do {
                    let data = try Data(contentsOf: url)
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.imageView.image = image
                        }
                    }
                } catch {
                    print("이미지 로드 실패: \(error)")
                }
            }
        }
    }
    
    private func configureUI() {
        [
            imageView, nameLabel, typeLabel, heightLabel, weightLabel, bottomView
        ].forEach { stackView.addArrangedSubview($0) }
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(400)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.top).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(200)
        }
    }
}
