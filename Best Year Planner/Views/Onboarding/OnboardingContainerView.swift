import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack {
                ProgressView(value: Double(viewModel.currentStep + 1), total: Double(viewModel.totalSteps))
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primary))
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                TabView(selection: $viewModel.currentStep) {
                    WelcomeStepView()
                        .tag(0)

                    QuestionnaireStepView(
                        title: StringConstants.Onboarding.careerTitle,
                        subtitle: StringConstants.Onboarding.careerSubtitle,
                        questions: viewModel.careerQuestions,
                        answers: $viewModel.careerAnswers,
                        dimension: .career
                    )
                    .tag(1)

                    QuestionnaireStepView(
                        title: StringConstants.Onboarding.relationshipTitle,
                        subtitle: StringConstants.Onboarding.relationshipSubtitle,
                        questions: viewModel.relationshipQuestions,
                        answers: $viewModel.relationshipAnswers,
                        dimension: .relationship
                    )
                    .tag(2)

                    QuestionnaireStepView(
                        title: StringConstants.Onboarding.growthTitle,
                        subtitle: StringConstants.Onboarding.growthSubtitle,
                        questions: viewModel.growthQuestions,
                        answers: $viewModel.growthAnswers,
                        dimension: .growth
                    )
                    .tag(3)

                    GoalReviewView(viewModel: viewModel)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentStep)

                HStack(spacing: 16) {
                    if viewModel.currentStep > 0 {
                        Button(action: {
                            viewModel.previousStep()
                        }) {
                            Text(StringConstants.Onboarding.previousButton)
                                .secondaryButtonStyle()
                        }
                    }

                    if viewModel.currentStep < viewModel.totalSteps - 1 {
                        Button(action: {
                            viewModel.nextStep()
                        }) {
                            Text(StringConstants.Onboarding.nextButton)
                                .primaryButtonStyle()
                        }
                        .disabled(!viewModel.canProceedToNext)
                        .opacity(viewModel.canProceedToNext ? 1 : 0.6)
                    } else {
                        Button(action: {
                            viewModel.saveGeneratedGoals()
                            appState.completeOnboarding()
                        }) {
                            Text(StringConstants.Onboarding.startButton)
                                .primaryButtonStyle()
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(AppColors.primary)

            Text("讓我們開始吧！")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            Text("回答以下問題，我會根據《規劃最好的一年》原則，為你量身定制年度目標規劃。")
                .font(.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
    }
}

struct QuestionnaireStepView: View {
    let title: String
    let subtitle: String
    let questions: [QuestionnaireQuestion]
    @Binding var answers: [String: String]
    let dimension: GoalDimension

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: dimension.icon)
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: dimension.color))

                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(questions) { question in
                        QuestionCardView(
                            question: question,
                            selectedAnswer: Binding(
                                get: { answers[question.id] ?? "" },
                                set: { answers[question.id] = $0 }
                            )
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct QuestionCardView: View {
    let question: QuestionnaireQuestion
    @Binding var selectedAnswer: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.question)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            if let options = question.options {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedAnswer = option
                    }) {
                        HStack {
                            Text(option)
                                .font(.body)
                                .foregroundColor(selectedAnswer == option ? .white : AppColors.textPrimary)

                            Spacer()

                            if selectedAnswer == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(selectedAnswer == option ? AppColors.primary : Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedAnswer == option ? AppColors.primary : AppColors.divider, lineWidth: 1)
                        )
                    }
                }
            } else if question.requiresTextInput {
                TextField("請輸入你的回答", text: $selectedAnswer)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.divider, lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct GoalReviewView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.primary)

                Text("發現更好的自己")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)

                Text("根據你的回答，這是AI為你量身定制的成長方向")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)

            if viewModel.isGeneratingGoals {
                VStack(spacing: 16) {
                    ProgressView("AI正在分析你的回答...")
                        .padding()
                    Text("這將需要幾秒鐘")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        if !viewModel.directionalSuggestions.isEmpty {
                            Text("🌟 你的成長方向")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ForEach(viewModel.directionalSuggestions) { suggestion in
                                DirectionalSuggestionCardView(suggestion: suggestion)
                            }
                        }

                        Text("📋 建議的年度目標")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(viewModel.generatedGoals) { goal in
                            GoalCardView(goal: goal)
                        }

                        Text("💡 溫馨提示")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        TipCardView()
                    }
                    .padding(.horizontal, 24)
                }
            }

            Spacer()
        }
        .onAppear {
            if viewModel.generatedGoals.isEmpty && viewModel.directionalSuggestions.isEmpty {
                _Concurrency.Task {
                    await viewModel.generateGoals()
                }
            }
        }
    }
}

struct DirectionalSuggestionCardView: View {
    let suggestion: DirectionalSuggestion

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: suggestion.dimension.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: suggestion.dimension.color))
                Text(suggestion.title)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            Text(suggestion.description)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("具體行動步驟：")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)

                ForEach(Array(suggestion.actionSteps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.caption)
                            .foregroundColor(AppColors.primary)
                            .fontWeight(.bold)
                        Text(step)
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .padding()
            .background(Color(hex: suggestion.dimension.color).opacity(0.1))
            .cornerRadius(8)

            HStack {
                Image(systemName: "quote.opening")
                    .font(.caption)
                    .foregroundColor(AppColors.primary)
                Text(suggestion.inspiringQuote)
                    .font(.caption)
                    .italic()
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.primary.opacity(0.05))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: suggestion.dimension.color).opacity(0.3), lineWidth: 1)
        )
    }
}

struct TipCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("來自《規劃最好的一年》的建議")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
            }

            Text("目標設定後，關鍵在於持續執行。每天進步一點點，一年後你將看到巨大的改變。記住：最好的規劃是付諸行動的規劃！")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(12)
    }
}

struct GoalCardView: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: goal.dimension.icon)
                    .foregroundColor(Color(hex: goal.dimension.color))

                Text(goal.dimension.displayName)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Text(goal.title)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            if !goal.description.isEmpty {
                Text(goal.description)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: goal.dimension.color).opacity(0.3), lineWidth: 1)
        )
    }
}

