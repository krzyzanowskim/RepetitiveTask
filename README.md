# RepetitiveTask
Implementation of Retry pattern in Swift for iOS/OSX.

### Definition of repetitive task

HTTP request with retry:

```swift
struct FailableTransientURLTask: RepetitiveTaskProtocol  {
    private var session: NSURLSession?
    private var url: NSURL
    private var archivedParameters: NSData

    /// Input parameters for the Task. This should be adjusted for the actual Task
    /// For this example required input is in parameters
    init(session: NSURLSession, url: NSURL, parameters: NSCoding) {
        self.session = session
        self.url = url
        self.archivedParameters = NSKeyedArchiver.archivedDataWithRootObject(parameters)
    }

    /// Run the request
    func run(completion: RepetitiveTaskProtocolCompletion) {
        guard let parameters = NSKeyedUnarchiver.unarchiveObjectWithData(self.archivedParameters), httpBody = try? NSJSONSerialization.dataWithJSONObject(parameters, options: []) else
        {
            fatalError("Missing parameters")
        }

        let request = NSMutableURLRequest(URL: self.url)
        request.HTTPBody = httpBody

        let sessionURLTask = session?.dataTaskWithRequest(request) { (data, response, error) in
            // success and error handling
            if let data = data {
                completion(RepetitiveTaskResult(success: data))
            } else if let error = error {
                // check if error is transient or final and throw right error
                if let delay = error.userInfo["ErrorRetryDelayKey"] as? NSNumber {
                    // request failed and can be retry later
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay.doubleValue * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                        completion(RepetitiveTaskResult(error: RepetitiveTaskError.RetryDelay(delay.doubleValue)))
                    })
                } else {
                    // request failed for other reason
                    completion(RepetitiveTaskResult(error: RepetitiveTaskError.Failed(error)))
                }
            } else {
                // no data received scenario
                completion(RepetitiveTaskResult(error: RepetitiveTaskError.NoData))
            }
        }

        sessionURLTask?.resume()
    }
}
```

###usage

```swift
let task = FailableTransientURLTask(session: NSURLSession.sharedSession(), url: NSURL(string: "http://blog.krzyzanowskim.com/rss")!, parameters: ["foo": "bar"])

//: Run task maximum 3 times hoping for success

task.run(retryCount: 3,
         failure: { (error) -> Void in
             print("failure \(error)")
         },
         success: { (data) -> Void in
             print("success \(data)")
         })
```