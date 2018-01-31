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
        let btn = UIButton(frame: CGRect(x: 0, y: 100, width: 100, height: 100))
        btn.backgroundColor = UIColor.brown
        btn.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
        self.view.addSubview(btn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    @IBAction func btnTapped(){
        let popMenu = FLPopMenu.shared
        let btn1 = FLMenuItem(title: "我是一号", target: self, action: #selector(menuTapped))
        let btn2 = FLMenuItem(title: "我是二号,我比较长", target: self, action: #selector(menuTapped))
        
        let btn3 = FLMenuItem(title: "我是三号，我有图标", image: #imageLiteral(resourceName: "Image"), target: self, action: #selector(menuTapped))
        popMenu.addItems(items: [btn1,btn2,btn3])
        print("回到主界面啦！")
        print(popMenu.menuView?.contentView?.frame)
        popMenu.show(withIN: self.view, fromRect:CGRect(x:0,y:500,width:30,height:50))
    }
    
    
    @objc func menuTapped() {
        print("我被点啦！")
    }


}

