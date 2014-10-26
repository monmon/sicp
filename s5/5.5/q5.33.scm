(load "./operations.scm")
(load "./compile.scm")

(print
  (compile
    '(define (factorial-alt n)
       (if (= n 1)
         1
         (* n (factorial-alt (- n 1)))))
    'val
    'next))

;=> ((env) (val) ((assign val (op make-compiled-procedure) (label entry1) (reg env)) (got (label after-lambda2)) entry1 (assign env (op compiled-procedure-env) (reg proc)) (assign env (op extend-environment) (const (n)) (reg argl) (reg env)) (save continue) (save env) (assign proc (op lookup-variable-value) (const =) (reg env)) (assign val (const 1)) (assign argl (op list) (reg val)) (assign val (op lookup-variable-value) (const n) (reg env)) (assign argl (op cons) (reg val) (reg argl)) (test (op primitive-procedure?) (reg proc)) (branch (label primitive-branch6)) compiled-branch7 (assign continue (label after-call8)) (assign val (op compiled-procedure-entry) (reg proc)) (goto (reg val)) primitive-branch6 (assign val (op apply-primitive-procedure) (reg proc) (reg argl)) after-call8 (restore env) (restore continue) (test (op false?) (reg val)) (branch (label false-branch4)) true-branch3 (assign val (const 1)) (goto (reg contnue)) false-branch4 (assign proc (op lookup-variable-value) (const *) (reg env)) (save continue) (save proc) (save env) (assign proc (op lookup-variable-value) (const factorial-alt) (reg env)) (save proc) (assign proc (op lookup-variable-value) (const -) (reg env)) (assign val (const 1)) (assign argl (op list) (reg val)) (assign val (op lookup-variable-value) (const n) (reg env)) (assign argl (op cons) (reg val) (reg argl)) (test (op primitive-procedure?) (reg proc)) (branch (label primitive-branch9)) compiled-branch10 (assign continue (label after-call11)) (assign val (op compiled-procedure-entry) (reg proc)) (goto (reg val)) primitive-branch9 (assign val (op apply-primitive-procedure) (reg proc) (reg argl)) after-call11 (assign argl (op list) (reg val)) (restore proc) (test (op primitive-procedure?) (reg proc)) (branch (label primitive-branch12)) compiled-branch13 (assign continue (label after-call14)) (assign val (op compiled-procedure-entry) (reg proc)) (goto (reg val)) primitive-branch12 (assign val (op apply-primitive-procedure) (reg proc) (reg argl)) after-call14 (assign argl (op list) (reg val)) (restore env) (assign val (op lookup-variable-value) (const n) (reg env)) (assign argl (op cons) (reg val) (reg argl)) (restore proc) (restore continue) (test (op primitive-procedure?) (reg proc)) (branch (label primitive-branch15)) compiled-branch16 (assign val (op compiled-procedure-entry) (reg proc)) (goto (reg val)) primitive-branch15 (assign val (op apply-primitive-procedure) (reg proc) (reg argl)) (goto (reg contnue)) after-call17 after-if5 after-lambda2 (perform (op define-variable!) (const factorial-alt) (reg val) (reg env)) (assign val (const ok))))

((env)
 (val)
 ((assign val (op make-compiled-procedure) (label entry1) (reg env))
  (got (label after-lambda2))
  entry1
  (assign env (op compiled-procedure-env) (reg proc))
  (assign env (op extend-environment) (const (n)) (reg argl) (reg env))
  (save continue)
  (save env)
  (assign proc (op lookup-variable-value) (const =) (reg env))
  (assign val (const 1))
  (assign argl (op list) (reg val))
  (assign val (op lookup-variable-value) (const n) (reg env))
  (assign argl (op cons) (reg val) (reg argl))
  (test (op primitive-procedure?) (reg proc))
  (branch (label primitive-branch6))
  compiled-branch7
  (assign continue (label after-call8))
  (assign val (op compiled-procedure-entry) (reg proc))
  (goto (reg val))
  primitive-branch6
  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
  after-call8
  (restore env)
  (restore continue)
  (test (op false?) (reg val))
  (branch (label false-branch4))
  true-branch3
  (assign val (const 1))
  (goto (reg contnue))
  false-branch4
  (assign proc (op lookup-variable-value) (const *) (reg env))
  (save continue)
  (save proc)
  (save env) ; env を退避
  (assign proc (op lookup-variable-value) (const factorial-alt) (reg env)) ; factorial-alt （再帰）の処理
  (save proc)
  (assign proc (op lookup-variable-value) (const -) (reg env))
  (assign val (const 1))
  (assign argl (op list) (reg val))
  (assign val (op lookup-variable-value) (const n) (reg env))
  (assign argl (op cons) (reg val) (reg argl))
  (test (op primitive-procedure?) (reg proc))
  (branch (label primitive-branch9))
  compiled-branch10
  (assign continue (label after-call11))
  (assign val (op compiled-procedure-entry) (reg proc))
  (goto (reg val))
  primitive-branch9
  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
  after-call11
  (assign argl (op list) (reg val))
  (restore proc)
  (test (op primitive-procedure?) (reg proc))
  (branch (label primitive-branch12))
  compiled-branch13
  (assign continue (label after-call14))
  (assign val (op compiled-procedure-entry) (reg proc))
  (goto (reg val))
  primitive-branch12
  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
  after-call14
  (assign argl (op list) (reg val))
  (restore env) ; env を回復
  (assign val (op lookup-variable-value) (const n) (reg env))
  (assign argl (op cons) (reg val) (reg argl))
  (restore proc)
  (restore continue)
  (test (op primitive-procedure?) (reg proc))
  (branch (label primitive-branch15))
  compiled-branch16
  (assign val (op compiled-procedure-entry) (reg proc))
  (goto (reg val))
  primitive-branch15
  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
  (goto (reg contnue))
  after-call17
  after-if5
  after-lambda2
  (perform (op define-variable!) (const factorial-alt) (reg val) (reg env))
  (assign val (const ok))))


; 主な diff は以下
; q5.33 の方は factorial-alt の再帰処理を先に処理するために env を退避回復するのに対し、
; s5.5.5 の方は n から先に処理をするので argl を退避回復している
; どちらも退避回復を行っているので違いはなさそう
; （ env と argl の退避回復の違いが出る？）
;
; % diff q5.33.scm s5.5.5.scm
; 49,50c49,52
; <   (save env) ; env を退避
; <   (assign proc (op lookup-variable-value) (const factorial-alt) (reg env)) ; factorial-alt （再帰）の処理
; ---
; >   (assign val (op lookup-variable-value) (const n) (reg env)) ; n の処理
; >   (assign argl (op list) (reg val))
; >   (save argl) ; argl を退避
; >   (assign proc (op lookup-variable-value) (const factorial) (reg env))
; 77,79c79
; <   (assign argl (op list) (reg val))
; <   (restore env) ; env を回復
; <   (assign val (op lookup-variable-value) (const n) (reg env))
; ---
; >   (restore argl) ; argl を回復
