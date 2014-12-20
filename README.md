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
