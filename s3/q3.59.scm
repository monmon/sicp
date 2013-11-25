(load "./s3.5.1-stream.scm")
(load "./q3.50.scm")

(define (add-streams s1 s2)
  (stream-map + s1 s2)) ; p.194

; a.
; 単純にintegersが分母にくればよいので
(define ones (cons-stream 1 ones)) ; p.194
(define integers (cons-stream 1 (add-streams ones integers))) ; p.194
(define (integrate-series s)
  (stream-map / s integers))

; b.
; sineの微分がcosなので
(define sine-series
  (cons-stream 0.0 (integrate-series cosine-series)))
; cosの微分はsinの（streamの）符号を全て変えたものなので
(define cosine-series
  (cons-stream 1.0 (stream-map (lambda (x) (- x)) (integrate-series sine-series))))

(load "./q3.55.scm")
(print (stream-ref (partial-sums sine-series) 100))
(print (stream-ref (partial-sums cosine-series) 100))
