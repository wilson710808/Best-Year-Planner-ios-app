import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [AppColors.primary.opacity(0.05), AppColors.background],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                if viewModel.currentStep > 0 {
                    ProgressView(value: Double(viewModel.currentStep), total: Double(viewModel.totalSteps - 1))
                        .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primary))
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Content
                TabView(selection: $viewModel.currentStep) {
                    WelcomeStepView(onTap: { viewModel.nextStep() })
                        .tag(0)

                    SingleQuestionStepView(
                        question: viewModel.questions[0],
                        answer: $viewModel.answer1,
                        stepNumber: 1,
                        totalSteps: 3
                    )
                    .tag(1)

                    TwoQuestionsStepView(
                        question2: viewModel.questions[1],
                        question3: viewModel.questions[2],
                        answer2: $viewModel.answer2,
                        answer3: $viewModel.answer3,
                        stepNumber: 2,
                        totalSteps: 3
                    )
                    .tag(2)

                    PlanPreviewStepView(viewModel: viewModel)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom buttons
                HStack(spacing: 16) {
                    if viewModel.currentStep > 0 && viewModel.currentStep < 3 {
                        Button(action: { viewModel.previousStep() }) {
                            Text(StringConstants.Onboarding.previousButton)
                                .secondaryButtonStyle()
                        }
                    }

                    if viewModel.currentStep > 0 && viewModel.currentStep < 3 {
                        Button(action: { viewModel.nextStep() }) {
                            Text(StringConstants.Onboarding.nextButton)
                                .primaryButtonStyle()
                        }
                        .disabled(!viewModel.canProceed)
                        .opacity(viewModel.canProceed ? 1 : 0.5)
                    }

                    if viewModel.currentStep == 3, let plan = viewModel.generatedPlan {
                        Button(action: {
                            viewModel.savePlanAndComplete()
                        }) {
                            Text(StringConstants.Onboarding.startButton)
                                .primaryButtonStyle()
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Welcome Step
struct WelcomeStepView: View {
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 72))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        startPoint: .top, endPoint: .bottom
                    )
                )

            VStack(spacing: 12) {
                Text(StringConstants.Onboarding.welcomeHeadline)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text(StringConstants.Onboarding.welcomeBody)
                    .font(.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button(action: onTap) {
                HStack(spacing: 8) {
                    Text(StringConstants.Common.startNow)
                        .font(.headline)
                    Image(systemName: "arrow.right")
                }
                .primaryButtonStyle()
            }

            Spacer()
        }
    }
}

// MARK: - Single Question Step
struct SingleQuestionStepView: View {
    let question: SimpleOnboardingQuestion
    @Binding var answer: String
    let stepNumber: Int
    let totalSteps: Int

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Step indicator
            Text("\(stepNumber) / \(totalSteps)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(AppColors.primary.opacity(0.1))
                .cornerRadius(20)

            VStack(spacing: 16) {
                Text(question.question)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                TextField(question.placeholder, text: $answer)
                    .font(.body)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(answer.isEmpty ? AppColors.divider : AppColors.primary, lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
            }

            Spacer()
        }
    }
}

// MARK: - Two Questions Step
struct TwoQuestionsStepView: View {
    let question2: SimpleOnboardingQuestion
    let question3: SimpleOnboardingQuestion
    @Binding var answer2: String
    @Binding var answer3: String
    let stepNumber: Int
    let totalSteps: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Step indicator
                Text("\(stepNumber) / \(totalSteps)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(AppColors.primary.opacity(0.1))
                    .cornerRadius(20)

                // Question 2
                VStack(spacing: 12) {
                    Text(question2.question)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    TextField(question2.placeholder, text: $answer2)
                        .font(.body)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(answer2.isEmpty ? AppColors.divider : AppColors.primary, lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                }

                // Question 3
                VStack(spacing: 12) {
                    Text(question3.question)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    TextField(question3.placeholder, text: $answer3)
                        .font(.body)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(answer3.isEmpty ? AppColors.divider : AppColors.primary, lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.vertical, 32)
        }
    }
}

// MARK: - Plan Preview Step
struct PlanPreviewStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.isGeneratingPlan {
                // Loading state
                VStack(spacing: 20) {
                    Spacer()

                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()

                    Text(StringConstants.Onboarding.generatingPlan)
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text("這將需要幾秒鐘")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)

                    Spacer()
                }
                .onAppear {
                    Task {
                        await viewModel.generateLaunchPlan()
                    }
                }
            } else if let plan = viewModel.generatedPlan {
                // Plan preview
                VStack(spacing: 12) {
                    Text(StringConstants.Onboarding.planReady)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.top, 16)

                    Text(StringConstants.Onboarding.planReadySubtitle)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)

                    // Plan title card
                    HStack {
                        Image(systemName: "sparkle")
                            .foregroundColor(AppColors.accent)
                        Text(plan.title)
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                    }
                    .padding()
                    .background(AppColors.accent.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Daily tasks list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(plan.tasks) { task in
                                DailyTaskPreviewCard(task: task)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

// MARK: - Daily Task Preview Card
struct DailyTaskPreviewCard: View {
    let task: DailyChallengeTask

    var body: some View {
        HStack(spacing: 16) {
            // Day number circle
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 44, height: 44)
                Text("\(task.dayNumber)")
                    .font(.headline)
                    .foregroundColor(AppColors.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)

                Text(task.description)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Label("\(task.estimatedMinutes)分鐘", systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary)

                    if task.aiTip != nil {
                        Label("AI建議", systemImage: "sparkle")
                            .font(.caption2)
                            .foregroundColor(AppColors.accent)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}
