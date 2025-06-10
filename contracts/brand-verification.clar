;; Brand Verification Contract
;; Manages verification and registration of beauty product brands

(define-map verified-brands
  { brand-id: uint }
  {
    name: (string-ascii 100),
    owner: principal,
    verified: bool,
    verification-date: uint,
    license-number: (string-ascii 50)
  }
)

(define-map brand-counter uint uint)

(define-data-var next-brand-id uint u1)

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-BRAND-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-VERIFIED (err u102))

;; Register a new brand
(define-public (register-brand (name (string-ascii 100)) (license-number (string-ascii 50)))
  (let ((brand-id (var-get next-brand-id)))
    (map-set verified-brands
      { brand-id: brand-id }
      {
        name: name,
        owner: tx-sender,
        verified: false,
        verification-date: u0,
        license-number: license-number
      }
    )
    (var-set next-brand-id (+ brand-id u1))
    (ok brand-id)
  )
)

;; Verify a brand (admin function)
(define-public (verify-brand (brand-id uint))
  (match (map-get? verified-brands { brand-id: brand-id })
    brand-data
    (if (get verified brand-data)
      ERR-ALREADY-VERIFIED
      (begin
        (map-set verified-brands
          { brand-id: brand-id }
          (merge brand-data { verified: true, verification-date: block-height })
        )
        (ok true)
      )
    )
    ERR-BRAND-NOT-FOUND
  )
)

;; Get brand information
(define-read-only (get-brand (brand-id uint))
  (map-get? verified-brands { brand-id: brand-id })
)

;; Check if brand is verified
(define-read-only (is-brand-verified (brand-id uint))
  (match (map-get? verified-brands { brand-id: brand-id })
    brand-data (get verified brand-data)
    false
  )
)
