import Foundation

public enum RepetitiveTaskError: Error {
    case Failed(Error)
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
