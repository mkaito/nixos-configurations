FACTORIO_BASE="$HOME/.factorio"

function fac_upload_mods() {
  echo "Stopping service first..."
  fac_service "$1" stop

  echo "Uploading mod folder..."
  rsync -rL --delete -e ssh "$FACTORIO_BASE/mods/" "factorio@${1}::mods"

  echo "Starting service..."
  fac_service "$1" restart

  echo "Done. Please allow a few seconds for the service to boot."
}

function fac_download_mods() {
  echo "Downloading mods from server..."
  rsync -rL --delete -e ssh "factorio@${1}::mods" "$FACTORIO_BASE/mods/"

  echo "Done."
}

function fac_latest_save() {
  ## This actually seems the best way to get the most recent file in a folder.
  # shellcheck disable=SC2012
  echo -n "$HOME/.factorio/saves/$(ls -t ~/.factorio/saves | head -n1)"
}

function fac_upload_save() {
  if [[ -z $2 ]]; then
    sfile="$(fac_latest_save)"
  else
    sfile="$2"
  fi

  if [[ -e $sfile ]]; then
    echo "Stopping service first..."
    fac_service "$1" stop

    echo "Uploading save $(basename "$sfile")..."
    rsync -z -e ssh "$sfile" "factorio@${1}::saves/default.zip"

    echo "Uploading mod folder..."
    rsync -rL --delete -e ssh "$FACTORIO_BASE/mods/" "factorio@${1}::mods"

    echo "Starting service..."
    fac_service "$1" start

    echo "Done. Please allow a few seconds for the service to boot."

  else
    echo "Am I supposed to guess which save you want to upload?"

  fi
}

function fac_service() {
  ssh "$1" sudo systemctl "${2:-start}" factorio
}

function usage() {
  cat <<-EOF
		USAGE
		fac [adalind|faore] [module] [action]

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

  ## Define target host
  targethost=adalind
  case "$1" in
    faore)
      targethost=home.admt
      shift
      ;;

    adalind|factorio)
      targethost="$1.mkaito.net"
      shift
      ;;

    *)
      ;;
  esac

  case "$1" in

    mods)
      case "$2" in
        upload)
          fac_upload_mods "$targethost"
          ;;

        download)
          fac_download_mods "$targethost"
          ;;

        *)
          echo "Wat"
          ;;

      esac
      ;; # End case mods

    save)
      case "$2" in
        upload)
          fac_upload_save "$targethost" "$3"
          ;;

        download)
          echo "Log into the game and save it from there, lazy bum."
          ;;

        *)
          echo "Wat"
          ;;

      esac
      ;; # end case save

    service)
      case "$2" in
        start)
          fac_service "$targethost" start
          ;;

        stop)
          fac_service "$targethost" stop
          ;;

        restart)
          fac_service "$targethost" restart
          ;;

        log)
          ssh "$targethost" sudo journalctl -ef -u factorio
          ;;

        status)
          fac_service "$targethost" status
          ;;

        *)
          echo "Wat"
          ;;

      esac
      ;; # End case service

    *)
      usage
      ;;

  esac
  [[ ! -z "$DEBUG" ]] && set +x
}

# Local Variables:
# sh-shell: zsh
# End:

# vim:ft=zsh
