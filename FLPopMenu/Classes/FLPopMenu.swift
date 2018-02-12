//
//  File.swift
//  FLPopMenu
//
//  Created by Atholon on 2018/1/25.
//  Copyright © 2018年 Atholon. All rights reserved.
//


// 存在问题：
//


import Foundation
import UIKit

// MARK: - 默认设置全局变量 ///////////////////////////////////////////////////////

/// 主题颜色
let gTintColor:UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
/// 阴影颜色
let gShadowColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
/// 文字颜色
let gTextColor:UIColor = UIColor.black
/// 字体大小
let gTextFontSize:CGFloat = 18.0
/// 文字对齐方式
let gAlignment:NSTextAlignment = .left
/// 垂直边距
let gVMargin:CGFloat = 10.0
/// 水平边距
let gLMargin:CGFloat = 17.0
/// 圆角半径
let gCornerRadius:CGFloat = 4.0
/// 箭头大小
let gArrowSize:CGFloat = 8.0
/// 是否阴影
let gHasShadow:Bool = true
/// 箭头方向
let gArrowDirection:FLMenuViewArrowDirection = .down
/// 分割线颜色
let gSeparatorColor:UIColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
/// 背景效果
let gBackgrounColorEffect:FLMenuBackgrounColorEffect = .solid

/// 背景效果枚举
enum FLMenuBackgrounColorEffect {
    ///<背景显示效果-纯色
    case solid
    ///<背景显示效果-渐变叠加>
    case Gradient
}

///箭头方向枚举
enum FLMenuViewArrowDirection{
    case up
    case down
    case left
    case right
    case none
}


// MARK: - 基层:Overlay类，覆盖全屏，提供点击取消菜单功能


/// 基层：Overlay类，覆盖全屏，提供点击取消菜单功能
class FLMenuOverlay:UIView{
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
        // 添加点击手势，调用dismissMenu取消菜单
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("OverlayView被注销！")
    }
    
    /// 单击响应，调用shared单例的dismissMenu来取消菜单显示。
    @objc func singleTap(recognizer:UITapGestureRecognizer){
//        for view in self.subviews{
//            if view.isKind(of: FLMenuView.self) && view.responds(to: #selector(FLMenuView.dismissMenu)){
//                view.perform(#selector(FLMenuView.dismissMenu), with: true)
//            }
//        }
        FLPopMenu.shared.dismissMenu(animated: true)
    }
    
}



// MARK: - 背景层:MenuView类 （内含内容view）
class FLMenuView:UIView{
    // 背景view
    //var overlayView:UIView?
    // 内容view
    var contentView:UIView?
    // Menu按钮对象数组
    var menuItems:[FLMenuItem] = [FLMenuItem]()
    // 文本字体
    var textFont:UIFont = FLPopMenu.textFont
    // 箭头方向
    var arrowDirection:FLMenuViewArrowDirection = FLPopMenu.arrowDirection
    // 箭头位置
    var arrowPosition:CGFloat = 0.0
    
    
    // 被选择按钮对象
    //var selectedItem
    
    // MARK: - 构造，析构函数//////////////////////////////////////////////////
    
    // 构造函数
    init(){
        super.init(frame: CGRect.zero)
        
        // 透明背景
        self.backgroundColor = UIColor.clear
        self.isOpaque = true
        // 起始于透明状态
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
    
    deinit {
        print("MenuView被注销！")
    }
    
    
    // MARK: - 接口函数  //////////////////////////////////////////////////////
    
    /// 内部接口：添加 Items ，调用私有函数 makeContentView 建立内容View
    func addItems (items:[FLMenuItem]) {
        if items.isEmpty {
            //print("MenuItems无内容！")
            contentView = nil
        }else{
            menuItems = items
            contentView = makeContentView()
            //print(contentView?.frame)
        }
    }
    
    /// 内部接口：在目标 view 中显示菜单
    func showMenuInView(view:UIView,fromRect:CGRect,animated:Bool = true){
        // 根据 fromView，contentView 设定 menuView 的位置，大小。
        setupFrameInView(view: view, fromRect: fromRect)
        //print(contentView?.frame)
        let overlay = FLMenuOverlay(frame: view.frame)
        // 将 contentView 添加到 menuView 上
        self.addSubview(contentView!)
        // 将 menuView 添加到 overlayView 上（将自动调用被重载的 draw 函数）
        overlay.addSubview(self)
        // 将 overlayView 添加到 目标view上（不能覆盖 navigationgBar ，ToolBar，TabBar）
        view.addSubview(overlay)
        
        //contentView?.isHidden = false
        //contentView?.layer.anchorPoint = CGPoint(x: 0, y: 0)
        //contentView?.transform = CGAffineTransform(a: 0.1, b: 0, c: 0, d: 0.1, tx: 0, ty: 0)
        //contentView?.alpha = 0.0
        
        //let toFrame = self.frame
        //self.frame = CGRect(origin: arrowPoint(), size: CGSize(width: toFrame.size.width * 0.1 , height: toFrame.size.height * 0.1))
        //self.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0.5)
        //let lOffset:CGFloat = -1 * self.frame.size.width / 2 + arrowPosition
        //let vOffset:CGFloat = self.frame.size.height / 2
        //let anchor:CGFloat = arrowPosition / self.frame.width
        //self.layer.anchorPoint = CGPoint(x: anchor, y: 1)
        
        // 先缩小（初始化时已设置为透明）
        self.transform = CGAffineTransform(a: 0.1, b: 0, c: 0, d: 0.1, tx: 0, ty: 0)
        // 用动画恢复为正常大小，不透明
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
            //self.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: lOffset, ty: vOffset)
            self.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
            //self.frame = toFrame
            //self.contentView?.alpha = 1.0
            //self.contentView?.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
        }, completion:nil)
    }
    
    
    
    // MARK: - 私有函数 ///////////////////////////////////////////////////////
    
    /// 生成contentView
    func makeContentView() -> UIView {
        print("开始制作ContentView")
        // 计算最长文字的size，初始为（0，0）
        var textSize = CGSize.zero
        
        // 检查是否有包含图标的item
        var hasIcon = false
        for item in menuItems {
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
        var textLabX:CGFloat = FLPopMenu.lMargin      //文字Label的水平起始位置
        if hasIcon {
            // 图标与文字Label高度相同，上移1，总高度+1
            vPlusForImg = 1.0
            // 图标高宽相等，再加上与文字的间隔：8.0
            lPlusForImg = textSize.height + 8.0
            //
            textLabX += lPlusForImg
        }
        // 计算item的高度和宽度
        let itemHeight = FLPopMenu.vMargin * 2 + textSize.height + vPlusForImg
        let itemWidth = FLPopMenu.lMargin * 2 + textSize.width + lPlusForImg + 2
        // 计算contentRect
        let contentRect = CGRect(x: 0, y: 0, width: itemWidth, height: itemHeight * CGFloat(menuItems.count))
        // 生成contentView
        let contentView = UIView(frame: contentRect)
        
        // 按钮高亮时背景图片Rect
        let imgRect = CGRect(x: 0, y: 0, width: itemWidth, height: itemHeight)
        // 开始绘制图片
        UIGraphicsBeginImageContext(imgRect.size)
        let context = UIGraphicsGetCurrentContext()
        let color = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3)
        context!.setFillColor(color.cgColor)
        context!.fill(imgRect)
        let selImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 添加每个 Item 的图片和文字
        for i in 0 ..< menuItems.count {
            var textRect:CGRect
            var img:UIImageView
            if menuItems[i].image != nil { // 有图标
                // 计算图标 Rect：
                let imgRect = CGRect(x: FLPopMenu.lMargin, y: CGFloat(i) * itemHeight + FLPopMenu.vMargin, width: textSize.height , height: textSize.height)
                // 生成图标对象
                img = UIImageView(frame: imgRect)
                //img.adjustsImageSizeForAccessibilityContentSizeCategory = false
                img.image = menuItems[i].image
                
                //测试用
                //img.backgroundColor = UIColor.lightGray
                
                //添加图标
                contentView.addSubview(img)
            }
            // 定位文字Label
            let origin = CGPoint(x:textLabX,y:CGFloat(i) * itemHeight + FLPopMenu.vMargin + 1.0)
            let size = menuItems[i].title.size(withAttributes: [NSAttributedStringKey.font:textFont])
            textRect = CGRect(origin: origin, size: size)
            // 生成文字Label对象
            let textLabel = UILabel(frame: textRect)
            // 设置文字，颜色，字体，对齐
            textLabel.text = menuItems[i].title
            textLabel.textColor = FLPopMenu.textColor
            textLabel.font = FLPopMenu.textFont
            textLabel.textAlignment = FLPopMenu.alignment
            
            //测试用
            //textLabel.backgroundColor = UIColor.lightGray
            
            // 添加文字Label
            contentView.addSubview(textLabel)
            
            // 如果不是最后一行，添加分割线
            if i < menuItems.count - 1 {
                // 分割线存在于每一行的最下面0.5
                let origin = CGPoint(x: FLPopMenu.lMargin, y: CGFloat(i + 1) * itemHeight - 0.5)
                // 分割线宽度为总宽度 - 2*边距
                let size = CGSize(width: itemWidth - FLPopMenu.lMargin * 2.0, height: 0.5)
                let seperator = UILabel(frame: CGRect(origin: origin, size: size))
                seperator.backgroundColor = FLPopMenu.separatorColor
                contentView.addSubview(seperator)
            }
            
            // 添加按钮
            let btnRect = CGRect(x: 0, y: CGFloat(i) * itemHeight, width: itemWidth, height: itemHeight)
            let btn = UIButton(frame: btnRect)
            // 设置为生成的高亮图片对象
            btn.setBackgroundImage(selImg, for: .highlighted)
            // 用于点击时识别的序号
            btn.tag = i
            // 设置由 FLPopMenu 的单例对象的 performAction 函数响应点击
            btn.addTarget(FLPopMenu.shared, action: #selector(FLPopMenu.performAction), for: .touchUpInside)
            //btn.backgroundColor = UIColor.blue
            contentView.addSubview(btn)
        }
        //print(contentView.frame)
        return contentView
    }
    
    // 设置view
    func setupFrameInView(view:UIView,fromRect:CGRect){
        if contentView == nil {
            return
        }
        print("状态栏高度：\(UIApplication.shared.statusBarFrame.height)")
        //let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        // 目前假设目标View为某个viewController，因此需考虑安全区顶部和底部的内缩。
        // 安全区的顶部内缩（由 StatusBar 和 NavigationBar 引起）
        let topInset = view.safeAreaInsets.top
        // 安全区的底部内缩（由 ToolBar 或 TabBar 引起）
        let bottomInset = view.safeAreaInsets.bottom
        // 获取内容view的尺寸
        let contentSize = contentView!.frame.size
        // 目标view的尺寸
        let outerWidth:CGFloat = view.bounds.size.width
        let outerHeight:CGFloat = view.bounds.size.height
        // 计算fromRect左上，右下，中心点在目标view中的坐标
        let rectX0:CGFloat = fromRect.origin.x
        let rectX1:CGFloat = fromRect.origin.x + fromRect.size.width
        let rectXM:CGFloat = fromRect.origin.x + fromRect.size.width * 0.5
        let rectY0:CGFloat = fromRect.origin.y
        let rectY1:CGFloat = fromRect.origin.y + fromRect.size.height
        let rectYM:CGFloat = fromRect.origin.y + fromRect.size.height * 0.5
        
        // 加箭头的宽度（箭头左右时）
        let widthPlusArrow:CGFloat = contentSize.width + FLPopMenu.arrowSize
        // 加箭头的高度（箭头上下时）
        let heightPlusArrow:CGFloat = contentSize.height + FLPopMenu.arrowSize
        // 宽和高的一半
        let widthHalf:CGFloat = contentSize.width * 0.5
        let heightHalf:CGFloat = contentSize.height * 0.5
        // MenuView 距目标view边界的距离
        let kMargin:CGFloat = 5.0
        
        switch arrowDirection {
        case .up:
            // MenuView左上角坐标（水平以fromView为中心，向下离开3）
            var point = CGPoint(x: rectXM - widthHalf, y: rectY1 + 3)
            // 确保不超出左边界
            if point.x < kMargin {
                point.x = kMargin
            }
            // 确保不超出右边界
            if (point.x + contentSize.width + kMargin) > outerWidth {
                point.x = outerWidth - contentSize.width - kMargin
            }
            // 箭头顶点在menuView中的水平位置
            arrowPosition = rectXM - point.x
            // 下移内容view，留出箭头位置
            contentView?.frame.origin.y = FLPopMenu.arrowSize
            // 设定menuView的frame
            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width, height: heightPlusArrow))
            // 设置锚点并恢复frame
            let oldFrame = self.frame
            self.layer.anchorPoint = CGPoint(x: arrowPosition / contentSize.width, y: 0)
            self.frame = oldFrame
        case .down:
            // MenuView左上角坐标（水平以fromView为中心，向上离开3）
            var point = CGPoint(x: rectXM - widthHalf, y: rectY0 - heightPlusArrow - 3)
            // 确保不超出左边界
            if point.x < kMargin {
                point.x = kMargin
            }
            // 确保不超出右边界
            if (point.x + contentSize.width + kMargin) > outerWidth {
                point.x = outerWidth - contentSize.width - kMargin
            }
            // 箭头顶点在menuView中的水平位置
            arrowPosition = rectXM - point.x
            // 设定menuView的frame
            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width, height: contentSize.height + FLPopMenu.arrowSize))
            // 设置锚点并恢复frame
            let oldFrame = self.frame
            self.layer.anchorPoint = CGPoint(x: arrowPosition / contentSize.width, y: 1)
            self.frame = oldFrame
        case .left:
            // MenuView左上角坐标（垂直以fromView为中心，向右离开3）
            var point = CGPoint(x: rectX1 + 3, y: rectYM - heightHalf)
            // 确保不超出上边界
            if point.y < kMargin + topInset {
                point.y = kMargin + topInset
            }
            // 确保不超出下边界
            if (point.y + contentSize.height + kMargin) > outerHeight - bottomInset {
                point.y = outerHeight - bottomInset - contentSize.height - kMargin
            }
            // 箭头顶点在menuView中的垂直位置
            arrowPosition = rectYM - point.y
            // 右移内容view，留出箭头位置
            contentView?.frame.origin.x = FLPopMenu.arrowSize
            // 设定menuView的frame
            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width + FLPopMenu.arrowSize, height: contentSize.height))
            // 设置锚点并恢复frame
            let oldFrame = self.frame
            self.layer.anchorPoint = CGPoint(x: 0, y: arrowPosition / contentSize.height)
            self.frame = oldFrame
        case .right:
            // MenuView左上角坐标（垂直以fromView为中心，向左离开3）
            var point = CGPoint(x: rectX0 - widthPlusArrow - 3, y: rectYM - heightHalf)
            // 确保不超出上边界
            if point.y < kMargin + topInset {
                point.y = kMargin + topInset
            }
            // 确保不超出下边界
            if (point.y + contentSize.height + kMargin) > outerHeight - bottomInset {
                point.y = outerHeight - bottomInset - contentSize.height - kMargin
            }
            // 箭头顶点在menuView中的垂直位置
            arrowPosition = rectYM - point.y
            // 设定menuView的frame
            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width + FLPopMenu.arrowSize, height: contentSize.height))
            // 设置锚点并恢复frame
            let oldFrame = self.frame
            self.layer.anchorPoint = CGPoint(x: 1, y: arrowPosition / contentSize.height)
            self.frame = oldFrame
        case .none:
            // MenuView左上角坐标（垂直，水平以fromView为中心）
            var point = CGPoint(x: rectXM - widthHalf, y: rectYM - heightHalf)
            // 确保不超出左边界
            if point.x < kMargin {
                point.x = kMargin
            }
            // 确保不超出右边界
            if (point.x + contentSize.width + kMargin) > outerWidth {
                point.x = outerWidth - contentSize.width - kMargin
            }
            // 确保不超出上边界
            if point.y < kMargin + topInset {
                point.y = kMargin + topInset
            }
            // 确保不超出下边界
            if (point.y + contentSize.height + kMargin) > outerHeight - bottomInset {
                point.y = outerHeight - bottomInset - contentSize.height - kMargin
            }
            // 设定menuView的frame
            self.frame = CGRect(origin: point, size: contentSize)
            
        
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
    
    /// 系统刻画menuView时自动调用，刻画自定义View
    override func draw(_ rect: CGRect){
        let context = UIGraphicsGetCurrentContext()
        if context != nil {
            drawBackground(withIn: self.bounds, inContext: context!)
            
        }
        // 重置菜单各项属性，以备再次使用
        FLPopMenu.reset()
        
    }
    
    // 刻画自定义 menuView
    func drawBackground(withIn frame:CGRect,inContext context:CGContext){
        let tintColor = FLPopMenu.tintColor
        // 背景颜色和渐变色的R，G，B，Alpha分量
        var R0:CGFloat = 0.0
        var R1:CGFloat = 0.0
        var G0:CGFloat = 0.0
        var G1:CGFloat = 0.0
        var B0:CGFloat = 0.0
        var B1:CGFloat = 0.0
        var a:CGFloat = 0.0
        // 获取各分量
        tintColor.getRed(&R0, green: &G0, blue: &B0, alpha: &a)
        tintColor.getRed(&R1, green: &G1, blue: &B1, alpha: &a)
        //print(R0)
        
        // 渐变效果时，渐变色比背景色暗0.2
        if FLPopMenu.backgrounColorEffect == .Gradient {
            R1 -= 0.2
            G1 -= 0.2
            B1 -= 0.2
        }
        
        // menuView 的左上，右下坐标
        var X0 = frame.origin.x
        var X1 = frame.origin.x + frame.size.width
        var Y0 = frame.origin.y
        var Y1 = frame.origin.y + frame.size.height
        // 刻画箭头的路径对象
        let arrowPath = UIBezierPath()
        
        // 箭头为等边三角形，高为 arrowSize，计算底边的一半
        let arrowBaseHalf:CGFloat = FLPopMenu.arrowSize / 1.732
        
        // 按不同的箭头方向画箭头
        switch arrowDirection {
        case .up:
            // 计算三角形各定点坐标
            let arrowXM = arrowPosition
            let arrowX0 = arrowXM - arrowBaseHalf
            let arrowX1 = arrowXM + arrowBaseHalf
            let arrowY0 = Y0
            let arrowY1 = Y0 + FLPopMenu.arrowSize + 1.0   //加1.0为修正箭头与主体之间的缝隙
            // 使用路径对象画三角形
            arrowPath.move(to: CGPoint(x: arrowXM, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowXM, y: arrowY0))
            // 设定填充颜色，顶部三角形为原色
            tintColor.set()
            // menu 主体下移至三角形底部
            Y0 += FLPopMenu.arrowSize
            
        case .down:
            // 计算三角形各定点坐标
            let arrowXM = arrowPosition
            let arrowX0 = arrowXM - arrowBaseHalf
            let arrowX1 = arrowXM + arrowBaseHalf
            let arrowY0 = Y1 - FLPopMenu.arrowSize - 1.0  //减1.0为修正箭头与主体之间的缝隙
            let arrowY1 = Y1
            // 使用路径对象画三角形
            arrowPath.move(to: CGPoint(x: arrowXM, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowXM, y: arrowY1))
            // 设定填充颜色，底部三角形为渐变色
            UIColor(red: R1, green: G1, blue: B1, alpha: 1).set()
            // menu 主体上移至三角形底部
            Y1 -= FLPopMenu.arrowSize
            
        case .left:
            // 计算三角形各定点坐标
            let arrowYM = arrowPosition
            let arrowX0 = X0
            let arrowX1 = X0 + FLPopMenu.arrowSize + 1.0    //加1.0为修正箭头与主体之间的缝隙
            let arrowY0 = arrowYM - arrowBaseHalf
            let arrowY1 = arrowYM + arrowBaseHalf
            // 使用路径对象画三角形
            arrowPath.move(to: CGPoint(x: arrowX0, y: arrowYM))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowYM))
            // 设定填充颜色，左边三角形为原色
            tintColor.set()
            // menu 主体右移至三角形底部
            X0 += FLPopMenu.arrowSize
            
        case .right:
            // 计算三角形各定点坐标
            let arrowYM = arrowPosition
            let arrowX0 = X1
            let arrowX1 = X1 - FLPopMenu.arrowSize - 1.0   //减1.0为修正箭头与主体之间的缝隙
            let arrowY0 = arrowYM - arrowBaseHalf
            let arrowY1 = arrowYM + arrowBaseHalf
            // 使用路径对象画三角形
            arrowPath.move(to: CGPoint(x: arrowX0, y: arrowYM))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowYM))
            // 设定填充颜色，右边三角形为渐变色
            UIColor(red: R1, green: G1, blue: B1, alpha: 1).set()
            // menu 主体左移至三角形底部
            X1 -= FLPopMenu.arrowSize
            
        case .none:
            break
        }
        // 刻画并填充三角形
        arrowPath.fill()
        
        // 渲染主体
        // 主体矩形frame
        let bodyFrame = CGRect(x: X0, y: Y0, width: X1 - X0, height: Y1 - Y0)
        // 生成圆角矩形path
        let borderPath = UIBezierPath(roundedRect: bodyFrame, cornerRadius: FLPopMenu.cornerRadius)
        // 两个渐变色的位置（0.0-1.0之间）
        let locations:[CGFloat] = [0.0,1.0]
        // 两个渐变色的分量
        let components:[CGFloat] = [R0,G0,B0,1,
                                    R1,G1,B1,1]
        // 生成设备的色彩空间
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // 生成渐变对象
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: locations.count)
        
        //CGColorSpaceRelease(colorSpace)
        
        // 添加剪切，使后续的渐变渲染只在圆角rect内生效。
        borderPath.addClip()
        // 起点和终点
        var start:CGPoint
        var end:CGPoint
        // 按箭头方向设置起点终点坐标
        if arrowDirection == .left || arrowDirection == .right {
            // 水平渐变
            start = CGPoint(x: X0, y: Y0)
            end = CGPoint(x: X1, y: Y0)
            
        }else{
            // 垂直渐变
            start = CGPoint(x: X0, y: Y0)
            end = CGPoint(x: X0, y: Y1)
            
        }
        // 渲染一个从起点到终点的线性渐变
        context.drawLinearGradient(gradient!, start: start, end: end, options: CGGradientDrawingOptions(rawValue: 0))
        
    }
    
    /// 生成箭头顶点在父View中的坐标（目前没用上）
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
//    @objc func performAction(sender:Any?){
//        //self.dismissMenu(animated: true)
//        let btn = sender as! UIButton
//        let target = menuItems[btn.tag].target as AnyObject
//        let action = menuItems[btn.tag].action
//        FLPopMenu.shared.performSelector(onMainThread:#selector(FLPopMenu.dismissMenu), with: true, waitUntilDone: true)
//        if  target.responds(to: action) {
//            target.performSelector(onMainThread: action!, with: self, waitUntilDone: true)
//            //target.perform( action!, with: self)
//        }
//
//    }
    
    
    
    
    /// 清除弹出菜单
    @objc func dismissMenu(animated:Bool){
        // 如果MenuView的父View为 nil ，说明menuView没有挂在任何view上，根本没有显示出来。不做任何操作。
        if self.superview != nil {
//            weak var weakSelf = self
//            func removeView () {
//                if (weakSelf?.superview?.isKind(of: FLMenuOverlay.self))! {
//                    weakSelf?.superview?.removeFromSuperview()
//                }
//                weakSelf?.removeFromSuperview()
//
//            }
            // 是否有动画效果
            if animated {
                //contentView?.isHidden = true
                //let toFrame = CGRect(origin: self.arrowPoint(), size: CGSize(width: 1.0, height: 1.0))
                // 设置菜单消失的动画效果
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0
                    self.transform = CGAffineTransform(a: 0.1, b: 0, c: 0, d: 0.1, tx: 0, ty: 0)
                    //self.frame = toFrame
                }, completion: { finished in
                    // 动画结束后移除view
                    if self.superview is FLMenuOverlay {
                        self.superview?.removeFromSuperview()
                    }
//                    if (self.superview?.isKind(of: FLMenuOverlay.self))! {
//                        self.superview?.removeFromSuperview()
//                    }
                    
                    self.removeFromSuperview()
                })
            }else{
                // 无动画直接移除view
                if (self.superview?.isKind(of: FLMenuOverlay.self))! {
                    self.superview?.removeFromSuperview()
                }
                
                self.removeFromSuperview()
            }
        }
        //FLPopMenu.shared.isShow = false
    }
}





// MARK: - 接口层:FLPopMenu类/////////////////////////////////////////////////////

/// 用户接口类，含有单实例 .shared ，各项静态属性供用户修改，使用 show 函数显示菜单。
class FLPopMenu:NSObject{
    // 单例对象
    static var shared = FLPopMenu()
    // 菜单 menuView 实例
    var menuView:FLMenuView?
    // 是否被监听
    var isObserving = false
    // 视图当前是否显示
    var isShow:Bool = false
    
    // 主题颜色
    static var tintColor:UIColor = gTintColor
    // 阴影颜色
    static var shadowColor = gShadowColor
    // 文字颜色
    static var textColor:UIColor = gTextColor
    // 标题字体
    static var textFont:UIFont = UIFont.systemFont(ofSize: gTextFontSize)
    // 文字对齐方式
    static var alignment:NSTextAlignment = gAlignment
    // 圆角尺寸
    static var cornerRadius:CGFloat = gCornerRadius
    // 箭头尺寸
    static var arrowSize:CGFloat = gArrowSize
    // 箭头方向
    static var arrowDirection:FLMenuViewArrowDirection = gArrowDirection
    // 垂直边距
    static var vMargin:CGFloat = gVMargin
    // 水平边距
    static var lMargin:CGFloat = gLMargin
    // 背景效果
    static var backgrounColorEffect:FLMenuBackgrounColorEffect = gBackgrounColorEffect
    // 是否显示阴影
    static var hasShadow:Bool = gHasShadow
    // 选中颜色
    //var selectedColor:UIColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    // 分割线颜色
    static var separatorColor:UIColor = gSeparatorColor
    
    
    // 菜单元素垂直方向上的边距值
    //var menuItemMarginY:CGFloat = 12.0
    
    
    // MARK: - 构造，析构函数//////////////////////////////////////////
    
    // 构造函数（单例类，设置为private）
//    private override init(){
//        print("PopMenu被创建")
//    }
    
    // 析构函数
//    deinit{
//        print("注销PopMenu")
//    }
    
    // MARK: - 接口函数/////////////////////////////////////////////
    
    /// 显示PopMenu（view：添加菜单的页面的 view 对象；fromRect：箭头所指向的矩形；items：菜单项数组；animated：是否动画效果）
    func show(withIN view:UIView,fromRect rect:CGRect,items:[FLMenuItem],animated:Bool = true){
//        if menuView != nil {
//            menuView?.dismissMenu(animated: false)
//            menuView = nil
//        }
        
//        if !isObserving {
//            isObserving = true
//            NotificationCenter.default.addObserver(self, selector: #selector(orientationWillChange), name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
//        }
        
        // 添加menuItems
        addItems(items: items)
        // 调用menuView的函数，显示菜单
        menuView?.showMenuInView(view: view, fromRect: rect,animated:animated)
        self.isShow = true
        
    }
    
    
    
    
    // MARK: - 私有函数///////////////////////////////////////////////
    
    // 向Menu中添加Item
    func addItems (items:[FLMenuItem]) {
        //print("向Menu中添加项目（\(items.count)个项目）")
        // 如果menuView不是nil，说明菜单正在显示，取消之。
        if menuView != nil {
            menuView?.dismissMenu(animated: false)
            menuView = nil
        }
        // 建立新的实例
        menuView = FLMenuView()
        // 添加菜单项
        menuView?.addItems(items: items)
        //print("添加成功")
        //print(menuView?.contentView?.frame)
    }
    

    /// 将PopMenu的各项属性重置为默认值
    class func reset(){
        FLPopMenu.tintColor = gTintColor
        FLPopMenu.shadowColor = gShadowColor
        FLPopMenu.textColor = gTextColor
        FLPopMenu.textFont = UIFont.systemFont(ofSize: gTextFontSize)
        FLPopMenu.alignment = gAlignment
        FLPopMenu.cornerRadius = gCornerRadius
        FLPopMenu.arrowSize = gArrowSize
        FLPopMenu.arrowDirection = gArrowDirection
        FLPopMenu.vMargin = gVMargin
        FLPopMenu.lMargin = gLMargin
        FLPopMenu.backgrounColorEffect = gBackgrounColorEffect
        FLPopMenu.hasShadow = gHasShadow
        FLPopMenu.separatorColor = gSeparatorColor
    }
    
    
    // 清除弹出菜单
    func dismissMenu(animated:Bool = true){
        if menuView != nil {
            menuView?.dismissMenu(animated: animated)
            menuView = nil
        }
        
        self.isShow = false
    }
    
    @objc func performAction(sender:Any?){
        //self.dismissMenu(animated: true)
        // 获取按钮的 target 和 action
        let btn = sender as! UIButton
        let target = menuView?.menuItems[btn.tag].target as AnyObject
        let action = menuView?.menuItems[btn.tag].action
        // 清除弹出菜单
        dismissMenu(animated: false)
        // 如果有相应的处理函数，发送消息
        if  target.responds(to: action) {
            target.performSelector(onMainThread: action!, with: self, waitUntilDone: false)
            //target.perform( action!, with: self)
        }
        
    }
    
    // MARK: - 监听///////////////////////////////////////////////////
    
    /// 监听到横竖屏事件后取消菜单显示
    @objc func orientationWillChange(notification:Notification) {
        dismissMenu(animated: false)
    }
    
    
        
}
