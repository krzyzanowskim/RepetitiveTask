import Foundation

public protocol RepetitiveTaskResultProtocol {
    associatedtype SuccessValue
    associatedtype Error

    init (success: SuccessValue)
    init (error: Error)
}

public enum RepetitiveTaskResult<T, Error>: RepetitiveTaskResultProtocol {
    case Success(T)
    case Failure(Error)

    public init(success: T) {
        self = .Success(success)
    }

    public init(error: Error) {
        self = .Failure(error)
    }
}
