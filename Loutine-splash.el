;;; Loutine-splash.el --- Loutine Splash             -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Loutine

;; Author: Loutine <uhuru-loutine@outlook.com>
;; Keywords: faces

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; A gentle and small splash screen , inspired by rougier/emacs-splash 

;;; Code:
(require 'subr-x)
(require 'cl-lib)

(defgroup Loutine-splash nil
  "Splash screen")

(defcustom Loutine-splash-title "Anti Bone Chick"
  "Splash screen title"
  :type 'string :group 'Loutine-splash)

(defcustom Loutine-splash-subtitle "The Best Editor On This Planet"
  "Splash screen subtitle"
  :type 'string :group 'Loutine-splash)
(defcustom Loutine-splash-user-key-bind
  '(("q" kill-current-buffer "Quit")
    ("c" open-config-file "Open Config File")
    ("r" counsel-recentf "Recent File")
    ("t" telega-persp "Telega"))
  "he user-setup keybind"
  :group 'Loutine-splash
  )

(defun Loutine-splash ()
  "Loutine Splash screen"
  (interactive)
  (let* ((splash-buffer (get-buffer-create "*splash*")))
    (with-current-buffer splash-buffer
      (setq header-line-format nil)
      (setq mode-line-format nil)))
  
  (let* ((splash-buffer  (get-buffer-create "*splash*"))
         (height         (round (- (window-body-height nil) 1) ))
         (width          (round (window-body-width nil)        ))
         (padding-center (+ (/ (- height 2 (length Loutine-splash-user-key-bind)) 2) 1)))
    
    ;; If there are buffer associated with filenames,
    ;;  we don't show the splash screen.
    (if (eq 0 (length (cl-loop for buf in (buffer-list)
                              if (buffer-file-name buf)
                              collect (buffer-file-name buf))))

	
        (with-current-buffer splash-buffer
	  (kill-all-local-variables)
	  (let ((inhibit-read-only t))
	    (erase-buffer))
	  (remove-overlays)
	  (if (one-window-p) (setq mode-line-format nil))
          (setq cursor-type nil
		line-spacing 0
		vertical-scroll-bar nil
		horizontal-scroll-bar nil
		fill-column width)
	    ;;padding to center

	  (newline padding-center)
	  (insert Loutine-splash-title)
	  (center-line)
	  (newline)
	  (insert Loutine-splash-subtitle)
	  (center-line)
	  (newline)
	  (use-local-map widget-keymap)
	  (insert-local-key-bind Loutine-splash-user-key-bind)
	  (switch-to-buffer splash-buffer)
	  (use-local-map widget-keymap)
	  
	    )
      ))
  ;; (if (and (not (member "-no-splash"  command-line-args))
  ;;          (not (member "--file"      command-line-args))
  ;;          (not (member "--insert"    command-line-args))
  ;;          (not (member "--find-file" command-line-args))
  ;;          ;; (not inhibit-startup-screen)
  ;;          ))
  (progn
    (add-hook 'window-setup-hook 'Loutine-splash)
    (setq inhibit-startup-screen t 
          inhibit-startup-message t
          inhibit-startup-echo-area-message t)))

(defun open-recent-file ()
  (interactive)
  (recentf-open-files))


(defun insert-local-key-bind (lst)
  (cl-flet ((key-bind (lambda (lst) (nth 0 lst)))
	    (command (lambda (lst) (nth 1 lst)))
	    (introduction (lambda (lst) (nth 2 lst)))
	    )
    (dolist (kb lst)
      (dotimes (_ (padding lst)) (widget-insert " "))
      (widget-create 'push-button
		     :action (lambda (&rest ignore)
			       (funcall (command kb)))
					;:format " %s "
		     :button-face '(:foreground "green" :box (:line-width (2 . 2) :color "white" :style released-button) :weight bold)
		     (key-bind kb)
		     )
      (widget-insert (introduction kb))
      (newline)
      (local-set-key (key-bind kb) (command kb)))
    ))

(defun padding (lst)
  (let* ((max (seq-reduce 'list-comp lst 0)))
    (round (/ (- (window-body-width nil) max) 2))
    )
  )

(defun list-comp (init first)
  (let ((len (+ (length (car first)) (length (caddr first)))))
    (if (< len init)
	init
      len) 
    ))

(defun open-config-file ()
  (interactive)
  (find-file user-init-file))
(provide 'Loutine-splash)
;;; Loutine-splash.el ends here
