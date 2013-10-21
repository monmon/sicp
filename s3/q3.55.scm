; p.195の一番上の式を書くと
;
; S0    S1       S2          S3 ... = s
;       S0    S0+S1    S0+S1+S2 ... = partial-sums
; ------------------------------------------------
; S0 S0+S1 S0+S1+S2 S0+S1+S2+S3 ... = partial-sums
;
; なので、
; 初めがsの先頭 (stream-car s)
; で、
; 以降の (stream-cdr s) に (partial-sums s) を足す

(define (partial-sums s)
  (cons-stream (stream-car s)
               (add-streams
                 (stream-cdr s)
                 (partial-sums s))))
