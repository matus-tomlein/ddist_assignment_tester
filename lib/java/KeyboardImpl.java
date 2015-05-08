import java.awt.*;
import java.awt.event.*;
import java.io.*;
import javax.swing.*;
import javax.swing.text.*;
import javax.swing.event.*;
import java.util.concurrent.*;
import java.awt.event.KeyEvent;
import java.lang.Thread;

public class KeyboardImpl {
  private Component textArea;
  private CustomTextArea customTextArea;
  private KeyboardListener listener;

  public KeyboardImpl(JTextArea textArea, KeyboardListener listener) {
    final DefaultCaret caret = new DefaultCaret();
    caret.setUpdatePolicy(DefaultCaret.ALWAYS_UPDATE);
    textArea.setCaret(caret);

    this.textArea = textArea;
    this.listener = listener;
  }

  public KeyboardImpl(JTextPane textArea, KeyboardListener listener) {
    final DefaultCaret caret = new DefaultCaret();
    caret.setUpdatePolicy(DefaultCaret.ALWAYS_UPDATE);
    textArea.setCaret(caret);

    this.textArea = textArea;
    this.listener = listener;
  }

  public KeyboardImpl(CustomTextArea customTextArea, KeyboardListener listener) {
    this.customTextArea = customTextArea;
    this.listener = listener;
  }

  public void typeString(String text, int speed) {
    for (char ch: text.toCharArray()) {
      typeChar(ch);
      try {
        Thread.sleep(speed);
      } catch (Exception ex) {
        System.out.println(ex.getMessage());
      }
    }
  }

  public void typeChar(char ch) {
    boolean isUpper = Character.isUpperCase(ch);
    int modifiers = isUpper ? KeyEvent.VK_SHIFT : 0;

    listener.logKeyPress(ch);

    if (textArea != null)
      textArea.dispatchEvent(new KeyEvent(textArea,
            KeyEvent.KEY_TYPED, 0,
            modifiers, KeyEvent.VK_UNDEFINED, ch));
    else
      customTextArea.keyTyped(ch);
  }
}
