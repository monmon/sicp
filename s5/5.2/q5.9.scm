(load "./simulator.scm")

; ラベルにも演算することを許してしまっているので例えば以下のようにすると
; シミュレートして初めてerrorになる

;(define op-machine
;  (make-machine
;    '(val)
;    (list (list '+ +))
;    '(start
;       (assign val (op +) (label start) (const 2)))))
;
;(start op-machine)
;=> operation + is not defined between (((assign val (op +) (label start) (const 2)) . #<closure (make-assign make-assign)>)) and 2

; なのでoperation-exp-operands後に被演算子がlabelかどうかのチェックをするようにすると
; defineの時点でerrorになる
(define (make-operation-exp exp machine labels operations)
  (let ((op (lookup-prim (operation-exp-op exp) operations))
        (aprocs
          (map (lambda (e)
                 (if (label-exp? e)
                   (error "cannot operate -- ASSEMBLE" e)
                   (make-primitive-exp e machine labels)))
               (operation-exp-operands exp))))
    (lambda ()
      (apply op (map (lambda (p) (p)) aprocs)))))

(define op-machine
  (make-machine
    '(val)
    (list (list '+ +))
    '(start
       (assign val (op +) (label start) (const 2)))))
;=> cannot operate -- ASSEMBLE (label start)
