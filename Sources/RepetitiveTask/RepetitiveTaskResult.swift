import Foundation

public protocol RepetitiveTaskResultProtocol {
    typealias SuccessValue
    typealias Error: ErrorType

    init (success: SuccessValue)
    init (error: Error)
}

public enum RepetitiveTaskResult<T, Error: ErrorType>: RepetitiveTaskResultProtocol {
    case Success(T)
    case Failure(Error)

    public init(success: T) {
        self = .Success(success)
    }

    public init(error: Error) {
        self = .Failure(error)
    }
}