import SwiftUI

struct ProfileView: View {
    @State private var isLoggedIn = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isLoggedIn {
                LoggedInProfileView(isLoggedIn: $isLoggedIn)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
        .navigationTitle("حسابي")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Login View
struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)

                // Logo
                VStack(spacing: 8) {
                    Image(systemName: "film.stack")
                        .font(.system(size: 60))
                        .foregroundStyle(LinearGradient(colors: [.red, .orange], startPoint: .top, endPoint: .bottom))
                    Text("سينمانا")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer(minLength: 20)

                // Fields
                VStack(spacing: 14) {
                    TextField("البريد الإلكتروني", text: $email)
                        .textFieldStyle(CinemanaTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    SecureField("كلمة المرور", text: $password)
                        .textFieldStyle(CinemanaTextFieldStyle())
                }

                // Login Button
                Button {
                    // أضف منطق تسجيل الدخول هنا
                    isLoggedIn = true
                } label: {
                    Group {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("تسجيل الدخول")
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.red)
                    .cornerRadius(12)
                }

                // Divider
                HStack {
                    Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                    Text("أو").foregroundColor(.gray).font(.caption)
                    Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                }

                // Social Login
                VStack(spacing: 10) {
                    SocialLoginButton(title: "تسجيل الدخول بـ Google", icon: "g.circle.fill", color: .white)
                    SocialLoginButton(title: "تسجيل الدخول بـ Facebook", icon: "f.circle.fill", color: .blue)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Logged In Profile
struct LoggedInProfileView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Avatar
                Circle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 90, height: 90)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                    )
                    .padding(.top, 30)

                Text("مرحباً بك!")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                // Options
                VStack(spacing: 0) {
                    ProfileOptionRow(icon: "heart.fill", title: "المفضلة", color: .red)
                    Divider().background(Color.gray.opacity(0.3))
                    ProfileOptionRow(icon: "clock.fill", title: "سجل المشاهدة", color: .orange)
                    Divider().background(Color.gray.opacity(0.3))
                    ProfileOptionRow(icon: "arrow.down.circle.fill", title: "التحميلات", color: .green)
                    Divider().background(Color.gray.opacity(0.3))
                    ProfileOptionRow(icon: "gear", title: "الإعدادات", color: .gray)
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                // Logout
                Button {
                    isLoggedIn = false
                } label: {
                    Text("تسجيل الخروج")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Components
struct CinemanaTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(10)
            .foregroundColor(.white)
            .environment(\.colorScheme, .dark)
    }
}

struct SocialLoginButton: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        Button { } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(10)
        }
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.left")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
