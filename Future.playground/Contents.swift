//: Playground - Future

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct Future<A> {
    let task: ((A) -> ()) -> ()
}

let getNumber = {
    return 23 + 26
}

let task: ((Int) -> ()) -> () = { continuation in
    continuation(getNumber())
}

Future(task: task)
