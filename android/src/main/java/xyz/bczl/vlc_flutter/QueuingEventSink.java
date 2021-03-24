package xyz.bczl.vlc_flutter;

import java.util.LinkedList;
import java.util.Queue;

import io.flutter.plugin.common.EventChannel;

/**
 * And implementation of {@link EventChannel.EventSink} which can wrap an underlying sink.
 *
 * <p>It delivers messages immediately when downstream is available, but it queues messages before
 * the eventSink event sink is set with setDelegate.
 *
 * <p>This class is not thread-safe. All calls must be done on the same thread or synchronized
 * externally.
 */
final class QueuingEventSink implements EventChannel.EventSink {

    private EventChannel.EventSink eventSink;
    private Queue<Object> eventQueue = new LinkedList();
    private boolean isEnd = false;

    public void setEventSinkProxy(EventChannel.EventSink es) {
        this.eventSink = es;
        consume();
    }

    @Override
    public void endOfStream() {
        enqueue(new EndEvent());
        consume();
        isEnd = true;
    }

    @Override
    public void error(String code, String message, Object details) {
        enqueue(new ErrorEvent(code, message, details));
        consume();
    }

    @Override
    public void success(Object event) {
        enqueue(event);
        consume();
    }

    private void enqueue(Object event) {
        if (isEnd)  return;
        eventQueue.offer(event);
    }

    private void consume() {
        if (eventSink == null) return;
        while (!eventQueue.isEmpty()){
            Object event = eventQueue.poll();
            if (event instanceof EndEvent) {
                eventSink.endOfStream();
            } else if (event instanceof ErrorEvent) {
                ErrorEvent errorEvent = (ErrorEvent) event;
                eventSink.error(errorEvent.code, errorEvent.message, errorEvent.details);
            } else {
                eventSink.success(event);
            }
        }
    }

    private static class EndEvent {

    }

    private static class ErrorEvent {
        String code;
        String message;
        Object details;

        ErrorEvent(String code, String message, Object details) {
            this.code = code;
            this.message = message;
            this.details = details;
        }
    }
}
