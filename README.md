# iOS-Network-Layer

This library provides the AFDataTransferServiceCombine and AFDataTransferService which are a subclasses of DataTransferService used for perfoming decoding and encoding tasks.
Both AFDataTransferServiceCombine and AFDataTransferService are built on top of Alamofire framework, allowing the user to perform network requests with support for Combine publishers, and async/await feature.

# Decoding

1. Endpoint is a generic class that takes a type parameter R, which is the response type.
2. Endpoint conforms to the ResponseRequestable protocol, which defines an associated type Response and a property responseDecoder of type ResponseDecoder.
3. ResponseDecoder is a protocol that defines a method decode to decode data into a specified type.
4. The Endpoint class has a property responseDecoder of type ResponseDecoder, which is initialized with a JSONResponseDecoder by default, but can also be initialized with a keyPath for JSON decoding.
5. To use an Endpoint, you need to create an instance of it and set its properties such as path, method, headerParameters, queryParameters, bodyParameters and the returning type R. Endpoint<R>
6. When you call the request function on the Endpoint, it sends a network request with the specified parameters and returns a Publisher.
7. The request function internally calls the networkService.request function, which takes an Endpoint as a parameter.
8. The networkService.request function converts the Endpoint into a URLRequest and returns a Publisher with the response data.
9. The response data is then decoded using the decode function, which takes the response data and the responseDecoder property of the Endpoint.
10. The decode function internally calls the decode method of the responseDecoder to decode the response data into the specified type.
11. Finally, the decoded response data is returned as a Publisher with the specified type.

Sample: 
```swift
    func checkKeyPaths() -> AnyPublisher<[Movie2DTO], DataTransferError> {
        let endpoint = Endpoint<[Movie2DTO]>(
            path: "3/movie/popular",
            method: .get,
            queryParameters: ["language": "en"],
            keyPath: "results")
        return dataTransferService.download(endpoint)            
    }  
```
```swift     
    func checkList() async throws -> CheckListDTO {
        let endpoint = Endpoint<CheckListDTO>(
            path: "3/genre/movie/list",
            method: .get, 
            queryParameters: ["language": "en"])   
        return try await dataTransferService.request(endpoint)
    }     
```

# Public Methods

### DataTransferService:
```swift
decode<T: Decodable>(data: Data, decoder: ResponseDecoder) throws -> T
```
This method takes in a Data instance and a ResponseDecoder instance, and returns a decoded object of type T. The decoder argument is responsible for decoding the Data instance into an object of type T.
```swift
encode<E: Encodable>(_ value: E, encoder: DataEncoder) throws -> Data
```
This method takes in an instance of type E that conforms to the Encodable protocol and a DataEncoder instance, and returns a Data instance that represents the encoded object. The encoder argument is responsible for encoding the object of type E into a Data instance.

### AFDataTransferServiceCombine:
```swift
request<T, E>(_ endpoint: E) -> AnyPublisher<T, DataTransferError>
```
This method takes in an endpoint conforming to ResponseRequestable protocol, performs a network request using Alamofire, and returns a publisher that emits the response object of type T or an error of type DataTransferError.
```swift
download<T, E>(_ endpoint: E) -> AnyPublisher<T, DataTransferError>
```
This method takes in an endpoint conforming to ResponseRequestable protocol, performs a network download request using Alamofire, and returns a publisher that emits the response object of type T or an error of type DataTransferError.
```swift
upload(_ value: String, url: URL) -> AnyPublisher<Progress, DataTransferError>
```
This method takes in a String and a URL instance, encodes the string using JSONEncoderData and uploads it to the specified URL. It returns a publisher that emits the upload progress or an error of type DataTransferError.
```swift
upload(multipartFormData: @escaping (MultipartFormData) -> Void, to url: URL) -> AnyPublisher<Progress, DataTransferError>
```
This method takes in a closure that provides a MultipartFormData instance to append data to, and a URL instance to upload the data to. It returns a publisher that emits the upload progress or an error of type DataTransferError.

### AFDataTransferService:
```swift
request<T, E>(_ endpoint: E) async throws -> T 
```
- performs a network request to the given endpoint of type E that conforms to the ResponseRequestable protocol, and returns the decoded response of type T that conforms to Decodable protocol. This method is marked as async and throws and it may throw a DataTransferError.parsing error if the decoding process fails.
```swift
download<T: Decodable, E: ResponseRequestable>(_ endpoint: E) async throws -> T 
```
- performs a network request to download the data from the given endpoint of type E that conforms to the ResponseRequestable protocol, and returns the decoded response of type T that conforms to Decodable protocol. This method is marked as async and throws and it may throw a DataTransferError.parsing error if the decoding process fails.
```swift
upload(_ value: String, url: URL) async throws -> Progress 
```
- encodes the given string value using the JSONEncoderData() encoder and uploads it to the specified URL. This method is marked as async and throws and it may throw a DataTransferError.resolvedNetworkFailure error if the network operation fails.
```swift
upload(multipartFormData: @escaping (MultipartFormData) -> Void, to url: URL) async throws -> Progress 
```
- uploads the multipart form data to the specified URL. This method is marked as async and throws and it may throw a DataTransferError.resolvedNetworkFailure error if the network operation fails. The multipart form data is provided by the closure parameter of type @escaping (MultipartFormData) -> Void.

### AFNetworkServiceCombine&AFNetworkService:
1. The NetworkConfigurable protocol is used to define a set of properties that need to be configured before making network requests. This protocol includes three properties: baseURL, headers, and queryParameters.
2. The APIConfiguration struct is a concrete implementation of NetworkConfigurable and provides a way to pass configuration values to AFNetworkServiceCombine and Session. It includes the three required properties: baseURL, headers, and queryParameters.
3. baseURL is the root URL for all network requests made using AFNetworkServiceCombine and Session. This is important because it helps ensure that all requests are being made to the correct endpoint.
4. headers is a dictionary that includes additional information that needs to be sent with each network request, such as authentication tokens or user-agent information. These headers can be modified on a per-request basis if needed.
5. queryParameters is another dictionary that includes additional information that needs to be sent with each network request as query parameters. These parameters are added to the end of the request URL as a key-value pair.
6. Passing configuration values through APIConfiguration ensures that these values are consistent across all network requests made using AFNetworkServiceCombine&AFNetworkService and Session. It also makes it easier to modify these values in one place instead of having to modify them separately for each request.
```swift
    let configuration: APIConfiguration = {
        let config = APIConfiguration(baseURL: URL(string: "https://example.com/")!,
                                      queryParameters: ["api_key": "gjk235g32538d92"])
        return config
    }()
```

Signature of a AFNetworkServiceCombine class (AFNetworkService got the same)
```swift
open class AFNetworkServiceCombine: AFNetworkServiceCombineProtocol {
    
    private let session: Session
    private let logger: Loger
    private let configuration: NetworkConfigurable
    
    public init(session: Session,
                logger: Loger = DEBUGLog(),
                configuration: NetworkConfigurable) {
        self.session = session
        self.logger = logger
        self.configuration = configuration
    }
}
```

# Examplinatory using

Init AFNetworkServiceCombine:

```swift
        let session = AFSessionManager.default
        let networkServiceCombine = AFNetworkServiceCombine(session: session,
                                                            configuration: configuration)
        let dataServiceCombine = AFDataTransferServiceCombine(with: networkServiceCombine)
        let dataSourceCombine = CheckCombineDataSource(dataTransferService: dataServiceCombine)
```
Init AFNetworkService:

```swift
        let session = AFSessionManager.default
        let networkServiceAsync = AFNetworkService(session: session,
                                                   configuration: configuration)
        let dataServiceAsync = AFDataTransferService(with: networkServiceAsync)
        let dataSourceAsync = CheckAsyncDataSource(dataTransferService: dataServiceAsync)
```
## Combine's DataSource:

```swift
    public func checkList() -> AnyPublisher<CheckListDTO, DataTransferError> {
        let endpoint = Endpoint<CheckListDTO>(
            path: "3/genre/movie/list",
            method: .get, queryParameters: ["language": "en"])
        return dataTransferService.request(endpoint)
    }
```
execution of DataSource #1:
```swift
        dataSourceCombine.checkList()
            .receive(on: DispatchQueue.main)
            .sink { complition in
                print(complition)
            } receiveValue: { check in
                print(check)
            }.store(in: &bag)
```
## Async/Await DataSource:

```swift
    public func checkList() async throws -> CheckListDTO {
        let endpoint = Endpoint<CheckListDTO>(
            path: "3/genre/movie/list",
            method: .get, queryParameters: ["language": "en"])
        return try await dataTransferService.request(endpoint)
    }
```
execution of DataSource #2:
```swift
        Task {
            do {
                let checkList = try await dataSourceAsync.checkList()
                print(checkList)
            } catch {
                print(error)
            }
        }
```
