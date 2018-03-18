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

Future.async({ 23 + 19 })
    .map { $0 + 3 }
    .runAsync { number in
        print(number)
}
