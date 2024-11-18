let
  pkgs = import <nixpkgs> {};
  settings = builtins.fromJSON (builtins.readFile ./settings.json);
in
  pkgs.mkShell {
    packages = with pkgs; [
      python310
      (poetry.override {python3 = python310;})
      terraform
      google-cloud-sdk
    ];
    shellHook = ''
      export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
        pkgs.stdenv.cc.cc
      ]}
      export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring
      export TERRAFORM_RUN_DIR=$(pwd)/infrastructure/terraform
      export PROJECT_ID="${settings.projectId}";
      poetry install
      gcloud auth application-default set-quota-project $PROJECT_ID
      gcloud config set project $PROJECT_ID
    '';
  }
