# Prettier alternative to cat
brew "bat"

# Tmux, of course
brew "tmux"

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

# Clojure
brew "clojure"

# Rust
brew "rust"

# Emacs
tap 'jimeh/emacs-builds'
cask 'emacs-app'

# Fira Code Font used in Emacs
tap 'homebrew/cask-fonts'
cask 'font-fira-code'

