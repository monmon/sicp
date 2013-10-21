; mergeの動きは
; S1の先頭がS2の先頭よりも小さい場合には
; - S1の先頭に、S1の以降とS2をmergeしたもの
; とし、
; 逆の場合には
; - S2の先頭に、S2の以降とS1をmergeしたもの
; とし、
; 同じ場合には
; - S1の先頭に、S1の以降とS2の以降をmergeしたもの
; とすることで重複をなくすものである
;
; 問題からSの要素のすべては2をかけたもの、3をかけたもの、5をかけたもの、のmergeなので

(define S (cons-stream 1 (merge (scale-stream S 2)
                                (merge (scale-stream S 3)
                                       (scale-stream S 5)))))
