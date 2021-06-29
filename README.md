# eshell-vterm

An Emacs global minor mode allowing `eshell` to use
[`vterm`](https://github.com/akermu/emacs-libvterm) for visual commands.

## Installation

0. Make sure you have `vterm` installed

1. Download `eshell-vterm`

```
git clone https://github.com/iostapyshyn/eshell-vterm.git ~/.emacs.d/site-lisp/eshell-vterm
```

2. Configure automatic loading for the package using your preferred method (e.g. `use-package`):

```
(use-package eshell-vterm
  :load-path "site-lisp/eshell-vterm"
  :demand t
  :after eshell
  :config
  (eshell-vterm-mode))
```

3. Optionally, add an alias to `eshell` to be able to run any command in visual mode:
```
~ $ (defalias 'eshell/v 'eshell-exec-visual) # add this to your init.el
~ $ v nethack
```
