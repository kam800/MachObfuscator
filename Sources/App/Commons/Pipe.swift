import Foundation

precedencegroup ForwardApplication {
    associativity: left
}

infix operator |>: ForwardApplication

func |> <T, U>(value: T, function: (T) -> U) -> U {
    return function(value)
}
