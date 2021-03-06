; originally from https://gist.github.com/mururu/a27918cb98cbbe213dca
(define false #f)
(define true #t)

(define (true? x)
 (not (eq? x false)))
(define (false? x)
 (eq? x false))


; eval
(define (eval exp env)
  (cond ((self-evaluating? exp) exp)
        ((variable? exp) (lookup-variable-value exp env))
        ((quoted? exp) (text-of-quotation exp))
        ((assignment? exp) (eval-assignment exp env))
        ((definition? exp) (eval-definition exp env))
        ((if? exp) (eval-if exp env))
        ((lambda? exp)
         (make-procedure (lambda-parameters exp)
                         (lambda-body exp)
                         env))
        ((begin? exp) 
         (eval-sequence (begin-actions exp) env))
        ((cond? exp) (eval (cond->if exp) env))
        ((unless? exp) (analyze (unless->if exp)))            ; q4.26
        ((application? exp)
         (my-apply (actual-value (operator exp) env)
                   (operands exp)
                   env))
        (else
          (error "Unknown expression type -- EVAL" exp))))

(define (actual-value exp env)
  (force-it (eval exp env)))

(define (thunk? obj)
  (tagged-list? obj 'thunk))

(define (delay-it exp env)
  (list 'thunk exp env))

(define (thunk-exp thunk) (cadr thunk))

(define (thunk-env thunk) (caddr thunk))

;; メモ化なし thunk
;(load "./thunk-without-memoization.scm")
;; メモ化あり thunk
(load "./thunk-with-memoization.scm")

(define (analyze-self-evaluating exp)
  (lambda (env) exp))

(define (analyze-quoted exp)
  (let ((qval (text-of-quotation exp)))
    (lambda (env) qval)))

(define (analyze-variable exp)
  (lambda (env) (lookup-variable-value exp env)))

(define (analyze-assignment exp)
  (let ((var (assignment-variable exp))
        (vproc (analyze (assignment-value exp))))
    (lambda (env)
      (set-variable-value! var (vproc env) env)
      'ok)))
(define (analyze-definition exp)
  (let ((var (definition-variable exp))
        (vproc (analyze (definition-value exp))))
    (lambda (env)
      (define-variable! var (vproc env) env)
      'ok)))

(define (analyze-if exp)
  (let ((pproc (analyze (if-predicate exp)))
        (cproc (analyze (if-consequent exp)))
        (aproc (analyze (if-alternative exp))))
    (lambda (env)
      (if (true? (pproc env))
          (cproc env)
          (aproc env)))))

(define (analyze-lambda exp)
  (let ((vars (lambda-parameters exp))
        (bproc (analyze-sequence (lambda-body exp))))
    (lambda (env) (make-procedure vars bproc env))))

(define (analyze-sequence exps)
  (define (sequentially proc1 proc2)
    (lambda (env) (proc1 env) (proc2 env)))
  (define (loop first-proc rest-procs)
    (if (null? rest-procs)
        first-proc
        (loop (sequentially first-proc (car rest-procs))
              (cdr rest-procs))))
  (let ((procs (map analyze exps)))
    (if (null? procs)
        (error "Empty sequence -- ANALYZE"))
    (loop (car procs) (cdr procs))))

(define (analyze-application exp)
  (let ((fproc (analyze (operator exp)))
        (aprocs (map analyze (operands exp))))
    (lambda (env)
      (execute-application (fproc env)
                           (map (lambda (aproc) (aproc env))
                                aprocs)))))
(define (execute-application proc args)
  (cond ((primitive-procedure? proc)
         (apply-primitive-procedure proc args))
        ((compound-procedure? proc)
         ((procedure-body proc)
          (extend-environment (procedure-parameters proc)
                              args
                              (procedure-environment proc))))
        (else
         (error
          "Unknown procedure type -- EXECUTE-APPLICATION"
          proc))))

; q4.22
(define (let? exp) (tagged-list? exp 'let))
(define (let-parameters exp)
  (map car (cadr exp)))
(define (let-real-parameters exp)
  (map cadr (cadr exp)))
(define (let-body exp) (cddr exp))
(define (let->combination exp)
 (let ((names (let-parameters exp))
       (values (let-real-parameters exp))
       (body (let-body exp)))
       (cons (make-lambda names body) values)))

(define (self-evaluating? exp)
 (cond ((number? exp) true)
       ((string? exp) true)
       (else false)))

(define (variable? exp) (symbol? exp))

; tagged-list
(define (tagged-list? exp tag)
 (if (pair? exp)
     (eq? (car exp) tag)
     false))

; quote
(define (quoted? exp)
 (tagged-list? exp 'quote))

(define (text-of-quotation exp) (cadr exp))


; assignment
(define (assignment? exp)
 (tagged-list? exp 'set!))

(define (assignment-variable exp) (cadr exp))
(define (assignment-value exp) (caddr exp))

; definition
(define (definition? exp)
 (tagged-list? exp 'define))

(define (definition-variable exp)
 (if (symbol? (cadr exp))
     (cadr exp)
     (caadr exp)))

(define (definition-value exp)
 (if (symbol? (cadr exp))
     (caddr exp)
     (make-lambda (cdadr exp)   ; 仮パラメタ
                  (cddr exp)))) ; 本体

; lambda
(define (lambda? exp) (tagged-list? exp 'lambda))
(define (lambda-parameters exp) (cadr exp))
(define (lambda-body exp) (cddr exp))

(define (make-lambda parameters body)
 (cons 'lambda (cons parameters body)))

; if
(define (if? exp) (tagged-list? exp 'if))
(define (if-predicate exp) (cadr exp))
(define (if-consequent exp) (caddr exp))
(define (if-alternative exp)
 (if (not (null? (cdddr exp)))
     (cadddr exp)
     'false))

(define (make-if predicate consequent alternative)
 (list 'if predicate consequent alternative))

; begin
(define (begin? exp) (tagged-list? exp 'begin))
(define (begin-actions exp) (cdr exp))
(define (last-exp? seq) (null? (cdr seq)))
(define (first-exp seq) (car seq))
(define (rest-exps seq) (cdr seq))
(define (sequence->exp seq)
 (cond ((null? seq) seq)
       ((last-exp? seq) (first-exp seq))
       (else (make-begin seq))))

(define (make-begin seq)
 (cons 'begin seq))

; 式
(define (application? exp) (pair? exp))
(define (operator exp) (car exp))
(define (operands  exp) (cdr exp))
(define (no-operands? ops) (null? ops))
(define (first-operand ops) (car ops))
(define (rest-operands ops) (cdr ops))

; cond
(define (cond? exp) (tagged-list? exp 'cond))
(define (cond-clauses exp) (cdr exp))
(define (cond-else-clause? clause)
 (eq? (cond-predicate clause) 'else))
(define (cond-actions clause) (cdr clause))
(define (cond->if exp)
 (expand-clauses (cond-clauses exp)))
(define (expand-clauses clauses)
 (if (null? clauses)
  'false
  (let ((first (car clauses))
        (rest (cdr clauses)))
   (if (cond-else-clause? first)
       (if (null? rest)
           (sequence->exp (cond-actions first))
           (error "ELSE clause isn't last -- COND->IF"
                  clauses))
       (make-if (cond-predicate first)
                (sequence->exp (cond-actions first))
                (expand-clauses rest))))))

; q4.26
; unless
; cond->if と同じように作ればよい & make-if のconsequent と alternative を逆にすればよい
(define (unless? exp) (tagged-list? exp 'unless))
(define (unless-clauses exp) (cdr exp))
(define (unless-predicate clause) (car clause))
(define (unless-consequent clause) (cadr clause))
(define (unless-alternative clauses)
  (let ((alternative-list (cddr clauses)))
    (if (null? alternative-list)
      'false                          ; else節なし
      (car alternative-list))))
(define (unless->if exp)
  (let ((clauses (unless-clauses exp)))
    (make-if (unless-predicate clauses)
             (unless-alternative clauses)
             (unless-consequent clauses))))

; procedure
(define primitive-procedures
 (list (list 'car car)
       (list 'cdr cdr)
       (list 'cons cons)
       (list 'null? null?)
       (list 'let let)
       (list 'list list)
       (list 'if if)
       (list 'print print)
       (list '+ +)
       (list '- -)
       (list '* *)
       (list '/ /)
       (list '= =)
 ))
(define (primitive-procedure? proc)
 (tagged-list? proc 'primitive))
(define (primitive-implementation proc) (cadr proc))
(define (primitive-procedure-names)
 (map car
  primitive-procedures))
(define (primitive-procedure-objects)
 (map (lambda (proc) (list 'primitive (cadr proc)))
  primitive-procedures))
(define apply-in-underlying-acheme apply)
(define (apply-primitive-procedure proc args)
 (apply-in-underlying-acheme
  (primitive-implementation proc) args))

(define (make-procedure parameters body env)
 (list 'procedure parameters body env))
(define (compound-procedure? p)
 (tagged-list? p 'procedure))
(define (procedure-parameters p) (cadr p))
(define (procedure-body p) (caddr p))
(define (procedure-environment p) (cadddr p))

; environment
(define (lookup-variable-value var env)
 (define (env-loop env)
  (define (scan vars vals)
   (cond ((null? vars)
          (env-loop (enclosing-environment env)))
    ((eq? var (car vars))
     (car vals))
    (else (scan (cdr vars) (cdr vals)))))
  (if (eq? env the-empty-environment)
     (error "Unbound variable" var)
     (let ((frame (first-frame env)))
      (scan (frame-variables frame)
            (frame-values frame)))))
  (env-loop env))
(define (extend-environment vars vals base-env)
 (if (= (length vars) (length vals))
     (cons (make-frame vars vals) base-env)
     (if (< (length vars) (length vals))
         (error "Too many arguments supplied" vars vals)
         (error "Too few arguments supplied" vars vals))))

(define (set-variable-value! var val env)
 (define (env-loop env)
  (define (scan vars vals)
   (cond ((null? vars)
          (env-loop (enclosing-environment env)))
         ((eq? var (car vars))
          (set-car! vals val))
         (else (scan (cdr vars) (cdr vals)))))
  (if (eq? env the-empty-environment)
   (error "Unbound variable -- SET!" var)
   (let ((frame (first-frame env)))
    (scan (frame-variables frame)
          (frame-values frame)))))
  (env-loop env))

(define (define-variable! var val env)
 (let ((frame (first-frame env)))
  (define (scan vars vals)
   (cond ((null? vars)
          (add-binding-to-frame! var val frame))
         ((eq? var (car vars))
          (set-car! vals val))
         (else (scan (cdr vars) (cdr vals)))))
  (scan (frame-variables frame)
        (frame-values frame))))

(define (enclosing-environment env) (cdr env))
(define (first-frame env) (car env))
(define the-empty-environment '())


(define (make-frame variables values)
 (cons variables values))

(define (frame-variables frame) (car frame))
(define (frame-values frame) (cdr frame))
(define (add-binding-to-frame! var val frame)
 (set-car! frame (cons var (car frame)))
 (set-cdr! frame (cons val (cdr frame))))

(define (setup-environment)
 (let ((initial-env
        (extend-environment (primitive-procedure-names)
                            (primitive-procedure-objects)
                            the-empty-environment)))
  (define-variable! 'true true initial-env)
  (define-variable! 'false false initial-env)
  initial-env))



(define (list-of-values exps env)
 (if (no-operands? exps)
     '()
     (cons (eval (first-operand exps) env)
           (list-of-values (rest-operands exps) env))))


(define (eval-if exp env)
  (if (true? (actual-value (if-predicate exp) env))
    (eval (if-consequent exp) env)
    (eval (if-alternative exp) env)))


(define (eval-sequence exps env)
 (cond ((last-exp? exps) (eval (first-exp exps) env))
       (else (eval (first-exp exps) env)
             (eval-sequence (rest-exps exps) env))))


(define (eval-assignment exp env)
 (set-variable-value! (assignment-variable exp)
                      (eval (assignment-value exp) env)
                      env)
 'ok)


(define (eval-definition exp env)
 (define-variable! (definition-variable exp)
                   (eval (definition-value exp) env)
                   env)
 'ok)

; apply
(define (my-apply procedure arguments env)
  (cond ((primitive-procedure? procedure)
         (apply-primitive-procedure
           procedure
           (list-of-arg-values arguments env)))  ; 変更した
        ((compound-procedure? procedure)
         (eval-sequence
           (procedure-body procedure)
           (extend-environment
             (procedure-parameters procedure)
             (list-of-delayed-args arguments env) ; 変更した
             (procedure-environment procedure))))
        (else
          (error
            "Unknown procedure type -- APPLY" procedure))))

(define (list-of-arg-values exps env)
  (if (no-operands? exps)
    '()
    (cons (actual-value (first-operand exps) env)
          (list-of-arg-values (rest-operands exps)
                              env))))

(define (list-of-delayed-args exps env)
  (if (no-operands? exps)
    '()
    (cons (delay-it (first-operand exps) env)
          (list-of-delayed-args (rest-operands exps)
                                env))))
