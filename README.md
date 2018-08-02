About
=====

This is a fork of [lean](https://github.com/miekg/lean) which adds more color 
customization support. Take a look at the [original repo](https://github.com/miekg/lean) for more 
information.

This is a one line prompt that tries to stay out of your face. It utilizes
the right side prompt for most information, like the CWD. The left side of
the prompt is only a '>'. The only other information shown on the left are
the jobs numbers of background jobs. When the exit code of a process isn't
zero the prompt turns red. If a process takes more then 2 (default) seconds
to run the total running time is shown in the next prompt.

Configuration:

- PROMPT_MYLEAN_TMUX: used to indicate being in tmux, set to "t ", by default
- PROMPT_MYLEAN_LEFT: executed to allow custom information in the left side
- PROMPT_MYLEAN_RIGHT: executed to allow custom information in the right side
- PROMPT_MYLEAN_COLOR_VCS: jobs and VCS info indicator color
- PROMPT_MYLEAN_COLOR_VCS_MOD: VCS info modifier indicator color
- PROMPT_MYLEAN_COLOR_CHARACTER: prompt character and directory color
- PROMPT_MYLEAN_COLOR_TIMER_SYMBOL: elapsed time symbol color
- PROMPT_MYLEAN_COLOR_TIMER: elapsed time indicator color
- PROMPT_MYLEAN_COLOR_ERROR: color displayed upon error
- PROMPT_MYLEAN_COLOR_CWD: color of the working directory
- PROMPT_MYLEAN_COLOR_SEPARATOR: color of the seperator
- PROMPT_MYLEAN_VIMODE: used to determine wether or not to display indicator
- PROMPT_MYLEAN_VIMODE_FORMAT: Defaults to "%F{red}[NORMAL]%f"
- PROMPT_MYLEAN_NOTITLE: used to determine wether or not to set title, set to 0
 by default. Set it to your own condition, make it to be 1 when you don't
 want title.

You can invoke it thus:

  prompt mylean

When lean starts, only 2 characters show on the screen '>' on the left and '~'
on the right. All other info is omitted (like the user and system you are on),
and shown only when needed.

Installation
===========

zgen
---

If you use [zgen](https://github.com/tarjoilija/zgen) you can add the following
to your `~/.zshrc`:

```
zgen load gharveymn/mylean
```

and force reload with `zgen reset && source ~/.zshrc`.

Note you must have the option PROMPT_SUBST set, see zshoptions(1).

prezto
---
If you use [prezto](https://github.com/sorin-ionescu/prezto) you should do the following:

```
cd ~/.zprezto/ \
&& git submodule add https://github.com/gharveymn/mylean.git modules/prompt/external/lean 2>/dev/null \
&& git submodule update --init --recursive \
&& cd modules/prompt/functions \
&& ln -s prompt_mylean_setup ../external/mylean/mylean.prompt.zsh
```

Then in `~/.zpreztorc`:

```
zstyle ':prezto:module:prompt' theme 'mylean'
```

`PROMPT_LEAN_LEFT` and `PROMPT_LEAN_RIGHT` should be customized in `~/.zshrc`.
The rest variables should be customized in `~/.zshenv`.
