;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname Invaders-shoot-revised) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; Authors: Alessandro Russo Kevin Zelaya
;; Purpose: Space Invaders where the invader shoots back


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 2htdp/image)
(require 2htdp/universe)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; A Game is a (make-game Base Base-Shots Invader-Shots Invaders Life)
(define-struct game (base base-shots inv-shots inv l))
; Interp: game state with an arbitrary number of shots fired.

;; A Shots is one of:
;; - (make-no-shots)
;; - (make-some-shots Shot Shots)
(define-struct no-shots ())
(define-struct some-shots (first rest))

;; A Base-Shots is one of:
;; - (make-no-base-shots)
;; - (make-some-base-shots Shot Shots)
(define-struct no-base-shots ())
(define-struct some-base-shots (first rest))
; Interp: structure that holds an arbitrary number of Shots fired from a base.

;; A Invader-Shots is one of:
;; - (make-no-inv-shots)
;; - (make-some-inv-shots Shot Shots)
(define-struct no-inv-shots ())
(define-struct some-inv-shots (first rest))
; Interp: structure that holds an arbitrary number of Shots fired from an invader.

;; An Invaders is one of:
;; - (make-no-invs)
;; - (make-some-invs Invader Invaders)
(define-struct no-invs ())
(define-struct some-invs (first rest))
; Interp: structure that holds an arbitrary number of Invaders

;; An Invader is a
;; (make-invader Integer Integer Dir Fire-Rate Next-Fire )
(define-struct invader (x y dir f n ))
;; Interp: the (x,y) px coordinate of the upper left corner of the invader
;; moving in the direction dir

;; A Base is an Integer
;; Interp: the px coordinate of the left edge of the base

;; A Shot is (make-posn Integer Integer)
;; Interp: the px coordinate of the shot

;;A Life is a number

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Constants

(define BASE-WIDTH 100)
(define BASE-HEIGHT 20)
(define BASE-IMAGE (rectangle BASE-WIDTH BASE-HEIGHT "solid" "green"))
(define SCENE-HEIGHT 200)
(define SCENE-WIDTH 500)
(define MT-SCENE (empty-scene SCENE-WIDTH SCENE-HEIGHT))
(define BASE-SPEED 10)

(define INV-WIDTH 80)
(define INV-HEIGHT 30)
(define INV-IMAGE (rectangle INV-WIDTH INV-HEIGHT "solid" "red"))
(define INV-SPEED 10)
(define INV-MAX-X (- SCENE-WIDTH INV-WIDTH))
(define INV-MAX-Y (- SCENE-HEIGHT INV-HEIGHT))

(define INV-X-OFF (* 1/2 INV-WIDTH))
(define INV-Y-OFF (* 1/2 INV-HEIGHT))

(define SHOT-SIZE 15)
(define SHOT-IMAGE (triangle SHOT-SIZE "solid" "blue"))
(define SHOT-SPEED 8)

(define BASE-X-OFF (* 1/2 BASE-WIDTH))
(define BASE-Y-OFF (- SCENE-HEIGHT (* 1/2 BASE-HEIGHT)))

(define B-SHOTS1
  (make-some-base-shots (make-posn 100 -1) (make-no-base-shots)))
(define B-SHOTS2
  (make-some-base-shots (make-posn 100 -1)
                        (make-some-base-shots (make-posn 100 99)
                                              (make-no-base-shots))))
(define B-SHOTS3
  (make-some-base-shots
   (make-posn 100 180) (make-some-base-shots
                        (make-posn 100 -10) (make-some-base-shots
                                             (make-posn 100 199)
                                             (make-no-base-shots)))))

(define I-SHOTS0 (make-no-inv-shots))
(define I-SHOTS1
  (make-some-inv-shots (make-posn 100 199) (make-no-inv-shots)))
(define I-SHOTS2
  (make-some-inv-shots (make-posn 100 201)
                       (make-some-inv-shots (make-posn 100 99)
                                            (make-no-inv-shots) )))
(define I-SHOTS3
  (make-some-inv-shots
   (make-posn 100 180) (make-some-inv-shots
                        (make-posn 100 -10) (make-some-inv-shots
                                             (make-posn 100 201)
                                             (make-no-inv-shots)))))

(define INV0 (make-invader 0 0 "right" 1  40 ))
(define INV1 (make-invader INV-SPEED 0 "right" 2 6 ))
(define INV2 (make-invader 0 0 "right" 4  4 ))
(define INV3 (make-invader 20 30 "right" 5  4 ))
(define INV4 (make-invader 100 180 "right" 6  4 ))
(define INV5 (make-invader 100 170 "right" 7  4 ))
(define INVN (make-invader 0 INV-MAX-Y "right" 3  7 ))

(define GAMEINV1 (make-invader 0 0 "right" 3  7 ))
(define GAMEINV2 (make-invader 80 0 "right" 4  7 ))
(define GAMEINV3 (make-invader 160 0 "right" 2  7 ))

(define INVADERS1
  (make-some-invs INV0 (make-some-invs INV1 (make-some-invs INV2 (make-no-invs)))))
(define INVADERS2
  (make-some-invs INV1 (make-some-invs INV2 (make-some-invs INV3 (make-no-invs)))))
(define INVADERS3
  (make-some-invs INV2 (make-some-invs INV3 (make-some-invs INV4 (make-no-invs)))))
(define INVADERS4
  (make-some-invs INV2 (make-some-invs INV3 (make-some-invs INV5 (make-no-invs)))))
(define INVADERS5
  (make-some-invs INV3 (make-some-invs INV4 (make-some-invs INV5 (make-no-invs)))))

(define GAMEINVADERS
  (make-some-invs GAMEINV1 (make-some-invs GAMEINV2 (make-some-invs GAMEINV3
                                                                    (make-no-invs)))))




(define INVSDRAW1
  (place-image INV-IMAGE 40 15
               (place-image INV-IMAGE 50 15
                            (place-image INV-IMAGE 40 15 MT-SCENE))))
(define INVSDRAW2
  (place-image INV-IMAGE 50 15
               (place-image INV-IMAGE 40 15
                            (place-image INV-IMAGE 60 45 MT-SCENE))))
(define INVSDRAW3
  (place-image INV-IMAGE 40 15
               (place-image INV-IMAGE 60 45
                            (place-image INV-IMAGE 140 195 MT-SCENE))))





(define NEW-GAME (make-game 0 (make-no-base-shots) (make-no-inv-shots) GAMEINVADERS 3))
(define GAME1 (make-game 0 B-SHOTS1 I-SHOTS1 GAMEINVADERS 3))
(define GAME2 (make-game 0 B-SHOTS2 I-SHOTS2 GAMEINVADERS 3))
(define GAME3 (make-game 0 B-SHOTS3 I-SHOTS3 GAMEINVADERS 3))
(define GAME4 (make-game 0 B-SHOTS3 I-SHOTS3 GAMEINVADERS 3))
(define GAME5 (make-game 0 B-SHOTS3 I-SHOTS3 GAMEINVADERS 3))

(define GAME-TOCK-RESULT1
  (make-game 0
             (make-no-base-shots)
             (make-no-inv-shots)
             INVADERS1 3))

(define GAME-TOCK-RESULT2
  (make-game 
   0
   (make-some-base-shots (make-posn 100 91)
                         (make-no-base-shots))
   I-SHOTS1 INVADERS2 3))


(define GAME-KEY-RESULT1
  (make-game 
   0
   (make-some-base-shots (make-posn 50 190) (make-some-base-shots
                                             (make-posn 100 -1)
                                             (make-no-base-shots)))
   I-SHOTS1 INVADERS1 3))

(define GAME-KEY-RESULT2
  (make-game 
   0
   (make-some-base-shots
    (make-posn 50 190) (make-some-base-shots
                        (make-posn 100 -1) (make-some-base-shots
                                            (make-posn 100 99)
                                            (make-no-base-shots))))
   I-SHOTS1 INVADERS2 3))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;main: Integer -> Game

(define (main i)
  (big-bang (make-game i (make-no-base-shots) (make-no-inv-shots) GAMEINVADERS 3)
            [to-draw game-draw]
            [on-tick game-tock]
            [on-key game-key]
            [stop-when game-over?]))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Shots Functions

;; shot-hits-invader? : Shot Invader -> Boolean
;; Does the shot hit the invader?
(check-expect (shot-hits-invader? (make-posn 0 0) INV0) #true)
(check-expect (shot-hits-invader? (make-posn (+ 10 INV-WIDTH) 0) INV0) #false)
(check-expect (shot-hits-invader? (make-posn 0 (+ 10 INV-HEIGHT)) INV0) #false)
(define (shot-hits-invader? s i)
  (and (<= (invader-x i) (posn-x s) (+ (invader-x i) INV-WIDTH))
       (<= (invader-y i) (posn-y s) (+ (invader-y i) INV-HEIGHT))))

;; any-shots-hit-invader?: Base-Shots Invader -> Boolean
;; takes a Base-Shots and an invader and produces true if
;; any shot in the collection hits the invader

(check-expect (any-shots-hit-invader?
               (make-some-base-shots (make-posn 0 0)
                                     (make-no-base-shots)) INV0) #true)
(check-expect (any-shots-hit-invader?
               (make-some-base-shots (make-posn (+ 10 INV-WIDTH) 0)
                                     (make-no-base-shots)) INV1) #true)
(check-expect (any-shots-hit-invader?
               (make-some-base-shots (make-posn 0 (+ 10 INV-HEIGHT))
                                     (make-no-base-shots)) INV1) #false)

(define (any-shots-hit-invader? s i)
  (cond[(no-base-shots? s) #false]
       [(some-base-shots? s)
        (or (shot-hits-invader? (some-base-shots-first s) i)
            (any-shots-hit-invader? (some-base-shots-rest s) i))]))

;; any-shots-hit-invaders?: Base-Shots Invaders -> Boolean
;; takes a Base-Shots and an invader and produces true if
;; any shot in the collection hits the invader

(check-expect (any-shots-hit-invaders? B-SHOTS1 INVADERS1) #false)

(define (any-shots-hit-invaders? bs i)
  (cond[(no-invs? i) #false]
       [(some-invs? i)
        (or (any-shots-hit-invader? bs (some-invs-first i))
            (any-shots-hit-invaders? bs (some-invs-rest i)))]))



;; shot-hits-base? : Shot Base -> Boolean
;; Does the shot hit the base?
(check-expect (shot-hits-base? (make-posn 0 0) 0) #true)
(check-expect (shot-hits-base? (make-posn 90 19) 90) #true)
(check-expect (shot-hits-base? (make-posn 123 97) 56) #false)
(define (shot-hits-base? s b)
  (and (<= b (posn-x s) (+ b BASE-WIDTH))
       (<= 0 (posn-y s) BASE-HEIGHT)))

;; any-shots-hit-base?: Invader-Shots Base -> Boolean
;; takes a Shots and a base and produces true if
;; any shot in the collection hits the base.

(check-expect (any-shots-hit-base?
               (make-some-inv-shots (make-posn 0 0)
                                    (make-no-inv-shots)) 0) #true)
(check-expect (any-shots-hit-base?
               (make-some-inv-shots (make-posn 80 20)
                                    (make-no-inv-shots)) 80) #true)
(check-expect (any-shots-hit-base?
               (make-some-inv-shots (make-posn 80 21)
                                    (make-no-inv-shots)) 80) #false)

(define (any-shots-hit-base? s b)
  (cond[(no-inv-shots? s) #false]
       [(some-inv-shots? s)
        (or (shot-hits-base? (some-inv-shots-first s) b)
            (any-shots-hit-base? (some-inv-shots-rest s) b))]))


;; shot-over-top? : Shot -> Boolean
;; Has the shot gone over the top of the scene

(check-expect (shot-over-top? (make-posn 100 200)) #false)
(check-expect (shot-over-top? (make-posn 100 0)) #false)
(check-expect (shot-over-top? (make-posn 100 -1)) #true)
(define (shot-over-top? s)
  (< (posn-y s) 0))

;; remove-all-over-top: Base-Shots -> Shots
;; takes a Base-Shots and removes all of the shots that have
;; gone over the top of the screen.

(check-expect (remove-all-over-top B-SHOTS1) (make-no-base-shots))
(check-expect (remove-all-over-top B-SHOTS2)
              (make-some-base-shots (make-posn 100 99)
                                    (make-no-base-shots) ))
(check-expect (remove-all-over-top B-SHOTS3)
              (make-some-base-shots
               (make-posn 100 180) (make-some-base-shots
                                    (make-posn 100 199) (make-no-base-shots))))

(define (remove-all-over-top s)
  (cond [(no-base-shots? s) (make-no-base-shots)]
        [(some-base-shots? s)
         (cond [(< (posn-y (some-base-shots-first s)) 0)
                (remove-all-over-top (some-base-shots-rest s))]
               [else (make-some-base-shots (some-base-shots-first s)
                                           (remove-all-over-top
                                            (some-base-shots-rest s)))])]))

;; shot-under-bottom? : Invader-Shot -> Boolean
;; Has the shot gone under the bottom of the scene

(check-expect (shot-under-bottom? (make-posn 200 201)) #true)
(check-expect (shot-under-bottom? (make-posn 20 20)) #false)
(check-expect (shot-under-bottom? (make-posn 200 199)) #false)

(define (shot-under-bottom? s)
  (> (posn-y s) 200))

;; shots-under-bottom? : Invader-Shots -> Boolean
;; Has the shots gone under the bottom of the scene

(check-expect (shots-under-bottom? I-SHOTS1) #false)

(define (shots-under-bottom? s)
  (cond[(no-inv-shots? s) #false]
       [(some-inv-shots? s)
        (or (shot-under-bottom? (some-inv-shots-first s))
            (shots-under-bottom? (some-inv-shots-rest s)))]))
  

;; remove-all-under-bottom: Invader-Shots -> Shots
;; takes a Invader-Shots and removes all of the shots that have
;; gone under the bottom of the screen.

(check-expect (remove-all-under-bottom I-SHOTS1)
              (make-some-inv-shots (make-posn 100 199) (make-no-inv-shots)))
(check-expect (remove-all-under-bottom I-SHOTS2)
              (make-some-inv-shots (make-posn 100 99)
                                   (make-no-inv-shots)))
(check-expect (remove-all-under-bottom I-SHOTS3)
              (make-some-inv-shots (make-posn 100 180)
                                   (make-some-inv-shots (make-posn 100 -10)
                                                        (make-no-inv-shots))))

(define (remove-all-under-bottom s)
  (cond[(no-inv-shots? s) (make-no-inv-shots)]
       [(some-inv-shots? s)
        (cond[(> (posn-y (some-inv-shots-first s)) 200)
              (remove-all-under-bottom (some-inv-shots-rest s))]
             [else (make-some-inv-shots (some-inv-shots-first s)
                                        (remove-all-under-bottom
                                         (some-inv-shots-rest s)))])]))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; shot-tock-base : Base-Shot -> Base-Shot
;; Advance the shot upward one tick of time

(check-expect (shot-tock-base (make-posn 100 200))
              (make-posn 100 (- 200 SHOT-SPEED)))
(check-expect (shot-tock-base (make-posn 10 150))
              (make-posn 10 (- 150 SHOT-SPEED)))
(check-expect (shot-tock-base (make-posn 100 100))
              (make-posn 100 (- 100 SHOT-SPEED)))

(define (shot-tock-base s)
  (make-posn (posn-x s)
             (- (posn-y s) SHOT-SPEED)))

;; shots-tock-base: Base-Shots -> Base-Shots
;; takes a Shots and advances each shot upward and eliminates
;; any shot that has gone over the top of the screen

(check-expect (shots-tock-base B-SHOTS1) (make-no-base-shots))

(check-expect (shots-tock-base B-SHOTS2)
              (make-some-base-shots (make-posn 100 91)
                                    (make-no-base-shots)))

(check-expect
 (shots-tock-base B-SHOTS3)
 (make-some-base-shots
  (make-posn 100 172) (make-some-base-shots
                       (make-posn 100 191) (make-no-base-shots))))
                  

(define (shots-tock-base s)
  (cond[(no-base-shots? s) (make-no-base-shots)]
       [(some-base-shots? s)
        (cond [(shot-over-top? (some-base-shots-first s))
               (shots-tock-base (some-base-shots-rest s))]
              [else (make-some-base-shots
                     (shot-tock-base (some-base-shots-first s))
                     (shots-tock-base
                      (some-base-shots-rest s)))])]))

;; shot-tock-inv : Invader-Shot -> Invader-Shot
;; Advance the shot downward one tick of time

(check-expect (shot-tock-inv (make-posn 100 200))
              (make-posn 100 (+ 200 SHOT-SPEED)))
(check-expect (shot-tock-inv (make-posn 10 150))
              (make-posn 10 (+ 150 SHOT-SPEED)))
(check-expect (shot-tock-inv (make-posn 100 100))
              (make-posn 100 (+ 100 SHOT-SPEED)))

(define (shot-tock-inv s)
  (make-posn (posn-x s)
             (+ (posn-y s) SHOT-SPEED)))


;; shots-tock-inv: Invader-shots -> Invader-Shots
;; takes a Shots and advances each shot downward and eliminates
;; any shot that has gone under the bottom of the screen

(check-expect (shots-tock-inv I-SHOTS1)
              (make-some-inv-shots (make-posn 100 207) (make-no-inv-shots)))

(check-expect (shots-tock-inv I-SHOTS2) 
              (make-some-inv-shots (make-posn 100 107)
                                   (make-no-inv-shots) ))

(check-expect (shots-tock-inv I-SHOTS3)
              (make-some-inv-shots (make-posn 100 188)
                                   (make-some-inv-shots (make-posn 100 -2)
                                                        (make-no-inv-shots))))

             

(define (shots-tock-inv s)
  (cond[(no-inv-shots? s) (make-no-inv-shots)]
       [(some-inv-shots? s)
        (cond[(shot-under-bottom? (some-inv-shots-first s))
              (shots-tock-inv (some-inv-shots-rest s))]
             [else (make-some-inv-shots (shot-tock-inv (some-inv-shots-first s))
                                        (shots-tock-inv (some-inv-shots-rest s)))])]
       [else (make-no-shots)]))
              

#|

;; shots-tock : Base-Shots Invaders -> Shots
(check-expect (shots-tock B-SHOTS1 (make-no-invs)) (shots-tock-base B-SHOTS1))

(check-expect (shots-tock (make-no-base-shots) GAMEINVADERS)
              (shots-tock-inv (invs->shots GAMEINVADERS)))

(check-expect (shots-tock (make-no-base-shots) (make-no-invs)) (make-no-shots))

(define (shots-tock b i)
  (cond [(and (no-base-shots? b) (some-invs? i))
         (shots-tock-invs (invs->shots i))]
        [(and (some-base-shots? b) (no-invs? i))
         (shots-tock-base b)]
        [(and (some-base-shots? b) (some-invs? i))
         (make-some-shots (shot-tock-inv (inv->shot (some-invs-first i)))
                          (make-some-shots
                           (shot-tock-base (some-base-shots-first b))
                        
                          (shots-tock (some-base-shots-rest b)
                                      (some-invs-rest i))))]
        [else (make-no-shots)]))

|#
;; shots-tock-invs: Invader-Shots  -> Invader-Shots
;; takes a Shots and advances each shot downwards and eliminates
;; any shot that has gone below the screen


(define (shots-tock-invs i)
  (cond[(no-inv-shots? i) (make-no-inv-shots)]
       [(some-inv-shots? i)
        (make-some-inv-shots (shots-tock-inv (new-inv-shot (some-inv-shots-first i)))
                             (shots-tock-invs (some-inv-shots-rest i)))]))
        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; shot-draw-on-1: Shot Image -> Image
;; Draw shot on given image in the case of a single shot being fired

(check-expect (shot-draw-on-1 (make-posn 50 60) MT-SCENE)
              (place-image SHOT-IMAGE 50 60 MT-SCENE))
(check-expect (shot-draw-on-1 (make-posn 110 50) MT-SCENE)
              (place-image SHOT-IMAGE 110 50 MT-SCENE))

(define (shot-draw-on-1 s img)
  (place-image SHOT-IMAGE (posn-x s) (posn-y s) img))

;; shot-draw-on: Shot Shot Image -> Image
;; Draw shot on given image in the case that there are two Shot's


(check-expect (shot-draw-on (make-posn 100 200) (make-posn 90 20) MT-SCENE)
              (place-image SHOT-IMAGE 100 200
                           (place-image SHOT-IMAGE 90 20 MT-SCENE)))
(check-expect (shot-draw-on (make-posn 166 109) (make-posn 20 23) MT-SCENE)
              (place-image SHOT-IMAGE 166 109
                           (place-image SHOT-IMAGE 20 23 MT-SCENE)))

(define (shot-draw-on b i img)
  (place-image SHOT-IMAGE (posn-x b) (posn-y b)
               (place-image SHOT-IMAGE (posn-x i) (posn-y i) img)))

;; shots-draw-on-special1: Invader-Shots Image -> Image
;; Draw shot on given image in the case that there is only Invader-Shots 


(define (shots-draw-on-special1 i img)
  (cond[(no-inv-shots? i) img]
       [(some-inv-shots? i)
        (shot-draw-on-1 (some-inv-shots-first i)
                        (shots-draw-on-special1 (some-inv-shots-rest i) img))]))

;; shots-draw-on-special2: Base-Shots Image -> Image
;; Draw shot on given image in the case that there is only Base-Shots 

(check-expect (shots-draw-on-special2 B-SHOTS2 MT-SCENE)
              (place-image SHOT-IMAGE 100 -1
                           (place-image SHOT-IMAGE 100 99 MT-SCENE)))

(check-expect (shots-draw-on-special2 B-SHOTS3 MT-SCENE)
              (place-image SHOT-IMAGE 100 180
                           (place-image SHOT-IMAGE 100 -10
                                        (place-image SHOT-IMAGE 100 199 MT-SCENE))))

(define (shots-draw-on-special2 s img)
  (cond[(no-base-shots? s) img]
       [(some-base-shots? s)
        (shot-draw-on-1 (some-base-shots-first s)
                        (shots-draw-on-special2 (some-base-shots-rest s) img))]))
      



;; shots-draw-on: Base-Shots Invader-Shots Image -> Image
;; draws all of the given shots of the base on the given scene

(check-expect (shots-draw-on B-SHOTS1 I-SHOTS1 MT-SCENE)
              (shot-draw-on (some-base-shots-first B-SHOTS1)
                            (some-inv-shots-first I-SHOTS1)
                            (shots-draw-on
                             (some-base-shots-rest B-SHOTS1)
                             (some-inv-shots-rest I-SHOTS1) MT-SCENE)))

(check-expect (shots-draw-on B-SHOTS1 (make-no-inv-shots) MT-SCENE)
              (shots-draw-on-special2 B-SHOTS1 MT-SCENE))

(check-expect (shots-draw-on (make-no-base-shots) I-SHOTS2 MT-SCENE)
              (shots-draw-on-special1 I-SHOTS2 MT-SCENE))

(check-expect (shots-draw-on (make-no-base-shots) (make-no-invs) MT-SCENE)
              MT-SCENE)

              

(define (shots-draw-on b i img)
  (cond [(and (no-base-shots? b) (some-inv-shots? i))
         (shots-draw-on-special1 i img)]
        [(and (some-base-shots? b) (no-inv-shots? i))
         (shots-draw-on-special2 b img)]
        [(and (some-base-shots? b) (some-inv-shots? i))
         (shot-draw-on (some-base-shots-first b)
                       (some-inv-shots-first i)
                       (shots-draw-on
                        (some-base-shots-rest b)
                        (some-inv-shots-rest i) img ))]
        [else img]))
        


;; invader-draw-on : Invader Image -> Image
;; Render the invader on the given scene
(check-expect (invader-draw-on INV0 MT-SCENE)
              (place-image INV-IMAGE INV-X-OFF INV-Y-OFF MT-SCENE))

(check-expect (invader-draw-on INV1 MT-SCENE)
              (place-image INV-IMAGE (+ 10 INV-X-OFF) INV-Y-OFF MT-SCENE))

(define (invader-draw-on i img)  
  (place-image INV-IMAGE
               (+ (invader-x i) INV-X-OFF)
               (+ (invader-y i) INV-Y-OFF)
               img))

;; invader-draw : Invader -> Image
;; Render the invader on an empty scene
(check-expect (invader-draw INV0)
              (place-image INV-IMAGE INV-X-OFF INV-Y-OFF MT-SCENE))
(check-expect (invader-draw (make-invader 0 0 "left" 1 4))
              (place-image INV-IMAGE INV-X-OFF INV-Y-OFF MT-SCENE))
(check-expect (invader-draw (make-invader 10 0 "left" 1 4))
              (place-image INV-IMAGE (+ 10 INV-X-OFF) INV-Y-OFF MT-SCENE))
(define (invader-draw i)
  (invader-draw-on i MT-SCENE))

;; invaders-draw-on : Invaders Image -> Image
;; Render the invaders on the given scene

(check-expect (invaders-draw-on INVADERS1 MT-SCENE) INVSDRAW1)
(check-expect (invaders-draw-on INVADERS2 MT-SCENE) INVSDRAW2)
(check-expect (invaders-draw-on INVADERS3 MT-SCENE) INVSDRAW3)

(define (invaders-draw-on i img)  
  (cond [(no-invs? i) img]
        [(some-invs? i)
         (invader-draw-on (some-invs-first i)
                          (invaders-draw-on (some-invs-rest i) img))]))



;; base-draw : Base -> Image
;; Render a base on an empty scene
(check-expect (base-draw 0)
              (place-image BASE-IMAGE BASE-X-OFF BASE-Y-OFF MT-SCENE))
(check-expect (base-draw 100)
              (place-image BASE-IMAGE (+ 100 BASE-X-OFF) BASE-Y-OFF MT-SCENE))

(define (base-draw b)
  (place-image BASE-IMAGE
               (+ b (* 1/2 BASE-WIDTH))
               (- SCENE-HEIGHT (* 1/2 BASE-HEIGHT))
               MT-SCENE))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; delta-x : Dir Integer -> Integer
;; Compute the change in x position given an x position and direction
(check-expect (delta-x "left" 0) 0)
(check-expect (delta-x "left" INV-SPEED) (- INV-SPEED))
(check-expect (delta-x "right" 0) INV-SPEED)
(check-expect (delta-x "right" INV-MAX-X) 0)
(define (delta-x dir x)
  (cond [(string=? dir "left")
         (cond [(= x 0) 0]
               [else (- INV-SPEED)])]
        [(string=? dir "right")
         (cond [(= x INV-MAX-X) 0]
               [else INV-SPEED])]))

;; delta-y : Dir Integer -> Integer
;; Compute the change in y position given an x position and direction
(check-expect (delta-y "left" 0) INV-SPEED)
(check-expect (delta-y "right" 0) 0)
(check-expect (delta-y "right" INV-MAX-X) INV-SPEED)
(check-expect (delta-y "left" INV-MAX-X) 0)
(define (delta-y dir x)
  (cond [(string=? dir "left")
         (cond [(= x 0) INV-SPEED]
               [else 0])]
        [(string=? dir "right")
         (cond [(= x INV-MAX-X) INV-SPEED]
               [else 0])]))

;; dir-tock : Dir Integer -> Dir
;; Compute the new direction given current direction and x position
(check-expect (dir-tock "left" 0) "right")
(check-expect (dir-tock "right" 0) "right")
(check-expect (dir-tock "right" INV-MAX-X) "left")
(check-expect (dir-tock "left" INV-MAX-X) "left")
(define (dir-tock dir x)
  (cond [(string=? dir "left")
         (cond [(= x 0) "right"]
               [else "left"])]
        [(string=? dir "right")
         (cond [(= x INV-MAX-X) "left"]
               [else "right"])]))

;; base-key : Base KeyEvent -> Base
;; Move the base left and right in response to left & right arrow keys
(check-expect (base-key 0 "left") (max 0 (- 0 BASE-SPEED)))
(check-expect (base-key 1 "left") (max 0 (- 1 BASE-SPEED)))
(check-expect (base-key 0 "right")
              (min (- SCENE-WIDTH BASE-WIDTH) (+ 0 BASE-SPEED)))
(check-expect (base-key 5 "right")
              (min (- SCENE-WIDTH BASE-WIDTH) (+ 5 BASE-SPEED)))
(check-expect (base-key (- SCENE-WIDTH BASE-WIDTH) "right")
              (- SCENE-WIDTH BASE-WIDTH))

(check-expect (base-key 0 "a") 0)
(define (base-key b ke)
  (cond [(string=? ke "left")
         (max 0 (- b BASE-SPEED))]
        [(string=? ke "right")
         (min (- SCENE-WIDTH BASE-WIDTH) (+ b BASE-SPEED))]
        [else b]))

;; invader-tock : Invader -> Invader
;; Advance the invader one tick of time
(check-expect (invader-tock INV0) (make-invader
                                   10
                                   0
                                   "right"
                                   1
                                   40
                                   ))

(check-expect (invader-tock (make-invader 0 INV-SPEED "left" 1 4))
              (make-invader 0 (* 2 INV-SPEED) "right" 1 4))

(check-expect (invader-tock (make-invader 0 0 "left" 1 4))
              (make-invader 0 INV-SPEED "right" 1 4))
(define (invader-tock i)
  (make-invader (+ (invader-x i) (delta-x (invader-dir i) (invader-x i)))
                (+ (invader-y i) (delta-y (invader-dir i) (invader-x i)))
                (dir-tock (invader-dir i) (invader-x i))
                (invader-f i)
                (invader-n i)))

;; invaders-tock : Invaders -> Invaders
;; Advance the invaders one tick of time

(define INVSTOCK1
  (make-some-invs (invader-tock INV0)
                  (make-some-invs (invader-tock INV1)
                                  (make-some-invs (invader-tock INV2)
                                                  (make-no-invs)))))
(define INVSTOCK2
  (make-some-invs (invader-tock INV1)
                  (make-some-invs (invader-tock INV2)
                                  (make-some-invs (invader-tock INV3)
                                                  (make-no-invs)))))
(define INVSTOCK3
  (make-some-invs (invader-tock INV2)
                  (make-some-invs (invader-tock INV3)
                                  (make-some-invs (invader-tock INV4)
                                                  (make-no-invs)))))

(check-expect (invaders-tock INVADERS1) INVSTOCK1)
(check-expect (invaders-tock INVADERS2) INVSTOCK2)
(check-expect (invaders-tock INVADERS3) INVSTOCK3)



(define (invaders-tock i)
  (cond [(no-invs? i) (make-no-invs)]
        [(some-invs? i)
         (make-some-invs (invader-tock (some-invs-first i))
                         (invaders-tock (some-invs-rest i)))]))

;; invader-on-bottom? : Invader -> Boolean
;; Is the invader on the bottom of the scene?
(check-expect (invader-on-bottom? (make-invader 0 0 "left" 1 4)) #false)
(check-expect (invader-on-bottom? INVN) #true)
(define (invader-on-bottom? i)
  (= INV-MAX-Y (invader-y i)))

;; invaders-on-bottom? : Invaders -> Boolean
;; Is the invaders on the bottom of the scene?

(check-expect (invaders-on-bottom? INVADERS1) #false)
(check-expect (invaders-on-bottom? INVADERS2) #false)
(check-expect (invaders-on-bottom? INVADERS3) #false)
(check-expect (invaders-on-bottom? INVADERS4) #true)

(define (invaders-on-bottom? i)
  (cond[(no-invs? i) #false]
       [(some-invs? i)
        (or (invader-on-bottom? (some-invs-first i))
            (invaders-on-bottom? (some-invs-rest i)))]
       [else #false]))




;; base->shot : Base -> Shot
;; Compute the location of a shot fired from given base
(check-expect (base->shot 50) (make-posn (+ 50 BASE-X-OFF) BASE-Y-OFF))
(check-expect (base->shot 60) (make-posn (+ 60 BASE-X-OFF) BASE-Y-OFF))
(check-expect (base->shot -10) (make-posn 40 BASE-Y-OFF))
(define (base->shot b)
  (make-posn (+ b BASE-X-OFF) BASE-Y-OFF))

;; inv->shot : Invader -> Invader-Shot
;; Compute the location of a shot fired from given invader

(check-expect (inv->shot INV0) (make-posn  INV-X-OFF INV-Y-OFF))
(check-expect (inv->shot INV1) (make-posn (+ 10 INV-X-OFF) INV-Y-OFF))
(check-expect (inv->shot INVN) (make-posn  40 185))

(define (inv->shot i)
  (make-posn (+ (invader-x i) INV-X-OFF ) (+ (invader-y i) INV-Y-OFF )))

;; invs->shot : Invaders -> Invader-Shots
;; Compute the location of a shot fired from given invader

(check-expect (invs->shots INVADERS1)
              (make-some-inv-shots
               (make-posn 40 15)
               (make-some-inv-shots
                (make-posn 50 15)
                (make-some-inv-shots (make-posn 40 15)
                                     (make-no-inv-shots)))))

(define (invs->shots i)
  (cond[(no-invs? i) (make-no-inv-shots)]
       [(some-invs? i)
        (make-some-inv-shots (inv->shot (some-invs-first i))
                             (invs->shots (some-invs-rest i)))]))

;; should-invader-shoot? : Invader -> Boolean
;; Determines if Invader should shoot
(check-expect (should-invader-shoot? INV0) #false)
(check-expect (should-invader-shoot? INV2) #true)


(define (should-invader-shoot? i)
  (= (modulo (invader-f i) (invader-n i)) 0))

;; should-invaders-shoot? : Invaders -> Boolean
;; Determines if Invaders should shoot

(check-expect (should-invaders-shoot? INVADERS1) #true)
(check-expect (should-invaders-shoot? INVADERS2) #true)
(check-expect (should-invaders-shoot? INVADERS5) #false)

(define (should-invaders-shoot? i)
  (cond[(no-invs? i) #false]
       [(some-invs? i)
        (or (should-invader-shoot? (some-invs-first i))
            (should-invaders-shoot? (some-invs-rest i)))]))
         
;; new-invader: Invader -> Invader
;; Produces a New Invader

(check-expect (new-invader INV0) (make-invader 0 0 "right" 2 40
                                               ))
(check-expect (new-invader INV2) (make-invader 0 0 "right" 5 4
                                               ))

(define (new-invader i)
  (make-invader (invader-x i)
                (invader-y i)
                (invader-dir i)
                (+ (invader-f i) 1)
                (invader-n i)
                ))

;; new-inv-shot: Invader -> Invader-Shot
;; Returns new shot


(check-expect (new-inv-shot INV0) (make-no-inv-shots))
(check-expect (new-inv-shot INV2) (make-posn 40 15))
                                                        

(define (new-inv-shot i)
  (cond [(should-invader-shoot? i)
         (inv->shot i) ]
        [else (make-no-inv-shots)]))



;; new-invs-shots: Invaders -> Invader-Shots
;; Returns new list of shots



(define (new-invs-shots i)
  (cond[(no-invs? i) (make-no-inv-shots)]
       [(some-invs? i)
        (make-some-inv-shots (new-inv-shot (some-invs-first i))
                             (new-invs-shots (some-invs-rest i)))]))

;; new-invaders: Invaders -> Invaders
;; Produces a New Invaders

(check-expect (new-invaders INVADERS1)
              (make-some-invs
               (make-invader 0 0 "right" 2  40)
               (make-some-invs
                (make-invader INV-SPEED 0 "right" 3 6)
                (make-some-invs (make-invader 0 0 "right" 5  4 )
                                (make-no-invs)))))
              

(define (new-invaders i)
  (cond[(no-invs? i) (make-no-invs)]
       [(some-invs? i)
        (make-some-invs (new-invader  (some-invs-first i))
                        (new-invaders (some-invs-rest i)))]))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; game-draw : Game -> Image
;; Draw the game on an empty scene
#|
(check-expect (game-draw (make-game 0 (make-no-base-shots) (make-no-inv-shots) GAMEINVADERS 3))
              (shots-draw-on (make-no-base-shots) GAMEINVADERS
                             (invaders-draw-on GAMEINVADERS
                                               (base-draw 0)))) 
  |#  
(define (game-draw g)
  (shots-draw-on (game-base-shots g) (game-inv-shots g)
                 (invaders-draw-on (game-inv g)
                                   (base-draw (game-base g)))))




 
(check-expect (game-tock GAME1)
              (make-game 0
                         (shots-tock-base B-SHOTS1)
                         (shots-tock-invs (new-invs-shots GAMEINVADERS))
                         (invaders-tock (new-invaders GAMEINVADERS))
                         3))
                         
                                    
                                 

;; game-tock : Game -> Game
;; Advance the game one tick of time
(define (game-tock g)
  (cond [(any-shots-hit-invaders? (game-base-shots g) (game-inv g))
         NEW-GAME]
        [else (make-game 
               (game-base g)
               (shots-tock-base (game-base-shots g))
               (shots-tock-invs (new-invs-shots (game-inv g)))
               (invaders-tock (new-invaders (game-inv g)))
               (game-l g))]))



#|
               (cond[(any-shots-hit-base? (invs->shots (game-inv g)) (game-base g))
                     (sub1 (game-l g))]
                    [else (game-l g)]))]))


                     

|#


;;              (invaders-tock (new-invaders g (game-inv g)))
        
;; game-key : Game KeyEvent -> Game
;; Handle left/right arrow keys by moving base, space fires a shot if available

(define (game-key g ke)
  (make-game 
   (base-key (game-base g) ke)
   (cond [(string=? ke " ")
          (make-some-base-shots (base->shot (game-base g))
                                (game-base-shots g) )]
         [else (game-base-shots g)])
   (game-inv-shots g)
   (game-inv g)
   (game-l g)))



;; game-over? Game -> Boolean
;; Has the invader reached the bottom of the scene in this game?

(define (game-over? g)
  (or (invaders-on-bottom? (game-inv g))
      (= (game-l g) 0)))


(main 0)
    


