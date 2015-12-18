usage
=====

This makes elscreen persistent.

To use this, use customize to turn on `elscreen-persist-mode`
or add the following line somewhere in your init file:

    (elscreen-persist-mode 1)

Or manually, use `elscreen-persist-store` to store,
and use `elscreen-persist-restore` to restore.

work with desktop
=================

You can use `desktop` to restore frames.

When `desktop` restored frames, `elscreen-persist` doesn't restore any frame.
The behavior occurs when `desktop` is enabled and `desktop-restore-frames` is `t`(default).

`elscreen-persist` restores all buffers, so `desktop` doesn't have to save the buffers.

    (setq desktop-files-not-to-save "")

work with desktop using "desktop-globals-to-save"
=================================================

You can use `desktop` like explained above (it is more simple and quick to setup). Or you
can use it like explained here (a little bit more setup) to use it in conjunction with
e.g. [bookmark](http://www.emacswiki.org/emacs/BookmarkPlus#toc7) or
[desktop+](https://github.com/ffevotte/desktop-plus). So you dont want to get two files on
disk (the desktop-file and the elscreen-file) and you want to save files anywhere on disc.

```elisp
(defcustom desktop-data-elscreen nil nil
  :type 'list
  :group 'desktop)

(defun desktop-prepare-data-elscreen! ()
  (setq desktop-data-elscreen
        (elscreen-persist-get-data)))

(defun desktop-evaluate-data-elscreen! ()
  (when desktop-data-elscreen
    (elscreen-persist-set-data desktop-data-elscreen)))

(add-hook 'desktop-after-read-hook 'desktop-evaluate-data-elscreen!)
(add-hook 'desktop-save-hook 'desktop-prepare-data-elscreen!)
(add-to-list 'desktop-globals-to-save 'desktop-data-elscreen)

(setq desktop-files-not-to-save "")
(setq desktop-restore-frames nil)
```