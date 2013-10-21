; p.189のstream-mapの一般系を作れば良い
; 1つめの<??>はthe-empty-streamを返してるので終了条件と考えるとstream-null?
; （複数の引数それぞれのstreamの長さは同じなのでcarしたはじめの引数がstream-null?なら終了）
; 2つめの<??>はstream-mapの結果はstreamになるのでcons-stream
; 3つめの<??>はargstreamsそれぞれのstreamの1つめの要素を取得してprocをapplyすれば良いのでmapでstream-car
; 4つめの<??>は同様にargstreamsそれぞれのstreamの1つめ以降の要素を繰り返したいのでprocをconsしてstream-mapをapplyする

(define (stream-map proc . argstreams)
  (if (stream-null? (car argstreams))
    the-empty-stream
    (cons-stream
     (apply proc (map stream-car argstreams))
     (apply stream-map
            (cons proc (map stream-cdr argstreams))))))

