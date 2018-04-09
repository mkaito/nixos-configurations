remotehost="factorio.udsgaming.net"

function fac_upload_mods() {
  echo "Uploading mod folder..."
  rsync -rL --delete -e ssh ~/.factorio/mods/ factorio@$remotehost::mods
  echo "Restarting service..."
  fac_service restart
  echo "Done. Please allow a few seconds for the service to boot."
}

function fac_download_mods() {
  echo "Downloading mods from server..."
  rsync -rL --delete -e ssh factorio@$remotehost::mods ~/.factorio/mods/
  echo "Done."
}

function fac_upload_save() {
  if [[ -e $1 ]]; then
    echo "Stopping service first..."
    fac_service stop
    echo "Uploading save..."
    rsync -z -e ssh "$1" factorio@$remotehost::saves/default.zip
    echo "Starting service..."
    fac_service start
    echo "Done. Please allow a few seconds for the service to boot."
  else
    echo "Am I supposed to guess which save you want to upload?"
  fi
}

function fac_service() {
  ssh $remotehost sudo systemctl "${1:-start}" factorio
}

function usage() {
  cat <<-EOF
		USAGE
		fac [module] [action]

		SYNOPSIS
		This shell function helps you manage your factorio server by wrapping common actions.

		MODULES
		  mods: act on the mod folder
		  save: act on the active save file
		  service: act on the systemd service

		ACTIONS
		  mods: upload, download. Upload will restart the service when done.
		  save: upload <path to local save file>. Stop service first, start again when done.
		  service: start, stop, restart, log, status.
		EOF
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
    service)
      case "$2" in
        start)
          fac_service start
          ;;
        stop)
          fac_service stop
          ;;
        restart)
          fac_service restart
          ;;
        log)
          ssh factorio.udsgaming.net sudo journalctl -ef -u factorio
          ;;
        status)
          fac_service status
          ;;
        *)
          echo "Wat"
          ;;
      esac
      ;;
    *)
      usage
      ;;
  esac
  [[ ! -z "$DEBUG" ]] && set +x
}
