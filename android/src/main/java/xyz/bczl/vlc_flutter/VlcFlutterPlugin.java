package xyz.bczl.vlc_flutter;

import android.content.Context;
import android.net.Uri;
import android.util.Log;
import android.util.LongSparseArray;

import androidx.annotation.NonNull;

import org.videolan.libvlc.MediaPlayer;

import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry;


/**
 * VlcFlutterPlugin
 */
public class VlcFlutterPlugin implements FlutterPlugin, VLCPlayerAPI.VLCPlayerApi {
    private static final String TAG = "VlcFlutterPlugin";

    private final LongSparseArray<VLCPlayer> mPlayers = new LongSparseArray<>();
    private FlutterState mFlutterState;


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        mFlutterState = new FlutterState(
                binding.getApplicationContext(),
                binding.getBinaryMessenger(),
                binding.getTextureRegistry());
        mFlutterState.startListening(this, binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (mFlutterState == null) {
            Log.wtf(TAG, "Detached from the engine before registering to it.");
        }
        mFlutterState.stopListening(binding.getBinaryMessenger());
        mFlutterState = null;
        release();
    }

    @Override
    public Long create(List<String> options) {
        TextureRegistry.SurfaceTextureEntry textureEntry =
                mFlutterState.textureRegistry.createSurfaceTexture();

        long textureId = textureEntry.id();

        EventChannel eventChannel = new EventChannel(
                mFlutterState.binaryMessenger, "xyz.bczl.vlc_flutter/VLCPlayer/id_" + textureId);

        VLCPlayer player = new VLCPlayer(mFlutterState.applicationContext, eventChannel, textureEntry, options);
        mPlayers.put(textureId, player);

        return textureId;
    }

    @Override
    public void createByIOS(List<String> options, Long viewId) {
    }

    @Override
    public void dispose(Long id) {
        VLCPlayer p = mPlayers.get(id);
        if (p != null) p.dispose();
        mPlayers.remove(id);
    }

    @Override
    public void release() {
        for (int i = 0; i < mPlayers.size(); i++) {
            mPlayers.valueAt(i).dispose();
        }
        mPlayers.clear();
    }

    @Override
    public void setDefaultBufferSize(Long width, Long height, Long textureId) {
        mPlayers.get(textureId).setDefaultBufferSize(width.intValue(), height.intValue());
    }

    @Override
    public void setDataSource(String uri, String path, Long textureId) {
        if (uri != null && !uri.isEmpty()) {
            mPlayers.get(textureId).setDataSource(Uri.parse(uri));
        } else if (path != null && !path.isEmpty()) {
            mPlayers.get(textureId).setDataSource(path);
        }
    }

    private MediaPlayer player(long key) {
        return mPlayers.get(key).getPlayer();
    }

    @Override
    public void setVideoScale(Long value, Long textureId) {
        player(textureId).setVideoScale(
                MediaPlayer.ScaleType.values()[value.intValue()]);
    }

    @Override
    public Long getVideoScale(Long textureId) {
        MediaPlayer.ScaleType type = player(textureId).getVideoScale();
        return (long) type.ordinal();
    }

    @Override
    public void play(String uri, String path, Long textureId) {
        if (uri != null && !uri.isEmpty()) {
            player(textureId).play(Uri.parse(uri));
        } else if (path != null && !path.isEmpty()) {
            player(textureId).play(path);
        } else {
            player(textureId).play();
        }
    }

    @Override
    public void stop(Long textureId) {
        player(textureId).stop();
    }

    @Override
    public Double getScale(Long textureId) {
        float val = player(textureId).getScale();
        return (double) val;
    }

    @Override
    public void setScale(Double scale, Long textureId) {
        player(textureId).setScale(scale.floatValue());
    }

    @Override
    public String getAspectRatio(Long textureId) {
        return player(textureId).getAspectRatio();
    }

    @Override
    public void setAspectRatio(String aspect, Long textureId) {
        player(textureId).setAspectRatio(aspect);
    }

    @Override
    public void setRate(Double rate, Long textureId) {
        player(textureId).setRate(rate.floatValue());
    }

    @Override
    public Double getRate(Long textureId) {
        float rate = player(textureId).getRate();
        return (double) rate;
    }

    @Override
    public Boolean isPlaying(Long textureId) {
        return player(textureId).isPlaying();
    }

    @Override
    public Boolean isSeekable(Long textureId) {
        return player(textureId).isSeekable();
    }

    @Override
    public void pause(Long textureId) {
        player(textureId).pause();
    }

    @Override
    public Long getPlayerState(Long textureId) {
        int state = player(textureId).getPlayerState();
        return (long) state;
    }

    @Override
    public Long getVolume(Long textureId) {
        int volume = player(textureId).getVolume();
        return (long) volume;
    }

    @Override
    public Long setVolume(Long volume, Long textureId) {
        Integer r = player(textureId).setVolume(volume.intValue());
        return r.longValue();
    }

    @Override
    public Long getTime(Long textureId) {
        return player(textureId).getTime();
    }

    @Override
    public Long setTime(Long time, Long textureId) {
        return player(textureId).setTime(time);
    }

    @Override
    public Double getPosition(Long textureId) {
        Float position = player(textureId).getPosition();
        return position.doubleValue();
    }

    @Override
    public void setPosition(Double pos, Long textureId) {
        player(textureId).setPosition(pos.floatValue());
    }

    @Override
    public Long getLength(Long textureId) {
        return player(textureId).getLength();
    }

    @Override
    public Boolean addSlave(Long type, String uri, String path, Boolean select, Long textureId) {
        boolean r = false;
        if (uri != null) {
            r = player(textureId).addSlave(type.intValue(), Uri.parse(uri), select);
        } else if (path != null) {
            r = player(textureId).addSlave(type.intValue(), path, select);
        }
        return r;
    }

    @Override
    public void setVideoTitleDisplay(Long position, Long timeout, Long textureId) {
        player(textureId).setVideoTitleDisplay(position.intValue(), timeout.intValue());
    }

    @Override
    public Boolean record(String directory, Long textureId) {
        String path = directory.isEmpty() ? null : directory;
        return player(textureId).record(path);
    }


    private static final class FlutterState {
        private final Context applicationContext;
        private final BinaryMessenger binaryMessenger;
        private final TextureRegistry textureRegistry;

        FlutterState(Context applicationContext,
                     BinaryMessenger messenger,
                     TextureRegistry textureRegistry) {
            this.applicationContext = applicationContext;
            this.binaryMessenger = messenger;
            this.textureRegistry = textureRegistry;
        }

        void startListening(VlcFlutterPlugin plugin, BinaryMessenger messenger) {
            VLCPlayerAPI.VLCPlayerApi.setup(messenger, plugin);
        }

        void stopListening(BinaryMessenger messenger) {
            VLCPlayerAPI.VLCPlayerApi.setup(messenger, null);
        }
    }
}
