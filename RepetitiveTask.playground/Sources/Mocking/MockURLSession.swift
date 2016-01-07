import Cocoa

public class MockURLSession: NSURLSession {
    public typealias MockResponse = () -> (data: NSData?, urlResponse: NSURLResponse?, error: NSError?)
    var completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?
    var mockResponse: MockResponse?

    public convenience init(response: MockResponse) {
        self.init()
        self.mockResponse = response
    }

    public override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        self.completionHandler = completionHandler
        return MockTask(response: mockResponse, completionHandler: completionHandler)
    }

    public override func dataTaskWithURL(url: NSURL, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)?) -> NSURLSessionDataTask {
        self.completionHandler = completionHandler
        return MockTask(response: mockResponse, completionHandler: completionHandler)
    }

    public class MockTask: NSURLSessionDataTask {
        typealias Completion = ((NSData!, NSURLResponse!, NSError!) -> Void)
        var mockResponse: MockResponse?
        let completionHandler: Completion?

        init(response: MockResponse?, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)?) {
            self.mockResponse = response
            self.completionHandler = completionHandler
        }
        
        override public func resume() {
            guard let mockResponse = self.mockResponse else {
                fatalError()
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
                // sleep(1)
                let response = mockResponse()
                self.completionHandler?(response.data, response.urlResponse, response.error)
            }
        }
    }
}