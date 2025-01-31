import UIKit
import Alamofire
import SwiftKeychainWrapper

extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(
            using: String.Encoding.utf8,
            allowLossyConversion: true)
        append(data!)
    }
}
extension String {
    var urlEncoded: String? {
        let allowedCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "~-_."))
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
    }
}

struct MultipartFormDataRequest {

    private let boundary: String = UUID().uuidString
    private var httpBody = NSMutableData()
    let url: URL
    var headers: Dictionary<String, String>?
    init(url: URL) {
        self.url = url
    }

    func addTextField(named name: String, value: String) {
        httpBody.append(textFormField(named: name, value: value))
    }

    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let headers = headers{
            request.allHTTPHeaderFields = headers
        }
        httpBody.appendString(string: "--\(boundary)--")
        request.httpBody = httpBody as Data
        return request
    }

    private func AddTextFormField(named name: String, value: UIImage) {
        var fieldString = Data()
        fieldString.append("--\(boundary)\r\n".data(using: .utf8)!)
        fieldString.append("Content-Disposition: form-data; name=\"\(name)\"\r\n".data(using: .utf8)!)
        fieldString.append("Content-Type: text/plain; charset=ISO-8859-1\r\n".data(using: .utf8)!)
        fieldString.append("Content-Transfer-Encoding: 8bit\r\n".data(using: .utf8)!)
        fieldString.append("\r\n".data(using: .utf8)!)
        fieldString.append(value.pngData()!)

    }

    private func textFormField(named name: String, value: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=ISO-8859-1\r\n"
        fieldString += "Content-Transfer-Encoding: 8bit\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        return fieldString
    }

    func addDataField(named name: String, data: Data, mimeType: String) {
        httpBody.append(dataFormField(named: name, data: data, mimeType: mimeType))
    }

    private func dataFormField(named name: String,
                               data: Data,
                               mimeType: String) -> Data {
        let fieldData = NSMutableData()

        fieldData.append("--\(boundary)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"\r\n")
        fieldData.append("Content-Type: \(mimeType)\r\n")
        fieldData.append("\r\n")
        fieldData.append(data)
        fieldData.append("\r\n")

        return fieldData as Data
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}



extension NSMutableData {
    func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}



typealias ApiCompletion = (_ data: Any?, _ error: Error?) -> ()

typealias ApiParam = [String: Any]
let boundary = "Boundary-\(UUID().uuidString)"
enum ApiMethod: String {
    case GET = "GET"
    case POST = "POST"
}
extension String {
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
}

extension Dictionary {
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            if value is String {
                let percentEscapedValue = (value as! String).addingPercentEncodingForURLQueryValue()!
                return "\(percentEscapedKey)=\(percentEscapedValue)"
            }
            else {
                return "\(percentEscapedKey)=\(value)"
            }
        }
        return parameterArray.joined(separator: "&")
    }
}
extension URLSession {
    
    func dataTask(with request: MultipartFormDataRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    -> URLSessionDataTask {
        return dataTask(with: request.asURLRequest(), completionHandler: completionHandler)
    }
}
class APIService:NSObject {
    static let shared: APIService = APIService()
    
    private func convertToJson(_ byData: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: byData, options: [])
        } catch {
            //            self.debug("convert to json error: \(error)")
        }
        return nil
    }
    func requestJSON(_ url: String,
                     param: ApiParam?,
                     method: ApiMethod,
                     loading: Bool,
                     completion: @escaping ApiCompletion)
    {
        var request:URLRequest!
        
        // set method & param
        if method == .GET {
            if let paramString = param?.stringFromHttpParameters() {
                request = URLRequest(url: URL(string:"\(url)?\(paramString)")!)
            }
            else {
                request = URLRequest(url: URL(string:url)!)
            }
        }
        else if method == .POST {
            request = URLRequest(url: URL(string:url)!)
            
            // content-type
            let headers: Dictionary = ["Content-Type": "application/json"]
            request.allHTTPHeaderFields = headers
            
            do {
                if let p = param {
                    request.httpBody = try JSONSerialization.data(withJSONObject: p, options: .prettyPrinted)
                }
            } catch { }
        }
        
        request.timeoutInterval = 30
        request.httpMethod = method.rawValue
        
        //
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // check for fundamental networking error
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                
                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                }
                
                if let resJson = self.convertToJson(data) {
                    completion(resJson, nil)
                }
                else if let resString = String(data: data, encoding: .utf8) {
                    completion(resString, error)
                }
                else {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    func requestRemoveAccount(_ url: String,
                              param:  [String: String],
                              method: ApiMethod,
                              loading: Bool,
                              completion: @escaping ApiCompletion)
    {
        // set method & param
        if method == .POST {
            if let token_login: String = KeychainWrapper.standard.string(forKey: "token_login"){
                let headers: Dictionary = [ "Authorization":"Bearer " + token_login]
                var request = MultipartFormDataRequest(url: URL(string: url)!)
                for (key, value) in param {
                    request.addTextField(named: key, value: value)
                }
                request.headers = headers
                var result:(message:String, data:Data?) = (message: "Fail", data: nil)
                URLSession.shared.dataTask(with: request, completionHandler: {data,response,error in
                    result.data = data
                    DispatchQueue.main.async {
                        // check for fundamental networking error
                        guard let data = data, error == nil else {
                            completion(nil, error)
                            return
                        }
                        // check for http errors
                        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                        }
                        if let resJson = self.convertToJson(data) {
                            completion(resJson, nil)
                        }
                        else if let resString = String(data: data, encoding: .utf8) {
                            completion(resString, error)
                        }
                        else {
                            completion(nil, error)
                        }
                    }
                }).resume()
                
            }
        }
    }
    
    func requestTokenGhepDoi(_ url: String,
                             _ link1: String,
                             _ link2: String,
                             param: ApiParam?,
                             method: ApiMethod,
                             loading: Bool,
                             completion: @escaping ApiCompletion)
    {
        var request:URLRequest!
        
        // set method & param
        if method == .GET {
            if let token_login: String = KeychainWrapper.standard.string(forKey: "token_login"){
                let headers: Dictionary = ["Link1":link1, "Link2": link2 , "Authorization":"Bearer " + token_login]
                if let paramString = param?.stringFromHttpParameters() {
                    if let linkPro = "\(url)?\(paramString)".urlEncoded{
                        request = URLRequest(url: (URL(string:linkPro )!))
                    }
                }
                else {
                    if let linkPro = "\(url)".urlEncoded{
                        request = URLRequest(url: (URL(string:"\(url)" )!))
                    }
                }
                request.allHTTPHeaderFields = headers
            }
        }
        else if method == .POST {
            request = URLRequest(url: URL(string:url)!)
            
            // content-type
            let headers: Dictionary = ["Link-detail":"https://www.mngdoom.com/"]
            request.allHTTPHeaderFields = headers
            
            do {
                if let p = param {
                    request.httpBody = try JSONSerialization.data(withJSONObject: p, options: .prettyPrinted)
                }
            } catch { }
        }
        
        request.timeoutInterval = 500
        request.httpMethod = method.rawValue
        
        //
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // check for fundamental networking error
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                
                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                }
                
                if let resJson = self.convertToJson(data) {
                    completion(resJson, nil)
                }
                else if let resString = String(data: data, encoding: .utf8) {
                    completion(resString, error)
                }
                else {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    func requestTokenFolderGhepDoi(_ url: String,
                              linkNam: String,
                                linkNu: String,
                             param: ApiParam?,
                             method: ApiMethod,
                             loading: Bool,
                             completion: @escaping ApiCompletion)
    {
        var request:URLRequest!
        
        // set method & param
        if method == .GET {
            if let token_login: String = KeychainWrapper.standard.string(forKey: "token_login"){
                let namString = linkNam.replacingOccurrences(of: "\"", with: "")
                let nuString = linkNu.replacingOccurrences(of: "\"", with: "")

                let headers: Dictionary = ["linknam":namString,"linknu":nuString ,"Authorization":"Bearer " + token_login]
                if let paramString = param?.stringFromHttpParameters() {
                    if let linkPro = "\(url)?\(paramString)".urlEncoded{
                        request = URLRequest(url: (URL(string:linkPro )!))
                    }
                }
                else {
                   
                    if let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                        let url = URL(string: urlString) {
                        request = URLRequest(url: url)
                        // Sử dụng URLRequest...
                    } else {
                        print("Không thể tạo URL từ chuỗi")
                    }
                }
                request.allHTTPHeaderFields = headers
            }
        }
        
        request.timeoutInterval = 1000
        request.httpMethod = method.rawValue
        
        //
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
           
                print("errorrr:  ")
               print(error)
           
            
            DispatchQueue.main.async {
                
                // check for fundamental networking error
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                
                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                }
                
                if let resJson = self.convertToJson(data) {
                    completion(resJson, nil)
                }
                else if let resString = String(data: data, encoding: .utf8) {
                    completion(resString, error)
                }
                else {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    
    func requestSwapVideoNhapVao(_ url: String,
                              linkNam: String,
                                linkNu: String,
                             param: ApiParam?,
                             method: ApiMethod,
                             loading: Bool,
                             completion: @escaping ApiCompletion)
    {
        var request:URLRequest!
        
        // set method & param
        if method == .GET {
            if let token_login: String = KeychainWrapper.standard.string(forKey: "token_login"){
                let namString = linkNam.replacingOccurrences(of: "\"", with: "")
                let nuString = linkNu.replacingOccurrences(of: "\"", with: "")

                let headers: Dictionary = ["Authorization":"Bearer " + token_login]
                if let paramString = param?.stringFromHttpParameters() {
                    if let linkPro = "\(url)?\(paramString)".urlEncoded{
                        request = URLRequest(url: (URL(string:linkPro )!))
                    }
                }
                else {
                    if let linkPro = "\(url)".urlEncoded{
                        request = URLRequest(url: (URL(string:"\(url)" )!))
                    }
                }
                request.allHTTPHeaderFields = headers
            }
        }
        
        request.timeoutInterval = 1000
        request.httpMethod = method.rawValue
        
        //
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // check for fundamental networking error
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                
                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                }
                
                if let resJson = self.convertToJson(data) {
                    completion(resJson, nil)
                }
                else if let resString = String(data: data, encoding: .utf8) {
                    completion(resString, error)
                }
                else {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    func requestFreeHostSON2(_ url: String,
                            param: [String: String],
                            method: ApiMethod,
                            loading: Bool,
                            completion: @escaping ApiCompletion)
    {
        var request:URLRequest!
        // set method & param
         if method == .POST {
            

            var body = Data()
            if let token_login: String = KeychainWrapper.standard.string(forKey: "token_login"){
                
                let headers: Dictionary = ["Authorization":"Bearer " + token_login]

                request = URLRequest(url: (URL(string:url )!))
               
                request.allHTTPHeaderFields = headers
            }
            
            
            request.timeoutInterval = 30
            request.httpMethod = method.rawValue
            
             request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            for (key, value) in param {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
             body.append("--\(boundary)\r\n")
             request.httpBody = body

             print(body)
             let task = URLSession.shared.dataTask(with: request) { data, response, error in
                 
                 DispatchQueue.main.async {
                     
                     // check for fundamental networking error
                     guard let data = data, error == nil else {
                         completion(nil, error)
                         return
                     }
                     
                     // check for http errors
                     if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                     }
                     
                     if let resJson = self.convertToJson(data) {
                         completion(resJson, nil)
                     }
                     else if let resString = String(data: data, encoding: .utf8) {
                         completion(resString, error)
                     }
                     else {
                         completion(nil, error)
                     }
                 }
             }
             task.resume()
        }
    }
    func requestFreeHostSON3(_ url: String,
                            param: [String: String],
                            method: ApiMethod,
                            loading: Bool,
                            completion: @escaping ApiCompletion)
    {
        var request:URLRequest!
        // set method & param
         if method == .POST {
            

            var body = Data()
            if let token_login: String = KeychainWrapper.standard.string(forKey: "token_login"){
                
                let headers: Dictionary = ["Authorization":"Bearer " + token_login]

                request = URLRequest(url: (URL(string:url )!))
               
                request.allHTTPHeaderFields = headers
            }
            
            
            request.timeoutInterval = 30
            request.httpMethod = method.rawValue
             //let boundary = "Boundary2-\(UUID().uuidString)"
             request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            for (key, value) in param {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
             body.append("--\(boundary)\r\n")
             request.httpBody = body

             print(body)
             let task = URLSession.shared.dataTask(with: request) { data, response, error in
                 
                 DispatchQueue.main.async {
                     
                     // check for fundamental networking error
                     guard let data = data, error == nil else {
                         completion(nil, error)
                         return
                     }
                     
                     // check for http errors
                     if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                     }
                     
                     if let resJson = self.convertToJson(data) {
                         completion(resJson, nil)
                     }
                     else if let resString = String(data: data, encoding: .utf8) {
                         completion(resString, error)
                     }
                     else {
                         completion(nil, error)
                     }
                 }
             }
             task.resume()
        }
    }
    func requestSON(_ url: String,
                    _ link1: String,
                    _ link2: String,
                    param: ApiParam?,
                    method: ApiMethod,
                    loading: Bool,
                    completion: @escaping ApiCompletion)
    {
        var request:URLRequest!
        
        // set method & param
        if method == .GET {
            let headers: Dictionary = ["Link1":link1, "Link2": link2]
            
            if let paramString = param?.stringFromHttpParameters() {
                request = URLRequest(url: URL(string:"\(url)?\(paramString)")!)
            }
            else {
                request = URLRequest(url: URL(string:url)!)
            }
            request.allHTTPHeaderFields = headers
            
            
        }
        else if method == .POST {
            request = URLRequest(url: URL(string:url)!)
            
            // content-type
            let headers: Dictionary = ["Link-detail":"https://www.mngdoom.com/"]
            request.allHTTPHeaderFields = headers
            
            do {
                if let p = param {
                    request.httpBody = try JSONSerialization.data(withJSONObject: p, options: .prettyPrinted)
                }
            } catch { }
        }
        
        request.timeoutInterval = 30
        request.httpMethod = method.rawValue
        
        //
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // check for fundamental networking error
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                
                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                }
                
                if let resJson = self.convertToJson(data) {
                    completion(resJson, nil)
                }
                else if let resString = String(data: data, encoding: .utf8) {
                    completion(resString, error)
                }
                else {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    func requestSON(_ url: String,
                    param: ApiParam?,
                    method: ApiMethod,
                    loading: Bool,
                    completion: @escaping ApiCompletion)
    {
        var request:URLRequest!
        
        // set method & param
        if method == .GET {
            if let paramString = param?.stringFromHttpParameters() {
                request = URLRequest(url: URL(string:"\(url)?\(paramString)")!)
            }
            else {
                request = URLRequest(url: URL(string:url)!)
            }
        }
        else if method == .POST {
            request = URLRequest(url: URL(string:url)!)
            
            // content-type
            let headers: Dictionary = ["Content-Type": "application/json"]
            request.allHTTPHeaderFields = headers
            
            do {
                if let p = param {
                    request.httpBody = try JSONSerialization.data(withJSONObject: p, options: .prettyPrinted)
                }
            } catch { }
        }
        
        request.timeoutInterval = 30
        request.httpMethod = method.rawValue
        
        //
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // check for fundamental networking error
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                
                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                }
                
                if let resJson = self.convertToJson(data) {
                    completion(resJson, nil)
                }
                else if let resString = String(data: data, encoding: .utf8) {
                    completion(resString, error)
                }
                else {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    func requestFreeHostSON(_ url: String,
                            param: [String: String],
                            method: ApiMethod,
                            loading: Bool,
                            completion: @escaping ApiCompletion)
    {
        var request:URLRequest!
        // set method & param
        if method == .GET {
            request = URLRequest(url: URL(string:url)!)
            request.timeoutInterval = 30
            request.httpMethod = method.rawValue
            let request = MultipartFormDataRequest(url: URL(string: url)!)
            for (key, value) in param {
                request.addTextField(named: key, value: value)
            }
            var result:(message:String, data:Data?) = (message: "Fail", data: nil)
            URLSession.shared.dataTask(with: request, completionHandler: {data,response,error in
                result.data = data
                DispatchQueue.main.async {
                    // check for fundamental networking error
                    guard let data = data, error == nil else {
                        completion(nil, error)
                        return
                    }
                    // check for http errors
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                    }
                    if let resJson = self.convertToJson(data) {
                        completion(resJson, nil)
                    }
                    else if let resString = String(data: data, encoding: .utf8) {
                        completion(resString, error)
                    }
                    else {
                        completion(nil, error)
                    }
                }
            }).resume()
        }
        
        else if method == .POST {
            request = URLRequest(url: URL(string:url)!)
            request.timeoutInterval = 30
            request.httpMethod = method.rawValue
            let request = MultipartFormDataRequest(url: URL(string: url)!)
            for (key, value) in param {
                request.addTextField(named: key, value: value)
            }
            var result:(message:String, data:Data?) = (message: "Fail", data: nil)
            URLSession.shared.dataTask(with: request, completionHandler: {data,response,error in
                result.data = data
                DispatchQueue.main.async {
                    // check for fundamental networking error
                    guard let data = data, error == nil else {
                        completion(nil, error)
                        return
                    }
                    // check for http errors
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                    }
                    if let resJson = self.convertToJson(data) {
                        completion(resJson, nil)
                    }
                    else if let resString = String(data: data, encoding: .utf8) {
                        completion(resString, error)
                    }
                    else {
                        completion(nil, error)
                    }
                }
            }).resume()
        }
    }
    
    func LoginAPI(param:[String: String], closure: @escaping (_ response: LoginModel?, _ error: Error?) -> Void) {
        requestFreeHostSON("https://databaseswap.mangasocial.online/login" , param: param, method: .POST, loading: true) { (data, error) in
            if let data = data as? [String:Any]{
                var  returnData:LoginModel = LoginModel()
                returnData = returnData.initLoad(data)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }
    func ChangePassAPI(param:[String: String],userId:Int, closure: @escaping (_ response: LoginModel?, _ error: Error?) -> Void) {
        requestFreeHostSON2("https://databaseswap.mangasocial.online/changepassword/\(userId)" , param: param, method: .POST, loading: true) { (data, error) in
            if let data = data as? [String:Any]{
                var  returnData:LoginModel = LoginModel()
                returnData = returnData.initLoad(data)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }
    func ChangeAvater(param:[String: String],userId:Int, closure: @escaping (_ response: avatarModal?, _ error: Error?) -> Void) {
        requestFreeHostSON3("https://databaseswap.mangasocial.online/changeavatar/\(userId)" , param: param, method: .POST, loading: true) { (data, error) in
            if let data = data as? [String:Any]{
                var  returnData:avatarModal = avatarModal()
                returnData = returnData.initLoad(data)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }
    func RegisterAccount(param:[String: String], closure: @escaping (_ response: RegisterModel?, _ error: Error?) -> Void) {
        requestFreeHostSON("https://databaseswap.mangasocial.online/register/user", param: param, method: .POST, loading: true) { (data, error) in
            if let data = data as? [String:Any]{
                var returnData: RegisterModel = RegisterModel()
                returnData = returnData.initLoad(data)
                closure(returnData,nil)
            }
        }
        closure(nil, nil)
    }
    
 
    func getLoveHistory(pageLoad:Int,idUser:String, closure: @escaping (_ response: HomeModel?, _ error: Error?) -> Void) {
        requestJSON("https://databaseswap.mangasocial.online/lovehistory/page/" + String(pageLoad) + "?id_user=" + idUser, param: nil, method: .GET, loading: true) { (data, error) in
            if let data2 = data as? [String:Any]{
                var returnData: HomeModel = HomeModel()
                returnData = returnData.initLoad(data2)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }
    
    func getDetailEvent(id: Int, closure: @escaping (_ response: DetailEvent?, _ error: Error?) -> Void) {
        requestJSON("https://databaseswap.mangasocial.online/lovehistory/\(id)", param: nil, method: .GET, loading: true) { (data, error) in
            if let data2 = data as? [String:Any]{
                var returnData: DetailEvent = DetailEvent()
                returnData = returnData.initLoad(data2)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }
    func GetListImages(albuum:String,closure: @escaping (_ response: [ListVideoModal]?, _ error: Error?) -> Void) {
        requestSON("https://api.mangasocial.online/get/list_image/1?album="+albuum, param: nil, method: .GET, loading: true) { (data, error) in
            if let d = data as? [String: Any] {
                var listComicReturn:[ListVideoModal] = [ListVideoModal]()
                if let slideshows = d["list_sukien_video"] as? [[String : Any]] {
                    for item1 in slideshows{
                       
                                var commicAdd:ListVideoModal = ListVideoModal()
                                commicAdd = commicAdd.initLoad(item1)
                                listComicReturn.append(commicAdd)
                            
                        
                    }
                }
                closure(listComicReturn, nil)
            }else {
                closure(nil, error)
            }
        }
    }
    func getIP(closure: @escaping (_ response: IPAddress?, _ error: Error?) -> Void) {
        requestJSON("https://ipinfo.io/json", param: nil, method: .GET, loading: true) { (data, error) in
            if let data2 = data as? [String:Any]{
                var returnData: IPAddress = IPAddress()
                returnData = returnData.initLoad(data2)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }
    
    func postComents(param:[String: String], closure: @escaping (_ response: PostComments?, _ error: Error?) -> Void) {
        requestFreeHostSON("https://databaseswap.mangasocial.online/lovehistory/comment", param: param, method: .POST, loading: true) { (data, error) in
            if let data = data as? [String:Any]{
                var  returnData:PostComments = PostComments()
                returnData = returnData.initLoad(data)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }
    
    func getCommentEvent(id: Int,id_toan_bo_su_kien: String,idUser:String, closure: @escaping (_ response: CommentEvent?, _ error: Error?) -> Void) {
        requestJSON("https://databaseswap.mangasocial.online/lovehistory/comment/\(id)?id_toan_bo_su_kien=\(id_toan_bo_su_kien)" + "&id_user=" + idUser, param: nil, method: .GET, loading: true) { (data, error) in
            if let data2 = data as? [String:Any]{
                var returnData: CommentEvent = CommentEvent()
                returnData = returnData.initLoad(data2)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }
    
    func getPageComment(page: Int,idUser:String, closure: @escaping (_ response: CommentsModel?, _ error: Error?) -> Void) {
        requestJSON("https://databaseswap.mangasocial.online/lovehistory/pageComment/" + String(page) + "?id_user=" + idUser, param: nil, method: .GET, loading: true) { (data, error) in
            if let data2 = data as? [String:Any]{
                var returnData: CommentsModel = CommentsModel()
                returnData = returnData.initLoad(data2)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }
    
    func getRecentComment(user: Int, closure: @escaping (_ response: RecentCommentModel?, _ error: Error?) -> Void) {
        requestJSON("https://databaseswap.mangasocial.online/lovehistory/comment/user/\(user)", param: nil, method: .GET, loading: true) { (data, error) in
            if let data2 = data as? [String:Any]{
                var returnData: RecentCommentModel = RecentCommentModel()
                returnData = returnData.initLoad(data2)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }
//    //${server}/lovehistory/user/video/${user.id_user}?trang=${count}
    func getRecentVideoSwap(user: Int, page: Int, closure: @escaping (_ response: [ResultVideoModel]?, _ error: Error?) -> Void) {
        requestJSON("https://databaseswap.mangasocial.online/lovehistory/user/video/\(user)?trang=\(page)", param: nil, method: .GET, loading: true) { (data, error) in
            var listVideoReturn : [ResultVideoModel] = [ResultVideoModel]()
            if let data = data as? [String:Any]{
                if let data2 = data["list_sukien_video"] as? [[String:Any]]{
                    for item in data2{
                        if let dataListSuKien = item["sukien_video"] as? [[String:Any]]{
                            for item2 in dataListSuKien{
                                var itemvideoAdd: ResultVideoModel = ResultVideoModel()
                                itemvideoAdd = itemvideoAdd.initLoad(item2)
                                listVideoReturn.append(itemvideoAdd)
                            }
                        }
                    }
                    closure(listVideoReturn,nil)
                }else{
                    closure([ResultVideoModel](),nil)
                }
            }else{
                closure([ResultVideoModel](),nil)
            }
        }
        closure(nil, nil)
    }
    
    func getUserEvent(user: Int, closure: @escaping (_ response: HomeModel?, _ error: Error?) -> Void) {
        requestJSON("https://databaseswap.mangasocial.online/lovehistory/user/\(user)", param: nil, method: .GET, loading: true) { (data, error) in
            if let data2 = data as? [String:Any]{
                var returnData: HomeModel = HomeModel()
                returnData = returnData.initLoad(data2)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }
    
    func getProfile(user: Int, closure: @escaping (_ response: ProfileModel?, _ error: Error?) -> Void) {
        requestJSON("https://databaseswap.mangasocial.online/profile/\(user)", param: nil, method: .GET, loading: true) { (data, error) in
            if let data2 = data as? [String:Any]{
                var returnData: ProfileModel = ProfileModel()
                returnData = returnData.initLoad(data2)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }
    
    func getEventsAPI(linkNam: String, linkNu: String,device: String, ip: String, Id: String, tennam:String,tennu:String, closure: @escaping (_ response: LoveModel?, _ error: Error?) -> Void) {
        if let linkDevice = device.urlEncoded,let tenNamLink = tennam.urlEncoded,let tenNuLink = tennu.urlEncoded{
            requestTokenFolderGhepDoi("https://thinkdiff.us/getdata?device_them_su_kien=\(linkDevice)&ip_them_su_kien=\(ip)&id_user=\(Id)&ten_nam=\(tenNamLink)&ten_nu=\(tenNuLink)", linkNam: linkNam,linkNu: linkNu, param: nil, method: .GET, loading: true) { (data, error) in
                if let data = data as? [String:Any]{
                    var returnData: LoveModel = LoveModel()
                    returnData = returnData.initLoad(data)
                    closure(returnData,nil)
                }else{
                    closure(nil,nil)
                }
            }
        }
        closure(nil, nil)
    }
    func getEventsAPISuKienNgam(linkNam: String, linkNu: String,device: String, ip: String, Id: String, tennam:String,tennu:String, closure: @escaping (_ response: LoveModel?, _ error: Error?) -> Void) {
        if let linkDevice = device.urlEncoded,let tenNamLink = tennam.urlEncoded,let tenNuLink = tennu.urlEncoded{
            requestTokenFolderGhepDoi("https://thinkdiff.us/getdata/skngam?device_them_su_kien=\(linkDevice)&ip_them_su_kien=\(ip)&id_user=\(Id)&ten_nam=\(tenNamLink)&ten_nu=\(tenNuLink)", linkNam: linkNam,linkNu: linkNu, param: nil, method: .GET, loading: true) { (data, error) in
                if let data = data as? [String:Any]{
                    var returnData: LoveModel = LoveModel()
                    returnData = returnData.initLoad(data)
                    closure(returnData,nil)
                }else{
                    closure(nil,nil)
                }
            }
        }
        closure(nil, nil)
    }
    func searchComment(searchText: String, closure: @escaping (_ response: HomeModel?, _ error: Error?) -> Void) {
        let LinkText = "https://databaseswap.mangasocial.online/search?word=" + searchText
        requestSON(LinkText,"","", param: nil, method: .GET, loading: true) { (data, error) in
            if let data = data as? [String:Any]{
                var returnData: HomeModel = HomeModel()
                returnData = returnData.initLoad(data)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }
    
    func reportComment(param:[String: String], closure: @escaping (_ response: RegisterModel?, _ error: Error?) -> Void) {
        requestFreeHostSON("https://databaseswap.mangasocial.online/report/comment", param: param, method: .POST, loading: true) { (data, error) in
            if let data = data as? [String:Any]{
                var returnData: RegisterModel = RegisterModel()
                returnData = returnData.initLoad(data)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }
    
    func getAll_KeyAPI(closure: @escaping (_ response: [APIKeyIMGBB], _ error: Error?) -> Void) {
        requestJSON("https://raw.githubusercontent.com/sonnh7289/python3-download/main/key-ios.json" , param: nil, method: .GET, loading: true) { (data, error) in
            var listAPIkey:[APIKeyIMGBB] = [APIKeyIMGBB]()
            if let data2 = data as? [[String:Any]]{
                for item in data2{
                    var returnData: APIKeyIMGBB = APIKeyIMGBB()
                    returnData = returnData.initLoad(item)
                    listAPIkey.append(returnData)
                }
                closure(listAPIkey,nil)
            }else{
                closure([APIKeyIMGBB](),nil)
            }
        }
        closure([APIKeyIMGBB](), nil)
    }
    
    func APISearchUser(nameSearch:String,closure: @escaping (_ response: [UserSearchModel], _ error: Error?) -> Void) {
        let linkUrl = "https://databaseswap.mangasocial.online/profile/user/" + (nameSearch.urlEncoded ?? "")
        requestJSON(linkUrl , param: nil, method: .GET, loading: true) { (data, error) in
            var listAPIkey:[UserSearchModel] = [UserSearchModel]()
            if let data2 = data as? [[String:Any]]{
                for item in data2{
                    var returnData: UserSearchModel = UserSearchModel()
                    returnData = returnData.initLoad(item)
                    listAPIkey.append(returnData)
                }
                closure(listAPIkey,nil)
            }else{
                closure([UserSearchModel](),nil)
            }
        }
        closure([UserSearchModel](), nil)
    }
    
//    //https://raw.githubusercontent.com/sonnh7289/funnyvideo_faceFunny/main/videoswapface.json
//    func listTemplateVideoSwap(closure: @escaping (_ response: [TempleVideoModel], _ error: Error?) -> Void) {
//        let linkUrl = "https://raw.githubusercontent.com/sonnh7289/mega27-5-2023/main/json-tam-video.json"
//        requestJSON(linkUrl, param: nil, method: .GET, loading: true) { (data, error) in
//            var listVideoReturn : [TempleVideoModel] = [TempleVideoModel]()
//            if let data2 = data as? [[String:Any]]{
//                for item in data2{
//                    var itemvideoAdd: TempleVideoModel = TempleVideoModel()
//                    itemvideoAdd = itemvideoAdd.initLoad(item)
//                    listVideoReturn.append(itemvideoAdd)
//                }
//                closure(listVideoReturn,nil)
//            }else{
//                closure([TempleVideoModel](),nil)
//            }
//            
//        }
//        // closure("Please Wait To Remove", nil)
//    }
//    

    func listAllTemplateVideoSwap(page:Int,categories:Int,closure: @escaping (_ response: [Temple2VideoModel], _ error: Error?) -> Void) {
        let linkUrl = "https://databaseswap.mangasocial.online/lovehistory/listvideo/" + String(page) + "?category=" + String(categories)
        requestJSON(linkUrl, param: nil, method: .GET, loading: true) { (data, error) in
            var listVideoReturn : [Temple2VideoModel] = [Temple2VideoModel]()
            if let data = data as? [String:Any]{
                if let data2 = data["list_sukien_video"] as? [[String:Any]]{
                    for item in data2{
                        var itemvideoAdd: Temple2VideoModel = Temple2VideoModel()
                        itemvideoAdd = itemvideoAdd.initLoad(item)
                        listVideoReturn.append(itemvideoAdd)
                    }
                    closure(listVideoReturn,nil)
                }else{
                    closure([Temple2VideoModel](),nil)
                }
            }else{
                closure([Temple2VideoModel](),nil)
            }
        }
        // closure("Please Wait To Remove", nil)
    }
    func listAllVideoSwaped(page:Int,closure: @escaping (_ response: [ResultVideoModel], _ error: Error?) -> Void) {
        let linkUrl = "https://databaseswap.mangasocial.online/lovehistory/video/" + String(page)
        requestJSON(linkUrl, param: nil, method: .GET, loading: true) { (data, error) in
            var listVideoReturn : [ResultVideoModel] = [ResultVideoModel]()
            if let data = data as? [String:Any]{
                if let data2 = data["list_sukien_video"] as? [[String:Any]]{
                    for item in data2{
                        if let dataListSuKien = item["sukien_video"] as? [[String:Any]]{
                            for item2 in dataListSuKien{
                                var itemvideoAdd: ResultVideoModel = ResultVideoModel()
                                itemvideoAdd = itemvideoAdd.initLoad(item2)
                                listVideoReturn.append(itemvideoAdd)
                            }
                        }
                    }
                    closure(listVideoReturn,nil)
                }else{
                    closure([ResultVideoModel](),nil)
                }
            }else{
                closure([ResultVideoModel](),nil)
            }
        }
        // closure("Please Wait To Remove", nil)
    }
    func listImageUploaded(type:String,idUser:String,closure: @escaping (_ response: [String], _ error: Error?) -> Void) {
        let linkUrl = "https://databaseswap.mangasocial.online/images/" + idUser + "?type=" + type
        requestJSON(linkUrl, param: nil, method: .GET, loading: true) { (data, error) in
            var listLinkImage : [String] = [String]()
            if let data = data as? [String:Any]{
                if type == "nam"{
                    if let data2 = data["image_links_nam"] as? [String]{
                        listLinkImage = data2
                        closure(listLinkImage,nil)
                    }else{
                        closure([String](),nil)
                    }
                }else if type == "nu"{
                    if let data2 = data["image_links_nu"] as? [String]{
                        listLinkImage = data2
                        closure(listLinkImage,nil)
                    }else{
                        closure([String](),nil)
                    }
                }else if type == "video"{
                    if let data2 = data["image_links_video"] as? [String]{
                        listLinkImage = data2
                        closure(listLinkImage,nil)
                    }else{
                        closure([String](),nil)
                    }
                }
            }else{
                closure([String](),nil)
            }
        }
        // closure("Please Wait To Remove", nil)
    }
//    func UploadVideoBatKyAndGen(_ url: String,
//                              videoUpload: UIImage,
//                              method: ApiMethod,
//                              loading: Bool,
//                              completion: @escaping ApiCompletion)
//    {
//        let form = MultipartForm(parts: [
//            MultipartForm.Part(name: "src_vid", data: videoUpload.jpegData(compressionQuality: 1)!, filename: "src_vid.mp4", contentType: "video/mp4"),
//        ])
//
//        var request = URLRequest(url: URL(string:url)!)
//        request.httpMethod = "POST"
//        request.setValue(form.contentType, forHTTPHeaderField: "Content-Type")
//        var result:(message:String, data:Data?) = (message: "Fail", data: nil)
//
//        URLSession.shared.uploadTask(with: request, from: form.bodyData){ (data, response, error) in
//
//            if let error = error {
//                 // Error
//            }
//            result.data = data
//            DispatchQueue.main.async {
//                // check for fundamental networking error
//                guard let data = data, error == nil else {
//                    completion(nil, error)
//                    return
//                }
//                // check for http errors
//                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
//                }
//                if let resJson = self.convertToJson(data) {
//                    completion(resJson, nil)
//                }
//                if let resString = String(data: data, encoding: .utf8) {
//                    completion(resString, error)
//                }
//                else {
//                    completion(nil, error)
//                }
//            }
//            // Do something after the upload task is complete
//
//       }.resume()
//    }
    func requestTokenFolderGhepDoi1(_ url: String,
                              link1: String,
                                
                             param: ApiParam?,
                             method: ApiMethod,
                             loading: Bool,
                             completion: @escaping ApiCompletion)
    {
        var request:URLRequest!
        
        // set method & param
        if method == .GET {
            if let token_login: String = KeychainWrapper.standard.string(forKey: "token_login"){
                let namString = link1.replacingOccurrences(of: "\"", with: "")
                //let nuString = linkNu.replacingOccurrences(of: "\"", with: "")

                let headers: Dictionary = ["link1":namString ,"Authorization":"Bearer " + token_login]
                if let paramString = param?.stringFromHttpParameters() {
                    if let linkPro = "\(url)?\(paramString)".urlEncoded{
                        request = URLRequest(url: (URL(string:linkPro )!))
                    }
                }
                else {
                    if let linkPro = "\(url)".urlEncoded{
                        request = URLRequest(url: (URL(string:"\(url)" )!))
                    }
                }
                request.allHTTPHeaderFields = headers
            }
        }
        
        request.timeoutInterval = 1000
        request.httpMethod = method.rawValue
        
        //
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // check for fundamental networking error
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                
                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                }
                
                if let resJson = self.convertToJson(data) {
                    completion(resJson, nil)
                }
                else if let resString = String(data: data, encoding: .utf8) {
                    completion(resString, error)
                }
                else {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    func SwapListAlbum (_ url: String,
                        linkImages : String,
                        closure: @escaping (_ response: [String]?, _ error: Error?) -> Void
    ){
        requestTokenFolderGhepDoi1(url, link1: linkImages, param: nil, method: .GET, loading: true) { (data, error) in
            if let d = data as? [String: Any] {
                var listComicReturn:[String] = [String]()
                if let slideshows = d["link anh da swap"] as? [String] {
                    for item1 in slideshows{
                       
                               
                                listComicReturn.append(item1)
                            
                        
                    }
                }
                closure(listComicReturn, nil)
            }else {
                closure(nil, error)
            }
        }
        
    }
    func UploadVideoBatKyAndGen(_ url: String,
                                 mediaData: Data,
                                 method: ApiMethod,
                                 loading: Bool,
                                // Thêm tham số này để truyền token vào hàm
                                closure: @escaping (_ response: DetaiModelUser?, _ error: Error?) -> Void) {

        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "src_vid", data: mediaData, filename: "src_vid.mp4", contentType: "video/mp4"),
        ])

        let token_login: String = KeychainWrapper.standard.string(forKey: "token_login") ?? "ADSF"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue(form.contentType, forHTTPHeaderField: "Content-Type")

        // Thêm token vào header
        request.setValue("Bearer \(token_login)", forHTTPHeaderField: "Authorization")

        var result: (message: String, data: Data?) = (message: "Fail", data: nil)

        URLSession.shared.uploadTask(with: request, from: form.bodyData) { (data, response, error) in

            if let error = error {
                 // Handle error
            }

            result.data = data
            DispatchQueue.main.async {
                // check for fundamental networking error
                guard let data = data, error == nil else {
                    closure(nil, error)
                    return
                }

                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                    // Handle HTTP error if needed
                }

                if let resJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                    if let data = data as? [String: Any] {
//                        if let sukienVideoData = data["sukien_video"] as? [String: Any] {
//                            var itemAdd = DetailVideoModel()
//                            itemAdd = itemAdd.initLoad(sukienVideoData) // Use sukienVideoData here
//                            print(itemAdd)
//                            closure(itemAdd, nil)
//                        }
//                    } else {
//                        closure(DetailVideoModel(), nil)
//                    }
                    if let sukienVideoData = resJson["sukien_swap_video"] as? [String: Any] {
                        var itemAdd = DetaiModelUser()
                        itemAdd = itemAdd.initLoad(sukienVideoData)
                        closure(itemAdd, nil)
                    }
                   
                } else if let resString = String(data: data, encoding: .utf8) {
                    closure(nil, error) // You might want to replace `YourErrorType` with an appropriate error type
                } else {
                    closure(nil, error)
                }

            }
            // Do something after the upload task is complete

       }.resume()
    }

//    ///upload-gensk/{id_user}
    func UploadImagesToGenRieng(_ url: String,
                              ImageUpload: UIImage,
                              method: ApiMethod,
                              loading: Bool,
                              completion: @escaping ApiCompletion)
    {
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "src_img", data: ImageUpload.jpegData(compressionQuality: 1)!, filename: "src_img.jpeg", contentType: "image/jpeg"),
        ])

        var request = URLRequest(url: URL(string:url)!)
        request.httpMethod = "POST"
        request.setValue(form.contentType, forHTTPHeaderField: "Content-Type")
        var result:(message:String, data:Data?) = (message: "Fail", data: nil)
       
        URLSession.shared.uploadTask(with: request, from: form.bodyData){ (data, response, error) in
            
            if let error = error {
                 // Error
            }
            result.data = data
            DispatchQueue.main.async {
                // check for fundamental networking error
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                }
                if let resJson = self.convertToJson(data) {
                    completion(resJson, nil)
                }
                if let resString = String(data: data, encoding: .utf8) {
                    completion(resString, error)
                }
                else {
                    completion(nil, error)
                }
            }
            // Do something after the upload task is complete

       }.resume()
    }
    //

    func GenVideoSwap(device_them_su_kien:String,id_video:String,ip_them_su_kien:String,id_user:String,link_img:String, ten_video:String,closure: @escaping (_ response: DetailVideoModel?, _ error: Error?) -> Void) {
        let newString = link_img.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
        if let devicePro = device_them_su_kien.urlEncoded{
            requestTokenFolderGhepDoi("https://videoswap.mangasocial.online/getdata/genvideo?id_video=\(id_video)&device_them_su_kien=\(devicePro)&ip_them_su_kien=\(ip_them_su_kien)&id_user=\(id_user)&image=\(newString)&ten_video=\(ten_video)", linkNam: "", linkNu: "", param: nil, method: .GET, loading: true) { (data, error) in
//                if let data = data as? [String: Any],
//                   let sukienVideoData = data["sukien_video"] as? [String: Any] {
//                    
//                    var itemAdd = DetailVideoModel()
//
//                    if let noidung = sukienVideoData["noidung"] as? String {
//                        itemAdd.noidung = noidung
//                    }
//                    if let idSukienVideo = sukienVideoData["id_sukien_video"] as? String {
//                        itemAdd.id_sukien_video = idSukienVideo
//                    }
//                    // Continue adding other properties
//                    
//                    // Print the created DetailVideoModel
//                    print(itemAdd)
//                    
//                    closure(itemAdd, nil)
//                } else {
//                    closure(DetailVideoModel(), nil)
//                }

                if let data = data as? [String: Any] {
                    if let sukienVideoData = data["sukien_video"] as? [String: Any] {
                        var itemAdd = DetailVideoModel()
                        itemAdd = itemAdd.initLoad(sukienVideoData) // Use sukienVideoData here
                        print(itemAdd)
                        closure(itemAdd, nil)
                    }
                } else {
                    closure(DetailVideoModel(), nil)
                }

            }
        }
    }
    func GenBaby(device_them_su_kien:String,ip_them_su_kien:String,id_user:Int,linknam:String, linknu:String,closure: @escaping (_ response: benbabymodal?, _ error: Error?) -> Void) {
        let newString1 = linknam.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
        let newString2 = linknu.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
        if let devicePro = device_them_su_kien.urlEncoded{
            requestTokenFolderGhepDoi("https://thinkdiff.us/getdata/sukien/baby?device_them_su_kien=\(device_them_su_kien)&ip_them_su_kien=\(ip_them_su_kien)&id_user=\(id_user)", linkNam: linknam, linkNu: linknu, param: nil, method: .GET, loading: true) { (data, error) in
                if let data = data as? [String: Any] {
//                    if let sukienVideoData = data["sukien_baby"] as? [String: Any] {
//                        var itemAdd = benbabymodal()
//                        itemAdd = itemAdd.initLoad(sukienVideoData) // Use sukienVideoData here
//                        print("asdfasdfddd\n\n\n\n\n\n   ")
//                        print(itemAdd)
//                        closure(itemAdd, nil)
//                    }
                    if let sukienVideoDataArray = data["sukien_baby"] as? [[String: Any]],
                       let sukienVideoData = sukienVideoDataArray.first {
                        var itemAdd = benbabymodal()
                        itemAdd = itemAdd.initLoad(sukienVideoData)
                        print("asdfasdfddd\n\n\n\n\n\n   ")
                        print(itemAdd)
                        closure(itemAdd, nil)
                    }
                } else {
                    closure(benbabymodal(), nil)
                }

            }
        }
    }
    func swapImageWithVideo(device: String, ip: String, userId: String, imageLink: String, videoFile: Data, closure: @escaping (_ response: DetailVideoModel?, _ error: Error?) -> Void) {
        let urlString = "https://videoswap.mangasocial.online/getdata/genvideo/swap/imagevid"
        let parameters: [String: String] = [
            "device_them_su_kien": device,
            "ip_them_su_kien": ip,
            "id_user": userId,
            "src_img": imageLink
        ]
        let token_login: String = KeychainWrapper.standard.string(forKey: "token_login") ?? "ADSF"
        print("token : " + token_login + " 99999999. sdfdgdsfg")
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                if let data = value.data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }
            multipartFormData.append(videoFile, withName: "src_vid", fileName: "video.mp4", mimeType: "video/mp4")
        }, to: urlString, method: .post, headers: ["Authorization": "Bearer " + token_login])
        .responseJSON { (response) in
            switch response.result {
            case .success(let data):
                if let data = data as? [String:Any]{
                    var itemAdd:DetailVideoModel = DetailVideoModel()
                    itemAdd = itemAdd.initLoad(data)
                    closure( itemAdd, nil)
                    
                }else{
                    closure( DetailVideoModel(), nil)
                }
            case .failure(let error):
                closure(DetailVideoModel(), error)
            }
        }
    }



//    func swapImageVideo(device_them_su_kien:String,src_vid:String,ip_them_su_kien:String,id_user:String,link_img:String, ten_video:String,closure: @escaping (_ response: DetailVideoModel?, _ error: Error?) -> Void) {
//        
//        
//    }
    func RemoveMyAccount(userID:String,password:String,closure: @escaping (_ response: String, _ error: Error?) -> Void) {
        let paramSend:[String: String] = ["password":password]
        let linkUrl = "https://databaseswap.mangasocial.online/deleteuser/" + userID
        requestRemoveAccount(linkUrl, param: paramSend, method: .POST, loading: true) { (data, error) in
            if let data2 = data as? [String:Any]{
                var messageSend = ""
                if let temp = data2["message"] as? String {messageSend = temp}
                closure(messageSend,nil)
            }else{
                if let data = data as? String{
                    closure(data,nil)
                }
                closure("ERROR NO Message",nil)
            }
        }
        // closure("Please Wait To Remove", nil)
    }
    func AddEvent(ten_sukien: String,noidung_su_kien: String,ten_nam:String,ten_nu:String, id_template :Int ,device: String,ip_them_su_kien:String, ip: Int, userId: String, imageLink: String,link_video:String,  closure: @escaping (_ response: String?, _ error: Error?) -> Void) {
        let urlString = "https://databaseswap.mangasocial.online/lovehistory/add/\(ip)"
        let newString1 = imageLink.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
        let parameters: [String: String] = [
            "ten_sukien": ten_sukien,
            "noidung_su_kien": noidung_su_kien,
            "ten_nam": ten_nam,
            "ten_nu": ten_nu,
            "device_them_su_kien": device,
            "ip_them_su_kien": ip_them_su_kien,
            "link_img": imageLink,
            "link_video": link_video,
            "id_user": userId,
            "id_template": String(id_template)
           
        ]
        let token_login: String = KeychainWrapper.standard.string(forKey: "token_login") ?? "ADSF"
        //print("token : " + token_login + " 99999999. sdfdgdsfg")
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                if let data = value.data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }
//            multipartFormData.append(videoFile, withName: "src_vid", fileName: "video.mp4", mimeType: "video/mp4")
        }, to: urlString, method: .post, headers: ["Authorization": "Bearer " + token_login])
        .responseJSON { (response) in
            switch response.result {
            case .success(let data):
                if let data = data as? [String:String]{
//                    var itemAdd:DetailVideoModel = DetailVideoModel()
//                    itemAdd = itemAdd.initLoad(data)
                    var dau = data["message"]
                    closure( dau , nil)
                    
                }else{
                    closure( "DetailVideoModel()", nil)
                }
            case .failure(let error):
                closure("DetailVideoModel()", error)
            }
        }
    }


}









