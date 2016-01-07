import Foundation

// MARK: - RepetitiveTaskProtocol

public typealias RepetitiveTaskProtocolCompletion = (RepetitiveTaskResult<NSData, RepetitiveTaskError>) -> Void

public protocol RepetitiveTaskProtocol {
    func run(completion: RepetitiveTaskProtocolCompletion) -> Void
}

public extension RepetitiveTaskProtocol {
    public func run(retryCount retryCount: Int, failure: (ErrorType) -> Void, success: (NSData) -> Void) {
        var operation = RequestWithRetry(retryCount: retryCount, failure: failure, success: success)
        operation.run(self)
    }
}

// MARK: - RequestWithRetry

private struct RequestWithRetry {
    private let retryCount: Int
    var currentRetry = 0
    private let failureCallback: (ErrorType) -> Void
    private let successCallback: (NSData) -> Void

    init(retryCount: Int, failure: (ErrorType) -> Void , success: (NSData) -> Void) {
        self.retryCount = retryCount
        self.failureCallback = failure
        self.successCallback = success
    }

    mutating func run(transientTask: RepetitiveTaskProtocol) {
        transientTask.run { (RepetitiveTaskResult) -> Void in
            switch (RepetitiveTaskResult) {
            case .Success(let value):
                self.successCallback(value)
            case .Failure(let error):
                // handle errors with retry or finish
                if !error.isTransient {
                    self.failureCallback(error)
                } else if (++self.currentRetry > self.retryCount) {
                    self.failureCallback(RepetitiveTaskError.RetryFailed(self.currentRetry))
                } else {
                    print("retry!")
                    self.run(transientTask)
                }
            }
        }
    }
}