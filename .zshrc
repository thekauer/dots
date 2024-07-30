# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/powerlevel10k/powerlevel10k.zsh-theme

alias v="nvim"
alias ss="stty sane"
alias t="tmux a -t "

ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export PATH="/opt/homebrew/opt/postgresql@13/bin:$PATH"
export PATH=$PATH:~/roc_nightly-macos_apple_silicon-2024-05-27-9fcd5a3fe88
export PATH=~/.asdf/shims:$PATH
export PATH="$HOME/go/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="/opt/homebrew/opt/libxslt/bin:$PATH"
export KERL_CONFIGURE_OPTIONS="--without-wx --without-javac"

export IBM_TEST_API_KEY="5W4uaU09GANzI2vUP257dvRhL7vRhQD-zfZZJ2z472l-"
alias gettoken='curl -kv -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: application/json" --data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" --data-urlencode "response_type=cloud_iam" --data-urlencode "apikey=$IBM_TEST_API_KEY" -X POST "https://iam.test.cloud.ibm.com/identity/token?pretty=true" 2>&1 | sed -n "s/.*\"access_token\":\"\\([^\"]*\\)\".*/\\1/p" | pbcopy && echo "Token copied to clipboard"'



# pnpm
export PNPM_HOME="/Users/andraskauer/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun completions
[ -s "/Users/andraskauer/.bun/_bun" ] && source "/Users/andraskauer/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

eval "$(direnv hook zsh)"
direnv allow
