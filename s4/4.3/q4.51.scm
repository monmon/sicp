; ambeval.scm に追加

(define (require p)
  (if (not p) (amb)))

(define (an-element-of items)
  (require (not (null? items)))
  (amb (car items) (an-element-of (cdr items))))

; 結果
;;;; Amb-Eval input:
;(define count 0)
;
;(let ((x (an-element-of '(a b c)))
;      (y (an-element-of '(a b c))))
;  (permanent-set! count (+ count 1))
;  (require (not (eq? x y)))
;  (list x y count))
;;;; Starting a new problem
;;;; Amb-Eval value:
;ok
;
;;;; Amb-Eval input:
;
;
;;;; Starting a new problem
;;;; Amb-Eval value:
;(a b 2)
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;(a c 3)
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;(b a 4)

; set!を使った場合はどうなるか
; old-valueで元の値に戻されるので常に1
;
;(define count 0)
;
;(let ((x (an-element-of '(a b c)))
;      (y (an-element-of '(a b c))))
;  (set! count (+ count 1))
;  (require (not (eq? x y)))
;  (list x y count))
;
;;;; Amb-Eval input:
;
;;;; Starting a new problem
;;;; Amb-Eval value:
;(a b 1)
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;(a c 1)
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;(b a 1)
