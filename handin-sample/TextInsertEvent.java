/**
 * 
 * @author Jesper Buus Nielsen
 *
 */
public class TextInsertEvent extends MyTextEvent {

  private String text;

  public TextInsertEvent(int offset, String text) {
    super(offset);
    this.text = text;
  }
  public String getText() { return text; }
}

