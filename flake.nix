{
  description = "OpenCV + MediaPipe flake using pip (Wayland-compatible)";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        pkgs.python312
        pkgs.python312Packages.pip
	(pkgs.python312Packages.opencv4.override {
		enableGtk3 = true;
	  })
        pkgs.libGL
        pkgs.gtk3
        pkgs.glib
        pkgs.zlib

        # X11 libraries (updated names)
        pkgs.libx11
        pkgs.libxext
        pkgs.libxrender
        pkgs.libxrandr
        pkgs.libxi
        pkgs.libxfixes
        pkgs.xcbutil
        pkgs.gtk3
        pkgs.libxcb
        pkgs.libxcb-util
        pkgs.libxcb-image
        pkgs.libxcb-errors
        pkgs.libxcb-cursor
        pkgs.libxcb-keysyms
        pkgs.libxcb-render-util
        pkgs.libxcb-wm
        pkgs.libxkbcommon
        # GCC runtime for C-extensions (numpy, mediapipe)
        pkgs.libc
      ];

      shellHook = ''
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath [
          pkgs.libGL
          pkgs.glib
          pkgs.zlib
          pkgs.libx11
          pkgs.libxext
          pkgs.libxrender
          pkgs.libxrandr
          pkgs.libxi
          pkgs.libxfixes
          pkgs.xcbutil
          pkgs.gtk3
          pkgs.stdenv.cc.cc.lib
          pkgs.libxcb
        pkgs.libxcb-util
        pkgs.libxcb-image
        pkgs.libxcb-errors
        pkgs.libxcb-cursor
        pkgs.libxcb-keysyms
        pkgs.libxcb-render-util
        pkgs.libxcb-wm
        pkgs.libxkbcommon
       ]}

        if [ ! -d .venv ]; then
          python -m venv .venv
        fi

        source .venv/bin/activate

        echo "Python $(python --version)"
        echo "LD_LIBRARY_PATH configured"
      '';
    };
  };
}


