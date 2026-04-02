import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/tryon_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class TryOnResultScreen extends ConsumerStatefulWidget {
  final String resultPath;
  final String avatarId;
  final String clothItemId;
  final double offsetX;
  final double offsetY;
  final double scale;
  final double rotation;
  final double opacity;
  final String? clothType;
  final String? clothColor;

  const TryOnResultScreen({
    super.key,
    required this.resultPath,
    required this.avatarId,
    required this.clothItemId,
    required this.offsetX,
    required this.offsetY,
    required this.scale,
    required this.rotation,
    required this.opacity,
    this.clothType,
    this.clothColor,
  });

  @override
  ConsumerState<TryOnResultScreen> createState() => _TryOnResultScreenState();
}

class _TryOnResultScreenState extends ConsumerState<TryOnResultScreen> {
  bool _isSaving = false;
  bool _isGettingAiComment = false;
  AiCommentResponse? _aiComment;

  @override
  void initState() {
    super.initState();
    _autoSave();
  }

  Future<void> _autoSave() async {
    await ref.read(tryOnListProvider.notifier).addTryOnResult(
          avatarId: widget.avatarId,
          clothItemId: widget.clothItemId,
          resultImagePath: widget.resultPath,
          offsetX: widget.offsetX,
          offsetY: widget.offsetY,
          scale: widget.scale,
          rotation: widget.rotation,
          opacity: widget.opacity,
        );
  }

  Future<void> _getAiComment() async {
    setState(() => _isGettingAiComment = true);

    try {
      final response = await ApiService.getAiComment(
        clothType: widget.clothType ?? 'top',
        clothColor: widget.clothColor ?? '黑色',
      );

      if (response['code'] == 200 && response['data'] != null) {
        setState(() {
          _aiComment = AiCommentResponse.fromJson(response['data']);
        });
      } else {
        _showToast(response['message']?.toString() ?? 'AI 点评失败，请稍后重试');
      }
    } catch (e) {
      _showToast('AI 点评失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isGettingAiComment = false);
      }
    }
  }

  Future<void> _shareResult() async {
    try {
      await Share.shareXFiles(
        [XFile(widget.resultPath)],
        text: 'FitMirror 铏氭嫙璇曠┛鏁堟灉',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('鍒嗕韩澶辫触: $e')),
        );
      }
    }
  }

  Future<void> _saveToGallery() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('宸蹭繚瀛樺埌鐩稿唽'),
        backgroundColor: AppTheme.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showToast(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 鏁堟灉鍥惧睍绀?
          Expanded(
            child: _buildResultImage(),
          ),

          // AI 鐐硅瘎鍗＄墖
          if (_aiComment != null) _buildAiCommentCard(),

          // 搴曢儴鎿嶄綔鏍?
          _buildBottomBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
      ),
      title: const Text('璇曠┛鏁堟灉'),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareResult,
        ),
      ],
    );
  }

  Widget _buildResultImage() {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Image.file(
            File(widget.resultPath),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiCommentCard() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 椤堕儴鏍囩鍜岃瘎鍒?
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AI 绌挎惌鐐硅瘎',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getScoreGradient(_aiComment!.score),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_aiComment!.score}鍒?,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 鎬荤粨
              Text(
                _aiComment!.summary,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // 璇勫垎璇︽儏
              _buildScoreDetail('棰滆壊鍖归厤', _aiComment!.color.score, _aiComment!.color.comment),
              const SizedBox(height: 12),
              _buildScoreDetail('椋庢牸濂戝悎', _aiComment!.style.score, _aiComment!.style.comment),
              const SizedBox(height: 16),

              // 閫傜敤鍦哄悎
              Text(
                '閫傜敤鍦哄悎',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _aiComment!.occasions.map((o) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    o,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[300],
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),

              // 鎼厤寤鸿
              Text(
                '鎼厤寤鸿',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 8),
              ...(_aiComment!.suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: AppTheme.accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ))),

              const SizedBox(height: 16),

              // 缁撹
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accentColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppTheme.accentColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _aiComment!.conclusion,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreDetail(String label, int score, String comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(score),
                  ),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 12,
                color: _getScoreColor(score),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          comment,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.accentColor;
    if (score >= 60) return AppTheme.secondaryColor;
    return Colors.orange;
  }

  List<Color> _getScoreGradient(int score) {
    if (score >= 80) return [AppTheme.accentColor, Color(0xFF00E676)];
    if (score >= 60) return [AppTheme.secondaryColor, Color(0xFFFFD54F)];
    return [Colors.orange, Colors.deepOrange];
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // AI 鐐硅瘎鎸夐挳
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isGettingAiComment ? null : _getAiComment,
                icon: _isGettingAiComment
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      )
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(_aiComment != null ? '閲嶆柊鐐硅瘎' : 'AI 鐐硅瘎'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 淇濆瓨鎸夐挳
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveToGallery,
                icon: const Icon(Icons.save_alt, size: 18),
                label: const Text('淇濆瓨'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
