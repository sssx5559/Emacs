﻿;;;; -*- coding: utf-8 -*-

;;-----------------------------------------------------------------------------
;; 初期フレームの設定
;;-----------------------------------------------------------------------------

(setq default-frame-alist
;     (append (list '(foreground-color . "blue1")
;			'(background-color . "azure")
 (append (list '(foreground-color . "white")
			   '(background-color . "gray30")
			   '(border-color . "green")
			   '(mouse-color . "green")
			   '(cursor-color . "pink")
		 	   '(alpha . (100 100 100 100))
;		    '(ime-font . "Nihongo-12") ; TrueType のみ
;		    '(font . "bdf-fontset")    ; BDF
;		    '(font . "private-fontset"); TrueType
			   (cons 'width my-screen-width)
			   (cons 'height my-screen-height)
			   (cons 'top my-screen-top)
			   (cons 'left my-screen-left))
		 default-frame-alist))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; モードライン、リージョン色設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 'modelineは旧バージョン用
(if (get 'modeline 'face-alias)
	(progn
	  ;; モードラインの文字の色
	  (set-face-foreground 'modeline "blue1")
	  ;; モードラインの背景色
	  (set-face-background 'modeline "azure"))
  ;; モードラインの文字の色
  (set-face-foreground 'mode-line "blue1")
  ;; モードラインの背景色
  (set-face-background 'mode-line "azure"))

;; 選択中のリージョンの色
;(set-face-background 'region "LightSteelBlue1")

(when (>= emacs-major-version 23)
	  ;; モードライン（アクティブでないバッファ）の文字色
	  (set-face-foreground 'mode-line-inactive "pink")
	  ;; モードライン（アクティブでないバッファ）の背景色
	  (set-face-background 'mode-line-inactive "gray85"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ソースコード色設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (>= emacs-major-version 23)
  (set-face-foreground 'font-lock-comment-face "chocolate1")
  (set-face-foreground 'font-lock-string-face  "LightSalmon")
  (set-face-foreground 'font-lock-keyword-face "Cyan")
  (set-face-foreground 'font-lock-function-name-face "LightSkyBlue")
  (set-face-foreground 'font-lock-variable-name-face "LightGoldenrod")
  (set-face-foreground 'font-lock-type-face "PaleGreen")
  (set-face-foreground 'font-lock-builtin-face "LightSteelBlue")
  (set-face-foreground 'font-lock-constant-face "Aquamarine")
  (set-face-foreground 'font-lock-warning-face "Pink")
  (set-face-foreground 'mode-line-inactive "royal blue")
  (set-face-bold-p 'mode-line-inactive t))
;; (when (>= emacs-major-version 23)
;;   (set-face-foreground 'font-lock-comment-face "YellowGreen")
;;   (set-face-foreground 'font-lock-string-face  "HotPink")
;;   (set-face-foreground 'font-lock-keyword-face "cyan")
;;   (set-face-foreground 'font-lock-function-name-face "MediumSeaGreen")
;;   (set-face-bold-p 'font-lock-function-name-face t)
;;   ;(set-face-foreground 'font-lock-variable-name-face "SandyBrown")
;;   (set-face-foreground 'font-lock-variable-name-face "white")
;;   (set-face-foreground 'font-lock-type-face "LightSeaGreen")
;;   (set-face-foreground 'font-lock-builtin-face "peachpuff")
;;   (set-face-bold-p 'font-lock-builtin-face t)
;;   (set-face-italic-p 'font-lock-builtin-face t)
;;   ;(set-face-underline-p 'font-lock-builtin-face t)
;;   (set-face-foreground 'font-lock-constant-face "thistle")
;;   (set-face-foreground 'font-lock-warning-face "blue")
;;   (set-face-bold-p 'font-lock-warning-face nil)
;;   )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 正規表現色設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(set-face-foreground 'font-lock-regexp-grouping-backslash "green3")
(set-face-foreground 'font-lock-regexp-grouping-construct "green")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; カーソルの形
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 't(デフォルト) 'nil(なし), 'box, 'hbar(下線), 'hollow(中抜き)
;(add-to-list 'default-frame-alist '(cursor-type . 'hbar))

;; ;; (set-cursor-type 'box)            ; Meadow-1.10互換 (SKK等で色が変る設定)
;; ;; (set-cursor-type 'hairline-caret) ; 縦棒キャレット

;;; マウスカーソルを消す設定
;(when (fboundp 'Meadow-version)
;  (setq w32-hide-mouse-on-key t)
;  (setq w32-hide-mouse-timeout 5000))


;タイトルバーにファイル名を表示
(setq frame-title-format "%f")

;; 起動時の画面はいらない
(setq inhibit-startup-message t)


;;改行、全角スペース、タブ、行末スペースを表示する設定
;;  
;(defface my-face-r-1 '((t (:background "gray32"))) nil) ;改行
(defface my-face-b-1 '((t (:background "bisque1"))) nil) ;全角スーペース
;(defface my-face-b-2 '((t (:background "honeydew1"))) nil) ;タブ
;(defface my-face-u-1 '((t (:foreground "Yellow" :underline t))) nil) ;行末スペース
(defface my-face-u-1 '((t (:background "gray40"))) nil) ;行末スペース
;(defvar my-face-r-1 'my-face-r-1)
(defvar my-face-b-1 'my-face-b-1)
;(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-u-1 'my-face-u-1)

(defadvice font-lock-mode 
   (before my-font-lock-mode ())
   (font-lock-add-keywords
     major-mode
;		'(("\t" 0 my-face-b-2 append)
       '(("　" 0 my-face-b-1 append)
		   ("[ \t]+$" 0 my-face-u-1 append)
;		   ("[\r]*\n" 0 my-face-r-1 append)
       )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)


;;; メニューバー表示設定(引数 正：表示  負：非表示)
(menu-bar-mode -1)

;; モード行に時間、日付の表示
;(setq display-time-day-and-date t)
;(display-time)

;; スクロールバー表示設定
(set-scroll-bar-mode nil)
;(set-scroll-bar-mode right)

;; ツールバー表示設定
(tool-bar-mode -1)

;; emacs23
(when (>= emacs-major-version 23)
  ;; 透明度の設定	(アクティブ画面の数値 非アクティブ画面の数値)
  (add-to-list 'default-frame-alist '(alpha . (100 100)))	;デフォルト
  (set-frame-parameter nil 'alpha '(100 100) )			;カレントウィンドウ

  ;; 透明度の下限(デフォルトは20%)
  ;; (setq frame-alpha-lower-limit 15)
  )

;;=========================================================
;; モードライン表示
;;=========================================================
(display-time-mode 1) 		;; 時計
(line-number-mode 1)		;; 行番号
(column-number-mode 1)		;; 列番号
;(when (>= emacs-major-version 23)
;  (display-battery-mode 1)	;; バッテリ残量
;  )

;;=========================================================
;; Title bar
;;=========================================================
(setq frame-title-format
	  ;; `(" %b [" (buffer-file-name "%f") "] - "
	  ;; 	"major-version:", (int-to-string emacs-major-version)))
;;	  (format "%%b [%%f] - emacs-version:%s" emacs-version))
	  (format "%%f - emacs-version:%s" emacs-version))

