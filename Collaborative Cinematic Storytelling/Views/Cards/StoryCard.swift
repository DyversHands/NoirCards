//
//  StoryCard.swift
//  Collaborative Cinematic Storytelling
//
//  Created by Hasan Tahir on 04/05/2022.
//

import Foundation
import UIKit
import SwiftUI
import MarkdownKit

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
        let paddingBottom: CGFloat = self.model.text == "" ? 0 : 50

        container.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor , right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: paddingBottom , paddingRight: 0)
        imgView.addConstraintsToFillView(container)
//        textView.addConstraintsToFillView(container)
        textView.anchor(top: container.topAnchor, left: container.leftAnchor, bottom: thumbnailImgView.topAnchor, right: container.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingBottom: 0, paddingRight: 30)
//        textView.anchor(top: container.topAnchor, left: container.leftAnchor, paddingTop: 20, paddingLeft: 20)
        textLbl.anchor(top: container.bottomAnchor, left: container.leftAnchor, bottom: bottomAnchor, right: container.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8)
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
        
        textLbl.numberOfLines = 1
        textLbl.font = UIFont.systemFont(ofSize: model.isZoomed ? 24 : 16)
        initialText = model.text
        textLbl.attributedText = MarkdownParser().parse(model.text)
        
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
                    self.model.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
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
        
        if self.frame.height == normaHeight || self.frame.height == cardHeight { // both text cards and empty cards can be zoomed
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
                        // updating height in model frame if text is added
                        let height = self.model.text == "" ? cardHeight : self.normaHeight
                        self.model.frame = CGRect(x: self.model.frame.minX, y: self.model.frame.minY, width: cardWidth, height: height)
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
        let height = self.model.text == "" ? cardHeight : normaHeight
        UIView.animate(withDuration: 1) { [self] in
            self.frame = CGRect(x: initialX, y: initialY, width: cardWidth, height: height)
            self.updateHeightWidht(newHeight: height, newWidth: cardWidth)
            self.cornerRadius = 12
            self.textLbl.font = UIFont.systemFont(ofSize: 16)
            
        } completion: {[self]  status in
//            textLbl.alpha = 1
            self.cornerRadius = 12
            self.model.isZoomed = false
        }
    }
        
    private func calculateFrameAlignment() {
        
        let centerX = (self.superview!.frame.width / 2) - (normalWidth / 2) + 25
        let centerY = (self.superview!.frame.height / 2) - (normaHeight / 2) + 25
        let cardFrames = storyViewModel.droppedImages.map({$0.frame.origin}) // all origins of cards
        
        var newX = centerX
        var newY = centerY
        
        findY()
        findX()
        animateFrame()
        
        /// if view is vertically center, For Y Axis Parallel to center y
        /*
        if frame.minY >= centerY - 25 && frame.minY <= centerY + 25 {
            while cardFrames.contains(where: { $0.y == centerY && $0.x == newX }) {
                findXToAlign()
                if newX == 0 || newX == (self.superview!.frame.maxX - normalWidth) {
                    break
                }
            }
            animateFrame()
            
        }
         */
        func findY() {
            // Animate Above Center Card
            if frame.minY < centerY {
                let topY = centerY - cardHeight + 10
                let isAtTop = frame.minY < 50
                newY = isAtTop ? 10 : topY
            }
            // Animate Below Center Card
            else if frame.minY > centerY {
                let bottomY = centerY + cardHeight - 10
                let isBottom = frame.minY > centerY + (cardHeight * 2)
                newY = isBottom ? centerY + (cardHeight * 2) + 20 : bottomY
            }
            roundValues()
        }
        
        func findX() {
            let leftX = centerX - cardWidth + 20
            let rightX = centerX + cardWidth - 20
            
            // move x to right or left
            let isLeftToCenter = frame.minX < centerX
            newX = isLeftToCenter ? leftX : rightX
            
            roundValues() // round values to zero to avoid false condition like 21.1 == 21.15 etc
            
            if cardFrames.contains(where: { $0.y.toRound() == newY.toRound() && $0.x.toRound() == newX.toRound()}) {
                while cardFrames.contains(where: { $0.y.toRound() == newY.toRound() && $0.x.toRound() == newX.toRound()}) {
                    newX = frame.minX < centerX ? (newX - normalWidth) : (newX + normalWidth)
                    if newX <= 0 || newX >= (self.superview!.frame.maxX - normalWidth) {
                        break
                        
                    }
                }
            }
        }
        
        func animateFrame() {
            roundValues()
            let height = self.model.text == "" ? cardHeight : normaHeight
            UIView.animate(withDuration: 0.5) {
                self.frame = CGRect(x: newX, y: newY, width: cardWidth, height: height)
            } completion: { completed in
                if completed {
                    self.frame = CGRect(x: newX, y: newY, width: cardWidth, height: height)
                    self.model.frame = self.frame
                    bringCenterCardToFront()
                }
            }
        }
        
        func roundValues() {
            newY = newY.toRound()
            newX = newX.toRound()
        }
        
        func bringCenterCardToFront() {
            if let card = self.superview?.subviews.first(where: {($0.frame.minX == centerX && $0.frame.minY == centerY)}) as? StoryCard {
                viewUpdated?(card.model)
            }
        }
    }
        
    func alignToGridPressed() {
//        let newX = floor(self.frame.midX / normalWidth) * normalWidth
//        let newY = floor(self.frame.midY / normaHeight) * normaHeight
        let centerX = (self.superview!.frame.width / 2) - (normalWidth / 2) + 25
        let centerY = (self.superview!.frame.height / 2) - (normaHeight / 2) + 25
        
        var containsCenterCard = false
        // Checking if Center Card is aligned or not
        for image in storyViewModel.droppedImages {
            if image.frame.minX == centerX && image.frame.minY == centerY {
                containsCenterCard = true
                break
            }
        }
        if containsCenterCard {
            calculateFrameAlignment()
        }
        else {
            let height = self.model.text == "" ? cardHeight : normaHeight
            UIView.animate(withDuration: 0.5) {
                self.frame = CGRect(x: centerX, y: centerY, width: cardWidth, height: height)
            } completion: { status in
                self.model.frame = self.frame
            }
        }
    }
    
    func animateToCardTray() {
        if storyViewModel.stackImages.count < 7 {
            self.bringSubviewToFront(self)
            var newX = 15.0
            for _ in storyViewModel.stackImages {
                newX += (cardWidth + 16)//* 1.11)
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
                    storyView.alignToGridPressed()
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
/*
// if view is vertically center, we have to find x Axis respectively right or left
if frame.minY >= centerY - 25 && frame.minY <= centerY + 25 {
//        if (centerY ... centerY + 25).contains(frame.minY) || (centerY - 25 ... centerY).contains(frame.minY) {
    if frame.minX < centerX { // Align to left of center card
        let newX = centerX - normalWidth
        self.frame = CGRect(x: newX, y: centerY, width: normalWidth, height: normaHeight)
    }
    else { // Align to right of center card
        let newX = centerX + normalWidth
        self.frame = CGRect(x: newX, y: centerY, width: normalWidth, height: normaHeight)
    }
}
// if view is above center view, finding X Respectively
else if frame.minY < centerY - 25 { // bring view to above i.e center y - height
    
    if frame.minX < centerX { // Align to left of center card
        let newX = centerX - normalWidth
        self.frame = CGRect(x: newX, y: centerY - normaHeight, width: normalWidth, height: normaHeight)
    }
    else { // Align to right of center card
        let newX = centerX + normalWidth
        self.frame = CGRect(x: newX, y: centerY - normaHeight, width: normalWidth, height: normaHeight)
    }

}
// if view is below center view, finding X Respectively
else if frame.minY > centerY + 25 {
    if frame.minX < centerX { // Align to left of center card
        let newX = centerX - normalWidth
        self.frame = CGRect(x: newX, y: centerY + normaHeight, width: normalWidth, height: normaHeight)
    }
    else { // Align to right of center card
        let newX = centerX + normalWidth
        self.frame = CGRect(x: newX, y: centerY + normaHeight, width: normalWidth, height: normaHeight)
    }

}
 */
