// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
// Note: Using internal import for ElTooltip - in production, consider implementing your own tooltip
import 'package:quill_html_editor/src/widgets/el_tooltip/el_tooltip.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';
import 'virtual_keyboard_handler.dart';

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

  // Virtual keyboard handler
  final GlobalKey<VirtualKeyboardHandlerState> _keyboardKey = GlobalKey();

  // Virtual keyboard state
  bool _isVirtualKeyboardEnabled = true; // Default to virtual keyboard

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

  // Virtual keyboard callbacks
  void _onKeyboardModeChanged(bool isVirtual) {
    setState(() {
      _isVirtualKeyboardEnabled = isVirtual;
    });
  }

  void _onKeyboardVisibilityChanged(bool isVisible) {
    // This callback can be used to track keyboard visibility if needed
    debugPrint('Virtual keyboard visibility changed: $isVisible');
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
          child: Stack(
            children: [
              Column(
                children: [
                  _buildModernToolbar(),
                  Expanded(child: _buildEditorSection()),
                  _buildVirtualKeyboard(),
                ],
              ),
              // Virtual keyboard handler widget
              VirtualKeyboardHandler(
                key: _keyboardKey,
                controller: controller,
                onKeyboardModeChanged: _onKeyboardModeChanged,
                onKeyboardVisibilityChanged: _onKeyboardVisibilityChanged,
                theme: const VirtualKeyboardTheme(
                  backgroundColor: surfaceColor,
                  textColor: textPrimary,
                  secondaryTextColor: textSecondary,
                  iconColor: textPrimary,
                  activeColor: accentColor,
                  borderColor: Color(0x1AFFFFFF),
                ),
                keyboardType: VirtualKeyboardType.Alphanumeric,
                supportedLayouts: const [VirtualKeyboardDefaultLayouts.English],
              ),
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
      title: Row(
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
          // Keyboard mode indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  _isVirtualKeyboardEnabled
                      ? accentColor.withOpacity(0.2)
                      : textSecondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isVirtualKeyboardEnabled
                      ? Icons.keyboard
                      : Icons.keyboard_outlined,
                  size: 14,
                  color:
                      _isVirtualKeyboardEnabled ? accentColor : textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _isVirtualKeyboardEnabled ? 'Virtual' : 'System',
                  style: GoogleFonts.inter(
                    color:
                        _isVirtualKeyboardEnabled ? accentColor : textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
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
        child: Row(
          children: [
            // Virtual keyboard toggle button using the handler
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: ElTooltip(
                content: Text(
                  _isVirtualKeyboardEnabled
                      ? 'Switch to System Keyboard'
                      : 'Switch to Virtual Keyboard',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                onTap: () {}, // Required parameter
                child:
                    _keyboardKey.currentState?.getKeyboardToggleButton() ??
                    const SizedBox(),
              ),
            ),
            // Vertical separator
            Container(
              width: 1,
              height: 24,
              color: Colors.white.withOpacity(0.1),
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            // Standard toolbar
            Expanded(
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
          ],
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
                  <h1 style='color: #E2E8F0; font-family: Inter, sans-serif; margin: 0 0 16px 0;'>Welcome to Premium Editor with Virtual Keyboard</h1>
                  <p style='color: #94A3B8; font-family: Inter, sans-serif; margin: 0; line-height: 1.6;'>Experience the future of rich text editing with our modern interface and virtual keyboard support. Toggle between virtual and system keyboard using the keyboard icon in the toolbar. The virtual keyboard will appear when you focus on the editor. ✨</p>
                  <br />
                  <p style='color: #94A3B8; font-family: Inter, sans-serif; margin: 0; line-height: 1.6;'><strong>Features:</strong></p>
                  <ul style='color: #94A3B8; font-family: Inter, sans-serif; margin: 8px 0; padding-left: 20px;'>
                    <li>Toggle between virtual and system keyboards</li>
                    <li>Multi-language support (English default, extendable)</li>
                    <li>Standardized integration functions</li>
                    <li>Modern UI with smooth animations</li>
                    <li>Customizable keyboard themes</li>
                  </ul>
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
                    if (_isVirtualKeyboardEnabled && focus) {
                      _keyboardKey.currentState?.showKeyboard();
                    } else {
                      _keyboardKey.currentState?.hideKeyboard();
                    }
                  });
                },
                onTextChanged: (text) => debugPrint('widget text change $text'),
                onEditorCreated: () {
                  debugPrint('Editor has been loaded');
                  setHtmlText(
                    'Welcome to the premium editor experience with virtual keyboard support!',
                  );
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

  Widget _buildVirtualKeyboard() {
    // Use the keyboard handler's virtual keyboard widget
    final keyboardWidget = _keyboardKey.currentState?.getVirtualKeyboard();
    if (keyboardWidget != null) {
      return keyboardWidget;
    }
    return const SizedBox.shrink();
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
