//
//  CollectionViewCell.swift
//  PokemonBook
//
//  Created by 강유정 on 8/6/24.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    static let id = "CollectionViewCell"
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .darkGray
        imageView.layer.cornerRadius = 10   // 모서리 부분이 조금 동그랗게 깍이도록 설정
        imageView.clipsToBounds = true      // 깍여진 부분을 imageView도 함께 깍여줄 수 있게 해주는 속성
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()     // 셀이 재사용될 준비가 되었을 때 호출되는 메서드
        imageView.image = nil       // 셀이 재사용되기 전에 이전에 설정된 이미지를 제거
    }
    
    func configure(with pokemonDetail: PokemonDetail) {
        guard let pokemonId = pokemonDetail.id else { return }
        // 없다면 return
        let urlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonId).png"
        // 포케몬 이미지 URL
        guard let url = URL(string: urlString) else { return }
        // 이거를 url 타입으로 바꾸도록.
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
            // url로부터 이미지 데이터를 가져오는 코드
                if let image = UIImage(data: data) {
                // 잘 받았다면 UIImage 객체로 변환
                    DispatchQueue.main.async {
                        // 메인 스레드를 활용
                        self?.imageView.image = image
                    }
                }
            }
        }
    }
}
