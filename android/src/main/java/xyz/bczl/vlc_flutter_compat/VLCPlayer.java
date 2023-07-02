package xyz.bczl.vlc_flutter_compat;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.net.Uri;

import org.videolan.libvlc.LibVLC;
import org.videolan.libvlc.Media;
import org.videolan.libvlc.MediaPlayer;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry;

public class VLCPlayer implements MediaPlayer.EventListener {

    private final QueuingEventSink mEventSink = new QueuingEventSink();

    private final Context mCtx;
    private final TextureRegistry.SurfaceTextureEntry mTextureEntry;
    private final EventChannel mChannel;
    private final List<String> mOptions;
    private MediaPlayer mMediaPlayer;
    private LibVLC mLibVLC;

    public VLCPlayer(Context ctx,
                     EventChannel channel,
                     TextureRegistry.SurfaceTextureEntry textureEntry,
                     List<String> options) {
        mCtx = ctx;
        mChannel = channel;
        mTextureEntry = textureEntry;
        mOptions = options;

        mChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink eventSink) {
                mEventSink.setEventSinkProxy(eventSink);
            }

            @Override
            public void onCancel(Object o) {
                mEventSink.setEventSinkProxy(null);
            }
        });

        init();
    }

    private void init() {
        if (mMediaPlayer == null) {
            mLibVLC = new LibVLC(mCtx, mOptions);
            mMediaPlayer = new MediaPlayer(mLibVLC);
            mMediaPlayer.setEventListener(this);

            SurfaceTexture texture = mTextureEntry.surfaceTexture();
            mMediaPlayer.getVLCVout().setVideoSurface(texture);
            mMediaPlayer.getVLCVout().attachViews();
        }
    }

    public void setDefaultBufferSize(int width, int height) {
        mTextureEntry.surfaceTexture().setDefaultBufferSize(width, height);
        mMediaPlayer.setAspectRatio(width + ":" + height);
        mMediaPlayer.getVLCVout().setWindowSize(width, height);
    }

    public void setDataSource(Uri uri) {
        if (mMediaPlayer != null) {
            mMediaPlayer.setMedia(new Media(mLibVLC, uri));
        }
    }

    public void setDataSource(String path) {
        if (mMediaPlayer != null) {
            mMediaPlayer.setMedia(new Media(mLibVLC, path));
        }
    }

    public void dispose() {
        if (mMediaPlayer != null) {
            mMediaPlayer.stop();
            mMediaPlayer.release();
            mTextureEntry.release();
            mChannel.setStreamHandler(null);
            mMediaPlayer.setEventListener(null);
            mMediaPlayer = null;
        }

        if (mLibVLC != null) {
            mLibVLC.release();
            mLibVLC = null;
        }
    }

    public MediaPlayer getPlayer() {
        return mMediaPlayer;
    }

    @Override
    public void onEvent(MediaPlayer.Event event) {
        Map<String, Object> param = new HashMap<>();
        param.put("type", event.type);
        param.put("Buffering", event.getBuffering());
        param.put("Time", event.getTimeChanged());
        param.put("Length", event.getLengthChanged());
        param.put("Position", event.getPositionChanged());
        param.put("VoutCount", event.getVoutCount());
        param.put("EsChangedType", event.getEsChangedType());
        param.put("EsChangedID", event.getEsChangedID());
        param.put("Seekable", event.getSeekable());
        param.put("Pausable", event.getPausable());
        param.put("Recording", event.getRecording());
        param.put("RecordPath", event.getRecordPath());
        mEventSink.success(param);
    }
}
