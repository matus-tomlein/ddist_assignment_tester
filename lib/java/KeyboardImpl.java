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

  public void pressDelete() {
    if (textArea != null)
      java.awt.EventQueue.invokeLater(new DeleteInTextArea(textArea));
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

  class DeleteInTextArea implements Runnable {
    Component textArea;

    DeleteInTextArea(Component textArea) {
      this.textArea = textArea;
    }

    public void run() {
      textArea.dispatchEvent(new KeyEvent(textArea, KeyEvent.KEY_PRESSED,
            System.currentTimeMillis(), 0, KeyEvent.VK_DELETE));
      textArea.dispatchEvent(new KeyEvent(textArea, KeyEvent.KEY_RELEASED,
            System.currentTimeMillis(), 0, KeyEvent.VK_DELETE));
    }
  }
}
