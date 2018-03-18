//: Playground - Future

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

typealias Task<A> = (DispatchQueue, @escaping (A) -> ()) -> ()

struct Future<A> {
    
    typealias Task<A> = (DispatchQueue, DispatchGroup, @escaping (A) -> ()) -> ()
    
    let task: Task<A>
    
    static func pure(_ value: A) -> Future<A> {
        let task: Task = { (_, _, continuation) in
            continuation(value)
        }
        
        return Future(task: task)
    }
    
    static func async(_ getValue: @autoclosure @escaping () -> A) -> Future<A> {
        let task: Task = { (queue, group, continuation) in
            queue.async(group: group) {
                continuation(getValue())
            }
        }
        
        return Future(task: task)
    }
    
    func map<B>(_ transform: @escaping (A) -> B) -> Future<B> {
        return self.flatMap { a in
            let task: Task<B> = { (_, _, continuation) in
                continuation(transform(a))
            }
            
            return Future<B>(task: task)
        }
    }
    
    func flatMap<B>(_ transform: @escaping (A) -> Future<B>) -> Future<B> {
        let task: Task<B> = { (queue, group, continuation) in
            self.task(queue, group) { a in
                let futureB = transform(a)
                
                futureB.task(queue, group, continuation)
            }
        }
        
        return Future<B>(task: task)
    }
    
    func apply<B>(_ futureAB: Future<(A) -> B>) -> Future<B> {
        let task: Task<B> = { (queue, _, continuation) in
            let group = DispatchGroup()
            
            var a: A?
            var ab: ((A) -> B)?
            
            self.task(queue, group) { value in
                a = value
            }
            
            futureAB.task(queue, group) { value in
                ab = value
            }
            
            group.wait()
            
            continuation(ab!(a!))
        }
        
        return Future<B>(task: task)
    }
    
    func runAsync(_ queue: DispatchQueue = DispatchQueue.global(), _ continuation: @escaping (A) -> ()) {
        self.task(queue, DispatchGroup(), continuation)
    }
}

infix operator <%>: AdditionPrecedence
infix operator <*>: AdditionPrecedence

func <%><A, B>(_ transform: @escaping (A) -> B, futureA: Future<A>) -> Future<B> {
    return futureA.map(transform)
}

func <*><A, B>(_ curriedFuture: Future<(A) -> B>, futureA: Future<A>) -> Future<B> {
    return futureA.apply(curriedFuture)
}

func >>=<A, B>(_ futureA: Future<A>, transform: @escaping (A) -> Future<B>) -> Future<B> {
    return futureA.flatMap(transform)
}

public func curry<A, B, C, D, E, F>(
    _ fn: @escaping (A, B, C, D, E) -> F) -> (A) -> (B) -> (C) -> (D) -> (E) -> F {
    
    return { a in { b in { c in { d in { e in fn(a, b, c, d, e) } } } } }
}

func parse(from url: String) -> [String: AnyObject] {
    return URL(string: url)
        .flatMap { try! Data(contentsOf: $0) }
        .flatMap { try! JSONSerialization.jsonObject(with: $0) }
        .flatMap { $0 as? [String: AnyObject] }!
}

struct Post {
    let title: String
    let content: String
    let authorId: Int
    
    static func decode(_ json: [String: AnyObject]) -> Post {
        let title = json["title"] as! String
        let content = json["content"] as! String
        let authorId = json["userId"] as! Int
        
        return Post(title: title, content: content, authorId: authorId)
    }
    
    static func get(_ id: Int) -> Future<Post> {
        return Future.async(
            Post.decode(parse(from: "http://functionalHub.com/exercises/posts/\(id)")))
    }
}

struct Author {
    let firstname: String
    let lastName: String
    let lastPostId: Int
    
    static func decode(_ json: [String: AnyObject]) -> Author {
        let firstName = json["firstName"] as! String
        let lastName = json["lastName"] as! String
        let lastPostId = json["lastPost"] as! Int
        
        return Author(firstname: firstName, lastName: lastName, lastPostId: lastPostId)
    }
    
    static func get(_ id: Int) -> Future<Author> {
        return Future.async(
            Author.decode(parse(from: "http://functionalHub.com/exercises/users/\(id)"
        )))
    }
}

func topFive() -> Future<[Int]> {
    return Future.async(parse(from: "http://functionalHub.com/exercises/top-users"))
        .map { json in
            json.map { Int($0.1 as! String)! }
    }
}

func average(first: Int, second: Int, third: Int, fourth: Int, fifth: Int) -> Int {
    return (first + second + third + fourth + fifth) / 5
}

topFive().flatMap { topFive in
    curry(average)
        <%> Author.get(topFive[0]).flatMap { Post.get($0.lastPostId) }.map { $0.content.components(separatedBy: " ").count }
        <*> Author.get(topFive[1]).flatMap { Post.get($0.lastPostId) }.map { $0.content.components(separatedBy: " ").count }
        <*> Author.get(topFive[2]).flatMap { Post.get($0.lastPostId) }.map { $0.content.components(separatedBy: " ").count }
        <*> Author.get(topFive[3]).flatMap { Post.get($0.lastPostId) }.map { $0.content.components(separatedBy: " ").count }
        <*> Author.get(topFive[4]).flatMap { Post.get($0.lastPostId) }.map { $0.content.components(separatedBy: " ").count }
    }.runAsync { average in
        print(average)
}
