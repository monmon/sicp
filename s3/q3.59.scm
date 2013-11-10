(load "./q3.51.scm")

; a.
; 単純にintegersが分母にくればよいので
(define (integrate-series s)
  (stream-map / s integers))

; b.
; sineの微分がcosなので
(define sine-series
  (cons-stream 0 (integrate-series cosine-series)))
; cosの微分はsinの（streamの）符号を全て変えたものなので
(define cosine-series
  (cons-stream 1 (stream-map (lambda (x) (- x)) (integrate-series sine-series))))
