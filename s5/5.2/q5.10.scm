; 5.2.3の始めに
; > レジスタ計算機の式の細い構文を一般の実行機構から分離するため, データ抽象を使い構文手続きで命令の部分を取り出し, 分類する
; とあるので、
; 例えばhogeみたいなのが作りたければmake-hogeを作り、'hogeで取り出してmake-hogeに与えればできる

; e.g. stack されている値をリストごとレジスタに入れる fetch-stack-list という命令を作る
(load "./simulator.scm")
(define (make-execution-procedure inst labels machine
                                  pc flag stack ops)
  (cond ((eq? (car inst) 'assign)
         (make-assign inst machine labels ops pc))
        ((eq? (car inst) 'test)
         (make-test inst machine labels ops flag pc))
        ((eq? (car inst) 'branch)
         (make-branch inst machine labels flag pc))
        ((eq? (car inst) 'goto)
         (make-goto inst machine labels pc))
        ((eq? (car inst) 'save)
         (make-save inst machine stack pc))
        ((eq? (car inst) 'restore)
         (make-restore inst machine stack pc))
        ((eq? (car inst) 'fetch-stack-list)
         (make-fetch-stack-list inst machine stack pc))
        ((eq? (car inst) 'perform)
         (make-perform inst machine labels ops pc))
        (else (error "Unknown instruction type -- ASSEMBLE"
                     inst))))

(define (make-fetch-stack-list inst machine stack pc)
  (let ((reg (get-register machine
                           (stack-inst-reg-name inst))))
    (lambda ()
      (set-contents! reg (stack 'get-list))
      (advance-pc pc))))

; 元の機能に影響しない物なら上記で終了だが、
; 今回はstackの中身を取得しなくてはいけないので make-stack に
; stack一覧を取得できるためのget-list という機能を足す
(define (make-stack)
  (let ((s '()))
    (define (push x)
      (set! s (cons x s)))
    (define (pop)
      (if (null? s)
        (error "Empty stack -- POP")
        (let ((top (car s)))
          (set! s (cdr s))
          top)))
    (define (initialize)
      (set! s '())
      'done)
    (define (dispatch message)
      (cond ((eq? message 'push) push)
            ((eq? message 'pop) (pop))
            ((eq? message 'initialize) (initialize))
            ((eq? message 'get-list) s)                  ; 足すのはここだけ
            (else (error "Unknown request -- STACK"
                         message))))
    dispatch))

; ===============================================================
(define fetch-stack-list-machine
  (make-machine
    '(x stack-list)
    '()
    '(start
       (assign x (const 1))
       (save x)
       (assign x (const 5))
       (save x)
       (assign x (const 10))
       (save x)
       (assign x (const 50))
       (save x)
       (fetch-stack-list stack-list))))

(start fetch-stack-list-machine)
(print (get-register-contents fetch-stack-list-machine 'stack-list)) ;=> (50 10 5 1)
