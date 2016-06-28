//
//  HGAlignment.swift
//  Sneakify
//
//  Created by Anton Doudarev on 12/8/15.
//  Copyright © 2015 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

func CGCSRectGetTopLeft(rect : CGRect) -> CGPoint {
    return CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))
}

func CGCSRectGetBottomLeft(rect : CGRect) -> CGPoint {
    return CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))
}

func CGCSRectGetTopRight(rect : CGRect) -> CGPoint {
    return CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))
}

func CGCSRectGetBottomRight(rect : CGRect) -> CGPoint {
    return CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))
}

func CGCSRectEdgeInset(inputFrame : CGRect, edgeInsets : UIEdgeInsets) -> CGRect {
    var retval :CGRect  = CGRectMake(inputFrame.origin.x + edgeInsets.left, inputFrame.origin.y + edgeInsets.top, 0, 0)
    retval.size.width = CGRectGetWidth(inputFrame) - (edgeInsets.left + edgeInsets.right)
    retval.size.height = CGRectGetHeight(inputFrame) - (edgeInsets.top + edgeInsets.bottom)
    return retval
}

func CGCSRectEdgeOutset(inputFrame : CGRect, edgeInsets : UIEdgeInsets) -> CGRect {
    let invertedEdgeInsets : UIEdgeInsets = UIEdgeInsetsMake(-edgeInsets.top, -edgeInsets.left, -edgeInsets.bottom, -edgeInsets.right)
    return CGCSRectEdgeInset(inputFrame, edgeInsets: invertedEdgeInsets)
}

func CGCSRectCenterInRect(sourceRect : CGRect, destRect : CGRect) -> CGRect {
    var newRect : CGRect = sourceRect
    newRect.origin.x = destRect.origin.x + (destRect.size.width - sourceRect.size.width) / 2.0
    newRect.origin.y = destRect.origin.y + (destRect.size.height - sourceRect.size.height) / 2.0
    return newRect
}

func CGCSPointVerticalCenterBetweenRect(topRect : CGRect, bottomRect : CGRect) -> CGPoint {
    let topCenter : CGPoint = CGCSRectGetCenter(topRect)
    let topBottomY = CGRectGetMaxY(topRect)
    let bottomTopY = CGRectGetMinY(bottomRect)
    return CGPointMake(topCenter.x, topBottomY + (bottomTopY - topBottomY) / 2.0)
}

func CGCSRectAspectFitRatio(inRect : CGRect, maxRect : CGRect) -> CGFloat {
    if (CGRectGetWidth(inRect) == 0 || CGRectGetHeight(inRect) == 0) {
        return 1.0
    }
    
    let horizontalRatio = CGRectGetWidth(maxRect) / CGRectGetWidth(inRect)
    let verticalRatio = CGRectGetHeight(maxRect) / CGRectGetHeight(inRect)
    return (horizontalRatio < verticalRatio ? horizontalRatio : verticalRatio)
}

func CGCSRectAspectFit(inRect : CGRect, maxRect : CGRect) -> CGRect {
    let ratio = CGCSRectAspectFitRatio(inRect, maxRect: maxRect)
    let newSize = CGSizeMake(CGRectGetWidth(inRect) * ratio, CGRectGetHeight(inRect) * ratio)
    
    return CGRectMake((CGRectGetWidth(maxRect) - newSize.width) / 2.0 + maxRect.origin.x,
                      (CGRectGetHeight(maxRect) - newSize.height) / 2.0 + maxRect.origin.y,
                      newSize.width,
                      newSize.height)
}

func CGCSRectAspectFillRatio(inRect : CGRect, maxRect : CGRect) -> CGFloat {
    if CGRectGetWidth(inRect) == 0 || CGRectGetHeight(inRect) == 0 {
        return 1.0
    }
    
    let horizontalRatio = CGRectGetWidth(maxRect) / CGRectGetWidth(inRect)
    let verticalRatio = CGRectGetHeight(maxRect) / CGRectGetHeight(inRect)
    return (horizontalRatio < verticalRatio ? verticalRatio : horizontalRatio)
}

func CGCSRectAspectFill(inRect : CGRect, maxRect : CGRect) -> CGRect {
    let ratio = CGCSRectAspectFillRatio(inRect, maxRect: maxRect)
    let newSize = CGSizeMake(CGRectGetWidth(inRect) * ratio, CGRectGetHeight(inRect) * ratio)
    
    return CGRectMake((CGRectGetWidth(maxRect) - newSize.width) / 2.0 + maxRect.origin.x,
                      (CGRectGetHeight(maxRect) - newSize.height) / 2.0 + maxRect.origin.y,
                      newSize.width,
                      newSize.height)
}

func CGCSRectGetCenter(inRect : CGRect) -> CGPoint {
    return CGPointMake(ceil(inRect.origin.x + inRect.width * 0.5), ceil(inRect.origin.y + inRect.height * 0.5))
}

func alignedHorizontalOriginWithFrame(source : CGRect,  dest : CGRect, align : HGHorizontalAlign) -> CGFloat {
    var origin = source.origin.x
    
    switch (align) {
    case .Left:
        origin = dest.origin.x - source.size.width;
    case .Right:
        origin = CGRectGetMaxX(dest);
    case .Center:
        origin = dest.origin.x + ((dest.size.width - source.size.width) / 2.0);
    case .LeftEdge:
        origin = dest.origin.x;
    case .RightEdge:
        origin = CGRectGetMaxX(dest) - source.size.width;
    }
    return round(origin)
}

func alignedVerticalOriginWithFrame(source : CGRect,  dest : CGRect, align : HGVerticalAlign) -> CGFloat {
    var origin = source.origin.x
    
    switch (align) {
    case .Top:
        origin = dest.origin.y
    case .Base:
        origin = CGRectGetMaxY(dest) - source.size.height
    case .Center:
        origin = dest.origin.y + ((dest.size.height - source.size.height) / 2.0)
    case .Above:
        origin = dest.origin.y - source.size.height
    case .Below:
        origin = CGRectGetMaxY(dest)
    }
    return round(origin)
}

enum HGVerticalAlign {
    case Top
    case Base
    case Center
    case Above
    case Below
}

enum HGHorizontalAlign {
    case Left
    case Right
    case Center
    case RightEdge
    case LeftEdge
}

extension UIView {
    
    func alignToView(otherView : UIView, horizontal:  HGHorizontalAlign, vertical : HGVerticalAlign , horizontalOffset : CGFloat = 0.0, verticalOffset : CGFloat = 0.0) {
        self.alignToFrame(otherView.frame, horizontal : horizontal, vertical : vertical,  horizontalOffset : horizontalOffset, verticalOffset : verticalOffset)
    }
    
    func alignToFrame(otherFrame : CGRect,
                      horizontal       : HGHorizontalAlign,
                      vertical         : HGVerticalAlign,
                      horizontalOffset : CGFloat = 0.0,
                      verticalOffset   : CGFloat = 0.0) {
        
        let x = alignedHorizontalOriginWithFrame(self.frame, dest:otherFrame, align : horizontal)
        let y = alignedVerticalOriginWithFrame(self.frame, dest:otherFrame, align :  vertical)
        
        self.frame = CGRectIntegral(CGRectMake(x + horizontalOffset, y + verticalOffset, self.frame.size.width, self.frame.size.height))
    }
    
    func alignWithSize(newSize : CGSize,
                       toFrame          : CGRect,
                       horizontal       : HGHorizontalAlign,
                       vertical         : HGVerticalAlign,
                       horizontalOffset : CGFloat = 0.0,
                       verticalOffset   : CGFloat = 0.0) {
        
        var  newRect =  CGRectMake(0,0, newSize.width, newSize.height)
        
        newRect.origin.x = alignedHorizontalOriginWithFrame(newRect, dest:toFrame, align : horizontal) + horizontalOffset
        newRect.origin.y = alignedVerticalOriginWithFrame(newRect, dest:toFrame, align :  vertical) + verticalOffset
        
        if CGRectEqualToRect(self.frame, CGRectIntegral(newRect)) == false {
            self.frame = newRect
        }
    }
}

