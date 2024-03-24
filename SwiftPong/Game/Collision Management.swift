//
//  Collision Management.swift
//  SwiftPong
//
//  Created by Edon Valdman on 3/23/24.
//

import SpriteKit

extension SKPhysicsContact {
    func involvesCategories(_ category1: CollisionCategory, and category2: CollisionCategory) -> Bool {
        return bodyA.category.contains(category1) && bodyB.category.contains(category2)
            || bodyA.category.contains(category2) && bodyB.category.contains(category1)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        print("[didBegin] Body A:", contact.bodyA.node?.name ?? "")
        print("[didBegin] Body B:", contact.bodyB.node?.name ?? "")
    }
}

struct CollisionCategory: OptionSet, Hashable {
    var rawValue: UInt32
    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    static let gameBoard = Self.init(rawValue: 1 << 0)
    static let enclosingWall = Self.init(rawValue: 1 << 1)
    static let ball = Self.init(rawValue: 1 << 2)
    static let paddle = Self.init(rawValue: 1 << 3)
}

extension SKPhysicsBody {
    /// A mask that defines which categories this physics body belongs to.
    var category: CollisionCategory {
        get {
            .init(rawValue: categoryBitMask)
        } set {
            categoryBitMask = newValue.rawValue
        }
    }
    
    /// A mask that defines which categories of physics bodies can collide with this physics body.
    var collisionCategories: CollisionCategory {
        get {
            .init(rawValue: collisionBitMask)
        } set {
            collisionBitMask = newValue.rawValue
        }
    }
    
    /// A mask that defines which categories of physics bodies cause intersection notifications with this physics body.
    var contactTestCategories: CollisionCategory {
        get {
            .init(rawValue: contactTestBitMask)
        } set {
            contactTestBitMask = newValue.rawValue
        }
    }
}
