(define (require p)
  (if (not p) (amb)))

(define (an-element-of items)
  (require (not (null? items)))
  (amb (car items) (an-element-of (cdr items))))

(define (even? n)
  (= (remainder n 2) 0))

; 利用者に式の失敗を捕らえることが出来るif-failという新しい構造を実装せよ. if-failは二つの式をとる. 第一の式を通常に評価し, 評価が成功すれば通常に戻る. しかし評価が失敗すれば, 次の例のように第二の式が戻される:
; ;;; Amb-Eval input:
; (if-fail (let ((x (an-element-of '(1 3 5))))
;            (require (even? x))
;            x)
;          'all-odd)
; ;;; Starting a new problem
; ;;; Amb-Eval value:
; all-odd
; 
; ;;; Amb-Eval input:
; (if-fail (let ((x (an-element-of '(1 3 5 8))))
;            (require (even? x))
;            x)
;          'all-odd)
; ;;; Starting a new problem
; ;;; Amb-Eval value:
; 8

