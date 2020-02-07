package com.nordef.memes;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);

    ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
    com.nordef.memes.WallpaperPlugin.registerWith(shimPluginRegistry.registrarFor("com.nordef.memes.WallpaperPlugin"));
  }
}
