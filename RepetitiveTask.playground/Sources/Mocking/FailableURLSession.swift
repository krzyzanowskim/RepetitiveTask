import Cocoa

// Requests fails randomly
public class FailableURLSession: MockURLSession {
    public convenience init(responseData: NSData) {
        self.init()

        self.mockResponse = { () -> (data: NSData?, urlResponse: NSURLResponse?, error: NSError?) in
            if arc4random_uniform(5) % 2 == 0 {
                let retryError = NSError(domain: "FailableURLSession", code: 0, userInfo: ["ErrorRetryDelayKey": UInt(arc4random_uniform(3) + 1) as NSNumber])
                return (nil, nil, retryError)
            } else if arc4random_uniform(10) % 2 == 0 {
                let retryError = NSError(domain: "FailableURLSession", code: 0, userInfo: nil)
                return (nil, nil, retryError)
            }
            return (responseData, nil, nil)
        }
    }
}