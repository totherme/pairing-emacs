# Emacs For Remote Pairing

Sometimes it's important to be able to pair-program remotely. If both
participants are comfortable with vim and tmux, then you can use
something like [tmate](https://tmate.io/) along with any voice-chat
solution and you're away (I like Luan's
[vim](https://github.com/luan/vimfiles) and
[tmux](https://github.com/luan/tmuxfiles) configs for this). However,
not all remote pairs are comfortable with vim.

This is an emacs and tmux configuration which is designed to:
- be as accessible as possible to users of IDEs like
  [goland](https://www.jetbrains.com/go/)
- work properly in a terminal, so we can pair over ssh.

# Table of Contents

1. [Installing](#installing)
   1. [Automatic](#automatic)
   1. [Prerequisites](#prerequisites)
   1. [By hand](#by-hand)
1. [Using](#using)
   1. [Non-standard features enabled here by default](#non-standard-features-enabled-here-by-default)
   1. [Tmux](#tmux)
	  1. [Plugins enabled in this tmux config](#plugins-enabled-in-this-tmux-config)
   1. [Golang editing](#golang-editing)
   1. [Learning more about emacs](#learning-more-about-emacs)
	  1. [The absolute essentials](#the-absolute-essentials)
	  1. [Emacs key notation](#emacs-key-notation)
	  1. [Basic things that might not be where you expect](#basic-things-that-might-not-be-where-you-expect)
	  1. [Some emacs UX philosophy](#some-emacs-UX-philosophy)
	  1. [Using the help system](#using-the-help-system)


# Installing

## Automatic

If you trust [my script](scripts/install), you can do:

```sh
curl https://raw.githubusercontent.com/totherme/pairing-emacs/master/scripts/install | bash
```

This essentially just does the manual steps [described below](#by-hand).

You can now start emacs in its own window with `emacs` or in the
terminal with `emacs -nw`. If you're starting in the terminal for any
reason other than a remote pairing session over ssh, you should
probably look into [TRAMP](https://www.emacswiki.org/emacs/TrampMode)
and the
[emacs-client](https://www.emacswiki.org/emacs/EmacsClient). They
might do what you want with less friction.

The first time you start emacs after installing this config, emacs
will download some plugins for doing golang editing and so on. This
will slow down your initial startup, and will display a whole bunch of
compilation output. Subsequent startups will be faster.

## Prerequisites

You'll need [git](https://git-scm.com/) and a recent version of
[emacs](https://www.gnu.org/software/emacs/). To take advantage of the
golang IDE-like features you'll need [go](https://golang.org/). It's
recommended that you use this config with [tmate](https://tmate.io/)
for remote pairing.

## By hand

```sh
# backup your existing emacs config
mv ~/.emacs.d ~/.emacs.d.backup
# get this emacs config
git clone https://github.com/totherme/pairing-emacs ~/.emacs.d
```

...and optionally
```sh
# get the golang tools that make this kind of thing possible
go get -u golang.org/x/tools/cmd/goimports \
          github.com/rogpeppe/godef \
          github.com/nsf/gocode \
          github.com/dougm/goflymake

# use our tmux config
mv ~/.tmux.conf ~/.tmux.conf.backup
ln -s ~/.emacs.d/tmux.conf ~/.tmux.conf
```

# Using

If you don't yet know how to save a file in emacs, see [Learning more
about emacs](#learning-more-about-emacs) below.

If you want to dive in and see all the things that are bundled and
enabled here, take a look at the [basic editing
features](configs/basics.org), [git features](configs/magit.org), and
[programming features](configs/programming.org) enabled in our config
directory. Some highlights are listed below.

## Non-standard features enabled here by default
- Line numbers. Every file you open will have line numbers displayed
  on the left hand side. This can be useful when remote pairing so you
  can talk about your code with a common reference point. If you don't
  like it, switch it off with `M-x global-linum-mode`.
- The following windows-like keyboard shortcuts are enabled. You can
  disable them with `M-x cua-mode`
  + `C-c` is "copy to clipboard"
  + `C-v` is "paste from clipboard"
  + `C-x` is "cut to clipboard"
  + `C-z` is "undo"
  + If you highlight some text and start typing, the highlighted text
    will be replaced with the new text that you're typing.
- In addition to the windows-like `C-z` for "undo", the emacs-like
  `C-/` and `C-_` also work. For "redo" we only have the emacs-like
  shortcuts `C-?` and `M-_`. Note that `C-?` won't work at the
  terminal, because on terminals `C-?` is equivalent to `DEL`.
- You can [naviate your entire undo
  history](http://www.dr-qubit.org/undo-tree.html), including branches
  that you previously edited over the top of, using `C-x u`.
- The mouse should work. Even at the terminal. Try clicking to move
  the cursor, or highlighting text, or activating a menu at the top of
  the screen.
- When editing go code, you can use `Control-Click` to introspect
  (using `godef`) the thing you clicked.
- There are browser-like "back" and "forward" buttons. You can use
  `C-x C-<left>` and `C-x C-<right>`, and in the GUI they're also
  available in the toolbar.
- Autocompletion is available for everything. 
  + It pops up by default for programming languages, but not for plain text.
  + If you want to summon it explicitly, hit `C-c C-n` or `C-c M-n`.
  + If you're mid-autocomplete, and want to read the docs for the
    thing you're about to complete to, hit `<F1>` or `C-h`
  + If you're mid-autocomplete, and want to read the definition of the
    thing you're about to complete to, hit `C-w`
- You can start a shell in emacs. Hit `C-x M-m`
- There's [a GUI for doing git operations](https://magit.vc/). Start
  it with `C-x g`
  + This gui has been tweaked to try to detect whether you want to use
    git-duet or not. It should work right out of the box, whether
    you're using git-duet or not. You can force it either way by
    [customizing](https://www.gnu.org/software/emacs/manual/html_node/emacs/Easy-Customization.html)
    the `git-duet-enabled` variable. You can do this with `M-x
    customize-variable` followed by `git-duet-enabled`. Whatever
    change you make will be saved for future sessions.
- [Avy mode](https://github.com/abo-abo/avy). This is a way of quickly
  moving the cursor around a file.
  + If you quickly double-tap the `j` key, emacs will ask you for the
    first letter of a word. Once you've entered that letter, emacs
    will highlight all words beginning with that letter and ask which
    you want to jump to.
  + If you mash `j` and `l`, emacs will prompt for which line you want
    to jump to.
  + If you mash `j` and `w`, emacs will prompt for which internal
    window you want to jump to.
 - [Multiple-cursor
   mode](https://github.com/magnars/multiple-cursors.el). If you
   highlight the an instance of the word `foo` in your file, then
   `C->` will cause the next instance to also be highlighted, and so
   on. Similarly, `C-<` will cause previous instances to be
   highlighted. Once you've highlighted all the things you want to
   edit, you can edit them as normal. Hit `C-g` to go back to just one
   cursor. Annoyingly, the `C->` and `C-<` shortcuts don't work at the
   terminal because the terminal doesn't distinguish between `C-.` and
   `C->`.

## Tmux

The tmux config included in this repository is intended to:

1. Stay out of the way of the emacs shortcuts we'll need when remote pairing
1. Be familiar to anyone who has experience using tmux
1. Provide cool and useful features

For example, while the default (and hence very common) tmux prefix-key
is `C-b`, **our prefix key is `C-q`**. This is because `C-b` is a
commonly used emacs shortcut for moving the cursor backwards, while
`C-q` is an infrequently used emacs shortcut for inserting a literal
character (often a tab or control character). If you want to use this
functionality you should hit `C-q C-q`, which will cause tmux to pass
a single `C-q` through to emacs.

To learn more about tmux, try [this free-to-read-online
book](https://leanpub.com/the-tao-of-tmux/read). If you're used to a
heavily customised tmux config, you may be interested in [this list of
default tmux
keybindings](https://leanpub.com/the-tao-of-tmux/read#leanpub-auto-keybindings-1).

### Non-standard keybindings

- `<Prefix> \` is bound to `synchronize-panes`. This is useful when,
  for example, simultaneously managing/debugging multiple remote
  machines in a single cluster.

### Plugins enabled in this tmux config

To use any of these plugins, you must install them. You can do this by
starting tmux, and hitting `C-q I`. You only need to do this once --
they will be available in every tmux session on your machine
thereafter.

- [sensible](https://github.com/tmux-plugins/tmux-sensible)
- [copycat](https://github.com/tmux-plugins/tmux-copycat)
- [yank](https://github.com/tmux-plugins/tmux-yank)
- [open](https://github.com/tmux-plugins/tmux-open)
- [prefix-highlight](https://github.com/tmux-plugins/tmux-prefix-highlight)

## Golang editing
Features mostly provided by
[go-mode](https://github.com/dominikh/go-mode.el), which is [well
documented
here](http://dominik.honnef.co/posts/2013/03/writing_go_in_emacs/).
- Every time you save, it will run goimports (which includes gofmt)
- Inteligent autocompletion should work as you expect. This is
  provided by
  [company-go](https://github.com/nsf/gocode/tree/master/emacs-company)
  and [company-mode](https://company-mode.github.io/).
  + It'll try to pop up when you want it, but if you want to summon it
    explicitly, hit `C-c C-n` or `C-c M-n`.
  + If you're mid-autocomplete, and want to read the docs for the
    thing you're about to complete to, hit `<F1>` or `C-h`
  + If you're mid-autocomplete, and want to read the definition of the
	thing you're about to complete to, hit `C-w`- The type of whatever
	your cursor is over is displayed at the bottom of the screen.
- Compile time errors will be highlighted in red, and underlined if
  your terminal supports that.
- Linter errors will be highlighted in yellow, and underlined if your
  terminal supports that. 
- To read what error caused a given highlight, put your cursor over
  the offending code, and hit `C-c C-e`. To dismiss the error, hit
  `C-g`.
- Introspection: to navigate to where something was declared or
  defined, either control-click it, or put the cursor over it, and and
  hit `M-.`
- To run tests:
  + in the current file, hit `C-x f`
  + in the current project, hit `C-x p`
  + for a coverage report, hit `C-x c`
  + for the current test, hit `C-x t`
  + to `go run` something, hit `C-x x`
- There are a bunch of
  [snippets](https://www.emacswiki.org/emacs/Yasnippet) available [for
  golang](https://github.com/dominikh/yasnippet-go/tree/master/go-mode)
  activate them by typing the abbreviation, and hitting `<TAB>`.
- There are a bunch of other functions you can use with `M-x`:
  + ‘gofmt’
  + ‘godoc’ and ‘godoc-at-point’
  + ‘go-import-add’
  + ‘go-remove-unused-imports’
  + ‘go-goto-arguments’
  + ‘go-goto-docstring’
  + ‘go-goto-function’
  + ‘go-goto-function-name’
  + ‘go-goto-imports’
  + ‘go-goto-return-values’
  + ‘go-goto-method-receiver’
  + ‘go-play-buffer’ and ‘go-play-region’
  + ‘go-download-play’
  + ‘godef-describe’ and ‘godef-jump’
  + ‘go-coverage’
  + ‘go-set-project’
  + ‘go-reset-gopath’

## Learning more about emacs
### The absolute essentials

- Holding `Control` and tapping `g` means "STOP IT!". Anything that
  feels like you might hit `Escape` or `Control-c` in another context
  probably wants a `Control-g` here.
- The emacs help system is awesome. Hold `Control`, and tap `h` to activate it.
  + Emacs will then ask you what sort of help you want. To get help on
    the things you can get help about, hit `?`.

### Emacs key notation
- `C-x` means "hold control while you tap x"
- `C-x C-c` means "hold control while you tap x, keep holding control
  while you tap c"
- `C-x c` means "hold control while you tap x, then release control before tapping c"
- Just as `C-` means the control key, so `M-` means the alt key. The
  "M" stands for "meta".  Back in the day, there were keyboards with
  an [actual meta key](https://en.wikipedia.org/wiki/Meta_key) in
  roughly the same place as modern alt keys.

### Basic things that might not be where you expect

- Open a file (or create a new file) is `C-x C-f`
- Save is `C-x C-s`
- You can switch between open files with `C-x b`
- You can split the screen
  + ...horizontally with `C-x 2`
  + ...vertically with `C-x 3`
  + you can close a split with `C-0`
  + you can close all splits except the current one with `C-1`
  + you can move from one split to another with `C-x o`

### Some emacs UX philosophy

- Literally everything that you can do with any keystroke or mouse
  gesture is a function which you can call directly by typing `M-x`
  and then the name of the function
- Often the Control key does something a bit, and the Meta (alt) key
  does it a lot. Sometimes sticking `C-x` on the front does it a
  LOT. For example:
	+ `C-t` is transpose characters
	+ `M-t` is transpose words
	+ `C-x t` is transpose lines
- Emacs is old, and lots of things have borrowed shortcuts from it
  over the years. If you're a fast bash user, you can transfer some of
  those skills:
  + `C-b` and `C-f` go backwards and forwards
  + `C-p` and `C-n` go to previous and next lines
  + `C-a` goes to the beginning of the line
  + `C-e` goes to the end of the line
  + `C-r` is "reverse search" -- searching backwards through things you
    typed above

### Using the help system

Recall that `C-h` activates the help system. There are many
sub-systems worth mentioning here:

- `C-h t` activates the emacs tutorial. It will interactively take you
  through learning emacs.
- `C-h r` is for Reading the manual. This isn't a manpage, it's a
  whole book about emacs.
- "I just did something, and something happened, and I don't know what
  I did" -- we can figure it out with the help system
  + `C-h l` will list the last 300 keystrokes you entered. Now you
	know what keys you pressed to do the thing you did
  + `C-h k <KEY>` will get help specifically on whatever happens when
	you press `<KEY>`.
  + If one of the things you did was call a function with `M-x`, you
    can get help on a function with `C-h f <function name>`
- If you want to know what keyboard shortcuts are available right now,
  hit `C-h b`
  
The whole help system is full of hyperlinks. Click on things with your
mouse, or position the cursor over them and hit `<ENTER>`. To go back
to where you came from, you can usually hit `l`.
