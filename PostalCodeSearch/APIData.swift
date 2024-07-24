import Foundation
import SwiftUI

struct AddressResponse: Codable {
    var status: Int
    var message: String?
    var results: [Address]?
}

struct Address: Codable {
    var zipcode: String
    var address1: String
    var address2: String
    var address3: String
}

class PostAddress: ObservableObject {
    @Published var address: [Address] = []
    @Published var zipAddress: String = ""
    
//    郵便番号を取得
    func fetchZipcode <T: Decodable>(url: String, decodeType: T.Type, completion: @escaping (Result<String, Error>) -> Void) {
        fetchData(url: url, decodeType: decodeType) { result in
            switch result {
            case .success(let decodedResponse):
                if let decodedIntData = decodedResponse as? Int {
                    let zipcode = self.formatZipcode(decodedIntData)
                    completion(.success(zipcode))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
//    住所を検索
    func fetchAddress <T: Decodable>(url: String, decodeType: T.Type, completion: @escaping (Result<[Address], Error>) -> Void) {
        fetchData(url: url, decodeType: AddressResponse.self) { result in
            switch result {
            case .success(let decodedResponse):
                let address = decodedResponse.results ?? []
                completion(.success(address))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
//    API通信メソッド
    private func fetchData<T: Decodable>(url: String, decodeType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let urlString = URL(string: url) else { return }
        let request = URLRequest(url: urlString)
        
        URLSession.shared.dataTask(with: request) { data, response , error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "dataTask", code: -1, userInfo: [NSLocalizedDescriptionKey: "データを受け取れません"])))
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(decodeType, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
//    取得した郵便番号を3桁と4桁で分けて表示
    private func formatZipcode(_ zipcode: Int) -> String {
        let zipString = String(zipcode)
        let firstZipcodeDigit = zipString.prefix(3)
        let secondZipcodeDigitIndex = zipString.index(zipString.startIndex, offsetBy: 3)
        let secondZipcodeDigit = zipString[secondZipcodeDigitIndex...]
        return firstZipcodeDigit + "-" + String(secondZipcodeDigit)
    }
}

