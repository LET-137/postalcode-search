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
    
//    郵便番号取得テスト
    func testFetchZipcodeSuccess() throws {
//        モック設定
        let mockURL = "https://mockurl.com/success"
        let mockZipcode = 1234567
        let mockData = try JSONEncoder().encode(mockZipcode)
        
//        テスト用のURLとレスポンスを設定
        URLProtocolMock.testURLs = [mockURL: mockData]
        URLProtocolMock.response = HTTPURLResponse(url: URL(string: mockURL)!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
//        非同期処理が終了するまで待機するexpectationを作成
        let expectation = self.expectation(description: "Fetch Zipcode")
//        fetchZipcodeのテストを実行
        postAddress.fetchZipcode(url: mockURL, decodeType: Int.self) { result in
            switch result {
            case .success(let zipcode):
                XCTAssertEqual(zipcode, "123-4567")
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
//            非同期処理を終了
            expectation.fulfill()
        }
//        2秒間expectation.fulfill()が呼ばれなければ、処理を終了
        waitForExpectations(timeout: 2, handler: nil)
    }
    
//    住所取得テスト　testFetchZipcodeSuccessと同等の処理を行う
    func testFetchAddressSuccess() throws {
        let mockURL = "https://mockurl.com/success"
        let mockResponse = AddressResponse(status: 200, message: nil, results: [Address(zipcode: "123-4567", prefecture: "Tokyo", city: "Shibuya", town: "Dogenzaka")])
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

//モックのプロトコルを設定
class URLProtocolMock: URLProtocol {
    static var testURLs = [String: Data]()
    static var response: URLResponse?
    
//    全てのリクエストを処理
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
//    リクエストをそのまま返す
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
//    リクエスト処理を実行
    override func startLoading() {
        if let url = request.url?.absoluteString, let data = URLProtocolMock.testURLs[url] {
            client?.urlProtocol(self, didReceive: URLProtocolMock.response ?? URLResponse(), cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
//    リクエスト処理を停止
    override func stopLoading() {}
}
