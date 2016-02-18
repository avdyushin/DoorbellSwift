# DoorbellSwift
Simple Doorbell.io client in Swift

Usage:

```
  let doorbell = Doorbell(applicationId: "YOUR_APP_ID", apiKey: "YOUR_API_KEY")
  doorbell.submit("user@email.com", message: "Feedback message") { data, error in
            if let error = error {
                // Error
            } else {
                // Success
            }
        }
```
