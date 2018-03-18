//: Playground - Future

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct Future<A> {
    
    let task: (@escaping (A) -> ()) -> ()
    
    static func async(_ getValue: @escaping () -> A) -> Future<A> {
        let task: (@escaping (A) -> ()) -> () = { continuation in
            DispatchQueue.global().async {
                continuation(getValue())
            }
        }
        
        return Future(task: task)
    }
}
