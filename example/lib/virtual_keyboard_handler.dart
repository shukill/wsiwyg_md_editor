import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

/// A handler widget that provides virtual keyboard functionality for QuillHtmlEditor
/// This widget can be used as a standardized example for integrating virtual keyboards
/// with the Quill HTML Editor
class VirtualKeyboardHandler extends StatefulWidget {
  /// The QuillEditorController to handle text operations
  final QuillEditorController controller;

  /// Callback when virtual keyboard mode is toggled
  final ValueChanged<bool>? onKeyboardModeChanged;

  /// Callback when virtual keyboard visibility changes
  final ValueChanged<bool>? onKeyboardVisibilityChanged;

  /// Theme colors for the virtual keyboard
  final VirtualKeyboardTheme theme;

  /// Whether to show the virtual keyboard initially
  final bool initiallyVisible;

  /// The virtual keyboard type (Alphanumeric or Numeric)
  final VirtualKeyboardType keyboardType;

  /// Supported keyboard layouts
  final List<VirtualKeyboardDefaultLayouts> supportedLayouts;

  const VirtualKeyboardHandler({
    super.key,
    required this.controller,
    this.onKeyboardModeChanged,
    this.onKeyboardVisibilityChanged,
    this.theme = const VirtualKeyboardTheme(),
    this.initiallyVisible = false,
    this.keyboardType = VirtualKeyboardType.Alphanumeric,
    this.supportedLayouts = const [VirtualKeyboardDefaultLayouts.English],
  });

  @override
  State<VirtualKeyboardHandler> createState() => VirtualKeyboardHandlerState();
}

class VirtualKeyboardHandlerState extends State<VirtualKeyboardHandler> {
  bool _isVirtualKeyboardEnabled = true;
  bool _showVirtualKeyboard = false;
  bool _shiftEnabled = false;

  @override
  void initState() {
    super.initState();
    _showVirtualKeyboard = widget.initiallyVisible;
  }

  /// Toggle between virtual and system keyboard
  void toggleKeyboardMode() {
    setState(() {
      _isVirtualKeyboardEnabled = !_isVirtualKeyboardEnabled;
      if (!_isVirtualKeyboardEnabled) {
        _showVirtualKeyboard = false;
        widget.onKeyboardVisibilityChanged?.call(false);
      }
    });
    widget.onKeyboardModeChanged?.call(_isVirtualKeyboardEnabled);
  }

  /// Show or hide the virtual keyboard
  void toggleKeyboardVisibility() {
    if (_isVirtualKeyboardEnabled) {
      setState(() {
        _showVirtualKeyboard = !_showVirtualKeyboard;
      });
      widget.onKeyboardVisibilityChanged?.call(_showVirtualKeyboard);
    }
  }

  /// Show the virtual keyboard
  void showKeyboard() {
    if (_isVirtualKeyboardEnabled) {
      setState(() {
        _showVirtualKeyboard = true;
      });
      widget.onKeyboardVisibilityChanged?.call(true);
    }
  }

  /// Hide the virtual keyboard
  void hideKeyboard() {
    setState(() {
      _showVirtualKeyboard = false;
    });
    widget.onKeyboardVisibilityChanged?.call(false);
  }

  /// Handle virtual key press events
  void _onVirtualKeyPress(VirtualKeyboardKey key) async {
    if (key.keyType == VirtualKeyboardKeyType.String) {
      final text =
          _shiftEnabled ? (key.capsText ?? key.text ?? '') : (key.text ?? '');
      await widget.controller.insertText(text);
    } else if (key.keyType == VirtualKeyboardKeyType.Action) {
      await _handleKeyAction(key.action);
    }
  }

  /// Handle virtual keyboard actions
  Future<void> _handleKeyAction(VirtualKeyboardKeyAction? action) async {
    switch (action) {
      case VirtualKeyboardKeyAction.Backspace:
        await _handleBackspace();
        break;
      case VirtualKeyboardKeyAction.Return:
        await widget.controller.insertText('\n');
        break;
      case VirtualKeyboardKeyAction.Space:
        await widget.controller.insertText(' ');
        break;
      case VirtualKeyboardKeyAction.Shift:
        setState(() {
          _shiftEnabled = !_shiftEnabled;
        });
        break;
      case VirtualKeyboardKeyAction.SwithLanguage:
        // Language switching can be implemented here if needed
        break;
      default:
        break;
    }
  }

  /// Handle backspace action
  Future<void> _handleBackspace() async {
    try {
      final selection = await widget.controller.getSelectionRange();
      if (selection.index != null && selection.index! > 0) {
        await widget.controller.setSelectionRange(selection.index! - 1, 1);
        await widget.controller.replaceText('');
      }
    } catch (e) {
      debugPrint('Backspace error: $e');
    }
  }

  /// Get the keyboard toggle button widget
  Widget getKeyboardToggleButton({
    double iconSize = 20,
    EdgeInsets padding = const EdgeInsets.all(8),
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: toggleKeyboardMode,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color:
                _isVirtualKeyboardEnabled
                    ? widget.theme.activeColor.withOpacity(0.2)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  _isVirtualKeyboardEnabled
                      ? widget.theme.activeColor.withOpacity(0.5)
                      : widget.theme.borderColor,
            ),
          ),
          child: Icon(
            _isVirtualKeyboardEnabled
                ? Icons.keyboard
                : Icons.keyboard_outlined,
            size: iconSize,
            color:
                _isVirtualKeyboardEnabled
                    ? widget.theme.activeColor
                    : widget.theme.iconColor,
          ),
        ),
      ),
    );
  }

  /// Get the virtual keyboard widget
  Widget? getVirtualKeyboard() {
    if (!_isVirtualKeyboardEnabled || !_showVirtualKeyboard) {
      return null;
    }

    return Container(
      decoration: BoxDecoration(
        color: widget.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(color: widget.theme.borderColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Keyboard header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: widget.theme.borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Virtual Keyboard',
                  style: GoogleFonts.inter(
                    color: widget.theme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_shiftEnabled)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.theme.activeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'CAPS',
                      style: GoogleFonts.inter(
                        color: widget.theme.activeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: hideKeyboard,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.keyboard_hide,
                        color: widget.theme.secondaryTextColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Virtual keyboard
          VirtualKeyboard(
            height: 300,
            width: MediaQuery.of(context).size.width,
            textColor: widget.theme.textColor,
            fontSize: 16,
            defaultLayouts: widget.supportedLayouts,
            type: widget.keyboardType,
            postKeyPress: _onVirtualKeyPress,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget is just a handler, it doesn't render anything itself
    return const SizedBox.shrink();
  }

  /// Check if virtual keyboard is enabled
  bool get isVirtualKeyboardEnabled => _isVirtualKeyboardEnabled;

  /// Check if virtual keyboard is visible
  bool get isKeyboardVisible => _showVirtualKeyboard;

  /// Check if shift is enabled
  bool get isShiftEnabled => _shiftEnabled;
}

/// Theme configuration for virtual keyboard
class VirtualKeyboardTheme {
  final Color backgroundColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color iconColor;
  final Color activeColor;
  final Color borderColor;

  const VirtualKeyboardTheme({
    this.backgroundColor = const Color(0xFF1E293B),
    this.textColor = const Color(0xFFE2E8F0),
    this.secondaryTextColor = const Color(0xFF94A3B8),
    this.iconColor = const Color(0xFFE2E8F0),
    this.activeColor = const Color(0xFF06B6D4),
    this.borderColor = const Color(0x1AFFFFFF),
  });
}

/// Extension methods for easy integration
extension QuillEditorVirtualKeyboard on QuillEditorController {
  /// A standardized way to handle virtual keyboard text insertion
  Future<void> insertVirtualKeyboardText(String text) async {
    await insertText(text);
  }

  /// A standardized way to handle virtual keyboard backspace
  Future<void> handleVirtualBackspace() async {
    try {
      final selection = await getSelectionRange();
      if (selection.index != null && selection.index! > 0) {
        await setSelectionRange(selection.index! - 1, 1);
        await replaceText('');
      }
    } catch (e) {
      debugPrint('Virtual keyboard backspace error: $e');
    }
  }

  /// A standardized way to handle virtual keyboard actions
  Future<void> handleVirtualKeyboardAction(
    VirtualKeyboardKeyAction action,
  ) async {
    switch (action) {
      case VirtualKeyboardKeyAction.Return:
        await insertText('\n');
        break;
      case VirtualKeyboardKeyAction.Space:
        await insertText(' ');
        break;
      case VirtualKeyboardKeyAction.Backspace:
        await handleVirtualBackspace();
        break;
      case VirtualKeyboardKeyAction.Shift:
        // Shift handling should be managed by the UI state
        break;
      case VirtualKeyboardKeyAction.SwithLanguage:
        // Language switching should be managed by the UI state
        break;
    }
  }
}
