;;;; L-Eval input:
;(define count 0)
;
;(define (id x)
;  (set! count (+ count 1))
;  x)
;;;; L-Eval value:
;ok
;
;;;; L-Eval input:
;(define w (id (id 10)))
;
;;;; L-Eval value:
;ok
;
;;;; L-Eval input:
;
;;;; L-Eval value:
;ok
;
;;;; L-Eval input:
;count
;
;;;; L-Eval value:
;1
;
;;;; L-Eval input:
;w
;
;;;; L-Eval value:
;10
;
;;;; L-Eval input:
;count
;
;;;; L-Eval value:
;2

; 初めに外側のidが評価され、wを評価した時点で内側のidが評価される
; (define w (id (id 10))) 時に (id (id 10)) が評価された値が w となる
; このとき id は合成手続きなので (id 10) は評価されず遅延する

(begin
  (set! count (+ count 1))
  (id 10))                    ; 実際には (id 10) は評価されず thunk 化されたものが返る

; この時点で count が 1 となる

; 次に w を評価すると遅延していた (id 10) が評価されるため
; w の結果は 10 count はさらに 1 足されて 2 となる
