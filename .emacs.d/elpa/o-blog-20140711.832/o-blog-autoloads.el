;;; o-blog-autoloads.el --- automatically extracted autoloads
;;
;;; Code:


;;;### (autoloads (o-blog-publish-async o-blog-publish) "o-blog"
;;;;;;  "o-blog.el" (21593 520 364511 487000))
;;; Generated autoloads from o-blog.el

(autoload 'o-blog-publish "o-blog" "\
Publish FILE using o-blog BACKEND.

If FILE is not provided, try to guess FILE and BACKEND from
current buffer.

\(fn &optional FILE BACKEND)" t nil)

(autoload 'o-blog-publish-async "o-blog" "\
Publish FILE synchronously using BACKEND.

\(fn FILE)" nil nil)

;;;***

;;;### (autoloads (ob:gettext) "o-blog-i18n" "o-blog-i18n.el" (21593
;;;;;;  520 500511 485000))
;;; Generated autoloads from o-blog-i18n.el

(autoload 'ob:gettext "o-blog-i18n" "\
Return part of `o-blog-i18n' that matches TEXT in LANG.

If LANG is not defined, the blog \"#+LANGUAGE:\" header would be
used. If not found, English (en) is used as a fall-back.

\(fn TEXT &optional LANG)" nil nil)

;;;***

;;;### (autoloads nil nil ("o-blog-backend-markdown.el" "o-blog-backend-org.el"
;;;;;;  "o-blog-backend.el" "o-blog-entry.el" "o-blog-framework.el"
;;;;;;  "o-blog-obsolete.el" "o-blog-pkg.el" "o-blog-tag.el" "o-blog-utils.el")
;;;;;;  (21593 520 603079 200000))

;;;***

(provide 'o-blog-autoloads)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; o-blog-autoloads.el ends here
