(define (unless condition usual-value exceptional-value)
  (if condition exceptional-value usual-value))

(define (factorial n)
  (unless (= n 1)
    (* n (factorial (- n 1)))
    1))

;; 作用的順序の置換えと正規順序の置換えを行う
;; http://sicp.iijlab.net/fulltext/x115.html

;; 作用的順序の場合

; (factorial 5) を置換え
(unless (= 5 1)
  (* 5 (factorial (- 5 1)))
  1)

; 4.2.1のはじめにある通り"Scheme手続きへの引数は, 手続きを作用する時にすべて評価"なので
; (= 5 1) と (- 5 1) を置換え
(unless #f
  (* 5 (factorial 4))
  1)

; 次に (* 5 (factorial 4)) を評価するために (factorial 4) を置換え
(unless #f
  (* 5 (unless (= 4 1)
         (* 4 (factorial (- 4 1)))
         1))
  1)

; 同様に
(unless #f
  (* 5 (unless #f
         (* 4 (factorial 3))
         1))
  1)

; 同様に (factorial 3) を置換え
(unless #f
  (* 5 (unless #f
         (* 4 (unless #f
                (* 3 (factorial 2))
                1))
         1))
  1)

; 同様に factorial を置換えていくが、以下のようにunlessを評価する前に引数が評価されてしまい
; unlessの評価にたどり着かないため動かない
(unless #f
  (* 5 (unless #f
         (* 4 (unless #f
                (* 3 (unless #f
                       (* 2 (unless #t
                              (* 1 (unless #f
                                     (* 0 (factorial -1))
                                     1))
                              1))
                       1))
                1))
         1))
  1)


;; 正規順序の場合

; (factorial 5) を置換え
(unless (= 5 1)
  (* 5 (factorial (- 5 1)))
  1)

; 引数を評価する前に合成手続きを置換えるので
(if (= 5 1)
  1
  (* 5 (factorial (- 5 1))))

; if の置換え
(* 5 (factorial (- 5 1)))

; また引数を評価する前に合成手続きを置換え
(* 5 (unless (= (- 5 1) 1)
       (* (- 5 1) (factorial (- (- 5 1) 1)))
       1))

; 引数を評価する前に unless の置換え
(* 5 (if (= (- 5 1) 1)
       1
       (* (- 5 1) (factorial (- (- 5 1) 1)))))

; if の置換え
(* 5 (* (- 5 1) (factorial (- (- 5 1) 1))))

; また引数を評価する前に合成手続きを置換え
(* 5 (* (- 5 1) (unless (= (- (- 5 1) 1) 1)
                  (* (- (- 5 1) 1) (factorial (- (- (- 5 1) 1) 1)))
                  1)))

; unless の置換え
(* 5 (* (- 5 1) (if (= (- (- 5 1) 1) 1)
                  1
                  (* (- (- 5 1) 1) (factorial (- (- (- 5 1) 1) 1))))))

; if の置換え
(* 5 (* (- 5 1) (* (- (- 5 1) 1) (factorial (- (- (- 5 1) 1) 1)))))

; 同様に
(* 5 (* (- 5 1) (* (- (- 5 1) 1) (unless (= (- (- (- 5 1) 1) 1) 1)
                                   (* (- (- (- 5 1) 1) 1) (factorial (- (- (- (- 5 1) 1) 1) 1)))
                                   1))))

; ...
(* 5 (* (- 5 1) (* (- (- 5 1) 1) (* (- (- (- 5 1) 1) 1) (factorial (- (- (- (- 5 1) 1) 1) 1))))))

; ...
(* 5 (* (- 5 1) (* (- (- 5 1) 1) (* (- (- (- 5 1) 1) 1) (unless (= (- (- (- (- 5 1) 1) 1) 1) 1)
                                                          (* (- (- (- (- 5 1) 1) 1) 1) (factorial (- (- (- (- (- 5 1) 1) 1) 1) 1)))
                                                          1)))))

; unless を置換えると1になるので
(* 5 (* (- 5 1) (* (- (- 5 1) 1) (* (- (- (- 5 1) 1) 1) 1))))

; あとは基本手続きの評価ができるので結果が出る
120
