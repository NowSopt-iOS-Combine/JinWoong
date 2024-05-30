//
//  LoginViewModel.swift
//  34th-Sopt-Assignment
//
//  Created by 김진웅 on 5/9/24.
//

import Combine

final class LoginViewModel {
    
    // MARK: - Output
    
    var isLoginEnabled: AnyPublisher<Bool, Never> { setIsLoginEnabled() }
    var isSucceedToLogin: AnyPublisher<Result<String, AppError>, Never> { setIsSucceedToLogin() }
    
    // MARK: - Input Subject

    private let idTextFieldDidChangeSubject = CurrentValueSubject<String?, Never>("")
    private let passwordTextFieldDidChangeSubject = CurrentValueSubject<String?, Never>("")
    private let loginButtonDidTapSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Input
    
    func idTextFieldDidChange(_ text: String?) {
        idTextFieldDidChangeSubject.send(text)
    }
    
    func passwordTextFieldDidChange(_ text: String?) {
        passwordTextFieldDidChangeSubject.send(text)
    }
    
    func loginButtonDidTap() {
        loginButtonDidTapSubject.send(())
    }
}

extension LoginViewModel: RegexCheckable {}

private extension LoginViewModel {
    func setIsLoginEnabled() -> AnyPublisher<Bool, Never> {
        return Publishers
            .CombineLatest(idTextFieldDidChangeSubject, passwordTextFieldDidChangeSubject)
            .map { id, pw in
                guard let id, !id.isEmpty,
                      let pw, !pw.isEmpty
                else {
                    return false
                }
                return true
            }
            .eraseToAnyPublisher()
    }
    
    func setIsSucceedToLogin() -> AnyPublisher<Result<String, AppError>, Never> {
        return loginButtonDidTapSubject.flatMap { _ -> Future<Result<String, AppError>, Never> in
            return Future<Result<String, AppError>, Never> { [weak self] promise in
                guard let self,
                      let id = idTextFieldDidChangeSubject.value,
                      let pw = passwordTextFieldDidChangeSubject.value
                else {
                    promise(.success(.failure(.unknown)))
                    return
                }
                
                if !checkFrom(input: id, regex: .id) {
                    promise(.success(.failure(.login(error: .invalidID))))
                    return
                }
                
                if !checkFrom(input: pw, regex: .pw) {
                    promise(.success(.failure(.login(error: .invalidPW))))
                    return
                }
                
                promise(.success(.success(id)))
            }
        }
        .eraseToAnyPublisher()
    }
}
