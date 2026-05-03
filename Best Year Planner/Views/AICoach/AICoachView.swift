import SwiftUI

struct AICoachView: View {
    @StateObject private var viewModel = AICoachViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                ChatBubbleView(message: message, isPartner: false)
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
                    TextField(StringConstants.AICoach.chatPlaceholder, text: $viewModel.inputText)
                        .padding()
                        .background(Color.white)
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
                            .background(viewModel.inputText.isEmpty ? AppColors.disabled : AppColors.primary)
                            .cornerRadius(22)
                    }
                    .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
                }
                .padding()
                .background(Color.white)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle(StringConstants.AICoach.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            _Concurrency.Task {
                await viewModel.loadWelcomeMessage()
            }
        }
    }
}

struct ChatBubbleView: View {
    let message: AIMessage
    let isPartner: Bool

    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 60)
            } else {
                // AI 头像
                Image(systemName: isPartner ? "person.2.fill" : "brain.head.profile")
                    .foregroundColor(isPartner ? AppColors.secondary : AppColors.primary)
                    .font(.title3)
                    .frame(width: 32, height: 32)
            }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(message.isFromUser ? .white : AppColors.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isFromUser ? AppColors.primary : Color.white)
                    .cornerRadius(16)

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }

            if message.isFromUser {
                // 用户头像
                Image(systemName: "person.circle.fill")
                    .foregroundColor(AppColors.primary)
                    .font(.title3)
                    .frame(width: 32, height: 32)
            } else {
                Spacer(minLength: 60)
            }
        }
    }
}