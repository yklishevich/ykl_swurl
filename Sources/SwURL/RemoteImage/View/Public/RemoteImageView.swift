//
//  RemoteImageView.swift
//  Landmarks
//
//  Created by Callum Trounce on 06/06/2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import SwiftUI

public protocol SwURLImageViewType: ImageOutputCustomisable, View {}

public protocol ImageOutputCustomisable {
    func imageProcessing<ProcessedImage: View>(
        _ processing: @escaping (Image) -> ProcessedImage
    ) -> Self
    func progress<T: View>(_ progress: @escaping (CGFloat) -> T) -> Self
}

enum SwURLImageView: SwURLImageViewType {
    case iOS13(iOS13RemoteImageView)
    @available(iOS 14.0, *)
    case iOS14(iOS14RemoteImageView)
    
    init<Base: SwURLImageViewType>(_ base: Base) {
        if let iOS13 = base as? iOS13RemoteImageView {
            self = .iOS13(iOS13)
        } else if
            #available(iOS 14.0, *),
            let iOS14 = base as? iOS14RemoteImageView
        {
            self = .iOS14(iOS14)
        } else {
            fatalError()
        }
    }
    
    func imageProcessing<ProcessedImage>(_ processing: @escaping (Image) -> ProcessedImage) -> Self where ProcessedImage : View {
        switch self {
        case .iOS13(let view):
            return SwURLImageView.iOS13(view.imageProcessing(processing))  
        case .iOS14(let view):
            if #available(iOS 14.0, *)  {
                return SwURLImageView.iOS14(view.imageProcessing(processing))
            } else {
                fatalError()
            }
        }
    }
    
    func progress<T>(_ progress: @escaping (CGFloat) -> T) -> Self where T : View {
        switch self {
        case .iOS13(let view):
            return SwURLImageView.iOS13(view.progress(progress))
        case .iOS14(let view):
            if #available(iOS 14.0, *) {
                return SwURLImageView.iOS14(view.progress(progress))
            } else {
                fatalError()
            }
        }
    }
    
    var body: some View {
        switch self {
        case .iOS13(let view):
            return AnyView(view.body)
        case .iOS14(let view):
            return AnyView(view.body)
        }
    }
}


public func RemoteImageView(
    url: URL,
    placeholderImage: Image? = nil,
    transition: ImageTransitionType = .none
) -> some SwURLImageViewType {
    if #available(iOS 14.0, *) {
        return SwURLImageView(iOS14RemoteImageView(
            url: url,
            placeholderImage: placeholderImage,
            transition: transition
        ))
    } else {
        return SwURLImageView(iOS13RemoteImageView(
            url: url,
            placeholderImage: placeholderImage,
            transition: transition
        ))
    }
}