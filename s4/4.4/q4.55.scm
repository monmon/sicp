; データベースから, 次の情報を検索する単純質問を示せ:
;
; a. Ben Bitdiddleに監督されている人すべて;
(supervisor ?person (Bitdiddle Ben))

; b. 経理部門[accounting division]のすべての人の名前と担当;
(job ?person (accounting . ?type))

; c. Slumervilleに住む人すべての名前と住所.
(address ?person (Slumerville . ?where))
