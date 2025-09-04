//
//  LoginView.swift
//  SodamProject
//
//  Created by 강윤서 on 8/12/25.
//

import SwiftUI

struct LoginView: View {
    @State private var id: String = ""
    @State private var password: String = ""
    @State private var isLoggin: Bool = false
    @State private var navigateToHome = false
    @State private var navigateToSighUp = false
    
    private var tempId: String = "1234" // 임시 아이디
    private var tempPw: String = "qwer1234" // 임시 비번
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                AppName()
                    .padding(.bottom, 20)
                VStack(spacing: 24) {
                    InputField(placeholder: "아이디를 입력해주세요", text: $id)
                    InputField(placeholder: "비밀번호를 입력해주세요", text: $password, isSecure: true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                DefaultButton(title: "로그인") {
                    // 로그인 로직 처리
                    if id == tempId && password == tempPw {
                        navigateToHome = true
                    } else {
                        print("로그인 실패")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                
            
                HStack(spacing: 10) {
                    Button("회원가입") {
                        navigateToSighUp = true
                    }
                    .foregroundColor(Color(hex: "7DDB69"))
                    
                    Text("|")
                        .foregroundColor(Color(hex: "999999"))
                    
                    Button("아이디 찾기") {
                        // 아이디 찾기 페이지로 이동
                    }
                    .foregroundColor(Color(hex: "999999"))
                    
                    Text("|")
                        .foregroundColor(Color(hex: "999999"))
                    
                    Button("비밀번호 찾기") {
                        // 아이디 찾기 페이지로 이동
                    }
                    .foregroundColor(Color(hex: "999999"))
                }
                .font(.system(size: 15))
                .padding(.top, 32)
                
                Spacer()
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
            }
            
            .navigationDestination(isPresented: $navigateToSighUp) {
                SignUpInfoView()
            }
        }
    }
}

#Preview {
    LoginView()
}
