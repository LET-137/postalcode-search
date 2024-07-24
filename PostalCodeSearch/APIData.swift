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
    func fetchZipcode(url: String) {
        fetchData(url: url, decodeType: Int.self) { result in
            switch result {
            case .success(let decodedResponse):
                DispatchQueue.main.async {
                    self.zipAddress = self.formatZipcode(decodedResponse)
                }
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.zipAddress = ""
                }
            }
        }
    }
    
//    住所を検索
    func fetchAddress(url: String) {
        fetchData(url: url, decodeType: AddressResponse.self) { result in
            switch result {
            case .success(let decodedResponse):
                DispatchQueue.main.async {
                    self.address = decodedResponse.results ?? []
                }
            case .failure(let error):
                print(error.localizedDescription)
               DispatchQueue.main.async {
                   self.address = []
               }
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

