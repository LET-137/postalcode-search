import SwiftUI

struct ContentView: View {
    @EnvironmentObject var postAddress: PostAddress
    @State private var addressString: String = ""
    @State private var zipcode: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section("郵便番号検索") {
                        TextField("町名を入力してください",text: $addressString)
                            .frame(height: 40)
                            .overlay(RoundedRectangle(cornerRadius: 5) .stroke(Color.gray,lineWidth: 1))
                        HStack {
                            Button("郵便番号を検索") {
                                postAddress.fetchZipcode(url: fetchPostalCode(),decodeType: Int.self) { result in
                                    switch result {
                                    case .success(let zipcode):
                                        DispatchQueue.main.async {
                                            postAddress.zipAddress = zipcode
                                        }
                                    case .failure(let error):
                                        print(error)
                                        DispatchQueue.main.async {
                                            postAddress.zipAddress = ""
                                        }
                                    }
                                }
                            }
                            .fontWeight(.bold)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                            Spacer()
                            Text(postAddress.zipAddress)
                        }
                    }
                    Section("住所を検索") {
                        TextField("郵便番号を入力してください",text: $zipcode)
                            .frame(height: 40)
                            .overlay(RoundedRectangle(cornerRadius: 5) .stroke(Color.gray,lineWidth: 1))
                        
                        Button("住所を検索") {
                            postAddress.fetchAddress(url: fetchAddress(), decodeType: AddressResponse.self) { result in
                                switch result {
                                case .success(let address):
                                    DispatchQueue.main.async {
                                        postAddress.address = address
                                    }
                                case .failure(_):
                                    DispatchQueue.main.async {
                                        postAddress.address = []
                                    }
                                }
                            }
                        }
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                    }
                    
                    .scrollContentBackground(.hidden)
                    ForEach(postAddress.address,id: \.zipcode) { address in
                        HStack {
                            Text("県名")
                            Spacer()
                            Text(address.address1)
                                .foregroundStyle(.blue)
                        }
                        HStack {
                            Text("市名")
                            Spacer()
                            Text(address.address2)
                                .foregroundStyle(.blue)
                        }
                        HStack {
                            Text("町名")
                            Spacer()
                            Text(address.address3)
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
    
    func fetchAddress() -> String {
        let baseUrl = "https://zipcloud.ibsnet.co.jp/api/search"
        let urlString = "\(baseUrl)?zipcode=\(zipcode)&limit=1"
        return urlString
    }
    
    func fetchPostalCode() -> String {
        let baseUrl = "https://api.excelapi.org/post/zipcode?address=\(addressString)"
        return baseUrl
    }
}
