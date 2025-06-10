;; Ingredient Tracking Contract
;; Tracks individual ingredients and their properties

(define-map ingredients
  { ingredient-id: uint }
  {
    name: (string-ascii 100),
    category: (string-ascii 50),
    cas-number: (string-ascii 20),
    added-by: principal,
    added-date: uint,
    active: bool
  }
)

(define-map product-ingredients
  { product-id: uint, ingredient-id: uint }
  {
    concentration: uint,
    purpose: (string-ascii 100),
    added-date: uint
  }
)

(define-data-var next-ingredient-id uint u1)

;; Error constants
(define-constant ERR-INGREDIENT-NOT-FOUND (err u200))
(define-constant ERR-INVALID-CONCENTRATION (err u201))
(define-constant ERR-ALREADY-EXISTS (err u202))

;; Add new ingredient
(define-public (add-ingredient (name (string-ascii 100)) (category (string-ascii 50)) (cas-number (string-ascii 20)))
  (let ((ingredient-id (var-get next-ingredient-id)))
    (map-set ingredients
      { ingredient-id: ingredient-id }
      {
        name: name,
        category: category,
        cas-number: cas-number,
        added-by: tx-sender,
        added-date: block-height,
        active: true
      }
    )
    (var-set next-ingredient-id (+ ingredient-id u1))
    (ok ingredient-id)
  )
)

;; Add ingredient to product
(define-public (add-ingredient-to-product (product-id uint) (ingredient-id uint) (concentration uint) (purpose (string-ascii 100)))
  (if (and (> concentration u0) (<= concentration u10000)) ;; concentration in basis points (0-100%)
    (if (is-some (map-get? ingredients { ingredient-id: ingredient-id }))
      (begin
        (map-set product-ingredients
          { product-id: product-id, ingredient-id: ingredient-id }
          {
            concentration: concentration,
            purpose: purpose,
            added-date: block-height
          }
        )
        (ok true)
      )
      ERR-INGREDIENT-NOT-FOUND
    )
    ERR-INVALID-CONCENTRATION
  )
)

;; Get ingredient details
(define-read-only (get-ingredient (ingredient-id uint))
  (map-get? ingredients { ingredient-id: ingredient-id })
)

;; Get product ingredient details
(define-read-only (get-product-ingredient (product-id uint) (ingredient-id uint))
  (map-get? product-ingredients { product-id: product-id, ingredient-id: ingredient-id })
)
