//
//  AnalyzeView.swift
//  SodamProject
//
//  Created by 강윤서 on 9/1/25.
//

import SwiftUI

struct AnalyzeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("분석 결과")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                
                Text("분석이 완료되었습니다!")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .navigationTitle("분석 결과")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AnalyzeView()
}
