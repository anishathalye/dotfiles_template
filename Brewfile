# Prettier alternative to cat
brew "bat"

# Tmux, of course
brew "tmux"

# JQ, of course
brew "jq"

# A useeful tool for learning about cli commands
# https://github.com/tldr-pages/tldr
brew "tldr"

# Different code search tools
brew "ripgrep"
brew "ag"
brew "fd"

# The hub tool for working with github
# https://cli.github.com/ 
brew "hub"

# GnuPG for GPG key management
# Pinning to v2.2 because latest version 2.4.2 has bug
# that causes Emacs to hang on decrypt. See:
# - https://www.reddit.com/r/emacs/comments/137r7j7/gnupg_241_encryption_issues_with_emacs_orgmode/
# - https://dev.gnupg.org/T6481
# It sounds like this is being worked on by GnuPG team and may be fixed in newer versions...
#
# Note: Brew does not automatically symlink these so we need to do a brew link command after.
brew "gnupg@2.2"

# Programming languages
brew "clojure"
brew "rust"
brew "python"
brew "java"

# Fira Code Font used in Emacs

cask 'font-fira-code'

# AWS Cli
brew "awscli"

# Emacs
brew "gcc"
brew "tree-sitter" 
tap 'jimeh/emacs-builds'
cask 'emacs-app'
#Used this for emacs29 with native comp originally
#brew "emacs-plus@29", args: ["with-native-comp"]
