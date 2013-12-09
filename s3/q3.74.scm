(load "./s3.5.1-stream.scm")

;-----------------------------------------------------------------------
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

(define (take s x)
  (cond ((stream-null? s) '())
        ((= x 0) '())
        (else (cons (stream-car s) (take (stream-cdr s) (- x 1))))))
;-----------------------------------------------------------------------

; とりあえず問題文の確認ができるようにdummyのstreamが作れるように
(define (make-dummy-stream l stream)
  (define (itr sub-l s)
    (if (null? sub-l)
      s
      (itr (cdr sub-l) (cons-stream (car sub-l) s))))
  (itr l stream))

;1  2  1.5  1  0.5  -0.1  -2  -3  -2  -0.5  0.2  3  4
(define sense-data (make-dummy-stream (reverse '(1  2  1.5  1  0.5  -0.1  -2  -3  -2  -0.5  0.2  3  4)) ones))
#?=(take sense-data 13)

; sign-change-detectorは最後の数と現在の数を比較して符号が違えば-1か1を返せばよいので
(define (sign-change-detector current last)
  (cond ((and (> last 0) (<= current 0)) -1)
        ((and (< last 0) (>= current 0))  1)
        (else  0)))

; sign-change-detectorの動きを考えると、stream-mapにsense-dataの値と、その1つ前の値を与え続ければよい
; また、zero-crossingsの始めはかならず0からなので、
(define zero-crossings
  (stream-map sign-change-detector sense-data (cons-stream 0 sense-data)))

(use gauche.test)
(test-start "q3.74")
(test "zero-crossings" '(0 0 0 0 0 -1 0 0 0 0 1 0 0) (lambda () (take zero-crossings 13)))
