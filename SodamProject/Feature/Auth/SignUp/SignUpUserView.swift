//
//  SignUpUserView.swift
//  SodamProject
//
//  Created by 강윤서 on 8/14/25.
//

import SwiftUI

struct SignUpUserView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var phone = ""
    @State private var birthDate = Date()
    @State private var showingDatePicker = false
    @State private var goNext = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }

    private var isNextEnabled: Bool {
        !name.isEmpty && !phone.isEmpty
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
                        
                        ProgressBarView(currentStep: 2, totalSteps: 4)
                            .padding(.horizontal, 130)
                    }

                    Text("사용자 정보를 입력해주세요")
                        .font(.system(size: 24, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            groupField(title: "이름") {
                                InputField(placeholder: "이름을 입력해 주세요",
                                           text: $name)
                            }

                            groupField(title: "전화번호") {
                                InputField(placeholder: "전화번호를 입력해 주세요",
                                           text: $phone,
                                           keyboardType: .phonePad)
                            }

                            groupField(title: "생년월일") {
                                Button {
                                    showingDatePicker = true
                                } label: {
                                    HStack {
                                        Text(dateFormatter.string(from: birthDate))
                                            .foregroundColor(.black)
                                        Spacer()
                                        Image(systemName: "calendar")
                                            .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(red: 0.39, green: 0.45, blue: 0.55).opacity(0.55), lineWidth: 1)
                                    )
                                    .cornerRadius(10)
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
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingDatePicker) {
                NavigationView {
                    DatePicker(
                        "생년월일",
                        selection: $birthDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .navigationTitle("생년월일 선택")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("완료") {
                                showingDatePicker = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
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
}

#Preview {
    SignUpUserView()
}
