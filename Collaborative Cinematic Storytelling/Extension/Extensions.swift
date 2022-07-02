import UIKit

// MARK: - UIView

extension UIView {
  func anchor(top: NSLayoutYAxisAnchor? = nil,
              left: NSLayoutXAxisAnchor? = nil,
              bottom: NSLayoutYAxisAnchor? = nil,
              right: NSLayoutXAxisAnchor? = nil,
              paddingTop: CGFloat = 0,
              paddingLeft: CGFloat = 0,
              paddingBottom: CGFloat = 0,
              paddingRight: CGFloat = 0,
              width: CGFloat? = nil,
              height: CGFloat? = nil) {
    
    // Activate programmatic auto layout
    translatesAutoresizingMaskIntoConstraints = false
    
    if let top = top {
      topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
    }
    
    if let left = left {
      leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
    }
    
    if let bottom = bottom {
      bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
    }
    
    if let right = right {
      rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
    }
    
    if let width = width {
      widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
      if let height = height {
      heightAnchor.constraint(equalToConstant: height).isActive = true
    }
  }
    
    func updateHeightWidht(newHeight : CGFloat , newWidth : CGFloat){
        
        if let constraint = self.constraints.first(where: {$0.firstAttribute == .height}){
            if constraint.constant < newHeight{
//                if let topConstraint = self.constraints.first(where: {$0.firstAttribute == .top}){
//                    topConstraint.constant -= newHeight/2
//                }
            }
            
            else{
//                if let constraint = self.constraints.first(where: {$0.firstAttribute == .top}){
//                    constraint.constant = newHeight/2
//                }
            }
            
            constraint.constant = newHeight
        }
        
        if let constraint = self.constraints.first(where: {$0.firstAttribute == .width}){
            constraint.constant = newWidth
            
//            if let leftconstraint = self.constraints.first(where: {$0.firstAttribute == .left}){
//                constraint.constant -= newWidth/2
//            }
        }
        self.layoutIfNeeded()
    }
  
  func center(inView view: UIView, yConstant: CGFloat? = 0) {
    translatesAutoresizingMaskIntoConstraints = false
    centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant!).isActive = true
  }
  
  func centerX(inView view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat? = 0) {
    translatesAutoresizingMaskIntoConstraints = false
    centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    if let topAnchor = topAnchor {
      self.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop!).isActive = true
    }
  }
  
  func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat? = nil, constant: CGFloat? = 0) {
    translatesAutoresizingMaskIntoConstraints = false
    
    centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant!).isActive = true
    
    if let leftAnchor = leftAnchor, let padding = paddingLeft {
      self.leftAnchor.constraint(equalTo: leftAnchor, constant: padding).isActive = true
    }
  }
  
  func setDimensions(width: CGFloat, height: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    widthAnchor.constraint(equalToConstant: width).isActive = true
    heightAnchor.constraint(equalToConstant: height).isActive = true
  }
  
  func addConstraintsToFillView(_ view: UIView) {
    translatesAutoresizingMaskIntoConstraints = false
    anchor(top: view.topAnchor, left: view.leftAnchor,
           bottom: view.bottomAnchor, right: view.rightAnchor)
  }
  
  // MARK: - Visual
  
  func addGradientBackground(topColor: UIColor, bottomColor: UIColor) {
    let bgView = UIView(frame: self.bounds)
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = self.frame
    gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.50)
    
    bgView.layer.insertSublayer(gradientLayer, at: 0)
    self.addSubview(bgView)
  }
  
}
extension CGFloat {
    
    func toRound() -> CGFloat {
        return CGFloat(Int(self))
    }
}
