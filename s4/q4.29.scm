; メモ化されない場合には q4.25.scm の置換えで見た部分の引数の所で何度も同じ処理をすることになる
; つまり、引数が何度も出てくるような手続きの場合にはメモ化しないと処理が遅くなる
;
; q4.25.scm の以下の例だと (- 5 1) の処理部分
; ; 引数を評価する前に unless の置換え
; (* 5 (if (= (- 5 1) 1)
;        1
;        (* (- 5 1) (factorial (- (- 5 1) 1)))))


; q4.25.scmの例の改（そのままだと答えが長くなるので割り算して 1 になるようにしてある）
(define (factorial-div n)
  (if (= n 1)
    1
    (/ (* n (factorial-div (- n 1))) (* n (factorial-div (- n 1))))))

; 以下のようにして調べる
            (time (actual-value input the-global-environment))

; メモ化なし
(factorial-div 15)
;(time (actual-value input the-global-environment))
; real   3.390
; user   3.360
; sys    0.000

; メモ化あり
(factorial-div 15)
;(time (actual-value input the-global-environment))
; real   0.591
; user   0.580
; sys    0.000


; （例2）引数を多く使えばいいのでこんな感じでいける
(define (fn n)
  (+ n n n n n n n n))

;;; L-Eval input:
(fn (fn (fn (fn (fn (fn (fn 1)))))))
;(time (actual-value input the-global-environment))
; real   4.990
; user   4.980
; sys    0.000

;;; L-Eval input:
(fn (fn (fn (fn (fn (fn (fn 1)))))))
;(time (actual-value input the-global-environment))
; real   0.000
; user   0.000
; sys    0.000

;=========================================================================================================

; メモ化なし

;;; L-Eval input:
(define count 0)

(define (id x)
  (set! count (+ count 1))
  x)
;;; L-Eval value:
ok

;;; L-Eval input:
(define (square x)
  (* x x))
;;; L-Eval value:
ok

;;; L-Eval input:
(square (id 10))

;;; L-Eval value:
ok

;;; L-Eval input:

;;; L-Eval value:
100

;;; L-Eval input:
count

;;; L-Eval value:
2

; メモ化あり

;;; L-Eval input:
(define count 0)

(define (id x)
  (set! count (+ count 1))
  x)
;;; L-Eval value:
ok

;;; L-Eval input:
(define (square x)
  (* x x))
;;; L-Eval value:
ok

;;; L-Eval input:
(square (id 10))

;;; L-Eval value:
ok

;;; L-Eval input:

;;; L-Eval value:
100

;;; L-Eval input:
count

;;; L-Eval value:
1


; 2つのcountが異なるのはsquare処理時に
(* (id 10) (id 10))
; =>
(*
  (begin
    (set! count (+ count 1))
    10)
  (begin
    (set! count (+ count 1))
    10))

; この後に
; - メモ化してない場合 (+ count 1) が2回処理されて2になる
; - メモ化してある場合 (+ count 1) が一度だけ処理されて1になる
; ため
