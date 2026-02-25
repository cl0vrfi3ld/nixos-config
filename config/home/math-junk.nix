{ pkgs, ... }:
let
  rstudio-fhs = pkgs.buildFHSEnv {
    name = "rstudio-fhs";

    # These packages will be available inside the FHS bubble
    targetPkgs =
      pkgs:
      (with pkgs; [
        # --- The Core ---
        R
        rstudio

        # --- Toolchain ---
        gcc
        gnumake
        gfortran
        binutils
        pkg-config
        cmake

        # --- Libraries & Headers (The Fix) ---
        # Network & Security
        openssl
        openssl.dev # Required for 'openssl' package
        curl
        curl.dev # Required for 'curl' package
        libxml2
        libxml2.dev # Required for 'xml2' package
        zlib
        zlib.dev # Required for 'haven'

        # Text & Fonts (The 'systemfonts' & 'textshaping' nightmares)
        freetype
        freetype.dev
        fontconfig
        fontconfig.dev
        harfbuzz
        harfbuzz.dev
        fribidi # Required for bidirectional text (textshaping)
        fribidi.dev
        icu
        icu.dev

        # Graphics
        libpng
        libpng.dev
        libjpeg
        libjpeg.dev
        libtiff
        libtiff.dev
        libwebp
        # libwebp.dev
        cairo
        cairo.dev
        pango
        pango.dev
        rPackages.V8

        # Common R deps
        udunits # Often needed for spatial packages
        # udunits.dev
      ]);

    # The command to start when the FHS env is entered
    runScript = "rstudio";
  };
in
{
  home.packages = [
    rstudio-fhs
  ];

  # add desktop entries
  xdg.desktopEntries = {
    rstudio-fhs = {
      name = "RStudio (FHS)";
      genericName = "Integrated Development Environment";
      comment = "RStudio with FHS environment for compilation";

      # This calls the wrapper binary we created in the previous step
      exec = "rstudio-fhs %F";

      # We assume the icon is available in your icon theme,
      # or you can point this to a specific path
      icon = "${pkgs.rstudio}/share/icons/hicolor/256x256/apps/rstudio.png";

      terminal = false;
      categories = [
        "Development"
        "Science"
        "Education"
      ];
      mimeType = [
        "text/x-r-source"
        "application/x-r-data"
      ];
    };
  };
}
