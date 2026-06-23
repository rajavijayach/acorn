import SwiftUI

struct InstallWizardView: View {
    let template: AppTemplate
    let appModel: AppModel
    @Environment(\.dismiss) private var dismiss

    enum Step {
        case details
        case configure
        case review
        case installing
        case success
        case failure(String)
    }

    @State private var currentStep: Step = .details
    @State private var appName: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var port: String = ""
    @State private var database: String = ""

    // Validation errors
    @State private var validationError: String?

    var body: some View {
        VStack(spacing: 0) {
            // Header / Progress indicator
            wizardHeader
                .padding(.horizontal, 24)
                .padding(.top, 24)

            Divider()
                .padding(.vertical, 16)

            // Content
            VStack {
                switch currentStep {
                case .details:
                    detailsStepView
                case .configure:
                    configureStepView
                case .review:
                    reviewStepView
                case .installing:
                    installingStepView
                case .success:
                    successStepView
                case .failure(let error):
                    failureStepView(error: error)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Divider()
                .padding(.vertical, 16)

            // Navigation Buttons
            wizardFooter
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .frame(width: 520, height: 480)
        .onAppear {
            initializeFields()
        }
    }

    // Initialize state fields from template defaults
    private func initializeFields() {
        appName = template.id
        for setting in template.settings {
            let defaultValue = setting.defaultValue ?? ""
            switch setting.id {
            case "username": username = defaultValue
            case "password": password = defaultValue
            case "port": port = defaultValue
            case "database": database = defaultValue
            default: break
            }
        }
    }

    // MARK: - Validation
    private func validateForm() -> Bool {
        if appName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationError = "Application Name is required."
            return false
        }
        if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationError = "Username is required."
            return false
        }
        if password.isEmpty {
            validationError = "Password is required."
            return false
        }
        guard let portInt = Int(port), portInt > 0, portInt <= 65535 else {
            validationError = "Port must be a valid number between 1 and 65535."
            return false
        }

        validationError = nil
        return true
    }

    // MARK: - Wizard Header
    private var wizardHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.title2)
                    .bold()
                Text(subtitleText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            stepBadge
        }
    }

    private var subtitleText: String {
        switch currentStep {
        case .details: "App Information"
        case .configure: "Configure Settings"
        case .review: "Review Installation"
        case .installing: "Deploying Application"
        case .success: "Installation Succeeded"
        case .failure: "Installation Failed"
        }
    }

    private var stepBadge: some View {
        let text: String
        switch currentStep {
        case .details: text = "Step 1 of 3"
        case .configure: text = "Step 2 of 3"
        case .review: text = "Step 3 of 3"
        case .installing, .success, .failure: text = "Deploying"
        }
        return Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.secondary.opacity(0.2), in: .capsule)
    }

    // MARK: - Details Step View
    private var detailsStepView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                    Text(template.category)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)

            Text(template.summary ?? "No description available.")
                .font(.body)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Technical Details")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text("Image:")
                        .bold()
                    Text(template.image)
                        .font(.system(.body, design: .monospaced))
                }
                .font(.subheadline)
            }
            .padding(12)
            .background(.quaternary.opacity(0.5), in: .rect(cornerRadius: 6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Configure Step View
    private var configureStepView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let validationError {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        Text(validationError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.red.opacity(0.1), in: .rect(cornerRadius: 6))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Application Name")
                        .font(.subheadline)
                        .bold()
                    TextField("App Name", text: $appName)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Username")
                        .font(.subheadline)
                        .bold()
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Password")
                        .font(.subheadline)
                        .bold()
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Port")
                        .font(.subheadline)
                        .bold()
                    TextField("Port", text: $port)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Review Step View
    private var reviewStepView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Please confirm the details below before starting the installation:")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                reviewRow(title: "App Name", value: appName)
                Divider()
                reviewRow(title: "Image", value: template.image)
                Divider()
                reviewRow(title: "Username", value: username)
                Divider()
                reviewRow(title: "Password", value: String(repeating: "•", count: password.count))
                Divider()
                reviewRow(title: "Port", value: port)
            }
            .background(.quaternary.opacity(0.4), in: .rect(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.separator, lineWidth: 1)
            )
        }
    }

    private func reviewRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .bold()
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .lineLimit(1)
        }
        .padding(12)
        .font(.subheadline)
    }

    // MARK: - Installing Step View
    private var installingStepView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Installing \(appName)...")
                .font(.headline)
            
            Text("Generating application manifest and writing configuration to database.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }

    // MARK: - Success Step View
    private var successStepView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            
            Text("Successfully Installed")
                .font(.title3)
                .bold()
            
            Text("\(appName) has been successfully configured and registered. The application status shows Running.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }

    // MARK: - Failure Step View
    private func failureStepView(error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.red)
            
            Text("Installation Failed")
                .font(.title3)
                .bold()
            
            Text(error)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }

    // MARK: - Wizard Footer
    private var wizardFooter: some View {
        HStack {
            switch currentStep {
            case .details:
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Configure") {
                    currentStep = .configure
                }
                .buttonStyle(.borderedProminent)

            case .configure:
                Button("Back") {
                    currentStep = .details
                }

                Spacer()

                Button("Next: Review") {
                    if validateForm() {
                        currentStep = .review
                    }
                }
                .buttonStyle(.borderedProminent)

            case .review:
                Button("Back") {
                    currentStep = .configure
                }

                Spacer()

                Button("Install") {
                    triggerInstallation()
                }
                .buttonStyle(.borderedProminent)

            case .installing:
                EmptyView()

            case .success, .failure:
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    // MARK: - Install Action
    private func triggerInstallation() {
        currentStep = .installing
        
        Task {
            // Add a small 1-second delay to make it feel premium and performative
            try? await Task.sleep(for: .seconds(1))
            
            var settings: [String: String] = [:]
            settings["username"] = username
            settings["password"] = password
            settings["port"] = port
            settings["database"] = database.isEmpty ? "app" : database

            do {
                try appModel.installApp(
                    template: template,
                    appName: appName,
                    settings: settings
                )
                currentStep = .success
            } catch {
                currentStep = .failure(error.localizedDescription)
            }
        }
    }
}
