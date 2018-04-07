function fac_upload_mods() {
  echo "Uploading mod folder..."
  rsync -rL --delete -e ssh ~/.factorio/mods/ factorio@factorio.udsgaming.net::mods
  echo "Restarting service..."
  facservice restart
  echo "Done. Please allow a few seconds for the service to boot."
}

function fac_download_mods() {
  echo "Downloading mods from server..."
  rsync -rL --delete -e ssh factorio@factorio.udsgaming.net::mods ~/.factorio/mods/
  echo "Done."
}

function fac_upload_save() {
  if [[ -e $1 ]]; then
    echo "Stopping service first..."
    facservice stop
    echo "Uploading save..."
    rsync -z -e ssh "$1" factorio@factorio.udsgaming.net::saves/default.zip
    echo "Starting service..."
    facservice start
    echo "Done. Please allow a few seconds for the service to boot."
  else
    echo "Am I supposed to guess which save you want to upload?"
  fi
}

function fac_service() {
  ssh factorio.udsgaming.net sudo systemctl "${1:-start}" factorio
}

function fac_server() {
  gcloud compute instances "${1:-start}" factorio
}

function fac() {
  [[ ! -z "$DEBUG" ]] && set -x
  case "$1" in
    mods)
      case "$2" in
        upload)
          fac_upload_mods
          ;;
        download)
          fac_download_mods
          ;;
        *)
          echo "Wat"
          ;;
      esac
      ;;
    save)
      case "$2" in
        upload)
          fac_upload_save "$3"
          ;;
        download)
          echo "Log into the game and save it from there, lazy bum."
          ;;
        *)
          echo "Wat"
          ;;
      esac
      ;;
    server)
      case "$2" in
        start)
          fac_server start
          ;;
        stop)
          fac_server stop
          ;;
        restart)
          fac_server stop
          fac_server start
          ;;
        *)
          echo "Wat"
          ;;
      esac
      ;;
    *)
      echo "Wat"
      ;;
  esac
  [[ ! -z "$DEBUG" ]] && set +x
}
