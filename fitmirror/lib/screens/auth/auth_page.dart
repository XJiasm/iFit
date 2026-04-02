import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../providers/user_provider.dart';

/// 认证页面 - 登录/注册
class AuthPage extends ConsumerStatefulWidget {
  final bool isLoginMode;

  const AuthPage({super.key, this.isLoginMode = true});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // 登录表单
  final _loginUsernameController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // 注册表单
  final _registerUsernameController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerNicknameController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.isLoginMode ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerPasswordController.dispose();
    _registerNicknameController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(
        username: _loginUsernameController.text.trim(),
        password: _loginPasswordController.text,
      );

      if (response['code'] == 200 && response['data'] != null) {
        final data = response['data'];

        // 保存用户状态
        await ref.read(userProvider.notifier).login(
              token: data['token'],
              userId: data['userId'],
              username: data['username'],
              nickname: data['nickname'],
              avatarUrl: data['avatarUrl'],
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('登录成功，欢迎 ${data['nickname'] ?? data['username']}'),
              backgroundColor: AppTheme.accentColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        _showError(response['message'] ?? '登录失败');
      }
    } catch (e) {
      _showError('登录失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _register() async {
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.register(
        username: _registerUsernameController.text.trim(),
        password: _registerPasswordController.text,
        nickname: _registerNicknameController.text.trim().isEmpty
            ? null
            : _registerNicknameController.text.trim(),
      );

      if (response['code'] == 200 && response['data'] != null) {
        final data = response['data'];

        // 保存用户状态
        await ref.read(userProvider.notifier).login(
              token: data['token'],
              userId: data['userId'],
              username: data['username'],
              nickname: data['nickname'],
              avatarUrl: data['avatarUrl'],
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('注册成功'),
              backgroundColor: AppTheme.accentColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        _showError(response['message'] ?? '注册失败');
      }
    } catch (e) {
      _showError('注册失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo 和标题
              _buildHeader(),

              const SizedBox(height: 32),

              // Tab 栏
              _buildTabBar(),

              // 表单内容
              SizedBox(
                height: 320,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginForm(),
                    _buildRegisterForm(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 其他登录方式
              _buildSocialLogin(),

              const SizedBox(height: 32),

              // 用户协议
              _buildAgreement(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.checkroom,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'FitMirror',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '虚拟试穿 · AI穿搭助手',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondaryLight,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        indicator: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '登录'),
          Tab(text: '注册'),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: _loginUsernameController,
              decoration: InputDecoration(
                hintText: '用户名',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) =>
                  v?.isEmpty ?? true ? '请输入用户名' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _loginPasswordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: '密码',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) =>
                  v?.isEmpty ?? true ? '请输入密码' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '登录',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // TODO: 忘记密码
              },
              child: Text(
                '忘记密码？',
                style: TextStyle(color: AppTheme.textHintLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: _registerUsernameController,
              decoration: InputDecoration(
                hintText: '用户名',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) {
                if (v?.isEmpty ?? true) return '请输入用户名';
                if (v!.length < 3) return '用户名至少3个字符';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registerNicknameController,
              decoration: InputDecoration(
                hintText: '昵称（可选）',
                prefixIcon: const Icon(Icons.badge_outlined),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registerPasswordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: '密码',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) {
                if (v?.isEmpty ?? true) return '请输入密码';
                if (v!.length < 6) return '密码至少6个字符';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '注册',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '其他登录方式',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textHintLight,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(Icons.wechat, '微信', Colors.green),
            const SizedBox(width: 32),
            _buildSocialButton(Icons.phone_android, '手机号', Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label登录暂未开放')),
        );
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreement() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textHintLight,
          ),
          children: [
            const TextSpan(text: '登录即代表同意'),
            TextSpan(
              text: '《用户协议》',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
            const TextSpan(text: '和'),
            TextSpan(
              text: '《隐私政策》',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
