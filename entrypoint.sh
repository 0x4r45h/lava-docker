#!/bin/bash
init_function() {
  if [ -z "$ACCOUNT_NAME" ]; then
    echo "Error: ACCOUNT_NAME environment variable is not set or empty."
    exit 1
  fi
  output=$(lavad keys list)
  if echo "$output" | grep -q "$ACCOUNT_NAME"; then
    echo "Account '$ACCOUNT_NAME' already exists."
    lavad keys show "$ACCOUNT_NAME"
  else
    echo "Account '$ACCOUNT_NAME' not found."
    echo "Would you like to recover a previous account using mnemonic keys? (Y/N)"
    while true; do
      read -p "Enter choice: " choice
      case "$choice" in
        [Yy])
          lavad keys add "$ACCOUNT_NAME" --recover
          break
          ;;
        [Nn])
          lavad keys add "$ACCOUNT_NAME"
          break
          ;;
        *)
          echo "Invalid choice. Please enter Y or N."
          ;;
      esac
    done
  fi

# Backup genesis.json
  mv /root/.lava/config/genesis.json /root/.lava/config/genesis.json.bak
  # Run lavad init command
  lavad init $MONIKER_NAME > /dev/null 2>&1
  # Replace genesis.json with backed up file
  cp /root/.lava/config/genesis.json.bak /root/.lava/config/genesis.json
  # Print validator pubkey
  echo "Validator pubkey is : "
  lavad tendermint show-validator
}

main() {
  case "$1" in
    "init")
      init_function
      ;;
    "start")
      lavad start --home=/root/.lava --p2p.seeds $SEED_NODE
      ;;
    *)
      default_function
      ;;
  esac
}

main "$@"

