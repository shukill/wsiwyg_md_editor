// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyApp(),
      theme: ThemeData.dark(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  ///[controller] create a QuillEditorController to access the editor methods
  late QuillEditorController controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Modern Design System Colors
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6); // Purple
  static const Color accentColor = Color(0xFF06B6D4); // Cyan
  static const Color surfaceColor = Color(0xFF1E293B); // Slate 800
  static const Color backgroundColor = Color(0xFF0F172A); // Slate 900
  static const Color textPrimary = Color(0xFFE2E8F0); // Slate 200
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color editorBackground = Color(0xFF1E293B); // Slate 800

  ///[customToolBarList] pass the custom toolbarList to show only selected styles in the editor
  final customToolBarList = [
    ToolBarStyle.bold,
    ToolBarStyle.italic,
    ToolBarStyle.underline,
    ToolBarStyle.strike,
    ToolBarStyle.blockQuote,
    ToolBarStyle.codeBlock,
    ToolBarStyle.indentMinus,
    ToolBarStyle.indentAdd,
    ToolBarStyle.directionRtl,
    ToolBarStyle.directionLtr,
    ToolBarStyle.headerOne,
    ToolBarStyle.headerTwo,
    ToolBarStyle.color,
    ToolBarStyle.background,
    ToolBarStyle.align,
    ToolBarStyle.listOrdered,
    ToolBarStyle.listBullet,
    ToolBarStyle.size,
    ToolBarStyle.link,
    ToolBarStyle.image,
    ToolBarStyle.video,
    ToolBarStyle.clean,
    ToolBarStyle.undo,
    ToolBarStyle.redo,
    ToolBarStyle.clearHistory,
    ToolBarStyle.addTable,
    ToolBarStyle.editTable,
    ToolBarStyle.separator,
  ];

  late TextStyle _editorTextStyle;
  late TextStyle _hintTextStyle;

  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();

    // Initialize text styles with Google Fonts
    _editorTextStyle = GoogleFonts.inter(
      fontSize: 16,
      color: textPrimary,
      fontWeight: FontWeight.w400,
      height: 1.6,
    );

    _hintTextStyle = GoogleFonts.inter(
      fontSize: 16,
      color: textSecondary,
      fontWeight: FontWeight.w300,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    controller = QuillEditorController();
    controller.onTextChanged((text) {
      debugPrint('listening to $text');
    });
    controller.onEditorLoaded(() {
      debugPrint('Editor Loaded :)');
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, Color(0xFF1E293B), backgroundColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernToolbar(),
              Expanded(child: _buildEditorSection()),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: // Status row
          Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _hasFocus ? accentColor : textSecondary,
              shape: BoxShape.circle,
              boxShadow:
                  _hasFocus
                      ? [
                        BoxShadow(
                          color: accentColor.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                      : [],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _hasFocus ? 'Editor Active' : 'Editor Ready',
            style: GoogleFonts.inter(
              color: _hasFocus ? textPrimary : textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const Spacer(),
        ],
      ),

      centerTitle: true,
    );
  }

  Widget _buildModernToolbar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: secondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: ToolBar(
          toolBarColor: secondaryColor.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          iconSize: 20,
          iconColor: textPrimary.withOpacity(0.9),
          activeIconColor: accentColor,
          controller: controller,
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.horizontal,
          toolBarConfig: customToolBarList,
        ),
      ),
    );
  }

  Widget _buildEditorSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: editorBackground.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: QuillHtmlEditor(
                text: """
                <div style='background-color: #1E293B; color: #E2E8F0; font-family: Inter, sans-serif; padding: 16px; border-radius: 16px;'>
                  <h1 style='color: #E2E8F0; font-family: Inter, sans-serif; margin: 0 0 16px 0;'>Welcome to Premium Editor</h1>
                  <p style='color: #94A3B8; font-family: Inter, sans-serif; margin: 0; line-height: 1.6;'>Experience the future of rich text editing with our modern, professional interface. ✨</p>
                </div>
                """,
                hintText: 'Start crafting your masterpiece...',
                controller: controller,
                isEnabled: true,
                ensureVisible: false,
                minHeight: 500,
                autoFocus: false,
                textStyle: _editorTextStyle,
                hintTextStyle: _hintTextStyle,
                hintTextAlign: TextAlign.start,
                padding: const EdgeInsets.all(24),
                hintTextPadding: const EdgeInsets.all(24),
                backgroundColor: editorBackground,
                inputAction: InputAction.newline,
                onEditingComplete: (s) => debugPrint('Editing completed $s'),
                loadingBuilder: (context) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Loading editor...',
                            style: GoogleFonts.inter(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                onFocusChanged: (focus) {
                  setState(() {
                    _hasFocus = focus;
                  });
                },
                onTextChanged: (text) => debugPrint('widget text change $text'),
                onEditorCreated: () {
                  debugPrint('Editor has been loaded');
                  setHtmlText('Welcome to the premium editor experience!');
                },
                onEditorResized:
                    (height) => debugPrint('Editor resized $height'),
                onSelectionChanged:
                    (sel) =>
                        debugPrint('index ${sel.index}, range ${sel.length}'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///[getHtmlText] to get the html text from editor
  void getHtmlText() async {
    String? htmlText = await controller.getText();
    debugPrint(htmlText);
  }

  ///[setHtmlText] to set the html text to editor
  void setHtmlText(String text) async {
    await controller.setText(text);
  }

  ///[insertNetworkImage] to set the html text to editor
  void insertNetworkImage(String url) async {
    await controller.embedImage(url);
  }

  ///[insertVideoURL] to set the video url to editor
  void insertVideoURL(String url) async {
    await controller.embedVideo(url);
  }

  /// to set the html text to editor
  void insertHtmlText(String text, {int? index}) async {
    await controller.insertText(text, index: index);
  }

  /// to clear the editor
  void clearEditor() => controller.clear();

  /// to enable/disable the editor
  void enableEditor(bool enable) => controller.enableEditor(enable);

  /// method to un focus editor
  void unFocusEditor() => controller.unFocus();
}
