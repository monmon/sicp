(define (show x)
  (display-line x)
  x)


(define x (stream-map show (stream-enumerate-interval 0 10)))
; まずstream-mapはstreamの先頭をstream-carで取り出しproc（この場合show）し、
; 残りのstream-cdr部分はcons-streamのdelay部分に当たるので初めの0だけ表示される
; => 0

(stream-ref x 5)
; (stream-ref (stream-cdr x) (- 5 1)) が評価されるので
; (stream-cdr x)により(stream-map proc (stream-cdr s))のprocが行われる
; => 1
; (stream-ref (stream-cdr x) (- 4 1)) が評価されるので同様に
; => 2
; (stream-ref (stream-cdr x) (- 3 1)) が評価されるので同様に
; => 3
; (stream-ref (stream-cdr x) (- 2 1)) が評価されるので同様に
; => 4
; (stream-ref (stream-cdr x) (- 1 1)) が評価されるので同様に
; => 5

(stream-ref x 7)
; 先と同様に(stream-ref (stream-cdr x) (- 7 1)) が評価されるので
; (stream-cdr x)により(stream-map proc (stream-cdr s))のprocが行われるが、
; memo-procにより先ほどの結果があるので印字はされない
; 結果、
; => 6
; => 7
