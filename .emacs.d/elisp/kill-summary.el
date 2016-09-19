;;; 
;;; kill-summary.el: �L�������O�̈ꗗ��\�����I�������N�ł���悤�ɂ���
;;;
;;;     [2001/12/25] OSHIRO Naoki. <oshiro@mibai.tec.u-ryukyu.ac.jp>
;;;     �E�ꗗ����I�������ҏW�o�b�t�@�Ƀ����N�ł���悤�ɂ���
;;;     [2001/08/05] OSHIRO Naoki. <oshiro@mibai.tec.u-ryukyu.ac.jp>
;;;     �E�ꗗ�\���݂̂������ɍ쐬
;;;

;;; �Eyank-browse �Ƃ��̖��O�̂ق������������i���ɑ��ł���܂����D�D�D�j
;;; �E�Q�l
;;;   * yank,yank-pop (simple.el)
;;;   * electric buffer list ���[�h (ebuff-menu.el) 

;;; [����m�F]
;;; �EMeadow-1.19
;;; �EMule-19.34.1
;;; �EXEmacs-21.1p14

;;; [~/.emacs �ł̓ǂݍ��ݐݒ�]
;;;   ;;; kill-summary
;;;   (autoload 'kill-summary "kill-summary" nil t)
;;;   (define-key global-map "\ey" 'kill-summary)

;;; [�g����]
;;;   �Ekill-ring �I��p�o�b�t�@��ʃE�B���h�E�ɕ\��
;;;   �Ep,n (j,k) �őO�Ǝ��̌���I�������ҏW�o�b�t�@�w�����N
;;;     C-p (previous-line),C-n (next-line) �Ȃ�����ړ����邾���D
;;;     SPC �Ō��ݍs��I���DC-v (scroll-up) �ŃX�N���[��
;;;   �E�����N�̈�� yank-pop ���Ɏ��X�ɐ؂�ւ��
;;;   �Eyank-pop �Ƃ̐��������m�ہDM-y �Ɋ��蓖�Ă�΂ЂƂ܂������悤�Ɏg
;;;     ����i�܂������O����͂ł��Ȃ��c�j�D
;;;   �E�\�����͑��̑���͂ł��Ȃ��DRET (newline) �őI������D
;;;     ���~ (q, C-g (keyboard-quit), C-xo (other-window)) ����
;;;     �����N�̈������
;;;   �Ed �Ō��ݍs�̃L�������O�𑦍��ɏ���
;;;   �E'.' �Ō��ݍs�������N�|�C���^�ɐݒ�
;;;   �Et �Ŋe�L���̍s���\����؂�ւ�
;;;   �E^,_ �ŃT�}���[������ύX
;;;   �E�����E�B���h�E������ ~/.emacs ���Ŏ��̂悤�ɍs�Ȃ��i�f�t�H���g�l 10�j�D
;;;     (setq kill-summary-window-height 10)


(defvar kill-summary-buffer "*kill-ring*")
(defvar kill-summary-mode-map nil)
(defvar kill-summary-window-height 10)
(defvar kill-summary-show-line-number t)
(defvar kill-summary-newline-notation "^J")
(defvar kill-summary-version "0.1.3")

(if kill-summary-mode-map
    ()
  (let ((map (make-keymap)) (submap (make-keymap))
	(esc-prefix (where-is-internal 'ESC-prefix global-map 'non-ascii))
	(control-x-prefix (where-is-internal 'Control-X-prefix global-map 'non-ascii)))
  (cond ((fboundp 'set-keymap-default-binding)
	 (set-keymap-default-binding map 'kill-summary-undefined))
	(t (fillarray (car (cdr map)) 'kill-summary-undefined)))
;  (fillarray (car (cdr kill-summary-prefix-map)) 'kill-summary-undefined)
  (mapcar (lambda (x) (if x (define-key map x submap)))
	  (list esc-prefix control-x-prefix))
  (define-key map " "   'kill-summary-yank)
  (define-key map (concat esc-prefix "y") 'kill-summary-next-line-with-yank)
  (define-key map "n" 'kill-summary-next-line-with-yank)
  (define-key map "p" 'kill-summary-previous-line-with-yank)
  (define-key map "j" 'kill-summary-next-line)
  (define-key map "k" 'kill-summary-previous-line)
  (substitute-key-definition 'next-line 'kill-summary-next-line map global-map)
  (substitute-key-definition 'previous-line 'kill-summary-previous-line map global-map)
  (substitute-key-definition 'newline 'kill-summary-quit map global-map)
  (substitute-key-definition 'keyboard-quit 'kill-summary-interrupt map global-map)
  (substitute-key-definition 'other-window 'kill-summary-quit map global-map)
  (substitute-key-definition 'delete-window 'kill-summary-quit map global-map)
  (substitute-key-definition 'scroll-up 'scroll-up map global-map)
  (substitute-key-definition 'scroll-down 'scroll-down map global-map)
  (substitute-key-definition 'isearch-forward  'isearch-forward  map global-map)
  (substitute-key-definition 'isearch-backward 'isearch-backward map global-map)
  (define-key map "." 'kill-summary-set-yank-pointer)
  (define-key map "q" 'kill-summary-quit)
  (define-key map "d" 'kill-summary-delete)
  (define-key map "t" 'kill-summary-toggle-show-line-number)
  (define-key map "^" 'kill-summary-enlarge-window)
  (define-key map "_" 'kill-summary-shrink-window)
  (setq kill-summary-mode-map map)))

(defun kill-summary-delete ()
  "�L�������O���猻�ݍs�̌����폜"
  (interactive)
  (let (n (max (length kill-ring)) (cb (current-buffer))
	  (zmacs-regions nil) (y (1- (count-lines (point-min) (point)))))
    (save-excursion
      (beginning-of-line)
      (if (re-search-forward "^ *\\([0-9]+\\):" 
			     (save-excursion (end-of-line) (point)) t)
	  (setq n (- max
		     (string-to-number
		      (buffer-substring (match-beginning 1) (match-end 1)))))))
    (if (not n) ()
      (if (eq (nth n kill-ring) (car kill-ring-yank-pointer))
	  (rotate-yank-pointer 1))
      (cond ((= (length kill-ring) 1)
	     (setq kill-ring nil))
	    (t (setq kill-ring (delq (nth n kill-ring) kill-ring))))
      (setq kill-summary-window-height (window-height))
      (kill-summary-make-summary))))

(defun kill-summary-set-yank-pointer ()
  "�L�������O�̃|�C���^���ꗗ�̌��ݍs�̌��ɐݒ�"
  (interactive)
  (let (n (max (length kill-ring)))
    (save-excursion
      (beginning-of-line)
      (if (re-search-forward "^ *\\([0-9]+\\):" 
			     (save-excursion (end-of-line) (point)) t)
	  (setq n (- max
		     (string-to-number
		      (buffer-substring (match-beginning 1) (match-end 1))))))
      (if (not n) ()
	(setq kill-ring-yank-pointer (nthcdr n kill-ring))
	(message "Set yank pointer.")))))

(defun kill-summary-yank ()
  "�L�������O�ꗗ����I���s�������N"
  (interactive)
  (let (n (max (length kill-ring)) (cb (current-buffer)) (pre-yank yanking)
	  (zmacs-regions nil) ;; for XEmacs
	  )
    (save-excursion
      (beginning-of-line)
      (setq n (nth (count-lines (point-min) (point)) kill-summary-list)))
    (if n (setq n (- max n)))
    (save-excursion
      ;(beginning-of-line)
      ;(if (re-search-forward "^ *\\([0-9]+\\):" 
      ;			     (save-excursion (end-of-line) (point)) t)
      ;	  (setq n (- max
      ;		     (string-to-number
      ;		      (buffer-substring (match-beginning 1) (match-end 1))))))
      (if (not n) ()
	(set-buffer (get-buffer-create parent-buffer))
	(if pre-yank
	    (progn
	      (delete-region (point) (mark t))
	      (set-marker (mark-marker) (point)))
	  (push-mark (point) nil))
	(setq kill-ring-yank-pointer (nthcdr n kill-ring))
	(insert (current-kill 0))
	(goto-char (prog1 (mark t) (set-marker (mark-marker) (point))))
	(if (< (point) (mark t))
	    (goto-char (prog1 (mark t) (set-marker (mark-marker) (point)))))
	(set-buffer cb)
	(setq yanking t)))))

(defun kill-summary-enlarge-window (arg)
  "�ꗗ�E�B���h�E�̍������g��i���ҏW�E�B���h�E���k���j"
  (interactive "p")
  (let (all)
    (setq all (pos-visible-in-window-p (point-max)))
    (select-window parent-window)
    (if (and (or (not all) (< arg 0))
	     (> (- (window-height) arg) window-min-height))
	(enlarge-window (- arg))))
  (select-window (get-buffer-window kill-summary-buffer)))

(defun kill-summary-shrink-window (arg)
  "�ꗗ�E�B���h�E�̍������k���i���ҏW�E�B���h�E���g��j"
  (interactive "p")
  (save-excursion
    (if (> (- (window-height) arg) window-min-height)
	(kill-summary-enlarge-window (- arg)))))

(defun kill-summary-next-line-with-yank (arg)
  "�L�������O�ꗗ�̎��̍s�Ɉړ������̌��������N
ARG �͈ړ��s��"
  (interactive "p")
  (kill-summary-next-line arg t))

(defun kill-summary-next-line (arg &optional yank)
  "�L�������O�ꗗ�̎��̍s�Ɉړ�
ARG �͈ړ��s���DYANK �� nil �łȂ���Έړ���̌��s�������N����"
  (interactive "p")
  (forward-line arg)
  (beginning-of-line)
  (if (re-search-forward "^ *[0-9]+:" nil t)
      (progn
	(goto-char (match-end 0))
	(if yank (kill-summary-yank)))))

(defun kill-summary-previous-line-with-yank (arg)
  "�L�������O�ꗗ�̑O�̍s�Ɉړ������̌��������N
ARG �͈ړ��s��"
  (interactive "p")
  (kill-summary-previous-line arg t))

(defun kill-summary-previous-line (arg &optional yank)
  "�L�������O�ꗗ�̑O�̍s�Ɉړ�
ARG �͈ړ��s���DYANK �� nil �łȂ���Έړ���̌��s�������N����"
  (interactive "p")
  (forward-line (- arg))
  (if (re-search-forward "^ *[0-9]+:" nil t)
      (progn
	(goto-char (match-end 0))
	(if yank (kill-summary-yank)))))

(defun kill-summary-toggle-show-line-number ()
  "�L�����ڂ̍s���\�����g�O���ؑ�"
  (interactive)
  (setq kill-summary-window-height (window-height))
  (setq kill-summary-show-line-number (not kill-summary-show-line-number))
  (kill-summary-make-summary))

(defun kill-summary-make-summary ()
  "�L�������O�ꗗ���쐬
�쐬��C���݂� kill-ring-yank-pointer �ɑΉ������s�ֈړ�����"
  (let ((max (length kill-ring)) n nyp str strtmp prev (ndsp 0) (lines "")
	(w (- (window-width) 6)) (hs (window-height (selected-window))) h
	buffer-read-only)
    (set-buffer kill-summary-buffer)
    (erase-buffer)
    (setq n max)
    (setq nyp (length (memq (car kill-ring-yank-pointer) kill-ring)))
    (setq kill-summary-list nil)
    (mapcar
     (lambda (x)
       (setq str (split-string x "\n"))
       (setq strtmp str)
       (if kill-summary-show-line-number
	   (setq lines (format "%3d" (length str))))
       (setq str (mapconcat (lambda (y) y) str " "))
       (if (or (string-match "^[ \t]*$" str) (string= str prev))
	   ()
	 (setq kill-summary-list (append kill-summary-list (list n)))
	 (insert (format "%2d:%s %s\n" n lines
			 (truncate-string
			  (mapconcat (lambda (y) y) strtmp
				     kill-summary-newline-notation) w)))
	 (setq prev str)
	 (setq ndsp (1+ ndsp)))
       (setq n (1- n)))
     kill-ring)
    (save-excursion
      (goto-char (point-max))
      (delete-backward-char 1))
    (set-buffer-modified-p nil)
    (if (zerop ndsp)
	(progn
	  (kill-summary-quit)
	  (error "There is no kill ring for display.")))
    (goto-char (point-min))
    (or (re-search-forward (format "^ *%s:" nyp) (point-max) t)
	(re-search-forward (format "\n *%s:" nyp) (point-max) t))
    (if (not window-popup) ()
      (setq h (min (1+ ndsp) kill-summary-window-height))
      (if (or (>= h hs) (eq (minibuffer-window) parent-window)) ()
	(setq h (max h window-min-height))
	(select-window parent-window)
	(enlarge-window (- hs h))
	(select-window (get-buffer-window kill-summary-buffer)))
      ndsp)))
  
(defun kill-summary ()
  "�L�������O���ꗗ�\�����I���ł���悤�ɂ���"
  (interactive)
  (let (buffer target-height pb pw pws pud pbm
	       (pop-up-windows t)
	       (one-window (one-window-p t)))
    (if (zerop (length kill-ring)) (error "kill ring is empty."))
    (setq pb (current-buffer)
	  pw (selected-window)
	  pws (window-start)
	  pud buffer-undo-list
	  pbm (buffer-modified-p))
    (set-buffer (get-buffer-create kill-summary-buffer))
    (kill-all-local-variables)
    (mapcar 'make-local-variable
	    '(truncate-lines print-escape-newlines
              yanking window-popup kill-summary-list
	      parent-buffer parent-window parent-window-start
	      parent-undo-list parent-buffer-modified-p))
    (setq window-popup nil)
    (if (and (not one-window)
	     (> (window-height (selected-window)) (* window-min-height 2)))
	(progn
	  (setq window-popup t)
	  (split-window)
	  (set-window-buffer (next-window) kill-summary-buffer)
	  (select-window (next-window)))
      (pop-to-buffer kill-summary-buffer)
      (setq window-popup t))
    (setq buffer-read-only t
	  parent-buffer pb
	  parent-window pw
	  parent-window-start pws
	  parent-undo-list pud
	  parent-buffer-modified-p pbm
	  yanking (eq last-command 'yank)
	  print-escape-newlines t
	  kill-summary-list nil
	  truncate-lines t))
  (kill-summary-make-summary)
  (use-local-map kill-summary-mode-map)
  (setq major-mode 'kill-summary
	mode-name "Kill Summary"))

(defun kill-summary-quit (&optional delete)
  "�L�������O�ꗗ�\���̏I��
DELETE �� nil �łȂ��ꍇ�͌��ҏW�o�b�t�@�ւ̃����N��������"
  (interactive)
  (let (p (pre-yank yanking)
	  (pb parent-buffer) (pw parent-window) (pws parent-window-start)
	  (pud parent-undo-list) (pbm parent-buffer-modified-p))
    (setq kill-summary-window-height (window-height (selected-window)))
    (set-buffer pb)
    (setq p (point))
    (if (and delete pre-yank)
	(progn
	  (delete-region p (mark t))
	  (setq buffer-undo-list pud)
	  (set-buffer-modified-p pbm)
	  (pop-mark))
      (if pre-yank (setq this-command 'yank))
      (goto-char p))
    (select-window pw)
    (set-window-start (selected-window) pws)
    (set-buffer kill-summary-buffer)
    (kill-all-local-variables)
    (delete-window (get-buffer-window kill-summary-buffer))
    (kill-buffer kill-summary-buffer)))

(defun kill-summary-yank-and-quit ()
  "�L�������O�ꗗ�������N���Ă���I��"
  (interactive)
  (kill-summary-yank)
  (kill-summary-quit))

(defun kill-summary-interrupt ()
  "�L�������O�ꗗ����̑I���̒��~"
  (interactive)
  (kill-summary-quit t))

(defun kill-summary-undefined ()
  "�L�������O�ꗗ�ł̖���`�L�[�o�C���h�p�֐�"
  (interactive)
  ;(set-buffer kill-summary-parent-buffer)
  (ding)
  (message "*Kill summary mode* Type 'q' to exit."))

(provide 'kill-summary)

(defvar kill-summary-load-hook nil)
(run-hooks 'kill-summary-load-hook)

;;; end of kill-summary here.

