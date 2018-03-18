//: Playground - Future

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

typealias Task<A> = (DispatchQueue, @escaping (A) -> ()) -> ()

struct Future<A> {
    
    let task: Task<A>
    
    static func async(_ getValue: @escaping () -> A) -> Future<A> {
        let task: Task = { (queue, continuation) in
            queue.async {
                continuation(getValue())
            }
        }
        
        return Future(task: task)
    }
    
    func runAsync(_ queue: DispatchQueue = DispatchQueue.global(), _ continuation: @escaping (A) -> ()) {
        self.task(queue, continuation)
    }
    
    func map<B>(_ transform: @escaping (A) -> B) -> Future<B> {
        return self.flatMap { a in
            let task: Task<B> = { (queue, continuation) in
                continuation(transform(a))
            }
            
            return Future<B>(task: task)
        }
    }
    
    func flatMap<B>(_ transform: @escaping (A) -> Future<B>) -> Future<B> {
        let task: Task<B> = { (queue, continuation) in
            self.task(queue) { a in
                let futureB = transform(a)
                
                futureB.task(queue, continuation)
            }
        }
        
        return Future<B>(task: task)
    }
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
        return Future.async {
            let json = parse(from: "http://functionalhub.com/exercises/posts/\(id)"
            )
            
            return Post.decode(json)
        }
    }
}

struct Author {
    let firstname: String
    let lastName: String
    
    static func decode(_ json: [String: AnyObject]) -> Author {
        let firstName = json["firstName"] as! String
        let lastName = json["lastName"] as! String
        
        return Author(firstname: firstName, lastName: lastName)
    }
    
    static func get(_ id: Int) -> Future<Author> {
        return Future.async {
            let json = parse(from: "http://functionalhub.com/exercises/users/\(id)"
            )
            
            return Author.decode(json)
        }
    }
}

