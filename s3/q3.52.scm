(load "./s3.5.1-stream.scm")

(define sum 0)
; sum: 0
; memo-procなしsum: 0

(define (accum x)
  (set! sum (+ x sum))
  sum)
; sum: 0
; memo-procなしsum: 0

(define seq (stream-map accum (stream-enumerate-interval 1 20)))
; stream-carが行われるので
; sum: 1
; memo-procなしsum: 1

(define y (stream-filter even? seq))
; p.190のstream-filterより、
; (pred (stream-car stream)) は (stream-car stream) が1で偽なので
; (stream-filter pred (stream-cdr stream)) が行われる
; これで
; sum: 1 + 2 = 3
; (pred (stream-car stream)) は (stream-car stream) が3で偽なので
; 同様に行い
; sum: 3 + 3 = 6
; ここで真となり終わり
;
; memo-procなしの場合にも同様に
; memo-procなしsum: 6

(define z (stream-filter (lambda (x) (= (remainder x 5) 0))
                         seq))
; seqは(1 3 6 ...)というstreamで、ここまでで (= (remainder x 5) 0) は偽
; 次に
; sum: 6 + 4 = 10
; となりここで真
;
; memo-procなしの場合、再評価が行われるので結果が変わってくる
; yのときと同様、p.190のstream-filterより、
; (pred (stream-car stream)) は (stream-car stream) が1で偽なので
; (stream-filter pred (stream-cdr stream)) が行われる
; このときにprocの結果をmemoしてないため (define y (stream-filter even? seq)) の結果の6に足される
; sum: 6 + 2 = 8
; (pred (stream-car stream)) は (stream-car stream) が8で偽なので
; sum: 8 + 3 = 11
; (pred (stream-car stream)) は (stream-car stream) が11で偽なので
; sum: 11 + 4 = 15
; となりここで真

(stream-ref y 7)
; memo化されている場合には単純に偶数の8番目がsumの結果なので
; (1 3 '6' '10' 15 21 '28' '36' 45 55 '66' '78' 91 105 '120' '136' ...)
; より、
; sum: 136
;
; memo-procなしの場合、
; (define y (stream-filter even? seq))
; 時に評価された3番目までは値が決定、
; その先のstreamの値が、先の結果の15の値に足されるため
; (1 3 '6' 19 '24' '30' 37 45 '54' '64' 75 87 '100' '114' 129 145 '162'
; より、
; sum: 162

(display-stream z)
; zをすべて表示するので
; (1 3 6 10 15 21 28 36 45 55 66 78 91 105 120 136 153 171 190 210)
; から、印字は
; 10
; 15
; 45
; 55
; 105
; 120
; 190
; 210
; となり、
; sum: 210
;
; memo-procなしの場合、
; 15までは評価されているので、その先のstreamが評価されるが、先の結果の162に足されるため、
; (1 8 11 15 167 173 180 188 197 207 218 230 243 257 272 288 305 323 342 362)
; となり、印字は
; 15
; 180
; 230
; 305
; で、
; sum: 362
