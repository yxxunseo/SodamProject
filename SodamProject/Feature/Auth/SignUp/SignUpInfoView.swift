//
//  SignUpInfoView.swift
//  SodamProject
//
//  Created by 강윤서 on 8/13/25.
//

// TODO : 아이디, 이메일 중복 체크
import SwiftUI

struct SignUpInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var id = ""
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirm = ""
    @State private var goNext = false

    private var isValidEmail: Bool {
        email.isEmpty || isValidEmailFormat(email)
    }
    
    private var isValidPassword: Bool {
        password.isEmpty || isValidPasswordFormat(password)
    }
    
    private var passwordsMatch: Bool {
        passwordConfirm.isEmpty || password == passwordConfirm
    }

    private var isNextEnabled: Bool {
        !id.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !passwordConfirm.isEmpty &&
        isValidEmail &&
        isValidPassword &&
        passwordsMatch
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 35) {
                    VStack(spacing: 10) {
                        HStack(spacing: 24) {
                            Button { dismiss() } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title3.weight(.semibold))
                            }
                            .foregroundColor(Color(red: 0.29, green: 0.29, blue: 0.29))
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        
                        ProgressBarView(currentStep: 1, totalSteps: 4)
                            .padding(.horizontal, 130)
                    }

                    Text("계정 정보를 입력해주세요")
                        .font(.system(size: 24, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            groupField(title: "아이디") {
                                InputField(placeholder: "아이디를 입력해 주세요",
                                           text: $id,
                                           keyboardType: .default)
                                .textInputAutocapitalization(.never) // 대문자 시작X
                                .autocorrectionDisabled()
                                .onChange(of: id) { _, newValue in
                                    // 한국어 입력 필터링
                                    let filtered = newValue.filter { char in
                                        let unicode = char.unicodeScalars.first!
                                        return (unicode.value >= 0x0020 && unicode.value <= 0x007F)
                                    }
                                    if filtered != newValue {
                                        id = filtered
                                    }
                                }
                            }
                            
                            groupField(title: "이메일") {
                                InputField(placeholder: "이메일을 입력해 주세요",
                                           text: $email,
                                           keyboardType: .emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                
                                if !email.isEmpty && !isValidEmail {
                                    Text("올바른 이메일 형식을 입력해주세요")
                                        .font(.footnote)
                                        .foregroundStyle(.red)
                                        .padding(.top, 1)
                                }
                            }
                            
                            groupField(title: "비밀번호") {
                                InputField(placeholder: "비밀번호를 입력해 주세요",
                                           text: $password,
                                           isSecure: true)
                                
                                if !password.isEmpty {
                                    if isValidPassword {
                                        Text("비밀번호는 8자 이상, 문자·숫자·특수문자 중 2가지 이상 포함")
                                            .font(.footnote)
                                            .foregroundStyle(.green)
                                            
                                    } else {
                                        Text("비밀번호는 8자 이상, 문자·숫자·특수문자 중 2가지 이상 포함")
                                            .font(.footnote)
                                            .foregroundStyle(.red)
                                    }
                                }
                            }
                            

                            groupField(title: "비밀번호 확인") {
                                InputField(placeholder: "비밀번호를 다시 입력해 주세요",
                                           text: $passwordConfirm,
                                           isSecure: true)
                                
                                if !passwordConfirm.isEmpty {
                                    if passwordsMatch {
                                        Text("비밀번호가 일치합니다")
                                            .font(.footnote)
                                            .foregroundStyle(.green)
                                            .padding(.top, 1)
                                    } else {
                                        Text("비밀번호가 일치하지 않습니다")
                                            .font(.footnote)
                                            .foregroundStyle(.red)
                                            .padding(.top, 1)
                                    }
                                }
                            }

                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 120)
                    }
                }

                VStack {
                    Spacer()
                    DefaultButton(
                        title: "다음",
                        action: onTapNext,
                        isEnabled: isNextEnabled
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture{
                UIApplication.shared.sendAction(#selector(UIResponder.resolveInstanceMethod(_:)), to: nil, from: nil, for: nil)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $goNext) {
                SignUpUserView()
            }
        }
    }

    private func groupField<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline.weight(.semibold))
            content()
        }
    }

    private func onTapNext() {
        guard isNextEnabled else { return }
        goNext = true
    }
    
    // 이메일 형식 검증 함수
    private func isValidEmailFormat(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // 비밀번호 형식 검증 함수
    private func isValidPasswordFormat(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }
        
        let hasLetter = password.rangeOfCharacter(from: .letters) != nil
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecial = password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil
        
        let conditions = [hasLetter, hasNumber, hasSpecial].filter { $0 }
        return conditions.count >= 2
    }
}

#Preview {
    SignUpInfoView()
}
