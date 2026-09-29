package ru.mishanikolaev.finny

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.SoundPool
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var effectsEnabled = true
    private var musicEnabled = false
    private var visible = false
    private var player: MediaPlayer? = null
    private var sounds: SoundPool? = null
    private val samples = mutableMapOf<String, Int>()
    private val readySamples = mutableSetOf<Int>()
    private var focusRequest: AudioFocusRequest? = null
    private var currentScene = MusicScene.MAIN

    private val audioManager by lazy { getSystemService(Context.AUDIO_SERVICE) as AudioManager }

    private val musicAttributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_GAME)
        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
        .build()

    private val focusListener = AudioManager.OnAudioFocusChangeListener { state ->
        when (state) {
            AudioManager.AUDIOFOCUS_GAIN -> {
                player?.setVolume(currentScene.volume, currentScene.volume)
                if (musicEnabled && visible && player?.isPlaying == false) {
                    player?.start()
                }
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                val ducked = currentScene.volume * DUCK_FACTOR
                player?.setVolume(ducked, ducked)
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                if (player?.isPlaying == true) player?.pause()
            }
            AudioManager.AUDIOFOCUS_LOSS -> stopMusic()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        loadEffects()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "configure" -> {
                        effectsEnabled = call.argument<Boolean>("effects") ?: true
                        musicEnabled = call.argument<Boolean>("music") ?: false
                        if (musicEnabled) safeStartMusic() else stopMusic()
                        result.success(null)
                    }
                    "setMusicScene" -> {
                        setMusicScene(MusicScene.fromWire(call.arguments as? String))
                        result.success(null)
                    }
                    "playEffect" -> {
                        if (effectsEnabled && visible) {
                            playEffect(call.arguments as? String)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun loadEffects() {
        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_GAME)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        sounds = SoundPool.Builder()
            .setMaxStreams(3)
            .setAudioAttributes(attributes)
            .build()
            .also { pool ->
                pool.setOnLoadCompleteListener { _, sample, status ->
                    if (status == 0) readySamples.add(sample)
                }
                samples["tap"] = pool.load(this, R.raw.finni_tap, 1)
                samples["success"] = pool.load(this, R.raw.finni_success, 1)
                samples["warning"] = pool.load(this, R.raw.finni_warning, 1)
                samples["purchase"] = pool.load(this, R.raw.finni_purchase, 1)
            }
    }

    private fun playEffect(name: String?) {
        val sample = name?.let { samples[it] } ?: return
        if (sample in readySamples) {
            sounds?.play(sample, 0.38f, 0.38f, 1, 0, 1f)
        }
    }

    private fun setMusicScene(scene: MusicScene) {
        if (scene == currentScene) return
        currentScene = scene
        releasePlayer()
        if (musicEnabled && visible) safeStartMusic()
    }

    private fun safeStartMusic() {
        try {
            startMusic()
        } catch (_: Exception) {
            releasePlayer()
        }
    }

    private fun startMusic() {
        if (!musicEnabled || !visible) return
        if (!requestMusicFocus()) return

        if (player == null) {
            createScenePlayer()
        }
        if (player?.isPlaying == false) player?.start()
    }

    private fun requestMusicFocus(): Boolean {
        if (focusRequest != null) return true

        val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
            .setAudioAttributes(musicAttributes)
            .setOnAudioFocusChangeListener(focusListener)
            .build()
        if (audioManager.requestAudioFocus(request) != AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
            return false
        }
        focusRequest = request
        return true
    }

    private fun createScenePlayer() {
        player = MediaPlayer.create(this, currentScene.resourceId, musicAttributes, 0)?.apply {
            isLooping = true
            setVolume(currentScene.volume, currentScene.volume)
        }
    }

    private fun releasePlayer() {
        player?.setOnCompletionListener(null)
        player?.release()
        player = null
    }

    private fun stopMusic() {
        releasePlayer()
        focusRequest?.let { audioManager.abandonAudioFocusRequest(it) }
        focusRequest = null
    }

    override fun onStart() {
        super.onStart()
        visible = true
        safeStartMusic()
    }

    override fun onStop() {
        visible = false
        stopMusic()
        super.onStop()
    }

    override fun onDestroy() {
        stopMusic()
        sounds?.release()
        sounds = null
        readySamples.clear()
        samples.clear()
        super.onDestroy()
    }

    private enum class MusicScene(
        val resourceId: Int,
        val volume: Float,
    ) {
        MAIN(R.raw.finni_music_03_main, 0.15f),
        CALM(R.raw.finni_music_02_calm, 0.12f),
        SHOP(R.raw.finni_music_01_shop, 0.16f);

        companion object {
            fun fromWire(value: String?): MusicScene = when (value) {
                "shop" -> SHOP
                "calm" -> CALM
                else -> MAIN
            }
        }
    }

    companion object {
        private const val AUDIO_CHANNEL = "ru.mishanikolaev.finny/audio"
        private const val DUCK_FACTOR = 0.32f
    }
}
