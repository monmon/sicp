(define (require p)
  (if (not p) (amb)))

(define (an-integer-starting-from n)
  (amb n (an-integer-starting-from (+ n 1))))


; 以下のように変えても動かないよという話らしい
; (define (a-pythagorean-triple low)
;   (let ((i (an-integer-starting-from low)))
;     (let ((j (an-integer-starting-from i)))
;       (let ((k (an-integer-starting-from j)))
;         (require (= (+ (* i i) (* j j)) (* k k)))
;         (list i j k)))))

; これは
; (a-pythagorean-triple-between 1)
; としたときに、初めに
; i = 1
; j = 1
; k = 1
; となり、
; その後はkが増えていくため

(define (an-integer-between low high)
  (require (<= low high))
  (amb low (an-integer-between (+ low 1) high)))

(define (a low upper)
  (let ((i (an-integer-starting-from low)))
        (print i)
        i))

(define (a-pythagorean-triple low upper)
        (print i)
  (let ((i (an-integer-starting-from low)))
        (print i)
    (require (<= i n))
        (print i)
    (let ((j (an-integer-between i upper)))
      (let ((k (an-integer-between j upper)))
        (print i j k)
        (require (<= k upper)
        (require (<= k (+ i J)))
        (require (= (+ (* i i) (* j j)) (* k k)))
        (list i j k)))))

1 1 1
1 1 2

1 2 2
1 2 3

1 3 3
1 3 4

1 4 4
1 4 5
