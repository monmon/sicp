(define (expand num den radix)
  (cons-stream
    (quotient (* num radix) den)
    (expand (remainder (* num radix) den) den radix)))

(expand 1 7 10)
; (quotient (* num radix) den) : 1
; (remainder (* num radix) den) : 3
;
; (expand 3 7 10)
; (quotient (* num radix) den) : 4
; (remainder (* num radix) den) : 2
;
; (expand 2 7 10)
; (quotient (* num radix) den) : 2
; (remainder (* num radix) den) : 6
;
; (expand 6 7 10)
; (quotient (* num radix) den) : 8
; (remainder (* num radix) den) : 4
;
; (expand 4 7 10)
; (quotient (* num radix) den) : 5
; (remainder (* num radix) den) : 5
;
; (expand 5 7 10)
; (quotient (* num radix) den) : 7
; (remainder (* num radix) den) : 1
;
; となるので、
; (1 4 2 8 5 7 1 ...)

(expand 3 8 10)
; (quotient (* num radix) den) : 3
; (remainder (* num radix) den) : 6
;
; (expand 6 8 10)
; (quotient (* num radix) den) : 7
; (remainder (* num radix) den) : 4
;
; (expand 4 8 10)
; (quotient (* num radix) den) : 5
; (remainder (* num radix) den) : 0
;
; (expand 0 8 10)
; (quotient (* num radix) den) : 0
; (remainder (* num radix) den) : 8
;
; (expand 0 8 10)
; (quotient (* num radix) den) : 0
; (remainder (* num radix) den) : 0
;
; となるので、
; (3 7 5 0 ...)
;
; どちらも「余りの数に10かけて割っている」ので小数を含めた割り算の商の列になる
