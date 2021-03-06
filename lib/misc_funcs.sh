# Runs stuff in a wrapper. If exit code is not zero, it exits
#
# Usage:
#     function greet() {
#       echo "Hello $1"
#     }
#     try_run "greet Akash"
function try_run() {
  (eval $1)
  local cmd_result=$?
  if [[ $cmd_result != 0 ]] ; then
      echo "Exiting"
      exit $cmd_result
  fi
}


# Outputs log line
#
# Usage:
#
#     output_line "Cloning repository"
#
function output_line() {
  local spacing="      "
  echo "${spacing} $1"
}

# Outputs section heading
#
# Usage:
#
#     output_section "Application tasks"
#
function output_section() {
  local indentation="----->"
  echo "${indentation} $1"
}


# Download archive of branch, tag or commit of a project from Github
#
# Usage:
#
#     github_download "elixir-lang" "elixir" "master"
#
function github_download() {
  # We don't use the -J option because curl on Heroku is really old.
  # So we pass a filename ourselves.
  curl -k -s -L "https://github.com/$1/$2/archive/$3.tar.gz" -o "${cache_path}/$2-$3.tar.gz" || exit 1
}


function load_config() {
  output_section "Checking Erlang and Elixir versions"

  local custom_config_file="${build_path}/elixir_buildpack.config"

  # Source for default versions file from buildpack first
  source "${build_pack_path}/elixir_buildpack.config"

  if [ -f $custom_config_file ];
  then
    source $custom_config_file
  else
    output_line "WARNING: elixir_buildpack.config wasn't found in the app"
    output_line "Using default config from Elixir buildpack"
  fi

  output_line "Will use the following versions:"
  output_line "* Erlang ${erlang_version}"
  output_line "* Elixir ${elixir_version[0]} ${elixir_version[1]}"
}


function export_mix_env() {
  if [ -d $env_path ] && [ -f $env_path/MIX_ENV ]; then
    export MIX_ENV=$(cat $env_path/MIX_ENV)
  else
    export MIX_ENV=prod
  fi

  output_line "* MIX_ENV=${MIX_ENV}"
}


function clean_cache() {
  if [ $always_rebuild = true ]; then
    output_section "Cleaning all cache to force rebuilds"
    rm -rf $cache_path/*
  fi
}
