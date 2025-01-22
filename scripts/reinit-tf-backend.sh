#!/usr/bin/env sh

# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset

. scripts/common.sh

section_open "Check if the necessary variables are set: PROJECT_ID"
    check_environment_variable "PROJECT_ID" "the Google Cloud project that Terraform will provision the resources in"
section_close

section_open  "Setting the Google Cloud project to TF_STATE_PROJECT"
    set_environment_variable_if_not_set "TF_STATE_PROJECT" "${PROJECT_ID}"
    gcloud config set project "${TF_STATE_PROJECT}"
section_close

section_open  "Check and set the LOCATION variable"
    set_environment_variable_if_not_set "LOCATION" "europe-west1"
section_close

section_open  "Check and set the TF_STATE_BUCKET variable"
    set_environment_variable_if_not_set "TF_STATE_BUCKET" "${TF_STATE_PROJECT}-terraform-state"
section_close

section_open "Check if the TF_STATE_BUCKET bucket exists"
    if gsutil ls -b gs://"${TF_STATE_BUCKET}" >/dev/null 2>&1; then
        printf "The ${TF_STATE_BUCKET} Google Cloud Storage bucket already exists. \n"
    else
        printf "The ${TF_STATE_BUCKET} Google Cloud Storage bucket doesn't exist. \n"
        exit 1
    fi
section_close

section_open "Creating terraform backend.tf configuration file"
    TERRAFORM_RUN_DIR="infrastructure/terraform"
    create_terraform_backend_config_file "${TERRAFORM_RUN_DIR}" "${TF_STATE_BUCKET}"
section_close

printf "$DIVIDER"
printf "You got the end the of your generate-tf-backend script with everything working. \n"
printf "$DIVIDER"
