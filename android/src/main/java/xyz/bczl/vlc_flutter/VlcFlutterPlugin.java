package xyz.bczl.vlc_flutter;

import android.content.Context;
import android.net.Uri;
import android.util.Log;
import android.util.LongSparseArray;

import androidx.annotation.NonNull;

import org.videolan.libvlc.MediaPlayer;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry;
import xyz.bczl.vlc_flutter.VLCPlayerAPI.VLCPlayerApi;

/** VlcFlutterPlugin */
public class VlcFlutterPlugin implements FlutterPlugin, VLCPlayerApi {
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
  public VLCPlayerAPI.TextureParam create(VLCPlayerAPI.VLCPlayerOptions options) {
    TextureRegistry.SurfaceTextureEntry textureEntry =
            mFlutterState.textureRegistry.createSurfaceTexture();

    long textureId = textureEntry.id();

    EventChannel eventChannel = new EventChannel(
            mFlutterState.binaryMessenger, "xyz.bczl.vlc_flutter/VLCPlayer/id_" + textureId);

    VLCPlayer player = new VLCPlayer(mFlutterState.applicationContext,eventChannel,textureEntry,options);
    mPlayers.put(textureId, player);

    VLCPlayerAPI.TextureParam result = new VLCPlayerAPI.TextureParam();
    result.setTextureId(textureId);
    return result;
  }

  @Override
  public void dispose(VLCPlayerAPI.TextureParam arg) {
    VLCPlayer p = mPlayers.get(arg.getTextureId());
    if (p != null) p.dispose();
    mPlayers.remove(arg.getTextureId());
  }

  @Override
  public void release() {
    for (int i = 0; i < mPlayers.size(); i++) {
      mPlayers.valueAt(i).dispose();
    }
    mPlayers.clear();
  }

  @Override
  public void setDefaultBufferSize(VLCPlayerAPI.BufferSize arg) {
    mPlayers.get(arg.getTextureId()).setDefaultBufferSize(
            arg.getWidth().intValue(),arg.getHeight().intValue());
  }

  @Override
  public void setDataSource(VLCPlayerAPI.PlayParam arg) {
    if (arg.getUri() != null){
      mPlayers.get(arg.getTextureId()).setDataSource(Uri.parse(arg.getUri()));
    }else if (arg.getPath() != null){
      mPlayers.get(arg.getTextureId()).setDataSource(arg.getPath());
    }
  }

  private MediaPlayer player(long key){
    return mPlayers.get(key).getPlayer();
  }

  @Override
  public void setVideoScale(VLCPlayerAPI.IntParam arg) {
    player(arg.getTextureId()).setVideoScale(
            MediaPlayer.ScaleType.values()[arg.getValue().intValue()]);
  }

  @Override
  public VLCPlayerAPI.IntParam getVideoScale(VLCPlayerAPI.TextureParam arg) {
    MediaPlayer.ScaleType type = player(arg.getTextureId()).getVideoScale();
    VLCPlayerAPI.IntParam p = new VLCPlayerAPI.IntParam();
    p.setValue((long)type.ordinal());
    return p;
  }

  @Override
  public void play(VLCPlayerAPI.PlayParam arg) {
    if (arg.getUri() != null){
      player(arg.getTextureId()).play(Uri.parse(arg.getUri()));
    }else if (arg.getPath() != null){
      player(arg.getTextureId()).play(arg.getPath());
    }else {
      player(arg.getTextureId()).play();
    }
  }

  @Override
  public void stop(VLCPlayerAPI.TextureParam arg) {
    player(arg.getTextureId()).stop();
  }

  @Override
  public VLCPlayerAPI.DoubleParam getScale(VLCPlayerAPI.TextureParam arg) {
    float val = player(arg.getTextureId()).getScale();
    VLCPlayerAPI.DoubleParam r = new VLCPlayerAPI.DoubleParam();
    r.setValue((double)val);
    return r;
  }

  @Override
  public void setScale(VLCPlayerAPI.DoubleParam arg) {
    player(arg.getTextureId()).setScale(arg.getValue().floatValue());
  }

  @Override
  public VLCPlayerAPI.StringParam getAspectRatio(VLCPlayerAPI.TextureParam arg) {
    String ratio = player(arg.getTextureId()).getAspectRatio();

    VLCPlayerAPI.StringParam sp = new VLCPlayerAPI.StringParam();
    sp.setValue(ratio);
    return sp;
  }

  @Override
  public void setAspectRatio(VLCPlayerAPI.StringParam arg) {
    player(arg.getTextureId()).setAspectRatio(arg.getValue());
  }

  @Override
  public void setRate(VLCPlayerAPI.DoubleParam arg) {
    player(arg.getTextureId()).setRate(arg.getValue().floatValue());
  }

  @Override
  public VLCPlayerAPI.DoubleParam getRate(VLCPlayerAPI.TextureParam arg) {
    float rate = player(arg.getTextureId()).getRate();

    VLCPlayerAPI.DoubleParam dp = new VLCPlayerAPI.DoubleParam();
    dp.setValue((double)rate);
    return dp;
  }

  @Override
  public VLCPlayerAPI.BoolParam isPlaying(VLCPlayerAPI.TextureParam arg) {
    boolean playing = player(arg.getTextureId()).isPlaying();

    VLCPlayerAPI.BoolParam bp = new VLCPlayerAPI.BoolParam();
    bp.setValue(playing);
    return bp;
  }

  @Override
  public VLCPlayerAPI.BoolParam isSeekable(VLCPlayerAPI.TextureParam arg) {
    boolean seekable = player(arg.getTextureId()).isSeekable();

    VLCPlayerAPI.BoolParam bp = new VLCPlayerAPI.BoolParam();
    bp.setValue(seekable);
    return bp;
  }

  @Override
  public void pause(VLCPlayerAPI.TextureParam arg) {
    player(arg.getTextureId()).pause();
  }

  @Override
  public VLCPlayerAPI.IntParam getPlayerState(VLCPlayerAPI.TextureParam arg) {
    int state = player(arg.getTextureId()).getPlayerState();

    VLCPlayerAPI.IntParam ip = new VLCPlayerAPI.IntParam();
    ip.setValue((long)state);
    return ip;
  }

  @Override
  public VLCPlayerAPI.IntParam getVolume(VLCPlayerAPI.TextureParam arg) {
    int volume = player(arg.getTextureId()).getVolume();

    VLCPlayerAPI.IntParam ip = new VLCPlayerAPI.IntParam();
    ip.setValue((long)volume);
    return ip;
  }

  @Override
  public VLCPlayerAPI.IntParam setVolume(VLCPlayerAPI.IntParam arg) {
    long r = player(arg.getTextureId()).setVolume(arg.getValue().intValue());

    VLCPlayerAPI.IntParam ip = new VLCPlayerAPI.IntParam();
    ip.setValue(r);
    return ip;
  }

  @Override
  public VLCPlayerAPI.IntParam getTime(VLCPlayerAPI.TextureParam arg) {
    long time = player(arg.getTextureId()).getTime();

    VLCPlayerAPI.IntParam ip = new VLCPlayerAPI.IntParam();
    ip.setValue(time);
    return ip;
  }

  @Override
  public VLCPlayerAPI.IntParam setTime(VLCPlayerAPI.IntParam arg) {
    long r = player(arg.getTextureId()).setTime(arg.getValue());

    VLCPlayerAPI.IntParam ip = new VLCPlayerAPI.IntParam();
    ip.setValue(r);
    return ip;
  }

  @Override
  public VLCPlayerAPI.DoubleParam getPosition(VLCPlayerAPI.TextureParam arg) {
    float position = player(arg.getTextureId()).getPosition();

    VLCPlayerAPI.DoubleParam dp = new VLCPlayerAPI.DoubleParam();
    dp.setValue((double)position);
    return dp;
  }

  @Override
  public void setPosition(VLCPlayerAPI.DoubleParam arg) {
    player(arg.getTextureId()).setPosition(arg.getValue().floatValue());
  }

  @Override
  public VLCPlayerAPI.IntParam getLength(VLCPlayerAPI.TextureParam arg) {
    long len = player(arg.getTextureId()).getLength();

    VLCPlayerAPI.IntParam ip = new VLCPlayerAPI.IntParam();
    ip.setValue(len);
    return ip;
  }

  @Override
  public VLCPlayerAPI.BoolParam addSlave(VLCPlayerAPI.SlaveParam arg) {
    boolean r = false;
    if (arg.getUri() != null){
      r = player(arg.getTextureId()).addSlave(
              arg.getType().intValue(),Uri.parse(arg.getUri()),arg.getSelect());
    }else if (arg.getPath() != null){
      r = player(arg.getTextureId()).addSlave(
              arg.getType().intValue(),arg.getPath(),arg.getSelect());
    }

    VLCPlayerAPI.BoolParam bp = new VLCPlayerAPI.BoolParam();
    bp.setValue(r);
    return bp;
  }

  @Override
  public void setVideoTitleDisplay(VLCPlayerAPI.TitleDisplayParam arg) {
    player(arg.getTextureId()).setVideoTitleDisplay(
            arg.getPosition().intValue(),arg.getTimeout().intValue());
  }

  @Override
  public VLCPlayerAPI.BoolParam record(VLCPlayerAPI.StringParam arg) {
    boolean r = player(arg.getTextureId()).record(arg.getValue());

    VLCPlayerAPI.BoolParam bp = new VLCPlayerAPI.BoolParam();
    bp.setValue(r);
    return bp;
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
      VLCPlayerApi.setup(messenger, plugin);
    }

    void stopListening(BinaryMessenger messenger) {
      VLCPlayerApi.setup(messenger, null);
    }
  }
}
