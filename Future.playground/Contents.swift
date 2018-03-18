//: Playground - Future

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct Future<A> {
    let task: (@escaping (A) -> ()) -> ()
}

let getNumber = {
    return 23 + 26
}

let task: (@escaping (Int) -> ()) -> () = { continuation in
    DispatchQueue.global().async {
        continuation(getNumber())
    }
}

Future(task: task)
