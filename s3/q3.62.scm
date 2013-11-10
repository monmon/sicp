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

(define (div-series s1 s2)
  (define n (stream-car s2))
  (if (= n 0)
    (error "0 dame!"))
  (let ((reciprocal-of-n (/ 1 n)))
    (mul-series s1
                (scale-stream (invert-unit-series scale-stream s2 reciprocal-of-n) reciprocal-of-n))))

; tanはsin/cosなので
(define tangent-series (div-series sine-series cosine-series))
