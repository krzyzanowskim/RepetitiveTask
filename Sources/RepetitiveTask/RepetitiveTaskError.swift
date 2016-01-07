import Foundation

public enum RepetitiveTaskError: ErrorType {
    case Failed(NSError)
    case RetryFailed(Int)
    case RetryDelay(Double)
    case NoData

    var isTransient: Bool {
        switch (self) {
        case .RetryDelay:
            return true
        default:
            return false
        }
    }
}