(load "./s3.5.1-stream.scm")

;-----------------------------------------------------------
;前のコピー

; q.3.50
(define (stream-map proc . argstreams)
  (if (stream-null? (car argstreams))
    the-empty-stream
    (cons-stream
     (apply proc (map stream-car argstreams))
     (apply stream-map
            (cons proc (map stream-cdr argstreams))))))

(define (add-streams s1 s2)
  (stream-map + s1 s2)) ; p.194

(define ones (cons-stream 1 ones)) ; p.194
(define integers (cons-stream 1 (add-streams ones integers))) ; p.194
(define (scale-stream stream factor)
  (stream-map (lambda (x) (* x factor)) stream)) ; q.195
(define (take s x)
  (cond ((stream-null? s) '())
        ((= x 0) '())
        (else (cons (stream-car s) (take (stream-cdr s) (- x 1))))))
;-----------------------------------------------------------
(define (integral integrand initial-value dt)
  (define int
    (cons-stream initial-value
                 (add-streams (scale-stream integrand dt)
                              int)))
  int)
;-----------------------------------------------------------

; 回路図をそのまま式にするだけ
;
; RCで回路を作り、
; 作った回路にiというstreamとv0という初期地を渡す
(define (RC R C dt)
  (define circuit (lambda (i v0) (add-streams (scale-stream i R)
                                              (integral (scale-stream i (/ 1 C)) v0 dt))))
  circuit)

; e.g.
(define rc (RC 1 1 1))

#?=(take (rc integers 10) 10)
