; originally from https://gist.github.com/mururu/a27918cb98cbbe213dca
(use srfi-27)
(define false #f)
(define true #t)

(define (true? x)
 (not (eq? x false)))
(define (false? x)
 (eq? x false))


; eval
(define (eval exp env)
  ((analyze exp) env))

(define (ambeval exp env succeed fail)
  ((analyze exp) env succeed fail))

(define (analyze exp)
  (cond ((self-evaluating? exp) 
         (analyze-self-evaluating exp))
        ((quoted? exp) (analyze-quoted exp))
        ((variable? exp) (analyze-variable exp))
        ((assignment? exp) (analyze-assignment exp))
        ((definition? exp) (analyze-definition exp))
        ((if? exp) (analyze-if exp))
        ((lambda? exp) (analyze-lambda exp))
        ((let? exp) (analyze (let->combination exp)))
        ((begin? exp) (analyze-sequence (begin-actions exp)))
        ((cond? exp) (analyze (cond->if exp)))
        ((unless? exp) (analyze (unless->if exp)))            ; q4.26
        ((amb? exp) (analyze-amb exp))                        ; p.255
        ((ramb? exp) (analyze-ramb exp))                      ; q4.50
        ((permanent-set!? exp) (analyze-permanent-set! exp))  ; q4.51
        ((application? exp) (analyze-application exp))
        (else
         (error "Unknown expression type -- ANALYZE" exp))))

(define (analyze-self-evaluating exp)
  (lambda (env succeed fail)
    (succeed exp fail)))

(define (analyze-quoted exp)
  (let ((qval (text-of-quotation exp)))
    (lambda (env succeed fail)
      (succeed qval fail))))

(define (analyze-variable exp)
  (lambda (env succeed fail)
    (succeed (lookup-variable-value exp env)
             fail)))

(define (analyze-assignment exp)
  (let ((var (assignment-variable exp))
        (vproc (analyze (assignment-value exp))))
    (lambda (env succeed fail)
      (vproc env
             (lambda (val fail2)
               (let ((old-value
                       (lookup-variable-value var env)))
                 (set-variable-value! var val env)
                 (succeed 'ok
                          (lambda ()
                            (set-variable-value! var
                                                 old-value
                                                 env)
                            (fail2)))))
             fail))))

; q4.51
; 失敗継続は, 失敗を継続する前に, 変数を昔の値に戻す. つまり成功する代入は, 後の失敗を横取りする失敗継続を準備する; 失敗が何を呼び出しても, fail2はその代りにこの手続きを呼び出し, 実際にfail2を呼び出す前に, 代入を戻す.
; の代入を戻さないバージョンを作れば良い
; 単純にold-valueの処理部分を消す
(define (analyze-permanent-set! exp)
  (let ((var (assignment-variable exp))
        (vproc (analyze (assignment-value exp))))
    (lambda (env succeed fail)
      (vproc env
             (lambda (val fail2)
                 (set-variable-value! var val env)
                 (succeed 'ok fail2))
             fail))))

(define (analyze-definition exp)
  (let ((var (definition-variable exp))
        (vproc (analyze (definition-value exp))))
    (lambda (env succeed fail)
      (vproc env
             (lambda (val fail2)
               (define-variable! var val env)
               (succeed 'ok fail2))
             fail))))

(define (analyze-if exp)
  (let ((pproc (analyze (if-predicate exp)))
        (cproc (analyze (if-consequent exp)))
        (aproc (analyze (if-alternative exp))))
    (lambda (env succeed fail)
      (pproc env
             (lambda (pred-value fail2)
               (if (true? pred-value)
                 (cproc env succeed fail2)
                 (aproc env succeed fail2)))
             fail))))

(define (analyze-lambda exp)
  (let ((vars (lambda-parameters exp))
        (bproc (analyze-sequence (lambda-body exp))))
    (lambda (env succeed fail)
      (succeed (make-procedure vars bproc env)
               fail))))

(define (analyze-sequence exps)
  (define (sequentially a b)
    (lambda (env succeed fail)
      (a env
         (lambda (a-value fail2)
           (b env succeed fail2))
         fail)))
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
  (let ((pproc (analyze (operator exp)))
        (aprocs (map analyze (operands exp))))
    (lambda (env succeed fail)
      (pproc env
             (lambda (proc fail2)
               (get-args aprocs
                         env
                         (lambda (args fail3)
                           (execute-application
                             proc args succeed fail3))
                         fail2))
             fail))))

(define (analyze-amb exp)
  (let ((cprocs (map analyze (amb-choices exp))))
    (lambda (env succeed fail)
      (define (try-next choices)
        (if (null? choices)
          (fail)
          ((car choices) env
                         succeed
                         (lambda ()
                           (try-next (cdr choices))))))
      (try-next cprocs))))

; q4.50
(define (analyze-ramb exp)
  (let ((cprocs (map analyze (ramb-choices exp))))
    (lambda (env succeed fail)
      (define (try-next choices)
        (if (null? choices)
          (fail)
          ((car choices) env
                         succeed
                         (lambda ()
                           (try-next (cdr choices))))))
      (try-next cprocs))))

(define (get-args aprocs env succeed fail)
  (if (null? aprocs)
    (succeed '() fail)
    ((car aprocs) env
                  (lambda (arg fail2)
                    (get-args (cdr aprocs)
                              env
                              (lambda (args fail3)
                                (succeed (cons arg args)
                                         fail3))
                              fail2))
                  fail)))

(define (execute-application proc args succeed fail)
  (cond ((primitive-procedure? proc)
         (succeed (apply-primitive-procedure proc args)
                  fail))
        ((compound-procedure? proc)
         ((procedure-body proc)
          (extend-environment (procedure-parameters proc)
                              args
                              (procedure-environment proc))
          succeed
          fail))
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
(define (cond-predicate clause) (car clause))
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

; p.255
; amb
(define (amb? exp) (tagged-list? exp 'amb))
(define (amb-choices exp) (cdr exp))

; q4.50
; ambの場合、たとえば
; exp が (amb 1 2 3)
; だと(cdr exp)で(1 2 3)が返るようになっている
; そのリストに対してその後の処理が左から処理される
;
; ので、
; (3 1 2)
; のようにシャッフルした状態で返せば良さそう
; (use gauche.sequence) の shuffle にしてみたけどparseを呼ぶと応答がないので自分でshuffleする
; => でも上手くいかない
; printすると動く（bufferされてるとか？）
(define (ramb? exp) (tagged-list? exp 'ramb))
(define (ramb-choices exp) (shuffle (cdr exp)))
(define (ramb-choices exp)
  ;(print (shuffle (cdr exp)))
  (shuffle (cdr exp)))
(define (shuffle list)
  (define (create-list created-list source)
    (if (null? source)
      created-list
      (let ((chosen (list-ref source (random-integer (length source)))))
        (create-list (cons chosen created-list) (remove (lambda (e) (eq? e chosen)) source)))))
  (create-list '() list))

; q4.51
(define (permanent-set!? exp) (tagged-list? exp 'permanent-set!))

; procedure
(define primitive-procedures
 (list (list 'car car)
       (list 'cdr cdr)
       (list 'cons cons)
       (list 'null? null?)
       (list 'let let)
       (list 'list list)
       (list 'if if)
       (list 'not not)
       (list 'print print)
       (list '+ +)
       (list '- -)
       (list '* *)
       (list '/ /)
       (list '= =)
       (list '< <)
       (list '> >)
       (list 'eq? eq?)
       (list 'equal? equal?)
       (list 'abs abs)
       (list 'random-integer random-integer)
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
 (if (true? (eval (if-predicate exp) env))
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
(define (my-apply procedure arguments)
 (cond ((primitive-procedure? procedure)
        (apply-primitive-procedure procedure arguments))
       ((compound-procedure? procedure)
        (eval-sequence
          (procedure-body procedure)
          (extend-environment
            (procedure-parameters procedure)
            arguments
            (procedure-environment procedure))))
       (else
        (error
         "Unknown procedure type -- APPLY" procedure))))
