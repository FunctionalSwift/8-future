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
}
