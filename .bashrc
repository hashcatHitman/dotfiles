# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH
export JAVA_HOME=/usr/lib/jvm/java-latest-openjdk/
source "$HOME/.cargo/env"

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            source "$rc"
        fi
    done
fi
unset rc

# Starship prompt
eval "$(starship init bash)"
