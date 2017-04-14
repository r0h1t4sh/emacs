;; ref: http://www.aaronbedra.com/emacs.d/
;; User
(setq user-full-name "Rohitash Kumar")
(setq user-mail-address "r0h1t4sh@gmail.com")

;; Default mode is org
;; (setq-default major-mode 'org-mode)

;; Package management
(require 'package)
(package-initialize)
(add-to-list 'package-archives
       '("gnu" . "http://elpa.gnu.org/packages/"))
(add-to-list 'package-archives
       '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
       '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives
       '("elpy" . "http://jorgenschaefer.github.io/packages/"))
(setq package-archive-enable-alist '(("melpa" deft magit)))

;; Default packages
(require 'cl)
(defvar remacs/packages '(ac-slime
  auto-complete
  ac-js2
  autopair
  coffee-mode
  csharp-mode
  deft
  erlang
  enh-ruby-mode
  feature-mode
  find-file-in-project
  find-file-in-repository
  flycheck
  gist
  go-mode
  graphviz-dot-mode
  haml-mode
  htmlize
  js3-mode
  js2-refactor
  magit
  markdown-mode
  marmalade
  nodejs-repl
  nrepl
  o-blog
  org
  paredit
  paredit-everywhere
  php-mode
  powerline
  projectile
  puppet-mode
  restclient
  rvm
  scala-mode
  smex
  sml-mode
  solarized-theme
  sx
  undo-tree
  web-mode
  writegood-mode
  xkcd
  yaml-mode)
  "Default packages")

(defun remacs/packages-installed-p ()
  (loop for pkg in remacs/packages
  when (not (package-installed-p pkg)) do (return nil)
  finally (return t)))

(unless (remacs/packages-installed-p)
  (message "%s" "Refreshing package database...")
  (package-refresh-contents)
  (dolist (pkg remacs/packages)
    (when (not (package-installed-p pkg))
      (package-install pkg))))

;; Init YASnippet
(add-to-list 'load-path
       "~/.emacs.d/elpa/yasnippet-20150415.244/")
(require 'yasnippet)
(yas-global-mode 1)

;; Skip splash and directly jump to *scratch*
(setq inhibit-splash-screen t
      initial-scratch-message nil
      initial-major-mode 'org-mode)

;; Remove fancy GUI
(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)

;; Marking tweaks
(delete-selection-mode t)
(transient-mark-mode t)
(setq x-select-enable-clipboard t)

;; Display settings
;; File path as frame title
(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b"))))

;; Put markers at file end
(setq-default indicate-empty-lines t)
(when (not indicate-empty-lines)
  (toggle-indicate-empty-lines))


;;powerline
(require 'powerline)
(powerline-default-theme)

;;nodejs-repl
(require 'nodejs-repl)

;;Javascript
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.json$" . js2-mode))



;; Use js-mode indentation in js2-mode, I don't like js2-mode's indentation
;;
;; thanks http://mihai.bazon.net/projects/editing-javascript-with-emacs-js2-mode
;; with my own modifications
;;
(defun my-js2-indent-function ()
  (interactive)
  (save-restriction
    (widen)
    (let* ((inhibit-point-motion-hooks t)
           (parse-status (save-excursion (syntax-ppss (point-at-bol))))
           (offset (- (current-column) (current-indentation)))
           (indentation (js--proper-indentation parse-status))
           node)

      (save-excursion

        (back-to-indentation)
        ;; consecutive declarations in a var statement are nice if
        ;; properly aligned, i.e:
        ;;
        ;; var foo = "bar",
        ;;     bar = "foo";
        (setq node (js2-node-at-point))
        (when (and node
                   (= js2-NAME (js2-node-type node))
                   (= js2-VAR (js2-node-type (js2-node-parent node))))
          (setq indentation ( 4 indentation))))

      (indent-line-to indentation)
      (when (> offset 0) (forward-char offset)))))

(defun my-indent-sexp ()
  (interactive)
  (save-restriction
    (save-excursion
      (widen)
      (let* ((inhibit-point-motion-hooks t)
             (parse-status (syntax-ppss (point)))
             (beg (nth 1 parse-status))
             (end-marker (make-marker))
             (end (progn (goto-char beg) (forward-list) (point)))
             (ovl (make-overlay beg end)))
        (set-marker end-marker end)
        (overlay-put ovl 'face 'highlight)
        (goto-char beg)
        (while (< (point) (marker-position end-marker))
          ;; don't reindent blank lines so we don't set the "buffer
          ;; modified" property for nothing
          (beginning-of-line)
          (unless (looking-at "\\s-*$")
            (indent-according-to-mode))
          (forward-line))
        (run-with-timer 0.5 nil '(lambda(ovl)
                                   (delete-overlay ovl)) ovl)))))

(defun my-js2-mode-hook ()
  (require 'js)
  (setq js-indent-level 2
        indent-tabs-mode nil
        c-basic-offset 2)
  (c-toggle-auto-state 0)
  (c-toggle-hungry-state 1)
  (set (make-local-variable 'indent-line-function) 'my-js2-indent-function)
  (define-key js2-mode-map [(meta control |)] 'cperl-lineup)
  (define-key js2-mode-map [(meta control \;)]
    '(lambda()
       (interactive)
       (insert "/* -----[ ")
       (save-excursion
         (insert " ]----- */"))
       ))
  (define-key js2-mode-map [(return)] 'newline-and-indent)
  (define-key js2-mode-map [(backspace)] 'c-electric-backspace)
  (define-key js2-mode-map [(control d)] 'c-electric-delete-forward)
  (define-key js2-mode-map [(control meta q)] 'my-indent-sexp)
  (if (featurep 'js2-highlight-vars)
    (js2-highlight-vars-mode))
  (message "My JS2 hook"))

(add-hook 'js2-mode-hook 'my-js2-mode-hook)

(require 'js2-refactor)
(add-hook 'js2-mode-hook #'js2-refactor-mode)

;; Set tabwidth to 2
(setq tab-width 2
      indent-tabs-mode nil)

;; Disable backup files
;;(setq make-backup-files nil)
(setq backup-directory-alist `(("." . "~/.saves")))
(setq backup-by-copying t)
(setq delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)


;; Shorten yes and not to y or n
(defalias 'yes-or-no-p 'y-or-n-p)

;;Keybindings
(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key (kbd "C-;") 'comment-or-uncomment-region)
(global-set-key (kbd "M-/") 'hippie-expand)
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-c C-k") 'compile)
(global-set-key (kbd "C-x g") 'magit-status)

;; Turn down the time to echo keystrokes so I don't have to wait around
;; for things to happen. Dialog boxes are also a bit annoying, so just
;; have Emacs use the echo area for everything. Beeping is for robots,
;; and I am not a robot. Use a visual indicator instead of making
;; horrible noises. Oh, and always highlight parentheses.
;; A person could go insane without that.
(setq echo-keystrokes 0.1
      use-dialog-box nil
      visible-bell t)
(show-paren-mode t)

;; vendor dir aka custom
(defvar remacs/vendor-dir (expand-file-name "vendor" user-emacs-directory))
(add-to-list 'load-path remacs/vendor-dir)

(dolist (project (directory-files remacs/vendor-dir t "\\w+"))
  (when (file-directory-p project)
    (add-to-list 'load-path project)))

;; Squirrel
;;(require 'squirrel-mode)

;; Org mode specific
(add-to-list 'auto-mode-alist '("\\.org\\¡¯" . org-mode))
;; TBD

;; ido
(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t
      ido-use-virtual-buffers t)

;; Column number mode
(setq column-number-mode t)

;; Show line numbers
(global-linum-mode 1)

;; This make temporary file go away
;; (setq backup-directory-alist `((".*" . ,temporary-file-directory)))
;; (setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Close braces as soon as the opening char is typed
(require 'autopair)


;; Lisp setting
;; TBD


;; Autocomplete
(require 'auto-complete-config)
(ac-config-default)


;; Theme :)
(load-theme 'solarized-dark t)

;;This re-indents, untabifies, and cleans up whitespace. It is stolen
;;directly from the emacs-starter-kit.
(defun untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (indent-buffer)
  (untabify-buffer)
  (delete-trailing-whitespace))

(defun cleanup-region (beg end)
  "Remove tmux artifacts from region."
  (interactive "r")
  (dolist (re '("\\\\│\·*\n" "\W*│\·*"))
    (replace-regexp re "" nil beg end)))

(global-set-key (kbd "C-x M-t") 'cleanup-region)
(global-set-key (kbd "C-c n") 'cleanup-buffer)

(setq-default show-trailing-whitespace t)


;; Spelling
(setq flyspell-issue-welcome-flag nil)
(if (eq system-type 'darwin)
    (setq-default ispell-program-name "/usr/local/bin/aspell")
  (setq-default ispell-program-name "/usr/bin/aspell"))
(setq-default ispell-list-command "list")


;; Web-mode
(add-to-list 'auto-mode-alist '("\\.hbs$" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb$" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html$" . web-mode))
(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-ac-sources-alist
        '(("css" . (ac-source-css-property))
          ("html" . (ac-source-words-in-buffer ac-source-abbrev))))
  ;; (setq web-mode-attr-indent-offset 0)
)
(add-hook 'web-mode-hook  'my-web-mode-hook)

;; Column width indicator
(require 'fill-column-indicator)
(define-globalized-minor-mode
  global-fci-mode fci-mode (lambda () (fci-mode 1)))
(global-fci-mode t)

;;SMEX make M-x to bheave like ido
(setq smex-save-file (expand-file-name ".smex-items" user-emacs-directory))
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)

;; Custom functions
(defun copy-all ()
    "Copy entire buffer to clipboard"
    (interactive)
    (clipboard-kill-ring-save (point-min) (point-max))
    (message "Buffer copied"))

(global-set-key (kbd "C-c c") 'copy-all)

;; Source: http://www.emacswiki.org/emacs-en/download/misc-cmds.el
(defun revert-buffer-no-confirm ()
    "Revert buffer without confirmation."
    (interactive)
    (revert-buffer t t)
    (message "Buffer reloaded"))

(global-set-key (kbd "C-c r") 'revert-buffer-no-confirm)

;; Add command to copy file path
;; http://stackoverflow.com/questions/2416655/file-path-to-clipboard-in-emacs
(defun copy-file-name-to-clipboard ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
          default-directory
        (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))

;; On buffer save untabify buffer
(add-hook 'before-save-hook 'untabify-buffer)

;; On buffer save cleanup whitespaces
(add-hook 'before-save-hook 'whitespace-cleanup)

; Autocomplete on python strings
(setq ac-disable-faces nil)

; enable elpy
(elpy-enable)

; enable projectile for all
(projectile-global-mode)

;; by default split windows vertically
(split-window-right)
(setq split-height-threshold nil)
(setq split-width-threshold 100)

;; Provide Autocomplete to sql client
(require 'sql-completion)
(setq sql-interactive-mode-hook
      (lambda ()
        (define-key sql-interactive-mode-map "\t" 'comint-dynamic-complete)
        (sql-mysql-completion-init)))

(require 'desktop)
(add-to-list 'desktop-globals-to-save 'sql-mysql-schema)

;; Code folding for python and other
(defun hs-enable-and-toggle ()
  (interactive)
  (hs-minor-mode 1)
  (hs-toggle-hiding))
(defun hs-enable-and-hideshow-all (&optional arg)
  "Hide all blocks. If prefix argument is given, show all blocks."
  (interactive "P")
  (hs-minor-mode 1)
  (if arg
      (hs-show-all)
      (hs-hide-all)))

(global-set-key (kbd "C-c C-h") 'hs-enable-and-toggle)
(global-set-key (kbd "C-c C-j") 'hs-enable-and-hideshow-all)

;; fonts

(if (string= (symbol-name system-type) "windows-nt")
    (set-default-font "-outline-Consolas-normal-normal-normal-mono-18-*-*-*-c-*-iso8859-1")
  (modify-frame-parameters nil '((wait-for-wm . nil))))

(if (string= (symbol-name system-type) "darwin")
    (set-default-font "-outline-Inconsolata-normal-normal-normal-mono-22-*-*-*-c-*-iso8859-1")
  (modify-frame-parameters nil '((wait-for-wm . nil))))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(python-check-command "/usr/local/bin/pyflakes"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(defun testers-dream ()
  (interactive)
  (defvar ccmd)
  (setq ccmd (concat "g++ " (buffer-name) " && ./a.out"))
  (shell-command ccmd))

;; Remap meta key from alt/option to command
(setq mac-option-key-is-meta nil)
(setq mac-command-key-is-meta t)
(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)


(message "Done loading .emacs")
