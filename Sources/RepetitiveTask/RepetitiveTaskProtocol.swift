import Foundation

// MARK: - RepetitiveTaskProtocol

public typealias RepetitiveTaskProtocolCompletion = (RepetitiveTaskResult<Data, RepetitiveTaskError>) -> Void

public protocol RepetitiveTaskProtocol {
    func run(completion: RepetitiveTaskProtocolCompletion) -> Void
}

public extension RepetitiveTaskProtocol {
    public func run(retryCount: Int, failure: @escaping (Error) -> Void, success: @escaping (Data) -> Void) {
        var operation = RequestWithRetry(retryCount: retryCount, failure: failure, success: success)
        operation.run(transientTask: self)
    }
}

// MARK: - RequestWithRetry

private struct RequestWithRetry {
    private let retryCount: Int
    var currentRetry = 0
    private let failureCallback: (Error) -> Void
    private let successCallback: (Data) -> Void
    
    init(retryCount: Int, failure: @escaping (Error) -> Void , success: @escaping (Data) -> Void) {
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
                } else if ((self.currentRetry + 1) > self.retryCount) {
                    self.currentRetry += 1
                    self.failureCallback(RepetitiveTaskError.RetryFailed(self.currentRetry))
                } else {
                    print("retry!")
                    self.run(transientTask: transientTask)
                }
            }
        }
    }
}
