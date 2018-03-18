import Foundation

public typealias Task<A> = (DispatchQueue, DispatchGroup, @escaping (A) -> ()) -> ()

public struct Future<A> {
    
    public let task: Task<A>
    
    public static func pure(_ value: A) -> Future<A> {
        let task: Task = { (_, _, continuation) in
            continuation(value)
        }
        
        return Future(task: task)
    }
    
    public static func async(_ getValue: @autoclosure @escaping () -> A) -> Future<A> {
        let task: Task = { (queue, group, continuation) in
            queue.async(group: group) {
                continuation(getValue())
            }
        }
        
        return Future(task: task)
    }
    
    public func map<B>(_ transform: @escaping (A) -> B) -> Future<B> {
        return self.flatMap { a in
            let task: Task<B> = { (_, _, continuation) in
                continuation(transform(a))
            }
            
            return Future<B>(task: task)
        }
    }
    
    public func flatMap<B>(_ transform: @escaping (A) -> Future<B>) -> Future<B> {
        let task: Task<B> = { (queue, group, continuation) in
            self.task(queue, group) { a in
                let futureB = transform(a)
                
                futureB.task(queue, group, continuation)
            }
        }
        
        return Future<B>(task: task)
    }
    
    public func apply<B>(_ futureAB: Future<(A) -> B>) -> Future<B> {
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
    
    public func runAsync(_ queue: DispatchQueue = DispatchQueue.global(), _ continuation: @escaping (A) -> ()) {
        self.task(queue, DispatchGroup(), continuation)
    }
    
    public func runSync() -> A {
        let queue = DispatchQueue.global()
        let group = DispatchGroup()
        
        var a: A?
        
        self.task(queue, group) { value in
            a = value
        }
        
        group.wait()
        
        return a!
    }
}
