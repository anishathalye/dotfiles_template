function mtp() {
  # List all MTP mount points
  local mount_points
  mount_points=$(ls -d /run/user/$(id -u)/gvfs/mtp* 2>/dev/null)

  # Check if any MTP mount points exist
  if [[ -z "$mount_points" ]]; then
    echo "No MTP devices found!"
    return 1
  fi

  # Use fzf to select a mount point if there are multiple options
  local mount_point
  if [[ $(echo "$mount_points" | wc -l) -gt 1 ]]; then
    mount_point=$(echo "$mount_points" | fzf --prompt="Select MTP device: ")
    [[ -z "$mount_point" ]] && { echo "Selection cancelled."; return 1; }
  else
    mount_point=$mount_points
  fi

  # Handle the action (cd or ls)
  case "$1" in
    cd)
      cd "$mount_point" || echo "Could not navigate to $mount_point."
      ;;
    ls)
      ls -l "$mount_point" || echo "Could not list files in $mount_point."
      ;;
    *)
      echo "Usage: mtp [cd|ls]"
      ;;
  esac
}

