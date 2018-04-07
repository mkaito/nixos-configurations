{ nixops, openssh, libvirt }:
nixops.overrideAttrs (super: {
  src = builtins.fetchGit {
    url = "https://github.com/NixOS/nixops";
    rev = "b267e2ba592d97d55296e8183689652dc4637416";
  };
  pythonPath = super.pythonPath ++ [ libvirt ];
  patches = [ ./eval-custom-nixpkgs.diff ];
  postPatch = ''
    for f in scripts/nixops setup.py; do
      substituteInPlace $f --subst-var-by version ${super.version}
    done

    rm -r doc/manual
  '';
  postInstall = ''
    mkdir -p $out/share/nix/nixops && cp -av nix/* $_
    wrapProgram $out/bin/nixops --prefix PATH : ${openssh}/bin
  '';
})
