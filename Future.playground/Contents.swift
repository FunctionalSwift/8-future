//: Playground - Future

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct Future {
    let task: () -> ()
}

let task: () -> () = {
    
}

Future(task: task)
