# Directory Structure

mkdir -p $HOME/autodl-tmp/cache
mkdir -p $HOME/autodl-tmp/share/data
mkdir -p $HOME/autodl-tmp/share/pkgs
mkdir -p $HOME/autodl-tmp/solid

\rm -fr $HOME/data
\rm -fr $HOME/dump
\rm -fr $HOME/tf-logs

ln -s $HOME/autodl-tmp/share/data $HOME/data
ln -s $HOME/autodl-tmp            $HOME/dump
ln -s $HOME/autodl-tmp            $HOME/tf-logs

# Bash Settings

cat << 'END' > $HOME/.bashrc
[ -z "$PS1" ] && return

shopt -s histappend

HISTCONTROL=ignoredups:ignorespace
HISTFILESIZE=2000
HISTSIZE=1000

shopt -s checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

PS1='\[\e[1;32m\]\u\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '

alias apt='apt --yes'
alias cl='clear'
alias du='du -ah -d 1'
alias ls='ls -Fhlt --color=auto --time-style +%Y-%m-%d\ %H:%M'
alias rm='trash-put'
alias rsync='rsync -Lah --info=progress2'
END

cat << 'END' >> $HOME/.bashrc
alias shutdown='/usr/bin/shutdown'
alias sudo=''
alias vpn='source /etc/network_turbo'

export HF_ENDPOINT='https://hf-mirror.com'
export HF_HOME='/root/autodl-tmp/share/pkgs/hugg'
export TORCH_HOME='/root/autodl-tmp/share/pkgs/torch'
export PIP_CACHE_DIR='/root/autodl-tmp/share/pkgs/pypi'
END

source $HOME/.bashrc

# Programs

apt update
apt install git
apt install zip
apt install tmux
apt install python3
apt install python3-pip
/usr/bin/pip3 install trash-cli

cat << 'END' >> $HOME/.bashrc
alias clean='trash-empty'
END

# Git

cat << 'END' > $HOME/.gitconfig
[alias]
    a = add -A
    l = log -n 3
    r = log -n 3
    s = status
    recent = log -n 3
[core]
    editor = vim
[init]
    defaultbranch = undone
[user]
    name = onedonedone
    email = loongdone@gmail.com
END

cat << 'END' > /usr/local/bin/git-at
#!/bin/bash

YYYY=$(date +%Y)
MM=$(date +%m)
DD=$(date +%d)
hh=$(date +%H)
mm=$(date +%M)
ss=$(date +%S)

time=$1

if   [[ $time =~ ^[0-9]{12}$ ]]; then   # YYYYMMDDhhmm
    time="${time:0:4}-${time:4:2}-${time:6:2}T${time:8:2}:${time:10:2}:00"
elif [[ $time =~ ^[0-9]{10}$ ]]; then   # YYYYMMDDhh
    time="${time:0:4}-${time:4:2}-${time:6:2}T${time:8:2}:00:00"
elif [[ $time =~ ^[0-9]{08}$ ]]; then   # MMDDhhmm
    time="${YYYY}-${time:0:2}-${time:2:2}T${time:4:2}:${time:6:2}:00"
elif [[ $time =~ ^[0-9]{06}$ ]]; then   # MMDDhh
    time="${YYYY}-${time:0:2}-${time:2:2}T${time:4:2}:00:00"
elif [[ $time =~ ^[0-9]{04}$ ]]; then   # hhmm
    time="${YYYY}-${MM}-${DD}T${time:0:2}:${time:2:2}:00"
elif [[ $time =~ ^[0-9]{02}$ ]]; then   # hh
    time="${YYYY}-${MM}-${DD}T${time:0:2}:00:00"
else
    time="${YYYY}-${MM}-${DD}T${hh}:${mm}:00"
fi

shift

GIT_AUTHOR_DATE=$time GIT_COMMITTER_DATE=$time git "$@"
END

chmod 744 /usr/local/bin/git-at

# Miniconda

cat << 'END' > $HOME/.condarc
channels:
    - defaults
show_channel_urls: true
default_channels:
    - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
    - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
    - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
    conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
    pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
env_prompt: "($(basename {default_env})) "
envs_dirs:
    - /root/autodl-tmp/share/envs/conda/
pkgs_dirs:
    - /root/autodl-tmp/share/pkgs/conda/
END

cat << 'END' >> $HOME/.bashrc
alias tensorboard='tensorboard --samples_per_plugin scalars=99999,images=9999'
END

conda init

source $HOME/.bashrc

conda activate base
pip install tensorboard==2.17.0 numpy==1.26.4
pip install nvitop==1.4.0
pip cache purge

# Visual Studio Code
cat << 'END' > $HOME/main.code-workspace
{
    "folders": [{ "path": "." }],
    "settings": {
        "files.exclude": {
            ".*": true,
            "**/CVS": true,
            "**/Thumbs.db": true,
            "**/__pycache__": true,
            "autodl-*/": true,
            "miniconda3": true,
            "tf-logs": true
        },
        "window.title": "${dirty}${rootName}"
    }
}
END

# Visual Studio Code (AutoDL)

cat << 'END' >> $HOME/.bashrc
alias code='VSCODE_IPC_HOOK_CLI=$(\ls -t /tmp/vscode-ipc-*.sock | head -1); $(cd $(dirname $BROWSER)/..; pwd)/remote-cli/code'
END

source $HOME/.bashrc

code --install-extension esbenp.prettier-vscode
code --install-extension ms-python.black-formatter
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter

# Blender

cat << 'END' > /usr/local/bin/install-blender
#!/bin/bash

rm -fr $HOME/autodl-tmp/share/pkgs/blender
rm -fr blender-4.3.2-linux-x64
rm -fr blender-4.3.2-linux-x64.tar.xz

wget https://download.blender.org/release/Blender4.3/blender-4.3.2-linux-x64.tar.xz
tar -xvf blender-4.3.2-linux-x64.tar.xz

mv blender-4.3.2-linux-x64 $HOME/autodl-tmp/share/pkgs/blender
rm -fr blender-4.3.2-linux-x64.tar.xz

cat << 'EOF' >> $HOME/.bashrc
alias blender='$HOME/autodl-tmp/share/pkgs/blender/blender -b'
alias bpy='$HOME/autodl-tmp/share/pkgs/blender/4.3/python/bin/python3.11'
alias bpip='$HOME/autodl-tmp/share/pkgs/blender/4.3/python/bin/python3.11 -m pip'
EOF

$HOME/autodl-tmp/share/pkgs/blender/4.3/python/bin/python3.11 -m pip install --upgrade pip
$HOME/autodl-tmp/share/pkgs/blender/4.3/python/bin/python3.11 -m pip install fake-bpy-module
$HOME/autodl-tmp/share/pkgs/blender/4.3/python/bin/python3.11 -m pip install tqdm
$HOME/autodl-tmp/share/pkgs/blender/4.3/python/bin/python3.11 -m pip cache purge
END

chmod 744 /usr/local/bin/install-blender

# TMUX

cat << 'END' > $HOME/.tmux.conf
set -g status-left "(#S) "

set -g pane-border-style fg=blue,bold
set -g pane-active-border-style fg=blue,bold

set -g status-right "%m-%d %H:%M"
set -g status-right-style bold

set -g status-style fg=blue

set -g window-status-style fg=gray
set -g window-status-format "[#I #W]"

set -g window-status-current-style fg=blue,bold
set -g window-status-current-format "[#I #W]"
END

# SSH

\rm -fr $HOME/.ssh/config
\rm -fr $HOME/.ssh/id_ed25519
\rm -fr $HOME/.ssh/id_ed25519.pub

cat << 'END' > $HOME/.ssh/config
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
END

ssh-keygen -t ed25519 -f $HOME/.ssh/id_ed25519 -N '' -C ''

code $HOME/.ssh/config
code $HOME/.ssh/authorized_keys
code $HOME/.ssh/id_ed25519
code $HOME/.ssh/id_ed25519.pub

# Clean
\rm -fr init.sh
