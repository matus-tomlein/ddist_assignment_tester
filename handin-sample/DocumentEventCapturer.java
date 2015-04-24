import java.util.concurrent.LinkedBlockingQueue;
import javax.swing.text.AttributeSet;
import javax.swing.text.BadLocationException;
import javax.swing.text.DocumentFilter;

/**
 * 
 * This class captures and remembers the text events of the given document on
 * which it is put as a filter. Normally a filter is used to put restrictions
 * on what can be written in a buffer. In out case we just use it to see all
 * the events and make a copy. 
 * 
 * @author Jesper Buus Nielsen
 *
 */
public class DocumentEventCapturer extends DocumentFilter {

  /*
   * We are using a blocking queue for two reasons: 
   * 1) They are thread safe, i.e., we can have two threads add and take elements 
   *    at the same time without any race conditions, so we do not have to do  
   *    explicit synchronization.
   * 2) It gives us a member take() which is blocking, i.e., if the queue is
   *    empty, then take() will wait until new elements arrive, which is what
   *    we want, as we then don't need to keep asking until there are new elements.
   */
  protected LinkedBlockingQueue<MyTextEvent> eventHistory = new LinkedBlockingQueue<MyTextEvent>();

  /**	
   * If the queue is empty, then the call will block until an element arrives.
   * If the thread gets interrupted while waiting, we throw InterruptedException.
   * 
   * @return Head of the recorded event queue. 
   */
  MyTextEvent take() throws InterruptedException {
    return eventHistory.take();
  }

  public void insertString(FilterBypass fb, int offset,
      String str, AttributeSet a)
    throws BadLocationException {

    /* Queue a copy of the event and then modify the textarea */
    eventHistory.add(new TextInsertEvent(offset, str));		
    super.insertString(fb, offset, str, a);
  }	

  public void remove(FilterBypass fb, int offset, int length) 					
    throws BadLocationException {
    /* Queue a copy of the event and then modify the textarea */
    eventHistory.add(new TextRemoveEvent(offset, length));		
    super.remove(fb, offset, length);
  }

  public void replace(FilterBypass fb, int offset,
      int length, 
      String str, AttributeSet a)
    throws BadLocationException {

    /* Queue a copy of the event and then modify the text */
    if (length > 0) {
      eventHistory.add(new TextRemoveEvent(offset, length));		
    }		
    eventHistory.add(new TextInsertEvent(offset, str));				
    super.replace(fb, offset, length, str, a);
  }    
}
