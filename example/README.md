# Quill HTML Editor with Virtual Keyboard Support

This example demonstrates how to integrate a virtual keyboard with the Quill HTML Editor using the `virtual_keyboard_multi_language` package.

## Features

- ✨ **Toggle between Virtual and System Keyboards**: Use the keyboard icon in the toolbar to switch between virtual and system keyboards
- 🌐 **Multi-language Support**: Built with support for multiple keyboard layouts (English by default, easily extendable)
- 🎨 **Customizable Themes**: Fully customizable keyboard appearance to match your app's design
- 📱 **Mobile-First Design**: Optimized for touch interfaces with smooth animations
- 🔧 **Standardized Integration**: Provides reusable functions and callbacks that can be adapted for other virtual keyboard solutions

## How It Works

### Virtual Keyboard Handler

The `VirtualKeyboardHandler` widget provides a standardized way to integrate virtual keyboards with the Quill HTML Editor. It includes:

- **Toggle Functionality**: Switch between virtual and system keyboards
- **Event Handling**: Proper handling of key presses, backspace, and special actions
- **Theme Support**: Customizable colors and styling
- **State Management**: Clean state management for keyboard visibility and mode

### Integration Pattern

```dart
// 1. Create a handler key
final GlobalKey<VirtualKeyboardHandlerState> _keyboardKey = GlobalKey();

// 2. Add the handler to your widget tree
VirtualKeyboardHandler(
  key: _keyboardKey,
  controller: quillController,
  onKeyboardModeChanged: (isVirtual) {
    // Handle keyboard mode changes
  },
  onKeyboardVisibilityChanged: (isVisible) {
    // Handle keyboard visibility changes
  },
  theme: VirtualKeyboardTheme(
    backgroundColor: Colors.grey[800]!,
    textColor: Colors.white,
    activeColor: Colors.blue,
    // ... other theme properties
  ),
)

// 3. Use the handler methods
_keyboardKey.currentState?.showKeyboard();
_keyboardKey.currentState?.hideKeyboard();
_keyboardKey.currentState?.toggleKeyboardMode();
```

### Toolbar Integration

The keyboard toggle button is integrated into the main toolbar:

```dart
// Get the toggle button from the handler
_keyboardKey.currentState?.getKeyboardToggleButton()
```

## Customization

### Keyboard Layouts

Add support for multiple languages by modifying the `supportedLayouts` parameter:

```dart
VirtualKeyboardHandler(
  supportedLayouts: const [
    VirtualKeyboardDefaultLayouts.English,
    VirtualKeyboardDefaultLayouts.Spanish,
    VirtualKeyboardDefaultLayouts.French,
    // Add more languages as needed
  ],
)
```

### Themes

Customize the keyboard appearance:

```dart
VirtualKeyboardTheme(
  backgroundColor: Color(0xFF1E293B),      // Keyboard background
  textColor: Color(0xFFE2E8F0),          // Key text color
  secondaryTextColor: Color(0xFF94A3B8),  // Secondary text
  iconColor: Color(0xFFE2E8F0),          // Icon color
  activeColor: Color(0xFF06B6D4),        // Active/selected color
  borderColor: Color(0x1AFFFFFF),        // Border color
)
```

### Keyboard Types

Switch between different keyboard types:

```dart
VirtualKeyboardHandler(
  keyboardType: VirtualKeyboardType.Alphanumeric, // or VirtualKeyboardType.Numeric
)
```

## Extension Methods

The example includes extension methods on `QuillEditorController` for standardized virtual keyboard integration:

```dart
// Insert text from virtual keyboard
await controller.insertVirtualKeyboardText('Hello');

// Handle backspace
await controller.handleVirtualBackspace();

// Handle keyboard actions
await controller.handleVirtualKeyboardAction(VirtualKeyboardKeyAction.Return);
```

## Building Upon This Example

This example provides a foundation that you can adapt for your own virtual keyboard solutions:

1. **Replace the Virtual Keyboard**: Swap out `virtual_keyboard_multi_language` with your preferred virtual keyboard package
2. **Customize Event Handling**: Modify the key press handlers in `VirtualKeyboardHandler`
3. **Add Features**: Extend the handler with features like autocomplete, suggestions, or custom layouts
4. **Integrate with State Management**: Connect the keyboard state to your app's state management solution

## Dependencies

This example uses the following packages:

- `virtual_keyboard_multi_language`: ^1.1.2 - The virtual keyboard implementation
- `google_fonts`: ^6.1.0 - For custom fonts
- `quill_html_editor`: The main editor package

## Running the Example

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the example:
   ```bash
   flutter run
   ```

3. Use the keyboard toggle button in the toolbar to switch between virtual and system keyboards

## Notes

- By default, the virtual keyboard is enabled
- The virtual keyboard automatically appears when the editor gains focus (in virtual mode)
- The keyboard can be hidden using the close button or by switching to system keyboard mode
- All keyboard interactions are properly handled and integrated with the Quill editor's undo/redo system

## Future Enhancements

Potential improvements for production use:

- **Persistence**: Remember the user's keyboard preference
- **Adaptive Layouts**: Different keyboard layouts based on input context
- **Autocomplete Integration**: Connect with autocomplete/suggestion systems
- **Accessibility**: Enhanced accessibility features for the virtual keyboard
- **Performance**: Optimize rendering for large text documents
