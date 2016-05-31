//
//  TextRendering.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

import Silica

// MARK: - Methods

public extension String {
    
    func render(in context: Silica.Context, with attributes: TextAttributes = TextAttributes()) {
        
        
    }
}

// MARK: - Supporting Types

public struct TextAttributes {
    
    public init() { }
    
    public var paragraphStyle = ParagraphStyle()
    
    
}

public struct ParagraphStyle {
    
    public init() { }
    
    public var alignment = TextAlignment()
}

public enum TextAlignment {
    
    public init() { self = .left }
    
    case left
    case lenter
    case right
}