//: Playground - Future

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct Future {
    let task: () -> ()
}

let getNumber = {
    return 23 + 26
}

let task: () -> () = {
    getNumber()
}

Future(task: task)
