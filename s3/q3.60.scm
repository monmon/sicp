; 前回の夜に布団で上手くいきそうな案浮かんだ。素晴らしい
; https://twitter.com/lesamoureuses/status/392318309162422272
;
; 先頭は a0 * b0 なので (* (stream-car s1) (stream-car s2)) で表現できる
; その先を考える
;
; 今回もP.195の一番上のfibsと同様に書くと
;       a0*b1       a0*b2               a0*b3           a0*b4                 = (scale-stream (stream-cdr s2) a0) = (scale-stream (stream-cdr s2) (stream-car s1))
;       b0*a1       b0*a2               b0*a3           b0*a4                 = (scale-stream (stream-cdr s1) b0) = (scale-stream (stream-cdr s1) (stream-car s2))
;           0       a1*b1               a1*b2 + b1*a2   a1*b3 + a2*b2 + a3*b1 = 1つずらしたmul-series（streamの足し算を考えると先頭が0）
; ---------------------------------------------------
; a0*b0 a0*b1+b0*a1 a0*b2+a1*b1+a2*b0
;
; ということで全部足せば良い
; 「1つずらしたmul-series」をstreamでそのまま足すと2行目の b0*a1 と3行目の a1*b1 が足されてしまうため
; 「先頭が0のstream」と考えれば良い

(load "./s3.5.1-stream.scm")

(define (scale-stream stream factor)
  (stream-map (lambda (x) (* x factor)) stream)) ; q.195

(define (take s x)
  (cond ((stream-null? s) '())
        ((= x 0) '())
        (else (cons (stream-car s) (take (stream-cdr s) (- x 1))))))

(define (mul-series s1 s2)
  (cons-stream (* (stream-car s1) (stream-car s2))
               (add-streams (scale-stream (stream-cdr s2) (stream-car s1))
                            (add-streams (scale-stream (stream-cdr s1) (stream-car s2))
                                         (cons-stream 0 (mul-series (stream-cdr s1) (stream-cdr s2)))))))

;    a0 a1 a2 a3
; b0 x1 ________x2_
; b1
; b2
; b3
;
; 先頭がx1、stream-cdrがx2と残りの部分のadd-stremsのstreamになるので残りの部分が
;
;    a0 a1 a2 a3
; b1
; b2
; b3
;
; となり、(mul-series s1 (stream-cdr s2)))))
;
;(define (mul-series s1 s2)
;  (cons-stream (* (stream-car s1) (stream-car s2))
;               (add-streams (scale-stream (stream-cdr s1) (stream-car s2))
;                            (mul-series s1 (stream-cdr s2)))))

; sin^2 + cos^2 = 1 試したいけどsin-seriesのdefineでcosine-series使ってるために
; gosh: "error": unbound variable: cosine-series
; のエラーになって辛い

(load "./q3.59.scm")

;(print (stream-car (mul-series sine-series sine-series)))
;(1 x x^1 x^2 x^3 ..)

(define (x-stream x)
    (stream-map (lambda (n) (expt x n)) (cons-stream 0 integers)))

(print (take (x-stream 2) 5))

;(print (take sine-series 5))
;(define y (mul-series sine-series sine-series))
(print (take (add-streams
               (mul-series sine-series sine-series)
               (mul-series cosine-series cosine-series)) 10))
