import XCTest
@testable import PostalCodeSearch

class PostAddressTests: XCTestCase {
    var postAddress: PostAddress!
    var urlSession: URLSession!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // URLProtocolMockをURLSessionのプロトコルクラスに設定
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        urlSession = URLSession(configuration: config)
        
        postAddress = PostAddress(urlSession: urlSession)
    }
    
    override func tearDownWithError() throws {
        postAddress = nil
        urlSession = nil
        try super.tearDownWithError()
    }
    
    
    func testFetchZipcodeSuccess() throws {
        let mockURL = "https://mockurl.com/success"
        let mockZipcode = 1234567
        let mockData = try JSONEncoder().encode(mockZipcode)
        
        URLProtocolMock.testURLs = [mockURL: mockData]
        URLProtocolMock.response = HTTPURLResponse(url: URL(string: mockURL)!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let expectation = self.expectation(description: "Fetch Zipcode")
        postAddress.fetchZipcode(url: mockURL, decodeType: Int.self) { result in
            switch result {
            case .success(let zipcode):
                XCTAssertEqual(zipcode, "123-4567")
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testFetchAddressSuccess() throws {
        let mockURL = "https://mockurl.com/success"
        let mockResponse = AddressResponse(status: 200, message: nil, results: [Address(zipcode: "123-4567", address1: "Tokyo", address2: "Shibuya", address3: "Dogenzaka")])
        let mockData = try JSONEncoder().encode(mockResponse)
        
        URLProtocolMock.testURLs = [mockURL: mockData]
        URLProtocolMock.response = HTTPURLResponse(url: URL(string: mockURL)!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let expectation = self.expectation(description: "Fetch Address")
        postAddress.fetchAddress(url: mockURL, decodeType: AddressResponse.self) { result in
            switch result {
            case .success(let address):
                XCTAssertEqual(address.count, 1)
                XCTAssertEqual(address[0].zipcode, "123-4567")
                
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
}

// Mock URLProtocol for testing
class URLProtocolMock: URLProtocol {
    static var testURLs = [String: Data]()
    static var response: URLResponse?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let url = request.url?.absoluteString, let data = URLProtocolMock.testURLs[url] {
            client?.urlProtocol(self, didReceive: URLProtocolMock.response ?? URLResponse(), cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
