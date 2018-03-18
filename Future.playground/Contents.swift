//: Playground - Future

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct Future<A> {
    
    let task: (DispatchQueue, @escaping (A) -> ()) -> ()
    
    static func async(_ getValue: @escaping () -> A) -> Future<A> {
        let task: (DispatchQueue, @escaping (A) -> ()) -> () = { (queue, continuation) in
            queue.async {
                continuation(getValue())
            }
        }
        
        return Future(task: task)
    }
}
