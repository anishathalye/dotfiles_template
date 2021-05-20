#-- START ZCACHE GENERATED FILE
#-- GENERATED: Tue 18 May 2021 16:05:40 AEST
#-- ANTIGEN v2.2.3
_antigen () {
	local -a _1st_arguments
	_1st_arguments=('apply:Load all bundle completions' 'bundle:Install and load the given plugin' 'bundles:Bulk define bundles' 'cleanup:Clean up the clones of repos which are not used by any bundles currently loaded' 'cache-gen:Generate cache' 'init:Load Antigen configuration from file' 'list:List out the currently loaded bundles' 'purge:Remove a cloned bundle from filesystem' 'reset:Clears cache' 'restore:Restore the bundles state as specified in the snapshot' 'revert:Revert the state of all bundles to how they were before the last antigen update' 'selfupdate:Update antigen itself' 'snapshot:Create a snapshot of all the active clones' 'theme:Switch the prompt theme' 'update:Update all bundles' 'use:Load any (supported) zsh pre-packaged framework') 
	_1st_arguments+=('help:Show this message' 'version:Display Antigen version') 
	__bundle () {
		_arguments '--loc[Path to the location <path-to/location>]' '--url[Path to the repository <github-account/repository>]' '--branch[Git branch name]' '--no-local-clone[Do not create a clone]'
	}
	__list () {
		_arguments '--simple[Show only bundle name]' '--short[Show only bundle name and branch]' '--long[Show bundle records]'
	}
	__cleanup () {
		_arguments '--force[Do not ask for confirmation]'
	}
	_arguments '*:: :->command'
	if (( CURRENT == 1 ))
	then
		_describe -t commands "antigen command" _1st_arguments
		return
	fi
	local -a _command_args
	case "$words[1]" in
		(bundle) __bundle ;;
		(use) compadd "$@" "oh-my-zsh" "prezto" ;;
		(cleanup) __cleanup ;;
		(update|purge) compadd $(type -f \-antigen-get-bundles &> /dev/null || antigen &> /dev/null; -antigen-get-bundles --simple 2> /dev/null) ;;
		(theme) compadd $(type -f \-antigen-get-themes &> /dev/null || antigen &> /dev/null; -antigen-get-themes 2> /dev/null) ;;
		(list) __list ;;
	esac
}
antigen () {
  local MATCH MBEGIN MEND
  [[ "$ZSH_EVAL_CONTEXT" =~ "toplevel:*" || "$ZSH_EVAL_CONTEXT" =~ "cmdarg:*" ]] && source "/usr/local/Cellar/antigen/2.2.3/share/antigen/antigen.zsh" && eval antigen $@;
  return 0;
}
typeset -gaU fpath path
fpath+=(/Users/claudine/dotfiles/antigen/bundles/ohmyzsh/ohmyzsh /Users/claudine/dotfiles/antigen/bundles/agkozak/zsh-z) path+=(/Users/claudine/dotfiles/antigen/bundles/ohmyzsh/ohmyzsh /Users/claudine/dotfiles/antigen/bundles/agkozak/zsh-z)
_antigen_compinit () {
  autoload -Uz compinit; compinit -i -d "/Users/claudine/.antigen/.zcompdump"; compdef _antigen antigen
  add-zsh-hook -D precmd _antigen_compinit
}
autoload -Uz add-zsh-hook; add-zsh-hook precmd _antigen_compinit
compdef () {}

if [[ -n "" ]]; then
  ZSH=""; ZSH_CACHE_DIR=""
fi
#--- BUNDLES BEGIN
source '/Users/claudine/dotfiles/antigen/bundles/ohmyzsh/ohmyzsh/oh-my-zsh.sh';
source '/Users/claudine/dotfiles/antigen/bundles/agkozak/zsh-z/zsh-z.plugin.zsh';
source '/Users/claudine/dotfiles/antigen/bundles/ohmyzsh/ohmyzsh/themes/candy.zsh-theme.antigen-compat';

#--- BUNDLES END
typeset -gaU _ANTIGEN_BUNDLE_RECORD; _ANTIGEN_BUNDLE_RECORD=('https://github.com/ohmyzsh/ohmyzsh.git / plugin true' 'https://github.com/agkozak/zsh-z.git / plugin true' 'https://github.com/ohmyzsh/ohmyzsh.git git plugin true' 'https://github.com/ohmyzsh/ohmyzsh.git themes/candy.zsh-theme theme true')
typeset -g _ANTIGEN_CACHE_LOADED; _ANTIGEN_CACHE_LOADED=true
typeset -ga _ZCACHE_BUNDLE_SOURCE; _ZCACHE_BUNDLE_SOURCE=('/Users/claudine/.antigen/bundles/ohmyzsh/ohmyzsh//' '/Users/claudine/.antigen/bundles/ohmyzsh/ohmyzsh///oh-my-zsh.sh' '/Users/claudine/.antigen/bundles/agkozak/zsh-z//' '/Users/claudine/.antigen/bundles/agkozak/zsh-z///zsh-z.plugin.zsh' '/Users/claudine/.antigen/bundles/ohmyzsh/ohmyzsh/git' '/Users/claudine/.antigen/bundles/ohmyzsh/ohmyzsh/themes/candy.zsh-theme' '/Users/claudine/.antigen/bundles/ohmyzsh/ohmyzsh/themes/candy.zsh-theme')
typeset -g _ANTIGEN_CACHE_VERSION; _ANTIGEN_CACHE_VERSION='v2.2.3'

#-- END ZCACHE GENERATED FILE
