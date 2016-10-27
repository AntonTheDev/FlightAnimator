//
//  HGAlignment.swift
//  Sneakify
//
//  Created by Anton Doudarev on 12/8/15.
//  Copyright © 2015 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

func CGCSRectGetTopLeft(_ rect : CGRect) -> CGPoint {
    return CGPoint(x: rect.minX, y: rect.minY)
}

func CGCSRectGetBottomLeft(_ rect : CGRect) -> CGPoint {
    return CGPoint(x: rect.minX, y: rect.maxY)
}

func CGCSRectGetTopRight(_ rect : CGRect) -> CGPoint {
    return CGPoint(x: rect.maxX, y: rect.minY)
}

func CGCSRectGetBottomRight(_ rect : CGRect) -> CGPoint {
    return CGPoint(x: rect.maxX, y: rect.maxY)
}

func CGCSRectEdgeInset(_ inputFrame : CGRect, edgeInsets : UIEdgeInsets) -> CGRect {
    var retval :CGRect  = CGRect(x: inputFrame.origin.x + edgeInsets.left, y: inputFrame.origin.y + edgeInsets.top, width: 0, height: 0)
    retval.size.width = inputFrame.width - (edgeInsets.left + edgeInsets.right)
    retval.size.height = inputFrame.height - (edgeInsets.top + edgeInsets.bottom)
    return retval
}

func CGCSRectEdgeOutset(_ inputFrame : CGRect, edgeInsets : UIEdgeInsets) -> CGRect {
    let invertedEdgeInsets : UIEdgeInsets = UIEdgeInsetsMake(-edgeInsets.top, -edgeInsets.left, -edgeInsets.bottom, -edgeInsets.right)
    return CGCSRectEdgeInset(inputFrame, edgeInsets: invertedEdgeInsets)
}

func CGCSRectCenterInRect(_ sourceRect : CGRect, destRect : CGRect) -> CGRect {
    var newRect : CGRect = sourceRect
    newRect.origin.x = destRect.origin.x + (destRect.size.width - sourceRect.size.width) / 2.0
    newRect.origin.y = destRect.origin.y + (destRect.size.height - sourceRect.size.height) / 2.0
    return newRect
}

func CGCSPointVerticalCenterBetweenRect(_ topRect : CGRect, bottomRect : CGRect) -> CGPoint {
    let topCenter : CGPoint = CGCSRectGetCenter(topRect)
    let topBottomY = topRect.maxY
    let bottomTopY = bottomRect.minY
    return CGPoint(x: topCenter.x, y: topBottomY + (bottomTopY - topBottomY) / 2.0)
}

func CGCSRectAspectFitRatio(_ inRect : CGRect, maxRect : CGRect) -> CGFloat {
    if (inRect.width == 0 || inRect.height == 0) {
        return 1.0
    }
    
    let horizontalRatio = maxRect.width / inRect.width
    let verticalRatio = maxRect.height / inRect.height
    return (horizontalRatio < verticalRatio ? horizontalRatio : verticalRatio)
}

func CGCSRectAspectFit(_ inRect : CGRect, maxRect : CGRect) -> CGRect {
    let ratio = CGCSRectAspectFitRatio(inRect, maxRect: maxRect)
    let newSize = CGSize(width: inRect.width * ratio, height: inRect.height * ratio)
    
    return CGRect(x: (maxRect.width - newSize.width) / 2.0 + maxRect.origin.x,
                      y: (maxRect.height - newSize.height) / 2.0 + maxRect.origin.y,
                      width: newSize.width,
                      height: newSize.height)
}

func CGCSRectAspectFillRatio(_ inRect : CGRect, maxRect : CGRect) -> CGFloat {
    if inRect.width == 0 || inRect.height == 0 {
        return 1.0
    }
    
    let horizontalRatio = maxRect.width / inRect.width
    let verticalRatio = maxRect.height / inRect.height
    return (horizontalRatio < verticalRatio ? verticalRatio : horizontalRatio)
}

func CGCSRectAspectFill(_ inRect : CGRect, maxRect : CGRect) -> CGRect {
    let ratio = CGCSRectAspectFillRatio(inRect, maxRect: maxRect)
    let newSize = CGSize(width: inRect.width * ratio, height: inRect.height * ratio)
    
    return CGRect(x: (maxRect.width - newSize.width) / 2.0 + maxRect.origin.x,
                      y: (maxRect.height - newSize.height) / 2.0 + maxRect.origin.y,
                      width: newSize.width,
                      height: newSize.height)
}

func CGCSRectGetCenter(_ inRect : CGRect) -> CGPoint {
    return CGPoint(x: ceil(inRect.origin.x + inRect.width * 0.5), y: ceil(inRect.origin.y + inRect.height * 0.5))
}

func alignedHorizontalOriginWithFrame(_ source : CGRect,  dest : CGRect, align : HGHorizontalAlign) -> CGFloat {
    var origin = source.origin.x
    
    switch (align) {
    case .left:
        origin = dest.origin.x - source.size.width;
    case .right:
        origin = dest.maxX;
    case .center:
        origin = dest.origin.x + ((dest.size.width - source.size.width) / 2.0);
    case .leftEdge:
        origin = dest.origin.x;
    case .rightEdge:
        origin = dest.maxX - source.size.width;
    }
    return round(origin)
}

func alignedVerticalOriginWithFrame(_ source : CGRect,  dest : CGRect, align : HGVerticalAlign) -> CGFloat {
    var origin = source.origin.x
    
    switch (align) {
    case .top:
        origin = dest.origin.y
    case .base:
        origin = dest.maxY - source.size.height
    case .center:
        origin = dest.origin.y + ((dest.size.height - source.size.height) / 2.0)
    case .above:
        origin = dest.origin.y - source.size.height
    case .below:
        origin = dest.maxY
    }
    return round(origin)
}

enum HGVerticalAlign {
    case top
    case base
    case center
    case above
    case below
}

enum HGHorizontalAlign {
    case left
    case right
    case center
    case rightEdge
    case leftEdge
}

extension UIView {
    
    func alignToView(_ otherView : UIView, horizontal:  HGHorizontalAlign, vertical : HGVerticalAlign , horizontalOffset : CGFloat = 0.0, verticalOffset : CGFloat = 0.0) {
        self.alignToFrame(otherView.frame, horizontal : horizontal, vertical : vertical,  horizontalOffset : horizontalOffset, verticalOffset : verticalOffset)
    }
    
    func alignToFrame(_ otherFrame : CGRect,
                      horizontal       : HGHorizontalAlign,
                      vertical         : HGVerticalAlign,
                      horizontalOffset : CGFloat = 0.0,
                      verticalOffset   : CGFloat = 0.0) {
        
        let x = alignedHorizontalOriginWithFrame(self.frame, dest:otherFrame, align : horizontal)
        let y = alignedVerticalOriginWithFrame(self.frame, dest:otherFrame, align :  vertical)
        
        self.frame = CGRect(x: x + horizontalOffset, y: y + verticalOffset, width: self.frame.size.width, height: self.frame.size.height).integral
    }
    
    func alignWithSize(_ newSize : CGSize,
                       toFrame          : CGRect,
                       horizontal       : HGHorizontalAlign,
                       vertical         : HGVerticalAlign,
                       horizontalOffset : CGFloat = 0.0,
                       verticalOffset   : CGFloat = 0.0) {
        
        var  newRect =  CGRect(x: 0,y: 0, width: newSize.width, height: newSize.height)
        
        newRect.origin.x = alignedHorizontalOriginWithFrame(newRect, dest:toFrame, align : horizontal) + horizontalOffset
        newRect.origin.y = alignedVerticalOriginWithFrame(newRect, dest:toFrame, align :  vertical) + verticalOffset
        
        if self.frame.equalTo(newRect.integral) == false {
            self.frame = newRect
        }
    }
}

