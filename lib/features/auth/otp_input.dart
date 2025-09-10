import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import GoogleFonts and AppTheme if you use them in your project.

class OtpInput extends StatefulWidget {
  final int length;
  final void Function(String)? onCompleted;
  final void Function()? onCleared;

  const OtpInput({Key? key, this.length = 6, this.onCompleted, this.onCleared})
      : super(key: key);

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  final FocusNode _keyboardFocusNode = FocusNode();
  int _backspaceRepeatCount = 0;
  DateTime? _lastBackspaceTime;
  bool _isValidOTP = false;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    // give keyboard focus so key events are captured
    _keyboardFocusNode.requestFocus();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handlePaste(String pastedText, int startIndex) {
    // Only digits (but you can change)
    final filtered = pastedText.replaceAll(RegExp(r'[^0-9]'), '');
    int writeIndex = startIndex;
    for (int i = 0; i < filtered.length && writeIndex < widget.length; i++) {
      _controllers[writeIndex].text = filtered[i];
      writeIndex++;
    }

    // update focus: if there are remaining slots, focus next free; else unfocus
    if (writeIndex < widget.length) {
      _focusNodes[writeIndex].requestFocus();
    } else {
      _focusNodes.last.unfocus();
    }

    _updateOtpStateAndMaybeComplete();
  }

  void _updateOtpStateAndMaybeComplete() {
    setState(() {
      _isValidOTP =
          _controllers.every((controller) => controller.text.trim().isNotEmpty);
    });

    if (_isValidOTP) {
      final otp = _controllers.map((c) => c.text).join();
      widget.onCompleted?.call(otp);
    }
  }

  void _clearAll() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {
      _isValidOTP = false;
    });
    widget.onCleared?.call();
  }

  KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
    // Only handle key down events
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;

    // Backspace handling
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      int currentIndex =
          _focusNodes.indexWhere((focusNode) => focusNode.hasFocus);
      if (currentIndex == -1) {
        // no single field focused -> do nothing
        return KeyEventResult.handled;
      }

      // Manage repeated backspace detection (to allow "clear all" by holding)
      final now = DateTime.now();
      if (_lastBackspaceTime == null ||
          now.difference(_lastBackspaceTime!) > const Duration(milliseconds: 500)) {
        _backspaceRepeatCount = 1;
      } else {
        _backspaceRepeatCount++;
      }
      _lastBackspaceTime = now;

      // If current field has a value -> clear it
      if (_controllers[currentIndex].text.isNotEmpty) {
        _controllers[currentIndex].clear();
        // keep focus on this field so user can continue deleting
        _focusNodes[currentIndex].requestFocus();
      } else {
        // current is empty -> move back and clear previous (if exists)
        if (currentIndex > 0) {
          _controllers[currentIndex - 1].clear();
          _focusNodes[currentIndex - 1].requestFocus();
        } else {
          // we're at index 0 and it's empty: if user holds backspace quickly,
          // clear everything (useful on platforms where repeated key events are available)
          if (_backspaceRepeatCount >= widget.length) {
            _clearAll();
          }
        }
      }

      _updateOtpStateAndMaybeComplete();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _keyboardFocusNode,
      onKey: _onKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Clear button (optional) — helpful on mobile where key repeat might not be sent
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear all OTP digits',
            onPressed: _clearAll,
          ),

          // The OTP boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(widget.length, (index) {
              return Container(
                width: 50,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextFormField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  inputFormatters: [
                    // 1) only digits
                    FilteringTextInputFormatter.digitsOnly,
                    // 2) custom paste detector: if more than 1 character arrives, call _handlePaste
                    _PasteTextInputFormatter(index: index, onPaste: _handlePaste),
                  ],
                  onChanged: (value) {
                    // If user typed or pasted single char, move focus forward
                    if (value.isNotEmpty) {
                      if (index < widget.length - 1) {
                        _focusNodes[index + 1].requestFocus();
                      } else {
                        _focusNodes[index].unfocus();
                      }
                    } else {
                      // value became empty because user deleted -> move focus back if possible
                      if (index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    }
                    _updateOtpStateAndMaybeComplete();
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Custom input formatter that detects paste (newValue has length > 1).
/// When paste is detected it calls onPaste with the pasted text and the start index,
/// then returns [oldValue] so default insertion doesn't happen (we populate controllers manually).
class _PasteTextInputFormatter extends TextInputFormatter {
  final int index;
  final void Function(String pasted, int startIndex) onPaste;

  _PasteTextInputFormatter({required this.index, required this.onPaste});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // If more than one character inserted at once -> paste (or programmatic insert)
    if (newValue.text.length > 1) {
      // notify parent to distribute pasted content
      try {
        onPaste(newValue.text, index);
      } catch (_) {}
      // return the old value to prevent the field from showing the entire pasted string
      return oldValue;
    }
    // otherwise accept the change (single char or deletion)
    return newValue;
  }
}
