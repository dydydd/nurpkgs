{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  mpv-unwrapped,
  ffmpeg,
  libadwaita,
  gst_all_1,
  openssl,
  libepoxy,
  libglycin-gtk4,
  wrapGAppsHook4,
  nix-update-script,
  meson,
  ninja,
  rustc,
  cargo,
  dbus,
  desktop-file-utils,
  blueprint-compiler,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tsukimi";
  version = "26.8.1";

  src = fetchFromGitHub {
    owner = "tsukinaha";
    repo = "tsukimi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Hf51P0Hfi21w/HwJc0hsatV2Mp8XUcxJOVQIKGWRmic=";
  };

  # 和 nixpkgs 官方包一致：从 src 读 Cargo.lock
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-uWfMWKXpLseGir+DvQor+IXl+fjeWmqm22meiq/BAa0=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    meson
    ninja
    rustPlatform.cargoSetupHook
    rustc
    cargo
    desktop-file-utils
    blueprint-compiler
  ];

  buildInputs = [
    mpv-unwrapped
    ffmpeg
    libadwaita
    openssl
    libepoxy
    libglycin-gtk4
    dbus
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ]);

  # 自动更新：nix-update 自动获取最新 release 并更新 version + hash
  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex" "v([0-9]+\\.[0-9]+\\.[0-9]+)"
    ];
  };

  meta = {
    description = "Simple third-party Emby client, featured with GTK4-RS, MPV and GStreamer";
    homepage = "https://github.com/tsukinaha/tsukimi";
    license = lib.licenses.gpl3Plus;
    mainProgram = "tsukimi";
    platforms = lib.platforms.linux;
  };
})
