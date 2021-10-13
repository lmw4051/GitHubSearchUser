//
//  UIView+Layout.swift
//  GitHubSearch
//
//  Created by David on 2021/10/14.
//

import UIKit
extension UIView {
  
  @discardableResult
  func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) -> AnchoredConstraints {
    
    translatesAutoresizingMaskIntoConstraints = false
    var anchoredConstraints = AnchoredConstraints()
    
    if let top = top {
      anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
    }
    
    if let leading = leading {
      anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
    }
    
    if let bottom = bottom {
      anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
    }
    
    if let trailing = trailing {
      anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
    }
    
    if size.width != 0 {
      anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
    }
    
    if size.height != 0 {
      anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
    }
    
    [anchoredConstraints.top, anchoredConstraints.leading, anchoredConstraints.bottom, anchoredConstraints.trailing, anchoredConstraints.width, anchoredConstraints.height].forEach{ $0?.isActive = true }
    
    return anchoredConstraints
  }
  
  func fillSuperview(padding: UIEdgeInsets = .zero) {
    translatesAutoresizingMaskIntoConstraints = false
    if let superviewTopAnchor = superview?.topAnchor {
      topAnchor.constraint(equalTo: superviewTopAnchor, constant: padding.top).isActive = true
    }
    
    if let superviewBottomAnchor = superview?.bottomAnchor {
      bottomAnchor.constraint(equalTo: superviewBottomAnchor, constant: -padding.bottom).isActive = true
    }
    
    if let superviewLeadingAnchor = superview?.leadingAnchor {
      leadingAnchor.constraint(equalTo: superviewLeadingAnchor, constant: padding.left).isActive = true
    }
    
    if let superviewTrailingAnchor = superview?.trailingAnchor {
      trailingAnchor.constraint(equalTo: superviewTrailingAnchor, constant: -padding.right).isActive = true
    }
  }
  
  @discardableResult
  func fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets = .zero) -> AnchoredConstraints {
    let anchoredConstraints = AnchoredConstraints()
    guard let superviewTopAnchor = superview?.safeAreaLayoutGuide.topAnchor,
      let superviewBottomAnchor = superview?.safeAreaLayoutGuide.bottomAnchor,
      let superviewLeadingAnchor = superview?.safeAreaLayoutGuide.leadingAnchor,
      let superviewTrailingAnchor = superview?.safeAreaLayoutGuide.trailingAnchor else {
        return anchoredConstraints
    }
    return anchor(top: superviewTopAnchor, leading: superviewLeadingAnchor, bottom: superviewBottomAnchor, trailing: superviewTrailingAnchor, padding: padding)
  }
  
  func centerInSuperview(size: CGSize = .zero) {
    translatesAutoresizingMaskIntoConstraints = false
    if let superviewCenterXAnchor = superview?.centerXAnchor {
      centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
    }
    
    if let superviewCenterYAnchor = superview?.centerYAnchor {
      centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
    }
    
    if size.width != 0 {
      widthAnchor.constraint(equalToConstant: size.width).isActive = true
    }
    
    if size.height != 0 {
      heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }
  }
  
  func centerXInSuperview() {
    translatesAutoresizingMaskIntoConstraints = false
    if let superViewCenterXAnchor = superview?.centerXAnchor {
      centerXAnchor.constraint(equalTo: superViewCenterXAnchor).isActive = true
    }
  }
  
  func centerYInSuperview() {
    translatesAutoresizingMaskIntoConstraints = false
    if let centerY = superview?.centerYAnchor {
      centerYAnchor.constraint(equalTo: centerY).isActive = true
    }
  }
  
  func constrainWidth(constant: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    widthAnchor.constraint(equalToConstant: constant).isActive = true
  }
  
  func constrainHeight(constant: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    heightAnchor.constraint(equalToConstant: constant).isActive = true
  }
  
  fileprivate func _stack(_ axis: NSLayoutConstraint.Axis = .vertical, views: [UIView], spacing: CGFloat = 0, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill) -> UIStackView {
    let stackView = UIStackView(arrangedSubviews: views)
    stackView.axis = axis
    stackView.spacing = spacing
    stackView.alignment = alignment
    stackView.distribution = distribution
    addSubview(stackView)
    stackView.fillSuperview()
    return stackView
  }
  
  @discardableResult
  func vStack(_ views: UIView..., spacing: CGFloat = 0, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill) -> UIStackView {
    return _stack(.vertical, views: views, spacing: spacing, alignment: alignment, distribution: distribution)
  }
  
  @discardableResult
  func hStack(_ views: UIView..., spacing: CGFloat = 0, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill) -> UIStackView {
    return _stack(.horizontal, views: views, spacing: spacing, alignment: alignment, distribution: distribution)
  }
  
  func setupShadow(opacity: Float = 0, radius: CGFloat = 0, offset: CGSize = .zero, color: UIColor = .black) {
    layer.shadowOpacity = opacity
    layer.shadowRadius = radius
    layer.shadowOffset = offset
    layer.shadowColor = color.cgColor
  }
}

struct AnchoredConstraints {
  var top, leading, bottom, trailing, width, height: NSLayoutConstraint?
}

