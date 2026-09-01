;;   -*- lexical-binding: nil; -*-

;;; packages.el --- native-treesitter layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2025 Sylvain Benner & Contributors
;;
;; Author: Data Mike <mjp35@cornell.edu>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `native-treesitter-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `native-treesitter/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `native-treesitter/pre-init-PACKAGE' and/or
;;   `native-treesitter/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst native-treesitter-packages
  '(treesit-auto
    treesit-fold
    ;; Hook into the following layers when they load
    csharp
    markdown
    python))

(defun native-treesitter/init-treesit-auto ()
  (use-package treesit-auto
    :ensure t
    :config
    (global-treesit-auto-mode)))

(defun native-treesitter/init-treesit-fold ()
  (use-package treesit-fold
    :ensure t))

;; ====================================================================
;; LANGUAGE EXTENSIONS (Hooks execute ONLY if layer is enabled in .spacemacs)
;; ====================================================================

;; --- PYTHON INTEGRATION ---
(defun native-treesitter/post-init-python ()
  (with-eval-after-load 'python
    (add-to-list 'auto-mode-alist '("\\.py\\'" . python-ts-mode))
    (add-hook 'python-ts-mode-hook #'treesit-fold-mode)
    (add-hook 'python-ts-mode-hook #'spacemacs//python-setup-backend)
    (add-hook 'python-ts-mode-hook #'native-treesitter//python-ts-mode-hook))

  (with-eval-after-load 'lsp-mode
    (lsp-dependency 'python '(:language-id "python"))
    (add-to-list 'lsp-language-id-configuration '(python-ts-mode . "python"))))

(defun native-treesitter//python-ts-mode-hook ()
  (run-hooks 'python-mode-hook)
  (when python-sort-imports-on-save
    (add-hook 'before-save-hook #'native-treesitter//py-isort-before-save)))

(defun native-treesitter//py-isort-before-save ()
  (when (or (eq major-mode 'python-mode)
            (eq major-mode 'python-ts-mode))
    (condition-case err (py-isort-buffer)
      (error (message "%s" (error-message-string err))))))

;; --- C# INTEGRATION ---
(defun native-treesitter/post-init-csharp ()
  (with-eval-after-load 'csharp-mode
    ;; Map C# files (.cs) to the native tree-sitter major mode
    (add-to-list 'auto-mode-alist '("\\.cs\\'" . csharp-ts-mode))

    ;; Enable folding and bridge formatting/LSP layers
    (add-hook 'csharp-ts-mode-hook #'treesit-fold-mode)
    (add-hook 'csharp-ts-mode-hook #'spacemacs//csharp-setup-backend)
    (add-hook 'csharp-ts-mode-hook #'native-treesitter//csharp-ts-mode-hook))

  (with-eval-after-load 'lsp-mode
    (add-to-list 'lsp-language-id-configuration '(csharp-ts-mode . "csharp"))))

(defun native-treesitter//csharp-ts-mode-hook ()
  (run-hooks 'csharp-mode-hook))

;; --- MARKDOWN INTEGRATION ---
(defun native-treesitter/post-init-markdown ()
  (with-eval-after-load 'markdown-mode
    ;; Map standard Markdown suffixes to the native tree-sitter major mode
    (dolist (re '("\\.md\\'" "\\.mdx\\'" "\\.markdown\\'"))
      (add-to-list 'auto-mode-alist (cons re 'markdown-ts-mode)))

    ;; Enable folding hooks and initialize Spacemacs backend routines
    (add-hook 'markdown-ts-mode-hook #'treesit-fold-mode)
    (add-hook 'markdown-ts-mode-hook #'spacemacs//markdown-setup-backend)
    (add-hook 'markdown-ts-mode-hook #'native-treesitter//markdown-ts-mode-hook))

  ;; Load Emacs 31 extensions (enables things like table of contents utilities)
  (with-eval-after-load 'markdown-ts-mode
    (require 'markdown-ts-mode-x)))

(defun native-treesitter//markdown-ts-mode-hook ()
  (run-hooks 'markdown-mode-hook))
