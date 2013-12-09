; 擬似的零交差がどういう状況かわからないけど、「通常ずっと+だけなのにノイズが入ってそこだけ-になった」みたいなことと解釈してみる

(load "./q3.74.scm")


; 以下のLouisの実装の問題点は？
; => 最後のmake-zero-crossings で平均値avptを渡しているため、再帰のときにlast-valueが実際の値ではなくなってしまっている
(define (make-zero-crossings input-stream last-value)
  (let ((avpt (/ (+ (stream-car input-stream) last-value) 2)))
    (cons-stream (sign-change-detector avpt last-value)
                 (make-zero-crossings (stream-cdr input-stream)
                                      avpt))))

; 修正版を作るので以下に着目
; - 「検出データの各値を直前の値と平均」なので直前の値を渡すようにする
; - また、sign-change-detector に渡す値は "直前の平均値（直前とその前の平均）" と "現在の平均値（現在の値と直前の平均）" であるべきなので直前の平均値も必要
(define (make-zero-crossings input-stream last-value last-avpt)
  (let ((avpt (/ (+ (stream-car input-stream) last-value) 2)))
    (cons-stream (sign-change-detector avpt last-avpt)
                 (make-zero-crossings (stream-cdr input-stream)
                                      (stream-car input-stream)
                                      avpt))))

(define sense-data (make-dummy-stream (reverse '(1  2  1.5  1  0.5  -0.1  -2  -3  -2  -0.5  0.2  3  4)) ones))
(define zero-crossings (make-zero-crossings sense-data 0 0))

(use gauche.test)
(test-start "q3.75")
(test "zero-crossings" '(0 0 0 0 0 -1 0 0 0 0 1 0 0) (lambda () (take zero-crossings 13)))
