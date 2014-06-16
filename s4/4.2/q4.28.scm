; 問題は

        ((application? exp)
         (my-apply (actual-value (operator exp) env)
                   (operands exp)
                   env))

; を

        ((application? exp)
         (my-apply (eval (operator exp) env)
                   (operands exp)
                   env))

; のように変更するということ

; actual-value は eval したものを force-it の引数にする

(define (actual-value exp env)
  (force-it (eval exp env)))

; なので force-it の実装を確認

(define (force-it obj)
  (if (thunk? obj)
    (actual-value (thunk-exp obj) (thunk-env obj))
    obj))

; thunk? が偽の場合には obj を返すので eval と同じ
; ということで thunk? が真のときを考えればよい

; thunk? が真のときはすでに 'thunk を付ける処理をされている場合なので
; 一度 thunk 処理をされたものを再度処理されるようなものを考えれば良い
; つまり、手続きを定義した後に再度その手続きを渡すようなものを作る


; actual-value

;;; L-Eval input:
(define (inc x) (+ x 1))

;;; L-Eval value:
ok

;;; L-Eval input:
(define (hoge fn) (fn 1))

;;; L-Eval value:
ok

;;; L-Eval input:
(hoge inc)

;;; L-Eval value:
2


; eval

;;; L-Eval input:
(define (inc x) (+ x 1))

;;; L-Eval value:
ok

;;; L-Eval input:
(define (hoge fn) (fn 1))

;;; L-Eval value:
ok

;;; L-Eval input:
(hoge inc)
gosh: "error": Unknown procedure type -- APPLY (thunk inc #0=(((inc hoge false true car cdr cons null? let list if print + - * / =) (procedure (x) ((+ x 1)) #0#) (procedure (fn) ((fn 1)) #0#) #f #t (primitive #<subr car>) (primitive #<subr cdr>) (primitive #<subr cons>) (primitive #<subr null?>) (primitive #<syntax let>) (primitive #<subr list>) (primitive #<syntax if>) (primitive #<closure print>) (primitive #<subr +>) (primitive #<subr ->) (primitive #<subr *>) (primitive #<subr />) (primitive #<subr =>))))
hell returned 1
