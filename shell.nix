let
  pkgs = import <nixpkgs> {};
  # Use an environment variable to select the settings file
  selectedCompany = builtins.getEnv "MAJ_COMPANY";
  settingsFile = ./settings-${selectedCompany}.json;
  settings = builtins.fromJSON (builtins.readFile settingsFile);
in
  pkgs.mkShell {
    packages = with pkgs; [
      python310
      uv
      terraform
      google-cloud-sdk
    ];
    shellHook = ''
      export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
        pkgs.stdenv.cc.cc
      ]}
      export TERRAFORM_RUN_DIR=$(pwd)/infrastructure/terraform
      export PROJECT_ID="${settings.project_id}";
      export TF_VAR_tf_state_project_id="${settings.project_id}";
      export TF_VAR_data_project_id="${settings.project_id}";
      export TF_VAR_property_id="${settings.property_id}";
      export TF_VAR_data_processing_project_id="${settings.project_id}";
      export TF_VAR_source_ga4_export_project_id="${settings.source_ga4_export_project_id}";
      export TF_VAR_source_ga4_export_dataset="${settings.source_ga4_export_dataset}_${settings.property_id}";
      export TF_VAR_source_ads_export_data='${settings.source_ads_export_data}';
      export TF_VAR_feature_store_project_id="${settings.project_id}";
      export TF_VAR_website_url="${settings.website_url}";
      export TF_VAR_activation_project_id="${settings.project_id}";
      export TF_VAR_ga4_property_id="${settings.property_id}";
      export TF_VAR_ga4_stream_id="${settings.ga4_stream_id}";
      export TF_VAR_ga4_measurement_id="${settings.ga4_measurement_id}";
      export TF_VAR_ga4_measurement_secret="${settings.ga4_measurement_secret}";
      gcloud auth application-default set-quota-project $PROJECT_ID
      gcloud config set project $PROJECT_ID
      rm infrastructure/terraform/.terraform.lock -rf
      rm infrastructure/terraform/backend.tf -f
      ./scripts/reinit-tf-backend.sh
      terraform -chdir=infrastructure/terraform init
    '';
  }
