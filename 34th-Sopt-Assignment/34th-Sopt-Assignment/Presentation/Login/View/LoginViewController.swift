//
//  LoginViewController.swift
//  34th-Sopt-Assignment
//
//  Created by 김진웅 on 4/15/24.
//

import Then
import UIKit
import SnapKit
import Combine
import CombineCocoa

final class LoginViewController: UIViewController, AlertShowable {
    
    // MARK: - Component
    
    private let titleLabel = UILabel()
    private let idTextField = TvingTextField(placeholder: "아이디", type: .id)
    private let idTextFieldRightView = UIView()
    private let idClearButton = UIButton()
    private let pwTextField = TvingTextField(placeholder: "비밀번호", type: .pw)
    private let pwTextFieldRightView = UIView()
    private let pwClearButton = UIButton()
    private let pwShowButton = UIButton()
    private let loginButton = UIButton()
    private let findIDButton = UIButton()
    private let divider = UIView()
    private let findPWButton = UIButton()
    private let helpButton = UIButton()
    private let nicknameButton = UIButton()
    
    // MARK: - Property
    
    private let viewModel: LoginViewModel
    
    private var anyCancellables = Set<AnyCancellable>()
    private var nickname: String?
    
    // MARK: - Initializer
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setViewHierarchy()
        setAutoLayout()
        setDelegate()
        
        configureViewModel()
        configureAction()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - Configure Method

private extension LoginViewController {
    func configureViewModel() {
        idTextField.textPublisher
            .sink { [weak self] text in
                self?.viewModel.idTextFieldDidChange(text)
            }
            .store(in: &anyCancellables)
        
        pwTextField.textPublisher
            .sink { [weak self] text in
                self?.viewModel.passwordTextFieldDidChange(text)
            }
            .store(in: &anyCancellables)
        
        loginButton.tapPublisher
            .sink { [weak self] _ in
                self?.viewModel.loginButtonDidTap()
            }
            .store(in: &anyCancellables)
        
        viewModel.isLoginEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] flag in
                self?.toggleLoginButton(flag)
            }
            .store(in: &anyCancellables)
        
        viewModel.isSucceedToLogin
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                switch result {
                case .success(let id):
                    self?.moveToWelcome(with: id)
                case .failure(let error):
                    self?.showAlert(title: error.description, message: error.message)
                }
            }
            .store(in: &anyCancellables)
    }
    
    func configureAction() {
        idClearButton.tapPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.idTextField.text = nil
                self?.idTextField.insertText("")
            }
            .store(in: &anyCancellables)
        
        pwClearButton.tapPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.pwTextField.text = nil
                self?.pwTextField.insertText("")
            }
            .store(in: &anyCancellables)
        
        pwShowButton.tapPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                pwTextField.isSecureTextEntry.toggle()
                let image = UIImage(resource: pwTextField.isSecureTextEntry ? .eyeSlash : .eye)
                pwShowButton.setImage(image, for: .normal)
            }
            .store(in: &anyCancellables)
        
        nicknameButton.tapPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.moveToNickname()
            }
            .store(in: &anyCancellables)
    }
}

// MARK: - Private Method

private extension LoginViewController {
    func moveToWelcome(with id: String) {
        let viewController = WelcomeViewController(id: id, nickname: nickname)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func moveToNickname() {
        let viewModel = NicknameViewModel()
        let viewController = MakeNicknameViewController(viewModel: viewModel)
        viewController.delegate = self
        viewController.modalPresentationStyle = .formSheet
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        present(viewController, animated: true)
    }
    
    func toggleLoginButton(_ flag: Bool) {
        let borderWidth: CGFloat = flag ? 0 : 1
        let titleColor: UIColor = flag ? .white : .gray2
        let backgroundColor: UIColor = flag ? .tvingRed : .black
        
        loginButton.setTitleColor(titleColor, for: .normal)
        loginButton.backgroundColor = backgroundColor
        loginButton.layer.borderWidth = borderWidth
        loginButton.isEnabled = flag
    }
}


// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
    }
}

// MARK: - MakeNicknameViewDelegate

extension LoginViewController: MakeNicknameViewDelegate {
    func configure(nickname: String) {
        self.nickname = nickname
    }
}

private extension LoginViewController {
    
    // MARK: - SetUI
    
    func setUI() {
        view.backgroundColor = .black
        
        titleLabel.do {
            $0.setText("TVING ID 로그인", color: .gray1, font: .pretendard(weight: .five, size: 23))
            $0.textAlignment = .center
        }
        
        idTextField.rightView = idTextFieldRightView
        
        idClearButton.setImage(UIImage(resource: .xCircle), for: .normal)
        
        pwTextField.rightView = pwTextFieldRightView
        
        pwShowButton.setImage(UIImage(resource: .eyeSlash), for: .normal)
        
        pwClearButton.setImage(UIImage(resource: .xCircle), for: .normal)
        
        loginButton.do {
            $0.setTitle(
                title: "로그인하기",
                titleColor: .gray2,
                font: .pretendard(weight: .six, size: 14)
            )
            $0.setLayer(borderWidth: 1)
            $0.isEnabled = false
            $0.backgroundColor = .black
        }
        
        findIDButton.do {
            $0.setTitle(
                title: "아이디 찾기",
                titleColor: .gray2,
                font: .pretendard(weight: .six, size: 14)
            )
        }
        
        divider.backgroundColor = .gray4
        
        findPWButton.do {
            $0.setTitle(
                title: "비밀번호 찾기",
                titleColor: .gray2,
                font: .pretendard(weight: .six, size: 14)
            )
        }
        
        helpButton.do {
            $0.setTitle(
                title: "아직 계정이 없으신가요?",
                titleColor: .gray3,
                font: .pretendard(weight: .six, size: 14)
            )
        }
        
        nicknameButton.do {
            $0.setTitle(
                title: "닉네임 만들러가기",
                titleColor: .gray2,
                font: .pretendard(weight: .four, size: 14)
            )
            $0.addUnderline()
        }
    }
    
    func setViewHierarchy() {
        view.addSubviews(
            titleLabel, idTextField, pwTextField, loginButton, findIDButton,
            divider, findPWButton, helpButton, nicknameButton
        )
        
        idTextFieldRightView.addSubview(idClearButton)
        pwTextFieldRightView.addSubviews(pwShowButton, pwClearButton)
    }
    
    // MARK: - AutoLayout
    
    func setAutoLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(safeArea.snp.top).offset(50)
        }
        
        idTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.horizontalEdges.equalTo(safeArea).inset(20)
            $0.height.equalTo(Constants.UI.textFieldAndButtonHeight)
        }
        
        idTextFieldRightView.snp.makeConstraints {
            $0.width.equalTo(35)
            $0.height.equalTo(Constants.UI.textFieldAndButtonHeight)
        }
        
        idClearButton.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.leading.centerY.equalTo(idTextFieldRightView)
        }
        
        pwTextField.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom).offset(7)
            $0.horizontalEdges.height.equalTo(idTextField)
        }
        
        pwTextFieldRightView.snp.makeConstraints {
            $0.width.equalTo(70)
            $0.height.equalTo(Constants.UI.textFieldAndButtonHeight)
        }
        
        pwShowButton.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.leading.centerY.equalTo(pwTextFieldRightView)
        }
        
        pwClearButton.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.trailing.equalTo(pwTextFieldRightView.snp.trailing).offset(-20)
            $0.centerY.equalTo(pwTextFieldRightView)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(pwTextField.snp.bottom).offset(20)
            $0.horizontalEdges.height.equalTo(idTextField)
        }
        
        findIDButton.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(30)
            $0.leading.equalTo(safeArea.snp.leading).offset(85)
            $0.height.equalTo(22)
        }
        
        divider.snp.makeConstraints {
            $0.centerY.equalTo(findIDButton)
            $0.centerX.equalToSuperview().offset(-2)
            $0.width.equalTo(1)
            $0.height.equalTo(12)
        }
        
        findPWButton.snp.makeConstraints {
            $0.top.height.equalTo(findIDButton)
            $0.trailing.equalTo(safeArea.snp.trailing).offset(-85)
        }
        
        helpButton.snp.makeConstraints {
            $0.top.equalTo(findIDButton.snp.bottom).offset(30)
            $0.leading.equalTo(safeArea.snp.leading).offset(50)
            $0.height.equalTo(findIDButton)
        }
        
        nicknameButton.snp.makeConstraints {
            $0.top.height.equalTo(helpButton)
            $0.trailing.equalTo(safeArea.snp.trailing).offset(-50)
            $0.width.equalTo(128)
        }
    }
    
    // MARK: - Delegate

    func setDelegate() {
        idTextField.delegate = self
        pwTextField.delegate = self
    }
}
