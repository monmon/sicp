(load "./simulator.scm")
; a.
;
; 図5.12 のコメントの通り、 afterfib-n-2 は
;
;       afterfib-n-2                         ; 戻った時Fib(n-2)の値はvalにある
;       (assign n (reg val))               ; nにはFib(n-2)がある
;       (restore val)                      ; valにはFib(n-1)がある
;
; なので、
;
; val <- Fib(n-2) ; 元から入っている
; n <- val
;   <- Fib(n-2)   ; val の値を n へ
; val <- Fib(n-1) ; stack していた val の取り出し
; val <- val + n
;     <- Fib(n-1) + Fib(n-2)
;
; という流れになっている
;
; 「stack に積んだ val の値を val が取り出さなくても良い」という動きが現在の振る舞いなので、
;
; val <- Fib(n-2) ; 元から入っている
; n <- Fib(n-1) ; stack していた val の取り出し
; val <- val + n
;     <- Fib(n-2) + Fib(n-1)
;
; のように変えてしまえば良い
; つまり
;
;       afterfib-n-2                         ; 戻った時Fib(n-2)の値はvalにある
;       (restore n)                          ; nにはFib(n-1)がある
;
; とする

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
(print (get-register-contents fib-machine 'val)) ;=> 2
