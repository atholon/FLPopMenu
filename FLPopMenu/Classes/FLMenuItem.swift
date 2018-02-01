//
//  FLMenuItem.swift
//  FLPopMenu
//
//  Created by Atholon on 2018/1/25.
//  Copyright © 2018年 Atholon. All rights reserved.
//

//import Foundation
import UIKit




class FLMenuItem:NSObject{
    // 左侧图标
    var image:UIImage?
    // 按钮文字
    var title = ""
    // 按钮索引
    //var tag:Int?
    // 字体
    //var titleFont:UIFont = UIFont.systemFont(ofSize: gTitleFontSize)
    
    // 文字颜色
    //var textColor:UIColor = gTextColor
    // 是否可用
    var isEnable:Bool = true
    // 执行目标
    var target:Any?
    //
    var action:Selector?
    
    
    
    // MARK: - 构造，析构函数/////////////////////////////////////////////////////////////
    init(title:String,target:Any?,action:Selector?){
        super.init()
        self.title = title
        self.target = target
        self.action = action
    }
    
    init(title:String,image:UIImage,target:AnyObject?,action:Selector?){
        super.init()
        self.title = title
        self.image = image
        self.target = target
        self.action = action
    }
    
    deinit{
        print("菜单项：“\(self.title)”被注销！")
    }
    
    
    // MARK: - 接口函数
    
    // 发送菜单指令
//    func performAction() {
//        //let target = self.target
//        if target != nil && target!.responds(to:action) {
//            target?.performSelector(onMainThread: action!, with: self, waitUntilDone: true)
//        }
//    }
    
    
}


