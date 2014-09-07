(load "./simulator.scm")

; allocate-register するタイミングで register ごとの stack も作る
; ので、 allocate-register を allocate-register-and-stack という名前に変更

(define (make-machine register-names ops controller-text)
  (let ((machine (make-new-machine)))
    (for-each (lambda (register-name)
                ((machine 'allocate-register-and-stack) register-name))
              register-names)
    ((machine 'install-operations) ops)
    ((machine 'install-instruction-sequence)
     (assemble controller-text machine))
    machine))

; stack は (reg-name . stack) という対をリストにしたもので実装する
; ので、内部では stack-list という名前に変更
; initialize-stack はそのリスト全てに対し initialize すればよい
(define (make-new-machine)
  (let ((pc (make-register 'pc))
        (flag (make-register 'flag))
        (stack-list '())           ; このタイミングではregisterがまだないので作らない
        (the-instruction-sequence '()))
    (let ((the-ops
            (list (list 'initialize-stack
                        (lambda ()
                          (for-each (lambda (reg-name-to-stack) ((cdr reg-name-to-stack) 'initialize)) stack-list)))))
          (register-table
            (list (list 'pc pc) (list 'flag flag))))
      (define (allocate-register-and-stack name)
        (if (assoc name register-table)
          (error "Multiply defined register: " name)
          (begin
            (set! register-table
              (cons (list name (make-register name))
                    register-table))
            (set! stack-list (append stack-list
                                (list (cons name (make-stack))))))) ; e.g. (list (x . #<closure (make-stack dispatch)>) (y . #<closure (make-stack dispatch)>))
        'register-allocated)
      (define (lookup-register name)
        (let ((val (assoc name register-table)))
          (if val
            (cadr val)
            (error "Unknown register:" name))))
      (define (lookup-stack name)
        (let ((val (assoc name stack-list)))
          (if val
            (cdr val)
            (error "Unknown stack:" name))))
      (define (execute)
        (let ((insts (get-contents pc)))
          (if (null? insts)
            'done
            (begin
              ((instruction-execution-proc (car insts)))
              (execute)))))
      (define (dispatch message)
        (cond ((eq? message 'start)
               (set-contents! pc the-instruction-sequence)
               (execute))
              ((eq? message 'install-instruction-sequence)
               (lambda (seq) (set! the-instruction-sequence seq)))
              ((eq? message 'allocate-register-and-stack) allocate-register-and-stack)
              ((eq? message 'get-register) lookup-register)
              ((eq? message 'get-stack) lookup-stack)
              ((eq? message 'install-operations)
               (lambda (ops) (set! the-ops (append the-ops ops))))
              ((eq? message 'stack) stack-list)
              ((eq? message 'operations) the-ops)
              (else (error "Unknown request -- MACHINE" message))))
      dispatch)))

; その register 専用のstackを取り出し、push
(define (make-save inst machine stack pc)
  (define my-stack (get-stack machine (stack-inst-reg-name inst)))
  (let ((reg (get-register machine
                           (stack-inst-reg-name inst))))
    (lambda ()
      (push my-stack (get-contents reg))
      (advance-pc pc))))

; その register 専用のstackを取り出し、pop
(define (make-restore inst machine stack pc)
  (define my-stack (get-stack machine (stack-inst-reg-name inst)))
  (let ((reg (get-register machine
                           (stack-inst-reg-name inst))))
    (lambda ()
      (set-contents! reg (pop my-stack))
      (advance-pc pc))))

(define (get-stack machine reg-name)
  ((machine 'get-stack) reg-name))

; ===============================================================
(define 5.11-machine
  (make-machine
    '(x y)
    '()
    '(start
       (assign y (const 1))
       (assign x (const 10))
       (perform (op initialize-stack)) ; 初期化
       (save y)
       (save x)
       (restore y))))

(start 5.11-machine)
(print (get-register-contents 5.11-machine 'y)) ;=> 1
