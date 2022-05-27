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
    var storyViewModel: StoryViewModel
    
    var vStack = UIStackView()
    var hStack = UIStackView()
    var imgView = UIImageView()
    var thumbnailImgView = UIImageView()
    var textView = UITextView()
//    var button = UIButton()
    let container = UIView()
    let textLbl = UILabel()
    let highlightView = UIView()
    
    private var showingBack = false
    
    private var zoomedHeight : CGFloat{
        get{
            return cardHeight * 5 //+ 50
        }
    }
    
    private var zoomedWidth : CGFloat{
        get{
            return cardWidth * 5 //+ 50
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
            highlightView.layer.cornerRadius = cornerRadius
        }
    }
    
    
    init(model : StoryModel, storyViewModel: StoryViewModel, frame: CGRect) {
        self.model = model
        self.storyViewModel = storyViewModel
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
        textView.anchor(top: container.topAnchor, left: container.leftAnchor, bottom: thumbnailImgView.topAnchor, right: container.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingBottom: 0, paddingRight: 30)
//        textView.anchor(top: container.topAnchor, left: container.leftAnchor, paddingTop: 20, paddingLeft: 20)
        textLbl.anchor(top: container.bottomAnchor, left: container.leftAnchor, bottom: bottomAnchor, right: container.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, height: 34)
//        button.anchor(top: container.topAnchor, left: container.rightAnchor,  paddingTop: 8, paddingLeft: 8)
        thumbnailImgView.anchor(bottom: container.bottomAnchor, right: container.rightAnchor, paddingBottom: 30, paddingRight: 30, width: cardWidth, height: cardHeight)
        highlightView.addConstraintsToFillView(container)
        thumbnailImgView.isHidden = true
        initialX = self.frame.minX
        initialY = self.frame.minY
        
        if model.isZoomed {
            zoomIn(withAnimation: false)
        }
    }
    
    
    func configureView(frame : CGRect){
        
        self.backgroundColor = .clear
        
        textLbl.numberOfLines = model.isZoomed ? 2 : 1
        textLbl.attributedText = CDMarkdownParser().parse(model.text)
        textLbl.font = UIFont.systemFont(ofSize: model.isZoomed ? 24 : 16)
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
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.font = UIFont.systemFont(ofSize: 60)
        textView.text = model.text
        
//        button.alpha = model.frame.width < 750 ? 0 : 1
//        button.tintColor = .black
//        button.setTitle("Edit", for: .normal)
//        button.setTitleColor(.black, for: .normal)
//        button.addTarget(self, action: #selector(editText), for: .touchDown)
        
        container.layer.masksToBounds = true
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.black.cgColor
        container.backgroundColor = .white
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeMade))
        rightSwipe.direction = .right
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeMade))
        leftSwipe.direction = .left
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapToZoom))
        doubleTap.numberOfTapsRequired = 2
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapToHighlight))
        singleTap.numberOfTapsRequired = 1
        // single tap will only fail on double tap otherwise double tap was not working with single tap
        singleTap.require(toFail: doubleTap)
        singleTap.delaysTouchesBegan = true
//        self.addSubview(button)
        self.addSubview(container)
        self.addSubview(textLbl)
        container.addSubview(textView)
        container.addSubview(imgView)
        container.addSubview(thumbnailImgView)
        container.addSubview(highlightView)
        self.addGestureRecognizer(rightSwipe)
        self.addGestureRecognizer(leftSwipe)
        self.addGestureRecognizer(singleTap)
        self.addGestureRecognizer(doubleTap)
        self.addGestureRecognizer(panGesture)
        self.addGestureRecognizer(pinchGesture)
        
        self.cornerRadius = model.frame.height ==  zoomedHeight ? 48 : 12
        if model.isZoomed { //model.frame.height ==  zoomedHeight {
            self.removeGestureRecognizer(panGesture)
            self.superview?.bringSubviewToFront(self)
        }
        
        // Context Menu
        
        let interaction = UIContextMenuInteraction(delegate: container)
        container.addInteraction(interaction)
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer){
        if !isCardZoomed {
            let translation: CGPoint = sender.translation(in: self.superview)
            self.superview?.bringSubviewToFront(self)
            //if sender.state == .changed{
            let x = self.center.x + translation.x
            let y = self.center.y + translation.y
            if x >= frame.width/2 && y >= frame.height/2{
                self.center = CGPoint(x: x, y:y )
                sender.setTranslation(CGPoint.zero, in: self.superview)
                print("translated Point",frame.minX  , frame.minY)
                
                if sender.state == .ended {
                    // grid calculation
                    alignToGrid()
                    //self.model.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
                    self.bringSubviewToFront(self)
                }
            }
        }
    }
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
        
        if model.isZoomed || isCardZoomed == false {
            if sender.state == .changed {
                self.superview?.bringSubviewToFront(self)
                let scale = sender.scale
                let width = (model.isZoomed ? zoomedWidth : normalWidth) * scale
                let height = (model.isZoomed ? zoomedHeight : normaHeight) * scale
                self.frame = CGRect(x: frame.minX, y: frame.minY, width: width, height: height)
            }
            else if sender.state == .ended {
                // set size to zoomed and centered
                if frame.width > (zoomedWidth - 200) || frame.height > ( zoomedHeight - 200) {
                    zoomIn(withAnimation: true)
                }
                else {
                    print("Zoom Out")
                    zoomOut()
                }
            }
        }
    }
    
    @objc func doubleTapToZoom(sender : UITapGestureRecognizer){
        
        if self.frame.height == normaHeight{
//            button.setTitle("Edit", for: .normal)
            zoomIn(withAnimation: true)
        }
        else{
            zoomOut()
        }
        
        
    }
    
    @objc func singleTapToHighlight(sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.2) {
            self.highlightView.backgroundColor = .white
        } completion: { completed in
            self.highlightView.backgroundColor = .clear
        }
    }
    
    @objc func swipeMade(gesture: UISwipeGestureRecognizer) {
        // to prevent swiping only when card is zoomed
        if model.isZoomed {
            // show back and open text view
            if gesture.direction == .left && !(self.showingBack) {
                print("BACK MODE")
                self.highlightView.isHidden = true
                self.textView.isEditable = true
                self.thumbnailImgView.isHidden = false // bottom left thumbnail view below text view
                self.showingBack = true // to prevent continous swiping in same direction
                
                UIView.transition(with: self, duration: 1, options: [.transitionFlipFromRight, .showHideTransitionViews]) {
                    self.textView.alpha = 1
                    self.imgView.alpha = 0
                } completion: { status in
                    if self.initialText != self.textView.text {
                        self.model.isZoomed = true
                        self.model.text = self.textView.text
                    }
                }
                
            }
            // show front and open image view, hide text view and thumbnail
            else if gesture.direction == .right && self.showingBack {
                print("FRONT MODE")
                self.highlightView.isHidden = false
                self.textView.isEditable = false
                self.textView.resignFirstResponder()
                self.thumbnailImgView.isHidden = true
                self.showingBack = false
                self.textLbl.sizeToFit()
                
                UIView.transition(with: self, duration: 1, options: [.transitionFlipFromLeft, .showHideTransitionViews]) {
                    self.textView.alpha = 0
                    self.imgView.alpha = 1
                } completion: { status in
                    if self.initialText != self.textView.text {
                        self.model.isZoomed = true
                        self.model.text = self.textView.text
                    }
                }
            }
        }
    }
    
    func zoomIn(withAnimation isAnimated: Bool) {
        
//        textLbl.alpha = 0
//        button.alpha = 1
        
        let newX = (self.superview!.frame.width / 2) - (zoomedWidth / 2) + 25
        var newY = (self.superview!.frame.height / 2) - (zoomedHeight / 2) - 25
        newY = newY < 0 ? 0 : newY
        if isAnimated && isCardZoomed == false {
            thumbnailImgView.alpha = 1
            self.superview?.bringSubviewToFront(self)

            UIView.animate(withDuration: 1) { [self] in
                self.frame = CGRect(x: newX, y: newY, width: zoomedWidth, height: zoomedHeight)
                self.updateHeightWidht(newHeight: zoomedHeight, newWidth: zoomedWidth)
                self.cornerRadius = 48
                self.textLbl.font = UIFont.systemFont(ofSize: 24)
            } completion: { status in
                self.cornerRadius = 48
                self.model.isZoomed = true
            }
        }
        else if model.isZoomed {
            thumbnailImgView.alpha = 1
            self.superview?.bringSubviewToFront(self)
            self.frame = CGRect(x: newX, y: newY, width: zoomedWidth, height: zoomedHeight)
            self.updateHeightWidht(newHeight: zoomedHeight, newWidth: zoomedWidth)
            self.cornerRadius = 48
        }
        
    }
    
    func zoomOut(){
        // not zoom out when in editing mode ( back of the card )
        if showingBack {
            return
        }
        
//        if button.titleLabel?.text == "Done" {
//            return
//        }
        
//        button.alpha =  0
        thumbnailImgView.alpha = 0
        UIView.animate(withDuration: 1) { [self] in
            self.frame = CGRect(x: initialX, y: initialY, width: normalWidth, height: normaHeight)
            self.updateHeightWidht(newHeight: normaHeight, newWidth: normalWidth)
            self.cornerRadius = 12
            
        } completion: {[self]  status in
//            textLbl.alpha = 1
            self.cornerRadius = 12
            self.model.isZoomed = false
        }
    }
    
    func alignToGrid() {
        let newX = floor(self.frame.midX / normalWidth) * normalWidth
        let newY = floor(self.frame.midY / normaHeight) * normaHeight
        UIView.animate(withDuration: 0.5) {
            self.frame = CGRect(x: newX, y: newY, width: self.normalWidth, height: self.normaHeight)
        } completion: { status in
            self.model.frame = CGRect(x: newX, y: newY, width: self.normalWidth, height: self.normaHeight)
        }
        
        
    }
    
    func animateToCardTray() {
        if storyViewModel.stackImages.count < 7 {
            var newX = 15.0
            for _ in storyViewModel.stackImages {
                newX += (cardWidth * 1.11)
            }
            UIView.animate(withDuration: 1) { [self] in
                self.frame = CGRect(x: newX, y: -(cardHeight * 1.51), width: normalWidth, height: normaHeight)
            } completion: { completed in
                self.cardReturned?(self.model.id, self.model.imageName)
            }

        }
    }
    
    
    func updateModel(){
        viewUpdated?(self.model)
    }
}

extension UIView: UIContextMenuInteractionDelegate {
    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            let inspectAction = UIAction(title: NSLocalizedString("Align to Grid", comment: ""), image: UIImage(systemName: "arrow.up.square")) { action in
                if let storyView = self.superview as? StoryCard {
                    storyView.alignToGrid()
                }
            }
            
            let duplicateAction =
            UIAction(title: NSLocalizedString("Return to Card Tray", comment: ""), image: UIImage(systemName: "plus.square.on.square")) { action in
                if let storyView = self.superview as? StoryCard {
                    storyView.animateToCardTray()
                }

            }
            
            let deleteAction = UIAction(title: NSLocalizedString("Remove from Play", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                if let storyView = self.superview as? StoryCard {
                    storyView.cardRemoved?(storyView.model.id)
                }
            }
            
            return UIMenu(title: "", children: [inspectAction, duplicateAction, deleteAction])
        })
    }
}
