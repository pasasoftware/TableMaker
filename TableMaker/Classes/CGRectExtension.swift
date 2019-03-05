//
//  CGRectExtension.swift
//  TableMaker
//
//  Created by pasasoft_mini on 2018/5/10.
//  Copyright © 2018年 Andrew Chai. All rights reserved.
//

import UIKit
import Foundation

extension CGRect{
     var x:CGFloat{
        set{
            origin.x = newValue
        }
        get{
            return origin.x
        }
    }
    
    var y:CGFloat{
        set{
            origin.y = newValue
        }
        get{
            return origin.y
        }
    }
    
    var width:CGFloat{
        set{
            size.width = newValue
        }
        get{
            return size.width
        }
    }
    
    var height:CGFloat{
        set{
            size.height = newValue
        }
        get{
            return size.height
        }
    }
    
    var left:CGFloat{
        return x
    }
    
    var right:CGFloat{
        return x + width
    }
    
    var top:CGFloat{
        return y
    }
    
    var bottom:CGFloat{
        return y + height
    }
    
}
