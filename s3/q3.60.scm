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
; ...
; ---------------------------------------------------
; a0*b0 a0*b1+b0*a1 a0*b2+a1*b1+a2*b0
;
; ということで全部足せば良い
; 「1つずらしたmul-series」をstreamでそのまま足すと2行目の b0*a1 と3行目の a1*b1 が足されてしまうため
; 「先頭が0のstream」と考えれば良い

(define (mul-series s1 s2)
  (cons-stream (* (stream-car s1) (stream-car s2))
               (add-streams (scale-stream (stream-cdr s2) (stream-car s1))
                            (add-streams (scale-stream (stream-cdr s1) (stream-car s2))
                                         (cons-stream 0 (mul-series (stream-cdr s1) (stream-cdr s2)))))))


; sin^2 + cos^2 = 1 試したいけどsin-seriesのdefineでcosine-series使ってるために
; gosh: "error": unbound variable: cosine-series
; のエラーになって辛い

(load "./q3.59.scm")

(print (add-streams
         (mul-series sine-series sine-series)
         (mul-series cosine-series cosine-series)))
