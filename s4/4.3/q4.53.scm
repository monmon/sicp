; from q2.40 s4.3
(define (square x) (* x x))
(define (divides? a b)
  (= (remainder b a) 0))
(define (smallest-divisor n)
  (find-divisor n 2))

(define (find-divisor n  test-divisor)
  (cond ((> (square test-divisor) n) n)
        ((divides? test-divisor n) test-divisor)
        (else (find-divisor n (+ test-divisor 1)))))
(define (prime? n)
  (= n (smallest-divisor n)))

(define (require p)
  (if (not p) (amb)))

(define (an-element-of items)
  (require (not (null? items)))
  (amb (car items) (an-element-of (cdr items))))

(define (prime-sum-pair list1 list2)
  (let ((a (an-element-of list1))
        (b (an-element-of list2)))
    (require (prime? (+ a b)))
    (list a b)))

; 問題
(let ((pairs '()))
  (if-fail (let ((p (prime-sum-pair '(1 3 5 8) '(20 35 110))))
             (permanent-set! pairs (cons p pairs))
             (amb))
           pairs))

; prime-sum-pair の pair が p で、
; p が作られるたびに pairs '() に追加されていく
; prime-sum-pair の結果の pair が全て終わると第二の式に行くため pairs が出力される
; set! を使ってしまうと失敗の度に元に戻ってしまうため pairs を出力しても空になってしまう

; 結果
; ;;; Starting a new problem
; ;;; Amb-Eval value:
; ((8 35) (3 110) (3 20))
;
; ;;; Amb-Eval input:
; try-again
;
; ;;; There are no more values of
; (let ((pairs '())) (if-fail (let ((p (prime-sum-pair '(1 3 5 8) '(20 35 110)))) (permanent-set! pairs (cons p pairs)) (amb)) pairs))
