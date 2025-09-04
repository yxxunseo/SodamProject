import SwiftUI
import MapKit
import CoreLocation

struct MyAreaDiagnosisView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var showBottomSheet = false
    @State private var selectedCategory = ""
    @State private var selectedSubCategory = ""
    @State private var showSubCategories = false
    @State private var navigateToAnalyze = false
    
    var body: some View {
        ZStack {
            // 지도
            Map(position: $locationManager.cameraPosition) {
                // 사용자 위치 마커
                if let userLocation = locationManager.userLocation {
                    Marker("내 위치", coordinate: userLocation.coordinate)
                        .tint(.blue)
                }
                
                // 검색된 위치 마커와 반경 원
                if let selectedLocation = selectedLocation {
                    Marker("진단 위치", coordinate: selectedLocation)
                        .tint(.red)
                    
                    // 500m 반경 원
                    MapCircle(center: selectedLocation, radius: 500)
                        .foregroundStyle(.red.opacity(0.3))
                        .stroke(.red, lineWidth: 2)
                }
            }
            .mapStyle(.standard)
            .ignoresSafeArea(.all)
            .onAppear {
                locationManager.requestLocation()
            }
            
            // 검색바
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 16)
                    
                    TextField("검색하거나 지도에서 위치를 선택해주세요", text: $searchText)
                        .padding(.vertical, 12)
                        .padding(.trailing, 16)
                        .onSubmit {
                            searchLocation()
                        }
                        .onTapGesture {
                            if !showBottomSheet && selectedLocation != nil {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    showBottomSheet = true
                                }
                            }
                        }
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .background(Color.white)
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                Spacer()
            }
            
            // Bottom Sheet
            if showBottomSheet {
                VStack {
                    Spacer()
                    
                    BottomSheetView(
                        selectedLocation: selectedLocation,
                        selectedCategory: $selectedCategory,
                        selectedSubCategory: $selectedSubCategory,
                        showSubCategories: $showSubCategories,
                        navigateToAnalyze: $navigateToAnalyze,
                        showBottomSheet: $showBottomSheet
                    )
                    .transition(.move(edge: .bottom))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showBottomSheet)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToAnalyze) {
            AnalyzeView()
        }
    }
    
    private func searchLocation() {
        guard !searchText.isEmpty else { return }
        
        // 키보드 숨기기
        hideKeyboard()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(
            center: locationManager.userLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 36.3504, longitude: 127.3845),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if error != nil {
                return
            }

            guard let response = response, let firstResult = response.mapItems.first else {
                return
            }
            
            DispatchQueue.main.async {
                self.selectedLocation = firstResult.placemark.coordinate
                self.locationManager.cameraPosition = MapCameraPosition.region(
                    MKCoordinateRegion(
                        center: firstResult.placemark.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
                self.showBottomSheet = true
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct BottomSheetView: View {
    let selectedLocation: CLLocationCoordinate2D?
    @Binding var selectedCategory: String
    @Binding var selectedSubCategory: String
    @Binding var showSubCategories: Bool
    @Binding var navigateToAnalyze: Bool
    @Binding var showBottomSheet: Bool
    @State private var dragOffset: CGFloat = 0
    
    private let mainCategories = ["전체", "외식업", "서비스업", "소매업"]
    private let restaurantSubCategories = ["한식음식점", "중식음식점", "일식음식점", "양식음식점", "제과점", "패스트푸드점", "치킨전문점", "분식전문점", "호프-간이주점", "커피-음료"]
    private let serviceSubCategories = ["일반교습학원", "외국어학원", "예술학원", "컴퓨터학원", "스포츠강습", "일반의원", "치과의원", "한의원", "동물병원"]
    private let retailSubCategories = ["슈퍼마켓", "편의점", "주류도매", "육류판매", "수산물판매", "반찬가게", "일반의류", "신발", "유아의류", "의약품", "서적", "문구"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 핸들바와 닫기 버튼
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 4)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showBottomSheet = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 16) {
                // 위치 정보
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text("진단 위치")
                            .font(.headline)
                        Text("500m 반경 분석")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                    
                    VStack(alignment: .trailing) {
                        Text("내 위치")
                            .font(.headline)
                        Text("현재 위치")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // 카테고리 선택
                VStack(alignment: .leading, spacing: 12) {
                    Text("업종 선택")
                        .font(.headline)
                        .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(mainCategories, id: \.self) { category in
                            CategoryButton(
                                title: category,
                                isSelected: selectedCategory == category,
                                action: {
                                    selectedCategory = category
                                    selectedSubCategory = ""
                                    showSubCategories = category != "전체"
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // 하위 카테고리
                if showSubCategories {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("세부 업종 선택")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(getSubCategories(), id: \.self) { subCategory in
                                CategoryButton(
                                    title: subCategory,
                                    isSelected: selectedSubCategory == subCategory,
                                    action: {
                                        selectedSubCategory = subCategory
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // 분석하기 버튼
                VStack(spacing: 0) {
                    Divider()
                        .padding(.horizontal, 20)
                    
                    DefaultButton(
                        title: "분석하기",
                        action: {
                            navigateToAnalyze = true
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .disabled(!isAnalyzeButtonEnabled)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        .offset(y: dragOffset)
        .clipped()
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height > 0 {
                        // 최대 드래그 거리 제한 (화면 높이의 50%까지만)
                        let maxDrag = UIScreen.main.bounds.height * 0.5
                        dragOffset = min(value.translation.height, maxDrag)
                    }
                }
                .onEnded { value in
                    if value.translation.height > 150 {
                        // 150px 이상 드래그 시에만 바텀시트 숨김
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showBottomSheet = false
                            dragOffset = 0
                        }
                    } else {
                        // 그 외에는 원래 위치로 복귀
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            dragOffset = 0
                        }
                    }
                }
        )
    }
    
    private func getSubCategories() -> [String] {
        switch selectedCategory {
        case "외식업":
            return restaurantSubCategories
        case "서비스업":
            return serviceSubCategories
        case "소매업":
            return retailSubCategories
        default:
            return []
        }
    }
    
    private var isAnalyzeButtonEnabled: Bool {
        if selectedCategory == "전체" {
            return true
        } else {
            return !selectedSubCategory.isEmpty
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .black)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 36.3504, longitude: 127.3845), // 기본값: 대전시청
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // 줌 레벨 조정 (적당히)
        )
    )
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            break
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.userLocation = location
            // 설정된 줌 레벨로 위치 업데이트
            self.cameraPosition = MapCameraPosition.region(
                MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 오류 처리 (필요시)
    }
}

#Preview {
    MyAreaDiagnosisView()
}
