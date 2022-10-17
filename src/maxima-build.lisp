(cl:defpackage #:maxima-build
  (:use #:cl)
  (:export #:compile-maxima
           #:load-maxima
           #:save-maxima-image
           #:save-maxima-executable)
  (:documentation "Package for building, loading, or dumping an image of Maxima."))

(cl:in-package #:maxima-build)

#+lispworks
(setq hcl:*packages-for-warn-on-redefinition*
    (remove-if (lambda (package-name)
                 (member package-name
                         '("HARLEQUIN-COMMON-LISP"
                           ;"CL-USER"
                           )
                         :test #'string-equal))
               *packages-for-warn-on-redefinition*))
#+lispworks (defun hcl:getenv (x) (LW:ENVIRONMENT-VARIABLE x))

(load
 #-lispworks "../lisp-utils/defsystem.lisp"
 #+lispworks (current-pathname "../lisp-utils/defsystem.lisp"))

#+ecl (load "maxima-package.lisp")
#+ecl
(compile 'maxima::make-unspecial
	 '(lambda (s)
	   (when (symbolp s)
	     (format t "~%;;; Declaring ~A as NOT SPECIAL" s)
	     (ffi::c-inline (s) (:object) :object
			    "((#0)->symbol.stype = stp_ordinary, #0)"
			    :one-liner t))))

(defun compile-maxima ()
  "Compile the Maxima source code."
  (mk:oos "maxima" :compile))

(defun load-maxima ()
  "Load the compiled Maxima code."
  (mk:oos "maxima" :load))

(defun save-maxima-image ()
  #+clisp (ext:saveinitmem "binary-clisp/maxima.mem" :init-function (function cl-user::run))
  #+sbcl (sb-ext:save-lisp-and-die "binary-sbcl/maxima.core" :toplevel (symbol-function 'cl-user::run))
  #+gcl (si:save-system "binary-gcl/maxima")
  #+cmu (extensions:save-lisp "binary-cmucl/maxima.core" :init-function 'cl-user::run)
  #+scl (extensions:save-lisp "binary-scl/maxima.core" :init-function 'cl-user::run)
  #+allegro (excl:dumplisp :name "binary-acl/maxima.dxl")
  #+lispworks (hcl:save-image "binary-lispworks/maxima" :restart-function 'cl-user::run)
  #+(and openmcl (not 64-bit-target)) (ccl:save-application "binary-openmcl/maxima" :toplevel-function 'cl-user::run)
  #+(and openmcl 64-bit-target) (ccl:save-application "binary-ccl64/maxima" :toplevel-function 'cl-user::run)
  #-(or clisp sbcl gcl cmu scl allegro lispworks ccl)
  (format t "Sorry, I don't know how to dump an image on this Lisp"))

(defvar *executable-file-extensions*
  (list #+windows ".exe"
        #+linux   ""
        #+unix    ""
        ""                              ; default
        )
  "A list of possible executable file extensions in high-to-low priority order.")

(defun save-maxima-executable ()
  "Produce an executable that loads straight into a Maxima interpreter."
  #+sbcl (sb-ext:save-lisp-and-die (concatenate 'string
                                                "binary-sbcl/maxima"
                                                (first *executable-file-extensions*))
                                   :executable t
                                   :toplevel (symbol-function 'cl-user::run))
  #-(or sbcl) (format t "Sorry, I don't know how to save an executable on this Lisp"))
