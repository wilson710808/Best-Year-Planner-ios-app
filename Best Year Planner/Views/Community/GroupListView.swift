import SwiftUI

struct GroupListView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @State private var searchText = ""
    @State private var selectedTheme: String?

    private var filteredGroups: [CommunityGroup] {
        var result = viewModel.groups

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.theme.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let theme = selectedTheme {
            result = result.filter { $0.theme == theme }
        }

        return result
    }

    private var availableThemes: [String] {
        Array(Set(viewModel.groups.map { $0.theme })).sorted()
    }

    var body: some View {
        VStack(spacing: 0) {
            // 搜尋欄
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textSecondary)

                TextField("搜尋揪團...", text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .padding()
            .background(AppColors.cardBackground)

            // 主題篩選
            if !availableThemes.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "全部", isSelected: selectedTheme == nil) {
                            selectedTheme = nil
                        }

                        ForEach(availableThemes, id: \.self) { theme in
                            FilterChip(title: theme, isSelected: selectedTheme == theme) {
                                selectedTheme = theme
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(AppColors.cardBackground)
            }

            // 揪團列表
            if filteredGroups.isEmpty {
                EmptyStateView(
                    icon: "person.3.fill",
                    title: searchText.isEmpty ? "還沒有揪團" : "搜尋無結果",
                    message: searchText.isEmpty ? "創建或加入一個揪團吧！" : "試試其他關鍵字"
                )
                .padding(.top, 40)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredGroups) { group in
                            NavigationLink(destination: GroupDetailView(group: group, viewModel: viewModel)) {
                                GroupCardView(group: group)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(StringConstants.Community.groups)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadGroups()
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AppColors.primary : Color.white)
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? AppColors.primary : AppColors.divider, lineWidth: 1)
                )
        }
    }
}
