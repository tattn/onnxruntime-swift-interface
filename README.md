# onnxruntime-swift-interface

Swift interface for ONNX Runtime to enable machine learning inference on Apple platforms.

**Important**: This package provides only the interfaces. You must obtain the ONNX Runtime core library from [microsoft/onnxruntime](https://github.com/microsoft/onnxruntime) and link it to your app.

## Usage

```swift
import onnxruntime_swift_interface

let environment = try ORTEnvironment(loggingLevel: .warning)
let session = try ORTSession(
    environment: environment,
    modelPath: "path/to/model.onnx",
    sessionOptions: nil
)

let inputTensor = try ORTValue(data: inputData, shape: [1, 224, 224, 3])
let outputs = try session.run(
    inputs: ["input": inputTensor],
    outputNames: ["output"]
)
```

## License

This project follows the same license as ONNX Runtime. See [ONNX Runtime License](https://github.com/microsoft/onnxruntime/blob/main/LICENSE).
