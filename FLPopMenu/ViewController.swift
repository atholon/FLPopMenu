//
//  ViewController.swift
//  FLPopMenu
//
//  Created by Atholon on 2018/1/25.
//  Copyright © 2018年 Atholon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
//        let btn = UIButton(frame: CGRect(x: 0, y: 100, width: 100, height: 100))
//        btn.backgroundColor = UIColor.brown
//        btn.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
//        self.view.addSubview(btn)
        self.navigationController?.setToolbarHidden(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    @IBAction func btnTapped(sender:Any?){
        let popMenu = FLPopMenu.shared
        let btn1 = FLMenuItem(title: "我是一号", target: self, action: #selector(menu1Tapped))
        let btn2 = FLMenuItem(title: "我是二号,我比较长", target: self, action: #selector(menu2Tapped))
        
        let btn3 = FLMenuItem(title: "我是三号，我有图标", image: #imageLiteral(resourceName: "Image"), target: self, action: #selector(menu3Tapped))
        
        
        print("回到主界面啦！")
        print(popMenu.menuView?.contentView?.frame)
        let btn = sender as! UIButton
        popMenu.show(withIN: self.view, fromRect:btn.frame,items: [btn1,btn2,btn3])
        
        //测试动画
//        let labBase = UIView(frame: CGRect(x: 50, y: 50, width: 100, height: 30))
//        labBase.backgroundColor = UIColor.darkGray
//        let lab = UILabel(frame: CGRect(x: 10, y: 0, width: 80, height: 30))
//        lab.backgroundColor = UIColor.lightGray
//        lab.font = UIFont.systemFont(ofSize: 12)
//        lab.text = "我能变形！"
//        labBase.addSubview(lab)
//        self.view.addSubview(labBase)
//        UIView.animate(withDuration: 5, animations: {
//                labBase.transform = CGAffineTransform(a: 2, b: 0, c: 0, d: 2, tx: 0, ty: 0)
//            }, completion: nil)
        
    }
    
    @IBAction func btnLUTapped(sender:Any?){
        let popMenu = FLPopMenu.shared
        let btn1 = FLMenuItem(title: "我是一号", target: self, action: #selector(menu1Tapped))
        let btn2 = FLMenuItem(title: "我是二号,我比较长", target: self, action: #selector(menu2Tapped))
        
        let btn3 = FLMenuItem(title: "我是三号，我有图标", image: #imageLiteral(resourceName: "Image"), target: self, action: #selector(menu3Tapped))
        FLPopMenu.arrowDirection = .left
        FLPopMenu.tintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        print("回到主界面啦！")
        print(popMenu.menuView?.contentView?.frame)
        let btn = sender as! UIButton
        
        popMenu.show(withIN: self.view, fromRect:btn.frame,items: [btn1,btn2,btn3])
        
    }
    
    @IBAction func btnRUTapped(sender:Any?){
        let popMenu = FLPopMenu.shared
        let btn1 = FLMenuItem(title: "我是一号", target: self, action: #selector(menu1Tapped))
        let btn2 = FLMenuItem(title: "我是二号,我比较长", target: self, action: #selector(menu2Tapped))
        
        let btn3 = FLMenuItem(title: "我是三号，我有图标", image: #imageLiteral(resourceName: "Image"), target: self, action: #selector(menu3Tapped))
        FLPopMenu.arrowDirection = .up
        FLPopMenu.textColor = UIColor.red
        
        print("回到主界面啦！")
        print(popMenu.menuView?.contentView?.frame)
        let btn = sender as! UIButton
        popMenu.show(withIN: self.view, fromRect:btn.frame,items: [btn1,btn2,btn3])
        
    }
    
    @IBAction func btnRDTapped(sender:Any?){
        let popMenu = FLPopMenu.shared
        let btn1 = FLMenuItem(title: "我是一号", target: self, action: #selector(menu1Tapped))
        let btn2 = FLMenuItem(title: "我是二号,我比较长", target: self, action: #selector(menu2Tapped))
        
        let btn3 = FLMenuItem(title: "我是三号，我有图标", image: #imageLiteral(resourceName: "Image"), target: self, action: #selector(menu3Tapped))
        FLPopMenu.arrowDirection = .right
        FLPopMenu.backgrounColorEffect = .Gradient
        
        print("回到主界面啦！")
        print(popMenu.menuView?.contentView?.frame)
        let btn = sender as! UIButton
        popMenu.show(withIN: self.view, fromRect:btn.frame,items: [btn1,btn2,btn3])
        
    }
    
    @IBAction func btnCTapped(sender:Any?){
        let popMenu = FLPopMenu.shared
        let btn1 = FLMenuItem(title: "我是一号", target: self, action: #selector(menu1Tapped))
        let btn2 = FLMenuItem(title: "我是二号,我比较长", target: self, action: #selector(menu2Tapped))
        
        let btn3 = FLMenuItem(title: "我是三号，我有图标", image: #imageLiteral(resourceName: "Image"), target: self, action: #selector(menu3Tapped))
        FLPopMenu.arrowDirection = .none
        FLPopMenu.textFont = UIFont.systemFont(ofSize: 20)
        
        print("回到主界面啦！")
        print(popMenu.menuView?.contentView?.frame)
        let btn = sender as! UIButton
        popMenu.show(withIN: self.view, fromRect:btn.frame,items: [btn1,btn2,btn3])
        
    }
    
    
    @objc func menu1Tapped() {
        print("一号被点啦！")
    }
    
    @objc func menu2Tapped() {
        print("二号被点啦！")
    }
    
    @objc func menu3Tapped() {
        print("三号被点啦！")
    }


}

