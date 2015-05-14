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

  public KeyboardImpl(Component textArea, KeyboardListener listener) {
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
      java.awt.EventQueue.invokeLater(new TypeKeyInTextArea(textArea, ch, modifiers));
    else
      customTextArea.keyTyped(ch);
  }

  public void pressBackspace() {
    if (textArea != null)
      java.awt.EventQueue.invokeLater(new PressInTextArea(textArea, KeyEvent.VK_BACK_SPACE));
    else
      customTextArea.backspaceKeyPressed();
  }

  public void pressDelete() {
    if (textArea != null)
      java.awt.EventQueue.invokeLater(new PressInTextArea(textArea, KeyEvent.VK_DELETE));
    else
      customTextArea.deleteKeyPressed();
  }

  class TypeKeyInTextArea implements Runnable {
    Component textArea;
    char ch;
    int modifiers;

    TypeKeyInTextArea(Component textArea, char ch, int modifiers) {
      this.textArea = textArea;
      this.ch = ch;
      this.modifiers = modifiers;
    }

    public void run() {
      textArea.dispatchEvent(new KeyEvent(textArea,
            KeyEvent.KEY_TYPED, 0,
            modifiers, KeyEvent.VK_UNDEFINED, ch));
    }
  }

  class PressInTextArea implements Runnable {
    Component textArea;
    int keyCode;

    PressInTextArea(Component textArea, int keyCode) {
      this.textArea = textArea;
      this.keyCode = keyCode;
    }

    public void run() {
      textArea.dispatchEvent(new KeyEvent(textArea, KeyEvent.KEY_PRESSED,
            System.currentTimeMillis(), 0, keyCode));
      textArea.dispatchEvent(new KeyEvent(textArea, KeyEvent.KEY_RELEASED,
            System.currentTimeMillis(), 0, keyCode));
    }
  }
}
