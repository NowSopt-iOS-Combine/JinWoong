//
//  MakeNicknameViewController.swift
//  34th-Sopt-Assignment
//
//  Created by 김진웅 on 4/17/24.
//

import Then
import UIKit
import SnapKit
import Combine
import CombineCocoa

protocol MakeNicknameViewDelegate: AnyObject {
    func configure(nickname: String)
}

final class MakeNicknameViewController: UIViewController, RegexCheckable, AlertShowable {
    
    // MARK: - Component
    
    private let titleLabel = UILabel()
    private let nicknameTextField = TvingTextField(placeholder: "닉네임", type: .nickname)
    private let descriptionLabel = UILabel()
    private let saveButton = UIButton()
    
    // MARK: - Property
    
    weak var delegate: MakeNicknameViewDelegate?
    
    private let viewModel: NicknameViewModel
    
    private var anyCancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init(viewModel: NicknameViewModel) {
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
        
        configureViewModel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - Configure Method

private extension MakeNicknameViewController {
    func configureViewModel() {
        nicknameTextField.textPublisher
            .sink { [weak self] text in
                self?.viewModel.nicknameTextFieldDidChange(text)
                self?.descriptionLabel.text = text
            }
            .store(in: &anyCancellables)
        
        saveButton.tapPublisher
            .sink { [weak self] _ in
                self?.viewModel.saveButtonDidTap()
            }
            .store(in: &anyCancellables)
        
        viewModel.isSaveEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] flag in
                self?.toggleSaveButton(flag)
            }
            .store(in: &anyCancellables)
        
        viewModel.isSucceedToSave
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                switch result {
                case .success(let nickname):
                    self?.delegate?.configure(nickname: nickname)
                    self?.dismiss(animated: true)
                case .failure(let error):
                    self?.showAlert(title: error.description, message: error.message)
                }
            }
            .store(in: &anyCancellables)
    }
}

// MARK: - Private Method

private extension MakeNicknameViewController {
    func toggleSaveButton(_ flag: Bool) {
        let titleColor: UIColor = flag ? .white : .gray2
        let backgroundColor: UIColor = flag ? .tvingRed : .black
        let borderWidth: CGFloat = flag ? 0 : 1
        
        saveButton.setTitleColor(titleColor, for: .normal)
        saveButton.backgroundColor = backgroundColor
        saveButton.layer.borderWidth = borderWidth
        saveButton.isEnabled = flag
    }
}

private extension MakeNicknameViewController {
    
    // MARK: - SetUI
    
    func setUI() {
        view.backgroundColor = .systemBackground
        
        titleLabel.setText(
            "닉네임을 입력해주세요",
            color: .black,
            font: .pretendard(weight: .five, size: 23)
        )
        
        descriptionLabel.do {
            $0.setText("", color: .white, font: .pretendard(weight: .five, size: 23))
            $0.backgroundColor = .gray4
            $0.textAlignment = .center
            $0.layer.cornerRadius = 10
            $0.numberOfLines = 0
        }
        
        saveButton.do {
            $0.setTitle(title: "저장하기", titleColor: .gray2, font: .pretendard(weight: .six, size: 14))
            $0.setLayer(borderWidth: 1, cornerRadius: 12)
            $0.isEnabled = false
            $0.backgroundColor = .black
        }
    }
    
    func setViewHierarchy() {
        view.addSubviews(titleLabel, nicknameTextField, descriptionLabel, saveButton)
    }
    
    // MARK: - AutoLayout
    
    func setAutoLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(50)
            $0.leading.equalToSuperview().offset(20)
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(Constants.UI.textFieldAndButtonHeight)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(10)
            $0.horizontalEdges.equalTo(nicknameTextField)
        }
        
        saveButton.snp.makeConstraints {
            $0.bottom.equalTo(safeArea.snp.bottom).offset(-10)
            $0.horizontalEdges.height.equalTo(nicknameTextField)
        }
    }
}
