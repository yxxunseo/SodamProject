//
//  SignUpView.swift
//  SodamProject
//
//  Created by 강윤서 on 8/12/25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCheckmark = false
    @State private var checkmarkScale: CGFloat = 0.0
    @State private var checkmarkRotation: Double = 0.0
    @State private var selectedRole: Role? = nil
    @State private var goNext = false
    
    enum Role: String, CaseIterable {
        case todayBoss = "오늘도 사장"
        case tomorrowBoss = "내일은 사장"
        
        var subtitle: String {
            switch self {
            case .todayBoss:
                return "(매장을 운영 중이에요)"
            case .tomorrowBoss:
                return "(창업을 준비하고 있어요)"
            }
        }
        
        var icon: String {
            switch self {
            case .todayBoss:
                return "Building"
            case .tomorrowBoss:
                return "Fire"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
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
                    
                    ProgressBarView(currentStep: 4, totalSteps: 4)
                        .padding(.horizontal, 130)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    ZStack {
                        Image("Check")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .scaleEffect(checkmarkScale)
                            .rotationEffect(.degrees(checkmarkRotation))
                            .rotation3DEffect(
                                .degrees(checkmarkRotation),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .opacity(showCheckmark ? 1.0 : 0.0)
                    }
                    .padding(.bottom, 40)
                    
                    VStack(spacing: 12) {
                        Text("회원가입 완료")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#4A4A4A"))
                        
                        Text("홍길동님 반가워요!")
                            .font(.body)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                        
                        Text("당신의 역할을 선택해주세요.")
                            .font(.body)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.bottom, 50)
                    
                    HStack(spacing: 20) {
                        ForEach(Role.allCases, id: \.self) { role in
                            RoleSelectionCard(
                                role: role,
                                isSelected: selectedRole == role
                            ) {
                                selectedRole = role
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    DefaultButton(
                        title: "시작하기"
                    ) {
                        goNext = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $goNext) {
                HomeView()
            }
        }
        .onAppear {
            startCheckmarkAnimation()
        }
    }
    
    private func startCheckmarkAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)) {
            showCheckmark = true
            checkmarkScale = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.3)) {
                checkmarkScale = 1.1
            }
            
            withAnimation(.easeInOut(duration: 0.3).delay(0.3)) {
                checkmarkScale = 1.0
            }
        }
    }
}

struct RoleSelectionCard: View {
    let role: SignUpView.Role
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                Text(role.rawValue)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "#4A4A4A"))
                
                Text(role.subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                    Image(role.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)

            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? Color.green : Color.gray.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: Color.black.opacity(0.05),
                        radius: 8,
                        x: 0,
                        y: 2
                    )
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}


#Preview {
    SignUpView()
}
