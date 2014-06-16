; Ben BitdiddleとAlyssa P. Hackerはunlessのようなものの実装での遅延評価の重要さにつき, 意見が分れた.
; Benはunlessは作用的順序では特殊形式で実装出来るという.
; Alyssaは, 誰かがそうすると, unlessは高水準手続きと一緒に使える手続きではなく, 単なる構文だと反論する.
; 両者の議論の細部をつめよ.
;
; unlessを(condやletのように)導出された式としてどう実装するかを示し,
; unlessが特殊形式としてではなく, 手続きとして使えると有用である状況の例を述べよ.


; （Ben の主張である）特殊形式での実装だと、 unless を手続きとして使いたい時に困るというのがAlyssaの主張かな？

; （cond や let のような）"導出された式"は以下を参照
; http://sicp.iijlab.net/fulltext/x412.html#index2363
;
; cond->if に倣って実装したのが以下
(load "./driver-loop.scm")

; unless が手続きとして有用である場合は、"手続きとして使いたいとき"という話なので、何かの手続きの引数として渡すときかな
; （そうしたい場合には lambda でくるんで渡すことになるので）
