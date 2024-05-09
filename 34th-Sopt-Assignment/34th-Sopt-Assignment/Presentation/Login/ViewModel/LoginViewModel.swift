//
//  LoginViewModel.swift
//  34th-Sopt-Assignment
//
//  Created by 김진웅 on 5/9/24.
//

import Combine
import CombineCocoa

final class LoginViewModel {
    
    @Published var idInput = ""
    
    @Published var pwInput = ""
    
    lazy var isLoginButtonEnabled: AnyPublisher<Bool, Never> = Publishers
        .CombineLatest($idInput, $pwInput)
        .map { (id: String, pw: String) in
            return !id.isEmpty && !pw.isEmpty
        }
        .eraseToAnyPublisher()
    
}
