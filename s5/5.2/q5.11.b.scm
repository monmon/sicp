(load "./simulator.scm")
; stack に積む時にreg-nameの情報を付加して積み、取り出す時にreg-nameが正しいかをチェックすれば良い

(define (make-save inst machine stack pc)
  (let ((reg-name (stack-inst-reg-name inst)))
    (let ((reg (get-register machine reg-name)))
      (lambda ()
        (push stack (cons reg-name (get-contents reg))) ; e.g. reg-name = n, contents = 2 => (n . 2)
        (advance-pc pc)))))

(define (make-restore inst machine stack pc)
  (let ((reg-name (stack-inst-reg-name inst)))
    (let ((reg (get-register machine reg-name)))
      (lambda ()
        (let ((poped (pop stack)))          ; e.g. poped = (n . 2)
          (let ((poped-reg-name (car poped))      ; reg-name = n
                (poped-contents (cdr poped)))     ; contents = 2
            (if (eq? poped-reg-name reg-name)
              (begin
                (set-contents! reg poped-contents)
                (advance-pc pc))
              (error "stacked reg-name is different --" poped-reg-name reg-name))))))))

; 元々のfibは通る
(define fib-machine
  (make-machine
    '(continue n val)
    (list (list '< <) (list '- -) (list '+ +))
    '(start
       (assign continue (label fib-done))
       fib-loop
       (test (op <) (reg n) (const 2))
       (branch (label immediate-answer))
       ;; Fib(n-1)を計算するよう設定
       (save continue)
       (assign continue (label afterfib-n-1))
       (save n)                           ; nの昔の値を退避
       (assign n (op -) (reg n) (const 1)); nを n-1 に変える
       (goto (label fib-loop))            ; 再帰呼出しを実行
       afterfib-n-1                         ; 戻った時 Fib(n-1)はvalにある
       (restore n)
       (restore continue)
       ;; Fib(n-2)を計算するよう設定
       (assign n (op -) (reg n) (const 2))
       (save continue)
       (assign continue (label afterfib-n-2))
       (save val)                         ; Fib(n-1)を退避
       (goto (label fib-loop))
       afterfib-n-2                         ; 戻った時Fib(n-2)の値はvalにある
       (assign n (reg val))               ; nにはFib(n-2)がある
       (restore val)                      ; valにはFib(n-1)がある
       (restore continue)
       (assign val                        ; Fib(n-1)+Fib(n-2)
               (op +) (reg val) (reg n))
       (goto (reg continue))              ; 呼出し側に戻る. 答えはvalにある
       immediate-answer
       (assign val (reg n))               ; 基底の場合: Fib(n)=n
       (goto (reg continue))
       fib-done)))

(set-register-contents! fib-machine 'n 3)
(start fib-machine)
(print (get-register-contents fib-machine 'val)) ;=> 2

; a. のfibはエラーになる
(define fib-machine
  (make-machine
    '(continue n val)
    (list (list '< <) (list '- -) (list '+ +))
    '(start
       (assign continue (label fib-done))
       fib-loop
       (test (op <) (reg n) (const 2))
       (branch (label immediate-answer))
       ;; Fib(n-1)を計算するよう設定
       (save continue)
       (assign continue (label afterfib-n-1))
       (save n)                           ; nの昔の値を退避
       (assign n (op -) (reg n) (const 1)); nを n-1 に変える
       (goto (label fib-loop))            ; 再帰呼出しを実行
       afterfib-n-1                         ; 戻った時 Fib(n-1)はvalにある
       (restore n)
       (restore continue)
       ;; Fib(n-2)を計算するよう設定
       (assign n (op -) (reg n) (const 2))
       (save continue)
       (assign continue (label afterfib-n-2))
       (save val)                         ; Fib(n-1)を退避
       (goto (label fib-loop))
       afterfib-n-2                         ; 戻った時Fib(n-2)の値はvalにある
       (restore n)                          ; nにはFib(n-1)がある
       (restore continue)
       (assign val                        ; Fib(n-1)+Fib(n-2)
               (op +) (reg val) (reg n))
       (goto (reg continue))              ; 呼出し側に戻る. 答えはvalにある
       immediate-answer
       (assign val (reg n))               ; 基底の場合: Fib(n)=n
       (goto (reg continue))
       fib-done)))

(set-register-contents! fib-machine 'n 3)
(start fib-machine)
(print (get-register-contents fib-machine 'val)) ;=> "error": stacked reg-name is different -- val n
