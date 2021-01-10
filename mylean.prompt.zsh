# mylean prompt theme
# modified for customizability
#
# by Miek Gieben: https://github.com/miekg/mylean
#
# Based on Pure by Sindre Sorhus: https://github.com/sindresorhus/pure
#
# MIT License

PROMPT_MYLEAN_COLOR_VCS=${PROMPT_MYLEAN_COLOR_VCS-"8"}
PROMPT_MYLEAN_COLOR_VCS_MOD=${PROMPT_MYLEAN_COLOR_VCS_MOD-${PROMPT_MYLEAN_COLOR_VCS}}
PROMPT_MYLEAN_COLOR_CHARACTER=${PROMPT_MYLEAN_COLOR_CHARACTER-"33"}
PROMPT_MYLEAN_COLOR_TIMER=${PROMPT_MYLEAN_COLOR_TIMER-"220"}
PROMPT_MYLEAN_COLOR_TIMER_SYMBOL=${PROMPT_MYLEAN_COLOR_TIMER_SYMBOL-${PROMPT_MYLEAN_COLOR_TIMER}}
PROMPT_MYLEAN_COLOR_ERROR=${PROMPT_MYLEAN_COLOR_ERROR-"1"}
PROMPT_MYLEAN_COLOR_CWD=${PROMPT_MYLEAN_COLOR_CWD-$PROMPT_MYLEAN_COLOR_CHARACTER}
PROMPT_MYLEAN_COLOR_SEPARATOR=${PROMPT_MYLEAN_COLOR_SEPARATOR-"15"}

PROMPT_MYLEAN_TMUX=${PROMPT_MYLEAN_TMUX-"t "}
PROMPT_MYLEAN_PATH_PERCENT=${PROMPT_MYLEAN_PATH_PERCENT-60}
PROMPT_MYLEAN_NOTITLE=${PROMPT_MYLEAN_NOTITLE-0}
PROMPT_MYLEAN_CHARACTER=${PROMPT_MYLEAN_CHARACTER-">"}
PROMPT_MYLEAN_SEPARATOR=${PROMPT_MYLEAN_SEPARATOR-|}

prompt_mylean_help() {
  cat <<'EOF'
This is a one line prompt that tries to stay out of your face. It utilizes
the right side prompt for most information, like the CWD. The left side of
the prompt is only a '>'. The only other information shown on the left are
the jobs numbers of background jobs. When the exit code of a process isn't
zero the prompt turns red. If a process takes more then 2 (default) seconds
to run the total running time is shown in the next prompt.

Configuration:

PROMPT_MYLEAN_TMUX: used to indicate being in tmux, set to "t ", by default
PROMPT_MYLEAN_LEFT: executed to allow custom information in the left side
PROMPT_MYLEAN_RIGHT: executed to allow custom information in the right side
PROMPT_MYLEAN_COLOR_VCS: jobs and VCS info indicator color
PROMPT_MYLEAN_COLOR_VCS_MOD: VCS info modifier indicator color
PROMPT_MYLEAN_COLOR_CHARACTER: prompt character and directory color
PROMPT_MYLEAN_COLOR_TIMER_SYMBOL: elapsed time symbol color
PROMPT_MYLEAN_COLOR_TIMER: elapsed time indicator color
PROMPT_MYLEAN_COLOR_ERROR: color displayed upon error
PROMPT_MYLEAN_COLOR_CWD: color of the working directory
PROMPT_MYLEAN_COLOR_SEPARATOR: color of the seperator
PROMPT_MYLEAN_VIMODE: used to determine wether or not to display indicator
PROMPT_MYLEAN_VIMODE_FORMAT: Defaults to "%F{red}[NORMAL]%f"
PROMPT_MYLEAN_NOTITLE: used to determine wether or not to set title, set to 0
 by default. Set it to your own condition, make it to be 1 when you don't
 want title.

You can invoke it thus:

  prompt mylean

EOF
}

# turns seconds into human readable time, 165392 => 1d 21h 56m 32s
prompt_mylean_human_time() {
    local tmp=$1
    local days=$(( tmp / 60 / 60 / 24 ))
    local hours=$(( tmp / 60 / 60 % 24 ))
    local minutes=$(( tmp / 60 % 60 ))
    local seconds=$(( tmp % 60 ))
    echo -n "%F{"$PROMPT_MYLEAN_COLOR_TIMER_SYMBOL"}%{⌚︎%2G%}%f%F{"$PROMPT_MYLEAN_COLOR_TIMER"}"
    (( $days > 0 )) && echo -n "${days}d "
    (( $hours > 0 )) && echo -n "${hours}h "
    (( $minutes > 0 )) && echo -n "${minutes}m "
    echo "${seconds}s%f %F{"PROMPT_MYLEAN_COLOR_SEPARATOR"}$PROMPT_MYLEAN_SEPARATOR%f"
}

# displays the exec time of the last command if set threshold was exceeded
prompt_mylean_cmd_exec_time() {
    local stop=$EPOCHSECONDS
    local start=${cmd_timestamp:-$stop}
    integer elapsed=$stop-$start
    (($elapsed > ${PROMPT_MYLEAN_CMD_MAX_EXEC_TIME:=1})) && prompt_mylean_human_time $elapsed
}

prompt_mylean_git() {
    # check if we're in a git repo
    command git rev-parse --is-inside-work-tree &>/dev/null || return

    echo -n "%F{"$PROMPT_MYLEAN_COLOR_VCS"}"

    # print out branch info
    echo -n "$vcs_info_msg_0_"

    # check if the repo is dirty
    local umode="-uno" #|| local umode="-unormal"
    command test -n "$(git status --porcelain --ignore-submodules ${umode} 2>/dev/null | head -100)"
    (($? == 0)) && echo -n "%f %F{"$PROMPT_MYLEAN_COLOR_VCS_MOD"}+%f"

    # print seperator
    echo "$prompt_mylean_host %F{"PROMPT_MYLEAN_COLOR_SEPARATOR"}$PROMPT_MYLEAN_SEPARATOR%f"
}

prompt_mylean_set_title() {
    # shows the current tty and dir and executed command in the title when a process is active
    print -Pn "\e]0;"
    print -Pn "%l %c"
    print -n ": $1"
    print -Pn "\a"
}

prompt_mylean_preexec() {
    cmd_timestamp=$EPOCHSECONDS
    (($PROMPT_MYLEAN_NOTITLE != 1)) && prompt_mylean_set_title "$1"
}

prompt_mylean_pwd() {
    echo -n "%F{"$PROMPT_MYLEAN_COLOR_CWD"} "
    local mylean_path="`print -Pn '%~'`"
    if (($#mylean_path / $COLUMNS.0 * 100 > ${PROMPT_MYLEAN_PATH_PERCENT:=60})); then
        print -Pn '...%2/'
        return
    fi
    print "$mylean_path%f"
}

prompt_mylean_char() {
    echo "%(?.%F{"$PROMPT_MYLEAN_COLOR_CHARACTER"}.%F{"$PROMPT_MYLEAN_COLOR_ERROR"})$PROMPT_MYLEAN_CHARACTER%f "
}

prompt_mylean_precmd() {
    vcs_info
    rehash

    local jobs
    local prompt_mylean_jobs
    unset jobs
    for a (${(k)jobstates}) {
        j=$jobstates[$a];i='${${(@s,:,)j}[2]}'
        jobs+=($a${i//[^+-]/})
    }
    # print with [ ] and comma separated
    prompt_mylean_jobs=""
    [[ -n $jobs ]] && prompt_mylean_jobs="%F{"$PROMPT_MYLEAN_COLOR_VCS"}["${(j:,:)jobs}"] "

    local mylean_vimode_default="%F{red}[NORMAL]%f"
    #If MYLEAN_VIMODE is set, set mylean_vimode_indicator to either PROMPT_MYLEAN_VIMOD_FORMAT or a default value
    local mylean_vimode_indicator="${PROMPT_MYLEAN_VIMODE:+${PROMPT_MYLEAN_VIMODE_FORMAT:-${mylean_vimode_default}}}"

    prompt_mylean_vimode="${${KEYMAP/vicmd/$mylean_vimode_indicator}/(main|viins)/}"

    setopt promptsubst
    PROMPT="$prompt_mylean_jobs%F{"$PROMPT_MYLEAN_COLOR_TIMER"}${prompt_mylean_tmux}%f`$PROMPT_MYLEAN_LEFT`%f`prompt_mylean_char`"
    RPROMPT="`prompt_mylean_cmd_exec_time``prompt_mylean_git`$prompt_mylean_vimode%F{"$PROMPT_MYLEAN_COLOR_CWD"}`prompt_mylean_pwd``$PROMPT_MYLEAN_RIGHT`%f"

    unset cmd_timestamp # reset value since `preexec` isn't always triggered
}

function zle-keymap-select {
    prompt_mylean_precmd
    zle reset-prompt
}

prompt_mylean_setup() {
    prompt_opts=(cr percent sp subst)

    zmodload zsh/datetime
    autoload -Uz add-zsh-hook
    autoload -Uz vcs_info

    [[ "$PROMPT_MYLEAN_VIMODE" != '' ]] && zle -N zle-keymap-select

    add-zsh-hook precmd prompt_mylean_precmd
    add-zsh-hook preexec prompt_mylean_preexec

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git*' formats ' %b'
    zstyle ':vcs_info:git*' actionformats ' %b|%a'

    [[ "$SSH_CONNECTION" != '' ]] && prompt_mylean_host=" %F{"$PROMPT_MYLEAN_COLOR_TIMER"}%m%f"
    [[ "$TMUX" != '' ]] && prompt_mylean_tmux=$PROMPT_MYLEAN_TMUX

    return 0
}

prompt_mylean_setup "$@"
