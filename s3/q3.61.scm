; Xは定数項が1で、高次の項は「SRかけるX」の符号を変えたもの
; SRはSのstream-cdrで表現できるので「SRかけるX」は(mul-series (stream-cdr s) x)
; 符号を変えるためにはすべての項に-1を掛ければ良い
; また、Xを求める手続きをinvert-unit-seriesとするのでXは(invert-unit-series s)と書ける

(define (invert-unit-series s)
  (cons-stream 1
               (scale-stream (mul-series (stream-cdr s) (invert-unit-series s)) -1)))
