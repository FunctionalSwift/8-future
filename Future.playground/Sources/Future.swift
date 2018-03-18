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
    
    public func map2<B, C>( _ futureB: Future<B>, _ transform: @escaping (A, B) -> C) -> Future<C> {
        let task: Task<C> = { (queue, _, continuation) in
            let group = DispatchGroup()
            
            var a: A? = nil
            var b: B? = nil
            
            self.task(queue, group) { value in
                a = value
            }
            
            futureB.task(queue, group) { value in
                b = value
            }
            
            group.wait()
            
            continuation(transform(a!, b!))
        }
        
        return Future<C>(task: task)
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
        return self.map2(futureAB) { (a, transform) in
            transform(a)
        }
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
