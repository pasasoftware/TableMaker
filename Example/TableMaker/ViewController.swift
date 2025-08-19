//
//  ViewController.swift
//  TableMaker
//
//  Created by guanping.cai on 03/05/2019.
//  Copyright (c) 2019 guanping.cai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let people = People()
        let controller = PeopleViewController(people)
        
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true)
    }

}

