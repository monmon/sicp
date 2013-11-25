; s1とs2があったとき div-series は s1/s2 のようになれば良い
; つまり s1 * 1/s2 で表現できる
;
; 1/s2について考える
; q3.61を元にすると、Nが0でないとき
; s2/N * N/s2 = 1
; となる
; s2/Nのinvert-unit-seriesがN/s2なので、
; さらにそこから1/Nすれば1/s2を求められる
; Nはs2の先頭なので (stream-car s2) である

(load "./q3.60.scm")
(load "./q3.61.scm")

(define (div-series s1 s2)
  (define n (stream-car s2))
  (if (= n 0)
    (error "0 dame!"))
  (let ((reciprocal-of-n (/ 1 n)))
    (mul-series s1
                (scale-stream (invert-unit-series (scale-stream s2 reciprocal-of-n)) reciprocal-of-n))))

(load "./q3.54.scm")
; tanはsin/cosなので
(print (take (x-stream 2) 10))
(define tangent-series (div-series sine-series cosine-series))
(print (stream-ref (partial-sums (mul-streams tangent-series (x-stream 3.14))) 100))
(print (stream-ref (partial-sums (mul-streams tangent-series (x-stream 6.28))) 100))

(define (apply-series s x)
  (partial-sums (mul-streams s (x-stream x))))

(print (take (apply-series sine-series 3.14) 20))
(print (take (apply-series cosine-series 3.14) 20))
(print (take (apply-series tangent-series 3.14) 20))
