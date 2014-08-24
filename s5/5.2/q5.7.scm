(load "./simulator.scm")

; https://gist.github.com/MasamichiIdeue/f78484b355ec25b56773#%E5%95%8F%E9%A1%8C-54

;; Recursive
(define expt-machine
  (make-machine
    '(b n continue val)
    (list (list '= =) (list '- -) (list '* *))
    '((assign continue (label expt-done))
      expt-loop
      (test (op =) (reg n) (const 0))
      (branch (label base-case))
      (save continue)
      (save n)
      (assign n (op -) (reg n) (const 1))
      (assign continue (label after-expt))
      (goto (label expt-loop))
      after-expt
      (restore n)
      (restore continue)
      (assign val (op *) (reg b) (reg val))
      (goto (reg continue))
      base-case
      (assign val (const 1))
      (goto (reg continue))
      expt-done)))

(print "=== Recursive ===")
(set-register-contents! expt-machine 'b 3)
(set-register-contents! expt-machine 'n 4)
(start expt-machine)
(print (get-register-contents expt-machine 'val)) ; => 81

;; Iterative
(define expt-machine
  (make-machine
    '(b n counter val)
    (list (list '= =) (list '- -) (list '* *))
    '((assign counter (reg n))
      (assign val (const 1))
      expt-loop
      (test (op =) (reg counter) (const 0))
      (branch (label expt-done))
      (assign counter (op -) (reg counter) (const 1))
      (assign val (op *) (reg b) (reg val))
      (goto (label expt-loop))
      expt-done)))

(print "=== Iterative ===")
(set-register-contents! expt-machine 'b 3)
(set-register-contents! expt-machine 'n 4)
(start expt-machine)
(print (get-register-contents expt-machine 'val)) ; => 81
