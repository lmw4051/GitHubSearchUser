//
//  SearchResultCell.swift
//  GitHubSearch
//
//  Created by David on 2021/10/14.
//

import UIKit

class SearchResultCell: UICollectionViewCell {
  var user: User! {
    didSet {
      profileImageView.image = UIImage(named: "image_placeholder")
      loginLabel.text = user.login
      scoreLabel.text = String(user.score)
    }
  }
  
  let profileImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.layer.cornerRadius = 40
    iv.clipsToBounds = true
    return iv
  }()
  
  let loginLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.textAlignment = .center
    label.numberOfLines = 2
    label.font = .systemFont(ofSize: 18, weight: .semibold)
    return label
  }()
  
  let scoreLabel: UILabel = {
    let label = UILabel()
    label.textColor = .lightGray
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 16)
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configureViews() {
    let containerView = UIView()
    
    let stackView = containerView.hStack(
      profileImageView,
      containerView.vStack(loginLabel, scoreLabel, spacing: 8, alignment: .leading),
      spacing: 16, alignment: .center)
    
    stackView.layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 32)
    stackView.isLayoutMarginsRelativeArrangement = true
    profileImageView.constrainWidth(constant: 80)
    profileImageView.constrainHeight(constant: 80)
    
    addSubview(containerView)
    containerView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 8, left: 0, bottom: 8, right: 0))
  }
}
