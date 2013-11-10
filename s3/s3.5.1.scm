(load "./s1.2.6-prime.scm")

(define (sum-primes a b)
  (define (iter count accum)
    (cond ((> count b) accum)
          ((prime? count) (iter (+ count 1) (+ count accum)))
          (else (iter (+ count 1) accum))))
  (iter a 0))

(print (sum-primes 1 10))

(print '==========================================================================================================)

(load "./s3.5.1-stream.scm")

(stream-car
  (stream-cdr
    (stream-filter prime?
                   (stream-enumerate-interval 10000 1000000))))
