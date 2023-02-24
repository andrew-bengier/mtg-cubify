echo "List PR's for mtg-cubify"

# region -- Variables --
# These are temporary - and alternatively provided
GH_PAT=**REDACTED**
GH_HOST=github.com
# endregion -- Variables --

# Version
gh --version

# Login
gh auth status
gh auth login --hostname $GH_HOST --with-token <<< "$GH_PAT"
gh auth status

# PR list
gh pr list --repo https://github.com/andrew-bengier/mtg-cubify
