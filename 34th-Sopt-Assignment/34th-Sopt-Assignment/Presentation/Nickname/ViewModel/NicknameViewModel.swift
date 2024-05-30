//
//  NicknameViewModel.swift
//  34th-Sopt-Assignment
//
//  Created by 김진웅 on 5/31/24.
//

import Combine
import CombineCocoa

final class NicknameViewModel {
    
    // MARK: - Output
    
    var isSaveEnabled: AnyPublisher<Bool, Never> { setIsSaveEnabled() }
    var isSucceedToSave: AnyPublisher<Result<String, AppError>, Never> { setIsSucceedToSave() }
    
    // MARK: - Input Subject
    
    private let nicknameTextFieldDidChangeSubject = CurrentValueSubject<String?, Never>("")
    private let saveButtonDidTapSubject = PassthroughSubject<Void, Never>()

    // MARK: - Input

    func nicknameTextFieldDidChange(_ text: String?) {
        nicknameTextFieldDidChangeSubject.send(text)
    }
    
    func saveButtonDidTap() {
        saveButtonDidTapSubject.send(())
    }
}

extension NicknameViewModel: RegexCheckable {}

private extension NicknameViewModel {
    func setIsSaveEnabled() -> AnyPublisher<Bool, Never> {
        return nicknameTextFieldDidChangeSubject
            .map { text in
                guard let nickname = text,
                      !nickname.isEmpty
                else {
                    return false
                }
                return true
            }
            .eraseToAnyPublisher()
    }
    
    func setIsSucceedToSave() -> AnyPublisher<Result<String, AppError>, Never> {
        return saveButtonDidTapSubject
            .flatMap { _ -> Future<Result<String, AppError>, Never> in
                return Future<Result<String, AppError>, Never> { [weak self] promise in
                    guard let self,
                          let nickname = nicknameTextFieldDidChangeSubject.value
                    else {
                        promise(.success(.failure(.unknown)))
                        return
                    }
                    
                    if !checkFrom(input: nickname, regex: .nickname) {
                        promise(.success(.failure(.nickname)))
                        return
                    }
                    
                    promise(.success(.success(nickname)))
                }
            }
            .eraseToAnyPublisher()
    }
}
