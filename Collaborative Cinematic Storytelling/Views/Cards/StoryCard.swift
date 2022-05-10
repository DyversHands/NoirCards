//
//  StoryCard.swift
//  Collaborative Cinematic Storytelling
//
//  Created by Hasan Tahir on 04/05/2022.
//

import Foundation
import UIKit
import SwiftUI
import CDMarkdownKit

class StoryCard: UIView {
    var model : StoryModel! = nil{
        didSet{
            updateModel()
        }
    }
    
    var vStack = UIStackView()
    var hStack = UIStackView()
    var imgView = UIImageView()
    var textView = UITextView()
    var button = UIButton()
    let container = UIView()
    let textLbl = UILabel()
    
    private var showingBack = false
    
    private var zoomedHeight : CGFloat{
        get{
            return cardHeight * 5 + 50
        }
    }
    
    private var zoomedWidth : CGFloat{
        get{
            return cardWidth * 5 + 50
        }
    }
    
    
    private var normaHeight : CGFloat{
        get{
            return cardHeight + 50
        }
    }
    
    private var normalWidth : CGFloat{
        get{
            return cardWidth + 50
        }
    }
    
    
    var viewUpdated : ((StoryModel) -> Void)? = nil
    
    var cornerRadius : CGFloat = 12 {
        didSet{
            container.layer.cornerRadius = cornerRadius
            imgView.layer.cornerRadius = cornerRadius
            textView.layer.cornerRadius = cornerRadius
        }
    }
    
    
    init(model : StoryModel, frame: CGRect) {
        self.model = model
        super.init(frame: frame)
        configureView(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        //self.layer.masksToBounds = true
        
    }
    override func didMoveToSuperview() {
        if self.superview == nil{
            return
        }
        //self.anchor(top: self.superview!.topAnchor, left: self.superview!.leftAnchor,  paddingTop: model.frame.minY, paddingLeft: model.frame.minX, width: model.frame.width, height: model.frame.height)
        container.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor , right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 50 , paddingRight: 50)
        imgView.addConstraintsToFillView(container)
        textView.addConstraintsToFillView(container)
        textLbl.anchor(top: container.bottomAnchor, left: container.leftAnchor, bottom: bottomAnchor, right: container.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, height: 34)
        button.anchor(top: container.topAnchor, left: container.rightAnchor,  paddingTop: 8, paddingLeft: 8)
    }
    
    
    func configureView(frame : CGRect){
        
        self.backgroundColor = .clear
        
        textLbl.numberOfLines = 0
        textLbl.attributedText = CDMarkdownParser().parse(model.text)
        
        imgView.image = model.image
        imgView.layer.masksToBounds = true
        
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.alpha = 0
        textView.isEditable = true
        textView.contentInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        textView.font = UIFont.systemFont(ofSize: 60)
        
        button.alpha = model.frame.width < 750 ? 0 : 1
        button.tintColor = .black
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(editText), for: .touchDown)
        
        container.layer.masksToBounds = true
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.black.cgColor
        
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
        //self.addGestureRecognizer(pinchGesture)
        
        self.cornerRadius = model.frame.height ==  zoomedHeight ? 48 : 12
        if  model.frame.height ==  zoomedHeight {
            self.superview?.bringSubviewToFront(self)
        }
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
            
            if sender.state == .ended{
                self.model.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
            }
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
                
            }
            self.textView.font = UIFont.systemFont(ofSize: 17 * scale)
            
        }
        
    }
    
    @objc func handleTap(sender : UITapGestureRecognizer){
        
        if self.frame.height == normaHeight{
            button.setTitle("Edit", for: .normal)
            self.cornerRadius =  48
            zoomIn()
        }
        else{
            self.cornerRadius =  12
            zoomOut()
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
            textLbl.sizeToFit()
            button.setTitle("Edit", for: .normal)
            self.model.text = self.textView.text
        }
        
        
        UIView.transition(with: self, duration: 1, options: [.transitionFlipFromRight , .showHideTransitionViews]) {
            if self.imgView.alpha == 0{
                self.imgView.alpha = 1
                self.textView.alpha = 0
                
            }
            else{
                self.textView.alpha = 1
                self.imgView.alpha = 0
                
            }
        } completion: { status in
            
        }
    }
    
    func zoomIn(){

        self.superview?.bringSubviewToFront(self)
        textLbl.alpha = 0
        button.alpha = 1
        
        let newX = frame.minX - (zoomedWidth - normalWidth)/2 < 0 ? 0 : frame.minX - (zoomedWidth - normalWidth)/2
        
        let newY = frame.minX - (zoomedHeight - normaHeight)/2 < 0 ? 0 : frame.minY - (zoomedHeight - normaHeight)/2
        
        UIView.animate(withDuration: 1) { [self] in
            self.frame = CGRect(x: newX, y: newY, width: zoomedWidth, height: zoomedHeight)
            self.updateHeightWidht(newHeight: zoomedHeight, newWidth: zoomedWidth)
        } completion: {[self]  status in
            self.cornerRadius = 48
            //model.frame = self.frame
        }
        
    }
    
    func zoomOut(){
        
        button.alpha =  0
        UIView.animate(withDuration: 1) { [self] in
            self.frame = CGRect(x: frame.minX + (zoomedWidth - normalWidth)/2, y: frame.minY + (zoomedHeight -  normaHeight)/2, width: normalWidth, height: normaHeight)
            self.updateHeightWidht(newHeight: normaHeight, newWidth: normalWidth)
            
        } completion: {[self]  status in
            textLbl.alpha = 1
            self.cornerRadius = 12
            //model.frame = self.frame
        }
    }
    
    
    func updateModel(){
        viewUpdated?(self.model)
    }
}
