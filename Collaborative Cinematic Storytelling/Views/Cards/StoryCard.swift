//
//  StoryCard.swift
//  Collaborative Cinematic Storytelling
//
//  Created by Hasan Tahir on 04/05/2022.
//

import Foundation
import UIKit
import SwiftUI

class StoryCard: UIView {
    
    var image : UIImage
    var imgView = UIImageView()
    var textView = UITextView()
    var button = UIButton()
    let container = UIView()
    let textLbl = UILabel()
    
    let superViewZoomFrame = CGRect(x: 0, y: 0, width: 750, height: 500)
    let superViewNormalFrame = CGRect(x: 0, y: 0, width: 175, height: 175)
    
    let subviewZoomFrame = CGRect(x: 0, y: 0, width: 700, height: 500)
    let subviewNormalFrame = CGRect(x: 0, y: 0, width: 175, height: 125)
    
    private var showingBack = false
    private var isZoomedIn = false
    
    var cornerRadius : CGFloat = 12 {
        didSet{
            container.layer.cornerRadius = cornerRadius
            imgView.layer.cornerRadius = cornerRadius
            textView.layer.cornerRadius = cornerRadius
        }
    }
    
    
    init(model : StoryModel, frame: CGRect) {
        self.image = model.image
        super.init(frame: frame)
        configureView(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(frame : CGRect){
        
        self.backgroundColor = .clear
        
        textLbl.numberOfLines = 0
        textLbl.frame = CGRect(x: 0, y: 130, width: frame.width, height: 0)
        
        imgView.image = image
        imgView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        imgView.layer.masksToBounds = true
        
        textView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        //textView.text = "This is textview"
        textView.isScrollEnabled = false
        textView.isSelectable = false
        //textView.isUserInteractionEnabled = false
        textView.isHidden = true
        textView.isEditable = true
        textView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        button.isHidden = true
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(editText), for: .touchDown)
        
        container.layer.masksToBounds = true
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.black.cgColor
        container.frame = subviewNormalFrame
        
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        singleTap.numberOfTapsRequired = 1
        
        self.addSubview(button)
        self.addSubview(container)
        self.addSubview(textLbl)
        container.addSubview(textView)
        container.addSubview(imgView)
        self.addGestureRecognizer(singleTap)
        self.addGestureRecognizer(panGesture)
        self.addGestureRecognizer(pinchGesture)
        
       
        self.cornerRadius = 12
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer){
        
        let translation: CGPoint = sender.translation(in: self.superview)
        self.superview?.bringSubviewToFront(self)
        //if sender.state == .changed{
        let x = self.center.x + translation.x
        let y = self.center.y + translation.y
        if x >= frame.width/2 && y >= frame.height/2{
            self.center = CGPoint(x: x, y:y )
            sender.setTranslation(CGPoint.zero, in: self.superview)
            print("translated Point",self.center.x + translation.x  , self.center.y + translation.y)
        }
    }
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer){
        let scale = sender.scale
        print("scale",scale)
        let width = frame.width * scale
        let height = frame.height * scale
        
        if width <= 700 && width >= 88 && height <= 500 && height >= 63 {
            UIView.animate(withDuration: 1) { [self] in
                self.cornerRadius =  scale * 12
                self.frame = CGRect(x: frame.minX, y: frame.minY, width: width, height: height)
                imgView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            }
            self.textView.font = UIFont.systemFont(ofSize: 17 * scale)
            
        }
        
    }
    
    @objc func handleTap(sender : UITapGestureRecognizer){
        
        if !isZoomedIn{
            button.setTitle("Edit", for: .normal)
            self.cornerRadius =  48
            self.textView.font = UIFont.systemFont(ofSize: 60)
            zoomIn()
            isZoomedIn = true
        }
        else{
            self.cornerRadius =  12
            self.textView.font = UIFont.systemFont(ofSize: 17)
            zoomOut()
            isZoomedIn = false
        }
        
        
    }
    
    @objc func editText(){
        if button.titleLabel?.text == "Edit"{
            //textView.becomeFirstResponder()
            textView.isEditable = true
            button.setTitle("Done", for: .normal)
        }
        else if button.titleLabel?.text == "Done"{
            textView.resignFirstResponder()
            textView.isEditable = false
            textLbl.text = textView.text
            textLbl.sizeToFit()
            textLbl.frame = CGRect(x: 0, y: 130, width: frame.width, height: textLbl.frame.height > 50 ? 50 : textLbl.frame.height )
            button.setTitle("Edit", for: .normal)
        }
        
        
        UIView.transition(with: self, duration: 1, options: [.transitionFlipFromRight , .showHideTransitionViews]) {
            if self.imgView.alpha == 0{
                self.textView.isHidden = true
                self.imgView.alpha = 1
                self.textView.alpha = 0
                
            }
            else{
                self.textView.isHidden = false
                self.imgView.alpha = 0
                self.textView.alpha = 1
                
            }
        } completion: { status in
            if !self.textView.isHidden{
                UIView.animate(withDuration: 1) { [self] in
                    self.frame = CGRect(x: frame.minX, y: frame.minY, width: 745 , height: 500)
                    imgView.frame = CGRect(x: 0, y: 0, width: 700, height: 500)
                    textView.frame = CGRect(x: 0, y: 0, width: 700, height: 500)
                    container.frame = CGRect(x: 0, y: 0, width: 700, height: 500)
                    button.frame = CGRect(x: 705, y: 8, width: 45, height: 30)
                    button.isHidden =  false
                }
            }
        }
    }
    
    func zoomIn(){
        UIView.animate(withDuration: 1) { [self] in
            self.frame = CGRect(x: frame.minX, y: frame.minY, width: 750, height: 500)
            self.cornerRadius = 48
            imgView.frame = subviewZoomFrame
            textView.frame = subviewZoomFrame
            container.frame = subviewZoomFrame
            button.frame = CGRect(x: 705, y: 8, width: 45, height: 30)
            button.isHidden =  false
            
            
        } completion: {[self]  status in
            textLbl.isHidden = true
        }
        
    }
    
    func zoomOut(){
        UIView.animate(withDuration: 1) { [self] in
            self.frame = CGRect(x: frame.minX, y: frame.minY, width: 175, height: 175)
            imgView.frame = subviewNormalFrame
            textView.frame = subviewNormalFrame
            container.frame = subviewNormalFrame
            //button.frame = CGRect(x: 705, y: 8, width: 45, height: 30)
            self.cornerRadius = 12
            button.isHidden =  true
            textLbl.isHidden = false
        } completion: {[self]  status in
            textLbl.isHidden = false
        }
    }
    
}
