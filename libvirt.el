;;; libvirt.el --- Manage virtual machines from emacs -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023
;;
;; Author:  nsaspy@airmail.cc
;; Maintainer:  nsaspy@airmail.cc
;; Created: November 27, 2023
;; Modified: November 27, 2023
;; Version: 0.0.1
;; Keywords: libvirt virtualmachine
;; Homepage: https://github.com/lost-rob0t/libvirt-el
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Manage virtual machines from emacs
;;
;;; Code:

(defvar virsh-path (executable-find "virsh"))



(defun libvirt-list-vms ()
  (let* ((default-directory "/sudo::/")
         (vms-raw (shell-command-to-string (format "%s list --all" virsh-path)))
         (vms (cl-loop for s in (cdr (split-string vms-raw "\n" t)) ;; Skip the header line
                       when (string-match-p "\\S-" s) ;; Skip empty lines
                       for line = (split-string s)
                       unless (or (null (nth 1 line)) (null (nth 2 line)))
                       collect (list (nth 1 line) (nth 2 line)))))

    vms))


(defun is-running-p (vm-name)
  "Is the vm running?"
  (string-equal (car (cdr (assoc vm-name (libvirt-list-vms)))) "running"))



(defun libvirt-start-vm (&optional vm-name)
  "Start a virtual machine"
  (interactive)
  (let ((default-directory "/sudo::/"))
    (when (not vm-name)
      (setf vm-name (completing-read "Select VM: " (mapcar #'car (libvirt-list-vms)))))
    (if vm-name
        (shell-command (format "%s start %s" virsh-path vm-name)))))


(defun libvirt-shutdown-vm (&optional vm-name)
  "Shutdown a virtual machine"
  (interactive)
  (let ((default-directory "/sudo::/"))

    (when (not vm-name)
      (setf vm-name (completing-read "Select VM: " (mapcar #'car (libvirt-list-vms)))))
    (if vm-name
        (start-process-shell-command "virsh" nil (format "%s shutdown %s" virsh-path vm-name)))))


(defun libvirt-retart-vm (&optional vm-name)
  "Force shutdown a virtual machine"
  (interactive)
  (let ((default-directory "/sudo::/"))

    (when (not vm-name)
      (setf vm-name (completing-read "Select VM: " (mapcar #'car (libvirt-list-vms)))))
    (if vm-name
        (progn
          (message "Restarting: %s" vm-name)
          (libvirt-shutdown-vm vm-name)
          (libvirt-start-vm vm-name)))))

(defun libvirt-force-shutdown-vm (&optional vm-name)
  "Force shutdown a virtual machine"
  (interactive)
  (let ((default-directory "/sudo::/"))

    (when (not vm-name)
      (setf vm-name (completing-read "Select VM: " (mapcar #'car (libvirt-list-vms)))))
    (if vm-name
        (progn
          (message "Force shutting down: %s" vm-name)
          (shell-command (format "%s destroy %s" virsh-path vm-name))))))


(defun libvirt-force-restart-vm (&optional vm-name)
  "Force shutdown a virtual machine"
  (interactive)
  (let ((default-directory "/sudo::/"))

    (when (not vm-name)
      (setf vm-name (completing-read "Select VM: " (mapcar #'car (libvirt-list-vms)))))
    (if vm-name
        (progn
          (message "Restarting: %s" vm-name)
          (libvirt-force-shutdown-vm vm-name)
          (libvirt-start-vm vm-name)))))



(provide 'libvirt)
;;; libvirt.el ends here
