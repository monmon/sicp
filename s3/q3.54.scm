; mul-streamsはadd-streamsと同様に
(define (mul-streams s1 s2)
  (stream-map * s1 s2))

; n番目の要素がn+1の階乗になるstreamは
; (1 1 2 6 24 120 ...)
; (1 1*1 2*1 3*2 4*6 5*24 ...)
; で、integersに1つ前の要素をかければよい
;
; P.195の一番上のfibsと同様に書くと
;   1 2 3  4   5 ... = integers
;   1 1 2  6  24 ... = factorials
; -------------------------------
; 1 1 2 6 24 120 ... = factorials
(define factorials (cons-stream 1
                                (mul-streams integers
                                             factorials)))
