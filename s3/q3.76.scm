; q3.75で平均値使ってノイズを減らしたstreamを見たくても見れないよね 問題

(load "./q3.74.scm")
(load "./q3.75.scm")
;-------------------------------------------------------------------------------------
(define ones (cons-stream 1 ones)) ; p.194
(define integers (cons-stream 1 (add-streams ones integers))) ; p.194
;-------------------------------------------------------------------------------------

; smoothは "直前の値" と "現在の値" を使って "現在の平均値" を出し続ければ良い
; 例えば
;     1 2 3 4 5 6 ....
; というstreamがあった場合に
;     0 1 2 3 4 5 ....
; を作ってそれぞれを足して2で割れば良い
(define (smooth input-stream)
    (stream-map (lambda (a b) (/ (+ a b) 2)) input-stream (cons-stream 0 input-stream)))

(use gauche.test)
(test-start "q3.76")
(test "smooth" '(1/2 3/2 5/2 7/2 9/2 11/2) (lambda () (take (smooth integers) 6)))

; make-zero-crossings の改良は "smoothの内部が変わっても抽出部分は変更しなくても良いようにする" という話なので、
; q3.74の make-zero-crossings の input-stream が smooth 後の stream になるようにすれば良い
(define (make-zero-crossings input-stream last-value)
  (cons-stream
    (sign-change-detector (stream-car input-stream) last-value)
    (make-zero-crossings (stream-cdr input-stream)
                         (stream-car input-stream))))

(define (improved-make-zero-crossings input-stream . smoother)
    (make-zero-crossings ((if (null? smoother) smooth (car smoother)) input-stream) 0))

(test-start "q3.76")
(define sense-data (make-dummy-stream (reverse '(1  2  1.5  1  0.5  -0.1  -2  -3  -2  -0.5  0.2  3  4)) ones))
(test "make vs. improved" '(0 0 0 0 0 0 -1 0 0 0 0 1 0) (lambda () (take (improved-make-zero-crossings sense-data) 13)))
