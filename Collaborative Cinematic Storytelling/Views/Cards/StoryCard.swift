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
    var thumbnailImgView = UIImageView()
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
    
    var didChangedInitialY = false
    var didChangedInitialX = false
    var initialX: CGFloat = 0
    var initialY: CGFloat = 0
    var initialText = ""
    
    var viewUpdated  : ((_ model: StoryModel) -> Void)? = nil
    var cardRemoved  : ((_ id: String) -> Void)? = nil
    var cardReturned : ((_ id: String, _ imgName: String) -> Void)? = nil

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
//        textView.addConstraintsToFillView(container)
        textView.anchor(top: thumbnailImgView.bottomAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, right: container.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
//        textView.anchor(top: container.topAnchor, left: container.leftAnchor, paddingTop: 20, paddingLeft: 20)
        textLbl.anchor(top: container.bottomAnchor, left: container.leftAnchor, bottom: bottomAnchor, right: container.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, height: 34)
        button.anchor(top: container.topAnchor, left: container.rightAnchor,  paddingTop: 8, paddingLeft: 8)
        thumbnailImgView.anchor(top: container.topAnchor, left: container.leftAnchor, paddingTop: 30, paddingLeft: 30, width: cardWidth, height: cardHeight)
        thumbnailImgView.isHidden = true
        initialX = self.frame.minX
        initialY = self.frame.minY
        
        if model.isZoomed {
            zoomIn(withAnimation: false)
        }
    }
    
    
    func configureView(frame : CGRect){
        
        self.backgroundColor = .clear
        
        textLbl.numberOfLines = 0
        textLbl.attributedText = CDMarkdownParser().parse(model.text)
        textLbl.font = UIFont.systemFont(ofSize: 16)
        initialText = model.text
        
        imgView.image = model.image
        imgView.layer.masksToBounds = true
        
        thumbnailImgView.image = model.image
        thumbnailImgView.layer.masksToBounds = true
        thumbnailImgView.alpha = model.frame.width < 750 ? 0 : 1
        thumbnailImgView.layer.cornerRadius = 8
        
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.alpha = 0
        textView.isEditable = true
        textView.contentInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        textView.font = UIFont.systemFont(ofSize: 60)
        textView.text = model.text
        
        button.alpha = model.frame.width < 750 ? 0 : 1
        button.tintColor = .black
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(editText), for: .touchDown)
        
        container.layer.masksToBounds = true
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.black.cgColor
        container.backgroundColor = .white
        
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        singleTap.numberOfTapsRequired = 2
        
        self.addSubview(button)
        self.addSubview(container)
        self.addSubview(textLbl)
        container.addSubview(textView)
        container.addSubview(imgView)
        container.addSubview(thumbnailImgView)
        self.addGestureRecognizer(singleTap)
        self.addGestureRecognizer(panGesture)
        //self.addGestureRecognizer(pinchGesture)
        
        self.cornerRadius = model.frame.height ==  zoomedHeight ? 48 : 12
        if  model.frame.height ==  zoomedHeight {
            self.superview?.bringSubviewToFront(self)
        }
        
        // Context Menu
        
        let interaction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(interaction)
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
            print("translated Point",frame.minX  , frame.minY)
            
            if sender.state == .ended{
                self.model.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
                self.bringSubviewToFront(self)
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
            zoomIn(withAnimation: true)
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
            thumbnailImgView.isHidden = false
        }
        else if button.titleLabel?.text == "Done"{
            textView.resignFirstResponder()
            textView.isEditable = false
            textLbl.sizeToFit()
            button.setTitle("Edit", for: .normal)
            thumbnailImgView.isHidden = true

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
            if self.initialText != self.textView.text {
                self.model.isZoomed = true
                self.model.text = self.textView.text
            }
        }
    }
    
    func zoomIn(withAnimation isAnimated: Bool) {

        self.superview?.bringSubviewToFront(self)
        textLbl.alpha = 0
        button.alpha = 1
        thumbnailImgView.alpha = 1
        /*
        var newX = frame.minX - (zoomedWidth - normalWidth)/2 < 0 ? 0 : frame.minX - (zoomedWidth - normalWidth)/2
        
        var newY = frame.minX - (zoomedHeight - normaHeight)/2 < 0 ? 0 : frame.minY - (zoomedHeight - normaHeight)/2
        
        if newY <= 0 { // when newY is goint offset from top
            newY = self.frame.minY
            
        }
        /*// to prevent offset from bottom
        else if newY + zoomedHeight > (self.superview!.frame.maxY) {
            newY = self.frame.minY - zoomedWidth/2
            didChangedInitialY = true
        }
         */

        else { // when card is at bottom or center no change in newY
            didChangedInitialY = true
        }

        
        // Checking For X Offsets
        if newX <= 0 { // when newX is goint off left from screen
            newX = self.frame.minX
        }
        // when card total width is going off right from screen
        else if newX + zoomedWidth > (self.superview!.frame.maxX) {
            let editBtnOffset = self.frame.maxX - self.superview!.frame.maxX
            newX = self.frame.minX - zoomedWidth + normalWidth - editBtnOffset
            didChangedInitialX = true
        }
        else { // when card is at center no change in newX
            didChangedInitialX = true
        }
        */
        let newX = (self.superview!.frame.width / 2) - (zoomedWidth / 2)
        var newY = (self.superview!.frame.height / 2) - (zoomedHeight / 2)
        newY = newY < 0 ? 0 : newY
        if isAnimated {
            UIView.animate(withDuration: 1) { [self] in
                self.frame = CGRect(x: newX, y: newY, width: zoomedWidth, height: zoomedHeight)
                self.updateHeightWidht(newHeight: zoomedHeight, newWidth: zoomedWidth)
            } completion: {[self]  status in
                self.cornerRadius = 48
                //model.frame = self.frame
            }
        }
        else {
            self.frame = CGRect(x: newX, y: newY, width: zoomedWidth, height: zoomedHeight)
            self.updateHeightWidht(newHeight: zoomedHeight, newWidth: zoomedWidth)
            self.cornerRadius = 48
        }
        
    }
    
    func zoomOut(){
        
//        let newY = initialY
//        let newX = initialX
        
//        if didChangedInitialY {
//            newY = initialY
//        }
//        if didChangedInitialX {
//            newX = initialX
//        }
        
        button.alpha =  0
        thumbnailImgView.alpha = 0
        UIView.animate(withDuration: 1) { [self] in
            self.frame = CGRect(x: initialX, y: initialY, width: normalWidth, height: normaHeight)
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

extension StoryCard: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            let inspectAction = UIAction(title: NSLocalizedString("Align to Grid", comment: ""), image: UIImage(systemName: "arrow.up.square")) { action in
//                self.performInspect()
            }
            
            let duplicateAction =
            UIAction(title: NSLocalizedString("Return to Card Tray", comment: ""), image: UIImage(systemName: "plus.square.on.square")) { action in
                self.cardReturned?(self.model.id, self.model.imageName)
            }
            
            let deleteAction = UIAction(title: NSLocalizedString("Remove from Play", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                self.cardRemoved?(self.model.id)
            }
            
            return UIMenu(title: "", children: [inspectAction, duplicateAction, deleteAction])
        })
    }
}
