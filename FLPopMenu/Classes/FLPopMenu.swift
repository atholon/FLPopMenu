//
//  File.swift
//  FLPopMenu
//
//  Created by Atholon on 2018/1/25.
//  Copyright © 2018年 Atholon. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 默认设置 ////////////////////////////////////////////////////

// 字体大小
let gTextFontSize:CGFloat = 12.0
// 文字对齐方式
let gAlignment:NSTextAlignment = .left
// 文字颜色
let gTextColor = UIColor.black
// 垂直边距
let gVMargin:CGFloat = 5.0
// 水平边距
let gLMargin:CGFloat = 8.0


enum FLMenuBackgrounColorEffect {
    case solid       //!<背景显示效果.纯色
    case Gradient    //!<背景显示效果.渐变叠加
}

//箭头方向枚举
enum FLMenuViewArrowDirection{
    case up
    case down
    case left
    case right
    case none
}


// MARK: - 最底层:Overlay类，覆盖全屏，提供点击取消菜单功能
class FLMenuOverlay:UIView{
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    @objc func singleTap(recognizer:UITapGestureRecognizer){
        for view in self.subviews{
            if view.isKind(of: FLMenuView.self) && view.responds(to: #selector(FLMenuView.dismissMenu)){
                view.perform(#selector(FLMenuView.dismissMenu), with: true)
            }
        }
    }
    
}



// MARK: - 中间层:MenuView类
class FLMenuView:UIView{
    // 背景view
    var overlayView:UIView?
    // 内容view
    var contentView:UIView?
    // 文本字体
    var textFont:UIFont = FLPopMenu.textFont
    // 箭头方向
    var arrowDirection:FLMenuViewArrowDirection = .down
    // 箭头位置
    var arrowPosition:CGFloat = 0.0
    
    // Menu按钮对象数组
    //var menuIrems:[FLMenuItem] = [FLMenuItem]()
    // 被选择按钮对象
    //var selectedItem
    
    // MARK: - 构造，析构函数//////////////////////////////////////////////////
    
    // 构造函数
    init(){
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = UIColor.clear
        self.isOpaque = true
        self.alpha = 0
        
        if FLPopMenu.hasShadow {
            self.layer.shadowOpacity = 0.5
            self.layer.shadowColor = FLPopMenu.shadowColor.cgColor
            self.layer.shadowOffset = CGSize(width: 2, height: 2)
            self.layer.shadowRadius = 2
        }
    }
    // 需求构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - 接口函数  //////////////////////////////////////////////////////
    
    // 添加 Items
    func addItems (items:[FLMenuItem]) {
        if items.isEmpty {
            print("MenuItems无内容！")
            contentView = nil
        }else{
            contentView = makeContentView(items:items)
            print(contentView?.frame)
        }
    }
    
    
    // 在目标 view 中显示菜单
    func showMenuInView(view:UIView,fromRect:CGRect,animated:Bool = true){
        setupFrameInView(view: view, fromRect: fromRect)
        print(contentView?.frame)
        let overlay = FLMenuOverlay(frame: view.frame)
        self.addSubview(contentView!)
        overlay.addSubview(self)
        view.addSubview(overlay)
        
        contentView?.isHidden = true
        
        let toFrame = self.frame
        self.frame = CGRect(origin: arrowPoint(), size: CGSize(width: 1.0, height: 1.0))
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
            self.frame = toFrame
        }, completion:{ _ in
            self.contentView?.isHidden = false
        })
    }
    
    
    
    // MARK: - 私有函数 ///////////////////////////////////////////////////////
    
    // 生成contentView
    func makeContentView(items:[FLMenuItem]) -> UIView {
        print("开始制作ContentView")
        // 计算最长文字的size，初始为（0，0）
        var textSize = CGSize.zero
        
        // 检查是否有包含图标的item
        var hasIcon = false
        for item in items {
            if item.image != nil {
                hasIcon = true
            }
            //找到最长的文字
            let itemTextSize = item.title.size(withAttributes: [NSAttributedStringKey.font:textFont])
            if textSize.width < itemTextSize.width {
                textSize = itemTextSize
            }
        }
        
        // 菜单项如果含有图片，对item宽度和高度以及文字Label位置的影响
        var vPlusForImg:CGFloat = 0.0                 //垂直增量
        var lPlusForImg:CGFloat = 0.0                 //水平增量
        var textLabX:CGFloat = FLPopMenu.lMargin      //文字Label的水平位置
        if hasIcon {
            // 图标比文字高2.0
            vPlusForImg = 2.0
            // 图标高宽相等，再加上与文字的间隔：5.0
            lPlusForImg = textSize.height + 2.0 + 5.0
            //
            textLabX = FLPopMenu.lMargin + lPlusForImg
        }
        // 计算item的高度和宽度
        let itemHeight = FLPopMenu.vMargin * 2 + textSize.height + vPlusForImg
        let itemWidth = FLPopMenu.lMargin * 2 + lPlusForImg + textSize.width
        // 计算contentRect
        let contentRect = CGRect(x: 0, y: 0, width: itemWidth, height: itemHeight * CGFloat(items.count))
        // 生成contentView
        let contentView = UIView(frame: contentRect)
        
        for i in 0 ..< items.count {
            var textRect:CGRect
            var img:UIImageView
            if items[i].image != nil { // 有图标
                let imgRect = CGRect(x: FLPopMenu.lMargin, y: CGFloat(i) * itemHeight + FLPopMenu.vMargin, width: textSize.height + 2.0, height: textSize.height + 2.0)
                img = UIImageView(frame: imgRect)
                img.adjustsImageSizeForAccessibilityContentSizeCategory = false
                img.image = items[i].image
                contentView.addSubview(img)
                // 定位文字Label
                let origin = CGPoint(x:textLabX,y:CGFloat(i) * itemHeight + FLPopMenu.vMargin + 2.0)
                let size = items[i].title.size(withAttributes: [NSAttributedStringKey.font:textFont])
                textRect = CGRect(origin: origin, size: size)
            }else{ // 无图标
                let origin = CGPoint(x:textLabX,y:CGFloat(i) * itemHeight + FLPopMenu.vMargin)
                let size = items[i].title.size(withAttributes: [NSAttributedStringKey.font:textFont])
                textRect = CGRect(origin: origin, size: size)
            }
            
            let textLabel = UILabel(frame: textRect)
            textLabel.text = items[i].title
            textLabel.textColor = FLPopMenu.textColor
            textLabel.font = FLPopMenu.textFont
            textLabel.textAlignment = FLPopMenu.alignment
            
            contentView.addSubview(textLabel)
            
            if i < items.count - 1 {
                let origin = CGPoint(x: FLPopMenu.lMargin, y: CGFloat(i + 1) * itemHeight - 0.5)
                let size = CGSize(width: itemWidth - FLPopMenu.lMargin * 2.0, height: 0.5)
                let seperator = UILabel(frame: CGRect(origin: origin, size: size))
                seperator.backgroundColor = FLPopMenu.separatorColor
                contentView.addSubview(seperator)
            }
            
            // 添加按钮
            let btnRect = CGRect(x: 0, y: CGFloat(i) * itemHeight, width: itemWidth, height: itemHeight)
            let btn = UIButton(frame: btnRect)
            btn.addTarget(items[i].target, action: items[i].action!, for: .touchUpInside)
            //btn.backgroundColor = UIColor.blue
            contentView.addSubview(btn)
        }
        print(contentView.frame)
        return contentView
    }
    
    // 设置view
    func setupFrameInView(view:UIView,fromRect:CGRect){
        if contentView == nil {
            return
        }
        let contentSize = contentView!.frame.size
        
        let outerWidth:CGFloat = view.bounds.size.width
        let outerHeight:CGFloat = view.bounds.size.height
        // 计算fromRect左上，右下，中心点在目标view中的坐标
        let rectX0:CGFloat = fromRect.origin.x
        let rectX1:CGFloat = fromRect.origin.x + fromRect.size.width
        let rectXM:CGFloat = fromRect.origin.x + fromRect.size.width * 0.5
        let rectY0:CGFloat = fromRect.origin.y
        let rectY1:CGFloat = fromRect.origin.y + fromRect.size.height
        let rectYM:CGFloat = fromRect.origin.y + fromRect.size.height * 0.5
        
        let widthPlusArrow:CGFloat = contentSize.width + FLPopMenu.arrowSize
        let heightPlusArrow:CGFloat = contentSize.height + FLPopMenu.arrowSize
        let widthHalf:CGFloat = contentSize.width * 0.5
        let heightHalf:CGFloat = contentSize.height * 0.5
        
        let kMargin:CGFloat = 5.0
        
        switch arrowDirection {
        case .up:
            var point = CGPoint(x: rectXM - widthHalf, y: rectY1 + 3)
            
            if point.x < kMargin {
                point.x = kMargin
            }
            
            if (point.x + contentSize.width + kMargin) > outerWidth {
                point.x = outerWidth - contentSize.width - kMargin
            }
            
            arrowPosition = rectXM - point.x
            contentView?.frame.origin.y = FLPopMenu.arrowSize
            
            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width, height: contentSize.height + FLPopMenu.arrowSize))
        case .down:
            var point = CGPoint(x: rectXM - widthHalf, y: rectY0 - heightPlusArrow - 3)
            
            if point.x < kMargin {
                point.x = kMargin
            }
            
            if (point.x + contentSize.width + kMargin) > outerWidth {
                point.x = outerWidth - contentSize.width - kMargin
            }
            
            arrowPosition = rectXM - point.x
            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width, height: contentSize.height + FLPopMenu.arrowSize))
        case .left:
            var point = CGPoint(x: rectX1 + 3, y: rectYM - heightHalf)
            
            if point.y < kMargin {
                point.y = kMargin
            }
            
            if (point.y + contentSize.height + kMargin) > outerHeight {
                point.y = outerHeight - contentSize.height - kMargin
            }
            
            arrowPosition = rectYM - point.y
            contentView?.frame.origin.x = FLPopMenu.arrowSize
            
            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width + FLPopMenu.arrowSize, height: contentSize.height))
        case .right:
            var point = CGPoint(x: rectX0 - widthPlusArrow - 3, y: rectYM - heightHalf)
            
            if point.y < kMargin {
                point.y = kMargin
            }
            
            if (point.y + contentSize.height + kMargin) > outerHeight {
                point.y = outerHeight - contentSize.height - kMargin
            }
            
            arrowPosition = rectYM - point.y
            
            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width + FLPopMenu.arrowSize, height: contentSize.height))
        case .none:
            self.frame = CGRect(origin: CGPoint(x:(outerWidth - contentSize.width) * 0.5,y:(outerHeight - contentSize.height) * 0.5), size: contentSize)
        
        }
        
        
        
//        if heightPlusArrow < (outerHeight - rectY1) {
//            arrowDirection = .up
//            var point = CGPoint(x: rectXM - widthHalf, y: rectY1)
//
//            if point.x < kMargin {
//                point.x = kMargin
//            }
//
//            if (point.x + contentSize.width + kMargin) > outerWidth {
//                point.x = outerWidth - contentSize.width - kMargin
//            }
//
//            arrowPosition = rectXM - point.x
//            contentView.frame = CGRect(origin: CGPoint(x:0,y:FLPopMenu.arrowSize), size: contentSize)
//
//            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width, height: contentSize.height + FLPopMenu.arrowSize))
//        }else if heightPlusArrow < rectY0 {
//            arrowDirection = .down
//            var point = CGPoint(x: rectXM - widthHalf, y: rectY0 - heightPlusArrow)
//
//            if point.x < kMargin {
//                point.x = kMargin
//            }
//
//            if (point.x + contentSize.width + kMargin) > outerWidth {
//                point.x = outerWidth - contentSize.width - kMargin
//            }
//
//            arrowPosition = rectXM - point.x
//            contentView.frame = CGRect(origin: CGPoint.zero, size: contentSize)
//
//            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width, height: contentSize.height + FLPopMenu.arrowSize))
//        }else if widthPlusArrow < (outerWidth - rectX1) {
//            arrowDirection = .left
//            var point = CGPoint(x: rectX1, y: rectYM - heightHalf)
//
//            if point.y < kMargin {
//                point.y = kMargin
//            }
//
//            if (point.y + contentSize.height + kMargin) > outerHeight {
//                point.y = outerHeight - contentSize.height - kMargin
//            }
//
//            arrowPosition = rectYM - point.y
//            contentView.frame = CGRect(origin: CGPoint(x:FLPopMenu.arrowSize,y:0), size: contentSize)
//
//            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width + FLPopMenu.arrowSize, height: contentSize.height))
//
//        }else if widthPlusArrow < rectX0 {
//
//            arrowDirection = .right
//            var point = CGPoint(x: rectX0 - widthPlusArrow, y: rectYM - heightHalf)
//
//            if point.y < kMargin {
//                point.y = kMargin
//            }
//
//            if (point.y + contentSize.height + 5) > outerHeight {
//                point.y = outerHeight - contentSize.height - kMargin
//            }
//
//            arrowPosition = rectYM - point.y
//            contentView.frame = CGRect(origin: CGPoint.zero, size: contentSize)
//            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width + FLPopMenu.arrowSize, height: contentSize.height))
//
//        }else{
//
//            arrowDirection = .none
//
//            self.frame = CGRect(origin: CGPoint(x:(outerWidth - contentSize.width) * 0.5,y:(outerHeight - contentSize.height) * 0.5), size: contentSize)
//
//        }
    }
    
    
    override func draw(_ rect: CGRect){
        let context = UIGraphicsGetCurrentContext()
        if context != nil {
            drawBackground(withIn: self.bounds, inContext: context!)
            
        }
        
    }
    
    func drawBackground(withIn frame:CGRect,inContext context:CGContext){
        let tintColor = FLPopMenu.tintColor
        var R0:CGFloat = 0.0
        var R1:CGFloat = 0.0
        var G0:CGFloat = 0.0
        var G1:CGFloat = 0.0
        var B0:CGFloat = 0.0
        var B1:CGFloat = 0.0
        var a:CGFloat = 0.0
        tintColor.getRed(&R0, green: &G0, blue: &B0, alpha: &a)
        tintColor.getRed(&R1, green: &G1, blue: &B1, alpha: &a)
        
        if FLPopMenu.backgrounColorEffect == .Gradient {
            R1 -= 0.2
            G1 -= 0.2
            B1 -= 0.2
        }
        
        var X0 = frame.origin.x
        var X1 = frame.origin.x + frame.size.width
        var Y0 = frame.origin.y
        var Y1 = frame.origin.y + frame.size.height
        
        let arrowPath = UIBezierPath()
        
        let kEmbedFix:CGFloat = 3.0
        
        switch arrowDirection {
        case .up:
            
            let arrowXM = arrowPosition
            let arrowX0 = arrowXM - FLPopMenu.arrowSize
            let arrowX1 = arrowXM + FLPopMenu.arrowSize
            let arrowY0 = Y0
            let arrowY1 = Y0 + FLPopMenu.arrowSize + kEmbedFix
            
            arrowPath.move(to: CGPoint(x: arrowXM, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowXM, y: arrowY0))
            
            tintColor.set()
            
            Y0 += FLPopMenu.arrowSize
            
        case .down:
            
            let arrowXM = arrowPosition
            let arrowX0 = arrowXM - FLPopMenu.arrowSize
            let arrowX1 = arrowXM + FLPopMenu.arrowSize
            let arrowY0 = Y1 - FLPopMenu.arrowSize - kEmbedFix
            let arrowY1 = Y1
            
            arrowPath.move(to: CGPoint(x: arrowXM, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowXM, y: arrowY1))
            
            UIColor(red: R1, green: G1, blue: B1, alpha: 1).set()
            
            Y1 -= FLPopMenu.arrowSize
            
        case .left:
            
            let arrowYM = arrowPosition
            let arrowX0 = X0
            let arrowX1 = X0 + FLPopMenu.arrowSize + kEmbedFix
            let arrowY0 = arrowYM - FLPopMenu.arrowSize
            let arrowY1 = arrowYM + FLPopMenu.arrowSize
            
            arrowPath.move(to: CGPoint(x: arrowX0, y: arrowYM))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowYM))
            
            tintColor.set()
            
            X0 += FLPopMenu.arrowSize
            
        case .right:
            
            let arrowYM = arrowPosition
            let arrowX0 = X1
            let arrowX1 = X1 - FLPopMenu.arrowSize - kEmbedFix
            let arrowY0 = arrowYM - FLPopMenu.arrowSize
            let arrowY1 = arrowYM + FLPopMenu.arrowSize
            
            arrowPath.move(to: CGPoint(x: arrowX0, y: arrowYM))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowYM))
            
            UIColor(red: R1, green: G1, blue: B1, alpha: 1).set()
            
            X1 -= FLPopMenu.arrowSize
            
        case .none:
            break
        }
        
        arrowPath.fill()
        
        // render body
        let bodyFrame = CGRect(x: X0, y: Y0, width: X1 - X0, height: Y1 - Y0)
        
        let borderPath = UIBezierPath(roundedRect: bodyFrame, cornerRadius: FLPopMenu.cornerRadius)
        
        let locations:[CGFloat] = [0.0,1.0]
        let components:[CGFloat] = [R0,G0,B0,1,
                                    R1,G1,B1,1]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: locations.count)
        
        //CGColorSpaceRelease(colorSpace)
        
        borderPath.addClip()
        
        var start:CGPoint
        var end:CGPoint
        if arrowDirection == .left || arrowDirection == .right {
        
            start = CGPoint(x: X0, y: Y0)
            end = CGPoint(x: X1, y: Y0)
            
        }else{
            
            start = CGPoint(x: X0, y: Y0)
            end = CGPoint(x: X0, y: Y1)
            
        }
        
        context.drawLinearGradient(gradient!, start: start, end: end, options: CGGradientDrawingOptions(rawValue: 0))
        
    }
    
    // 生成 arrowPoint
    func arrowPoint() -> CGPoint {
        var point:CGPoint
        switch arrowDirection {
        case .up:
            point = CGPoint(x: self.frame.minX + arrowPosition, y: self.frame.minY)
        case .down:
            point = CGPoint(x: self.frame.minX + arrowPosition, y: self.frame.maxY)
        case .left:
            point = CGPoint(x: self.frame.minX, y: self.frame.minY + arrowPosition)
        case .right:
            point = CGPoint(x: self.frame.maxX, y: self.frame.minY + arrowPosition)
        case .none:
            point = self.center
        }
        return point
    }
    
    // 响应按钮点击，传递消息
    func performAction(sender:Any?){
        self.dismissMenu(animated: true)
        let btn = sender as! UIButton
        btn.sendActions(for: .touchUpInside)
    }
    
    
    
    
    //清除弹出菜单
    @objc func dismissMenu(animated:Bool){
        if self.superview != nil {
            weak var weakSelf = self
            func removeView () {
                if (weakSelf?.superview?.isKind(of: FLMenuOverlay.self))! {
                    weakSelf?.superview?.removeFromSuperview()
                }
                weakSelf?.removeFromSuperview()
                
            }
            
            if animated {
                contentView?.isHidden = true
                let toFrame = CGRect(origin: self.arrowPoint(), size: CGSize(width: 1.0, height: 1.0))
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0
                    self.frame = toFrame
                }, completion: { finished in
                    removeView()
                })
            }else{
                removeView()
            }
        }
        FLPopMenu.shared.isShow = false
    }
}





// MARK: - 最上层:FLPopMenu类/////////////////////////////////////////////////////
class FLPopMenu:NSObject{
    // 单例对象
    static var shared = FLPopMenu()
    // 中间层 view 实例
    var menuView:FLMenuView?
    // 是否被监听
    var isObserving = false
    
    // 主题颜色
    static var tintColor:UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    // 阴影颜色
    static var shadowColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
    // 文字颜色
    static var textColor:UIColor = UIColor.black
    // 标题字体
    static var textFont:UIFont = UIFont.systemFont(ofSize: gTextFontSize)
    // 文字对齐方式
    static var alignment:NSTextAlignment = gAlignment
    // 圆角尺寸
    static var cornerRadius:CGFloat = 4.0
    // 箭头尺寸
    static var arrowSize:CGFloat = 8.0
    // 箭头方向
    var arrowDirection:FLMenuViewArrowDirection = .down
    // 垂直边距
    static var vMargin:CGFloat = gVMargin
    // 水平边距
    static var lMargin:CGFloat = gLMargin
    // 背景效果
    static var backgrounColorEffect:FLMenuBackgrounColorEffect = .solid
    // 是否显示阴影
    static var hasShadow:Bool = true
    // 选中颜色
    //var selectedColor:UIColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    // 分割线颜色
    static var separatorColor:UIColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
    // 菜单元素垂直方向上的边距值
    //var menuItemMarginY:CGFloat = 12.0
    // 视图当前是否显示
    var isShow:Bool = false
    
    // MARK: - 构造，析构函数//////////////////////////////////////////
    
    // 构造函数（单例类，设置为private）
    private override init(){
        print("PopMenu被创建")
    }
    
    // 析构函数
    deinit{
        print("注销PopMenu")
    }
    
    // MARK: - 接口函数/////////////////////////////////////////////
    
    // 显示PopMenu
    func show(withIN view:UIView,fromRect rect:CGRect,animated:Bool = true){
//        if menuView != nil {
//            menuView?.dismissMenu(animated: false)
//            menuView = nil
//        }
        
//        if !isObserving {
//            isObserving = true
//            NotificationCenter.default.addObserver(self, selector: #selector(orientationWillChange), name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
//        }
        
        // 创建 MenuView
        //menuView = FLMenuView()
        menuView?.showMenuInView(view: view, fromRect: rect,animated:animated)
        self.isShow = true
    }
    
    
    // 向Menu中添加Item
    func addItems (items:[FLMenuItem]) {
        print("向Menu中添加项目（\(items.count)个项目）")
        if menuView != nil {
            menuView?.dismissMenu(animated: false)
            menuView = nil
        }
        
        menuView = FLMenuView()
        menuView?.addItems(items: items)
        print("添加成功")
        print(menuView?.contentView?.frame)
    }
    

    
    // MARK: - 私有函数///////////////////////////////////////////////
    // 重置属性
    func reset(){
        
    }
    
    
    // 清除弹出菜单
    func dismissMenu(){
        if menuView != nil {
            menuView?.dismissMenu(animated: false)
            menuView = nil
        }
        
        self.isShow = false
    }
    
    // MARK: - 监听///////////////////////////////////////////////////
    
    @objc func orientationWillChange(notification:Notification) {
        self.dismissMenu()
    }
        
}