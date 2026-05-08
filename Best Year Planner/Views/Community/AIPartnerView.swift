import SwiftUI

struct AIPartnerView: View {
    @StateObject private var viewModel: AIPartnerViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(partnerName: String = "小夥伴", buddyRole: BuddyRole = .companion) {
        _viewModel = StateObject(wrappedValue: AIPartnerViewModel(partnerName: partnerName, buddyRole: buddyRole))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                ChatBubbleView(message: message, isPartner: true)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) {
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                HStack(spacing: 12) {
                    TextField("和夥伴聊聊...", text: $viewModel.inputText)
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )

                    Button(action: {
                        _Concurrency.Task {
                            await viewModel.sendMessage()
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(viewModel.inputText.isEmpty ? AppColors.disabled : AppColors.secondary)
                            .cornerRadius(22)
                    }
                    .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
                }
                .padding()
                .background(AppColors.cardBackground)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("\(viewModel.buddyRole.emoji) \(viewModel.partnerName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("關閉")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            viewModel.clearConversation()
                            _Concurrency.Task {
                                await viewModel.loadWelcomeMessage()
                            }
                        }) {
                            Label("重新開始對話", systemImage: "arrow.counterclockwise")
                        }
                        Button(action: {
                            // 可以弹出选择伙伴名称的界面
                        }) {
                            Label("更換夥伴名稱", systemImage: "person.crop.circle.badge.plus")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(AppColors.secondary)
                    }
                }
            }
        }
        .task {
            await viewModel.loadWelcomeMessage()
        }
    }
}

/// AI伙伴聊天室入口卡片
struct AIPartnerCardView: View {
    @State private var showPartnerChat = false

    var body: some View {
        Button(action: { showPartnerChat = true }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(AppColors.secondary)
                        .font(.title2)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI夥伴聊天室")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)

                        Text("找個夥伴聊聊，分享你的進展")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.disabled)
                }

                HStack {
                    Label("隨時陪伴", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.secondary)

                    Spacer()

                    Text("立即進入")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.secondary)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, AppColors.secondary.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .shadow(color: AppColors.secondary.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .sheet(isPresented: $showPartnerChat) {
            AIPartnerView()
        }
    }
}
