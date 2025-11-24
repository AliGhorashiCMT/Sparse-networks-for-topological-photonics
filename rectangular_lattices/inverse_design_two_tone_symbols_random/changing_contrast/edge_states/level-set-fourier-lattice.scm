(define-param rvecs    (list (vector3 1 0 0) (vector3 0 1 0) (vector3 0 0 1)))
(define-param uc-gvecs (list (vector3 0 0 0))) ; initialized as constant function
(define-param uc-coefs (list 1.0+0.0i))
(define-param uc-level  0.0)
(define-param epsin    10.0)
(define-param epsout    1.0)
(define-param epsin-diag     '()) ; a vector3:  (εxx εyy εzz) [Cartesian axes]
(define-param epsin-offdiag  '()) ; a cvector3: (εxy εxz εyz) [Cartesian axes]
(define-param epsout-diag    '()) ; a vector3:  (εxx εyy εzz) [Cartesian axes]
(define-param epsout-offdiag '()) ; a cvector3: (εxy εxz εyz) [Cartesian axes]
(define-param medianeps 0)
(define-param relativeshift 0.5)
(define-param cladding 1)
(cond
    ((equal? dim 2) ; 2D
        (set! geometry-lattice (make lattice
            (size 1 supercell no-size)
            (basis1 (list-ref rvecs 0)) (basis2 (list-ref rvecs 1))
            (basis-size (vector3-norm (list-ref rvecs 0)) (vector3-norm (list-ref rvecs 1)) 1)
        ))
    )
)

(add-to-load-path ".") ; ensure the ctl directory is in load path (+ avoid issues w/ paths relative to current working dir)
(load "calc-fourier-sum-fast.scm")

(define (level-set-eps r)
     (cond ((> (calc-fourier-sum-fast (vector3 (vector3-y r) (vector3-x r))) medianeps) epsout) (else epsin)) ; try to replace the places where it goes below vacuum 
)
(define (level-set-eps2 r)
    (define x (vector3-x r))
    (define y (vector3-y r))  
    (define xabs (abs x))
    (define yabs (abs y))
    (cond ( (< yabs cladding)
	(level-set-eps (vector3 x (+ y relativeshift))))
    (else
	(level-set-eps (vector3 x y))
    ))
)
(set! default-material (make material-function (epsilon-func level-set-eps2)))
