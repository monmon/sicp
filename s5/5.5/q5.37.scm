(load "./operations.scm")
(load "./compile.scm")

; p.352 に
; > seq1が修正するがseq2が必要とするregsにあるレジスタを守るためseq1の前後に適切なsaveとrestore命令をつけた命令列を返す
; とある通り、この条件じゃない時にも save と restore にすれば良いので if を消せば良い
(define (preserving regs seq1 seq2)
  (if (null? regs)
    (append-instruction-sequences seq1 seq2)
    (let ((first-reg (car regs)))
      (preserving (cdr regs)
                  (make-instruction-sequence
                    (list-union (list first-reg)
                                (registers-needed seq1))
                    (list-difference (registers-modified seq1)
                                     (list first-reg))
                    (append `((save ,first-reg))
                            (statements seq1)
                            `((restore ,first-reg))))
                  seq2))))

(print
  (compile
    '(define (inc n)
       (+ n 1))
    'val
    'next))

; 元の preserving

;=> ((env) (val) ((assign val (op make-compiled-procedure) (label entry1) (reg env)) (got (label after-lambda2)) entry1 (assign env (op compiled-procedure-env) (reg proc)) (assign env (op extend-environment) (const (n)) (reg argl) (reg env)) (assign proc (op lookup-variable-value) (const +) (reg env)) (assign val (const 1)) (assign argl (op list) (reg val)) (assign val (op lookup-variable-value) (const n) (reg env)) (assign argl (op cons) (reg val) (reg argl)) (test (op primitive-procedure?) (reg proc)) (branch (label primitive-branch3)) compiled-branch4 (assign val (op compiled-procedure-entry) (reg proc)) (goto (reg val)) primitive-branch3 (assign val (op apply-primitive-procedure) (reg proc) (reg argl)) (goto (reg contnue)) after-call5 after-lambda2 (perform (op define-variable!) (const inc) (reg val) (reg env)) (assign val (const ok))))

((env)
 (val)
 ((assign val (op make-compiled-procedure) (label entry1) (reg env))
  (got (label after-lambda2))

  entry1
  (assign env (op compiled-procedure-env) (reg proc))
  (assign env (op extend-environment) (const (n)) (reg argl) (reg env))
  (assign proc (op lookup-variable-value) (const +) (reg env))
  (assign val (const 1))
  (assign argl (op list) (reg val))
  (assign val (op lookup-variable-value) (const n) (reg env))
  (assign argl (op cons) (reg val) (reg argl))
  (test (op primitive-procedure?) (reg proc))
  (branch (label primitive-branch3))

  compiled-branch4
  (assign val (op compiled-procedure-entry) (reg proc))
  (goto (reg val))

  primitive-branch3
  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
  (goto (reg contnue))

  after-call5
  after-lambda2
  (perform (op define-variable!) (const inc) (reg val) (reg env))
  (assign val (const ok))))

; 常に save と restore の場合

;=> ((continue env) (val) ((save continue) (save env) (save continue) (assign val (op make-compiled-procedure) (label entry1) (reg env)) (restore continue) (got (label after-lambda2)) entry1 (assign env (op compiled-procedure-env) (reg proc)) (assign env (op extend-environment) (const (n)) (reg argl) (reg env)) (save continue) (save env) (save continue) (assign proc (op lookup-variable-value) (const +) (reg env)) (restore continue) (restore env) (restore continue) (save continue) (save proc) (save env) (save continue) (assign val (const 1)) (restore continue) (assign argl (op list) (reg val)) (restore env) (save argl) (save continue) (assign val (op lookup-variable-value) (const n) (reg env)) (restore continue) (restore argl) (assign argl (op cons) (reg val) (reg argl)) (restore proc) (restore continue) (test (op primitive-procedure?) (reg proc)) (branch (label primitive-branch3)) compiled-branch4 (assign val (op compiled-procedure-entry) (reg proc)) (goto (reg val)) primitive-branch3 (save continue) (assign val (op apply-primitive-procedure) (reg proc) (reg argl)) (restore continue) (goto (reg contnue)) after-call5 after-lambda2 (restore env) (perform (op define-variable!) (const inc) (reg val) (reg env)) (assign val (const ok)) (restore continue)))


((continue env)
 (val)
 ((save continue)
  (save env)
  (save continue)
  (assign val (op make-compiled-procedure) (label entry1) (reg env))
  (restore continue)
  (got (label after-lambda2))
  entry1
  (assign env (op compiled-procedure-env) (reg proc))
  (assign env (op extend-environment) (const (n)) (reg argl) (reg env))
  (save continue)
  (save env)
  (save continue)
  (assign proc (op lookup-variable-value) (const +) (reg env))
  (restore continue)
  (restore env)
  (restore continue)
  (save continue)
  (save proc)
  (save env)
  (save continue)
  (assign val (const 1))
  (restore continue)
  (assign argl (op list) (reg val))
  (restore env)
  (save argl)
  (save continue)
  (assign val (op lookup-variable-value) (const n) (reg env))
  (restore continue)
  (restore argl)
  (assign argl (op cons) (reg val) (reg argl))
  (restore proc)
  (restore continue)
  (test (op primitive-procedure?) (reg proc))
  (branch (label primitive-branch3))
  compiled-branch4
  (assign val (op compiled-procedure-entry) (reg proc))
  (goto (reg val))
  primitive-branch3
  (save continue)
  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
  (restore continue)
  (goto (reg contnue))
  after-call5
  after-lambda2
  (restore env)
  (perform (op define-variable!) (const inc) (reg val) (reg env))
  (assign val (const ok)) (restore continue)))
