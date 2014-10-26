(load "./operations.scm")
(load "./compile.scm")

;(print
;  (compile
;    '(define (add x y z)
;       (+ x y z))
;    'val
;    'next))

;=> ((env) (val) ((assign val (op make-compiled-procedure) (label entry1) (reg env)) (got (label after-lambda2)) entry1 (assign env (op compiled-procedure-env) (reg proc)) (assign env (op extend-environment) (const (x y z)) (reg argl) (reg env)) (assign proc (op lookup-variable-value) (const +) (reg env)) (assign val (op lookup-variable-value) (const z) (reg env)) (assign argl (op list) (reg val)) (assign val (op lookup-variable-value) (const y) (reg env)) (assign argl (op cons) (reg val) (reg argl)) (assign val (op lookup-variable-value) (const x) (reg env)) (assign argl (op cons) (reg val) (reg argl)) (test (op primitive-procedure?) (reg proc)) (branch (label primitive-branch3)) compiled-branch4 (assign val (op compiled-procedure-entry) (reg proc)) (goto (reg val)) primitive-branch3 (assign val (op apply-primitive-procedure) (reg proc) (reg argl)) (goto (reg contnue)) after-call5 after-lambda2 (perform (op define-variable!) (const add) (reg val) (reg env)) (assign val (const ok))))

; 改行すると
; ((env)
;  (val)
;  ((assign val (op make-compiled-procedure) (label entry1) (reg env))
;   (got (label after-lambda2))
;   entry1
;   (assign env (op compiled-procedure-env) (reg proc))
;   (assign env (op extend-environment) (const (x y z)) (reg argl) (reg env))
;   (assign proc (op lookup-variable-value) (const +) (reg env))
;   (assign val (op lookup-variable-value) (const z) (reg env))
;   (assign argl (op list) (reg val))
;   (assign val (op lookup-variable-value) (const y) (reg env))
;   (assign argl (op cons) (reg val) (reg argl))
;   (assign val (op lookup-variable-value) (const x) (reg env))
;   (assign argl (op cons) (reg val) (reg argl))
;   (test (op primitive-procedure?) (reg proc))
;   (branch (label primitive-branch3))
;   compiled-branch4
;   (assign val (op compiled-procedure-entry) (reg proc))
;   (goto (reg val))
;   primitive-branch3
;   (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;   (goto (reg contnue))
;   after-call5
;   after-lambda2
;   (perform (op define-variable!) (const add) (reg val) (reg env))
;   (assign val (const ok))))

; z, y, x の順に評価されているので右から左への処理になっている（ p.348 にも「引数を最後から最初へ処理する」と書いてある）
; 組合せの被演算子の処理は p.348 の construct-arglist で行っていて「引数を最後から最初へ処理する」の reverse をなくせば良さそう
; ただし、それだけだと
;
;   (assign val (op lookup-variable-value) (const z) (reg env))
;   (assign argl (op list) (reg val))
;   (assign val (op lookup-variable-value) (const y) (reg env))
;   (assign argl (op cons) (reg val) (reg argl))
;   (assign val (op lookup-variable-value) (const x) (reg env))
;   (assign argl (op cons) (reg val) (reg argl))
;
; の部分が、 x, y, z になるだけで argl の順番が逆になってしまうので
; 問題文にある 5.4.1 から adjoin-arg をもってきて逆にして追加していくようにする

(define (adjoin-arg arg arglist)
    (append arglist (list arg)))

(define (construct-arglist operand-codes)
  (let ((operand-codes operand-codes))
    (if (null? operand-codes)
      (make-instruction-sequence '() '(argl)
                                 '((assign argl (const ()))))
      (let ((code-to-get-last-arg
              (append-instruction-sequences
                (car operand-codes)
                (make-instruction-sequence '(val) '(argl)
                                           '((assign argl (op list) (reg val)))))))
        (if (null? (cdr operand-codes))
          code-to-get-last-arg
          (preserving '(env)
                      code-to-get-last-arg
                      (code-to-get-rest-args
                        (cdr operand-codes))))))))

(define (code-to-get-rest-args operand-codes)
  (let ((code-for-next-arg
          (preserving '(argl)
                      (car operand-codes)
                      (make-instruction-sequence '(val argl) '(argl)
                                                 '((assign argl
                                                           ;(op adjoin-arg) (reg val) (reg argl)))))))
                                                           (op cons) (reg val) (reg argl)))))))
    (if (null? (cdr operand-codes))
      code-for-next-arg
      (preserving '(env)
                  code-for-next-arg
                  (code-to-get-rest-args (cdr operand-codes))))))

(print
  (compile
    '(define (add x y z)
       (+ x y z))
    'val
    'next))

;=> ((env) (val) ((assign val (op make-compiled-procedure) (label entry1) (reg env)) (got (label after-lambda2)) entry1 (assign env (op compiled-procedure-env) (reg proc)) (assign env (op extend-environment) (const (x y z)) (reg argl) (reg env)) (assign proc (op lookup-variable-value) (const +) (reg env)) (assign val (op lookup-variable-value) (const x) (reg env)) (assign argl (op list) (reg val)) (assign val (op lookup-variable-value) (const y) (reg env)) (assign argl (op adjoin-arg) (reg val) (reg argl)) (assign val (op lookup-variable-value) (const z) (reg env)) (assign argl (op adjoin-arg) (reg val) (reg argl)) (test (op primitive-procedure?) (reg proc)) (branch (label primitive-branch3)) compiled-branch4 (assign val (op compiled-procedure-entry) (reg proc)) (goto (reg val)) primitive-branch3 (assign val (op apply-primitive-procedure) (reg proc) (reg argl)) (goto (reg contnue)) after-call5 after-lambda2 (perform (op define-variable!) (const add) (reg val) (reg env)) (assign val (const ok))))

; ((env)
;  (val)
;  ((assign val (op make-compiled-procedure) (label entry1) (reg env))
;   (got (label after-lambda2))
;   entry1
;   (assign env (op compiled-procedure-env) (reg proc))
;   (assign env (op extend-environment) (const (x y z)) (reg argl) (reg env))
;   (assign proc (op lookup-variable-value) (const +) (reg env))
;   (assign val (op lookup-variable-value) (const x) (reg env))
;   (assign argl (op list) (reg val))
;   (assign val (op lookup-variable-value) (const y) (reg env))
;   (assign argl (op adjoin-arg) (reg val) (reg argl))
;   (assign val (op lookup-variable-value) (const z) (reg env))
;   (assign argl (op adjoin-arg) (reg val) (reg argl))
;   (test (op primitive-procedure?) (reg proc))
;   (branch (label primitive-branch3))
;   compiled-branch4
;   (assign val (op compiled-procedure-entry) (reg proc))
;   (goto (reg val))
;   primitive-branch3
;   (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;   (goto (reg contnue))
;   after-call5
;   after-lambda2
;   (perform (op define-variable!) (const add) (reg val) (reg env))
;   (assign val (const ok))))

; 効率は append 次第、（多分）最後に足すことになるので要素数が多ければ多い程効率が悪いと思われる
