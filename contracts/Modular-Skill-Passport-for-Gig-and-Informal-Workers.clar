

(define-non-fungible-token skill-passport uint)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-TOKEN-OWNER (err u101))
(define-constant ERR-TOKEN-NOT-FOUND (err u102))
(define-constant ERR-NOT-AUTHORIZED (err u103))
(define-constant ERR-ALREADY-VERIFIED (err u104))
(define-constant ERR-INVALID-SKILL (err u105))
(define-constant ERR-ALREADY-ENDORSED (err u106))
(define-constant ERR-CANNOT-ENDORSE-OWN-SKILL (err u107))
(define-constant ERR-ENDORSEMENT-LIMIT-REACHED (err u108))

(define-data-var token-id-nonce uint u1)
(define-data-var contract-uri (optional (string-utf8 256)) none)

(define-map token-uris uint (string-utf8 256))
(define-map token-owners uint principal)
(define-map skills uint {
    skill-name: (string-ascii 100),
    skill-category: (string-ascii 50),
    verification-level: uint,
    issued-at: uint,
    expires-at: (optional uint),
    issuer: principal,
    metadata: (string-utf8 512)
})

(define-map verifiers principal bool)
(define-map worker-skills principal (list 50 uint))
(define-map skill-categories (string-ascii 50) bool)
(define-map skill-endorsements uint (list 20 principal))
(define-map endorser-count principal uint)

(define-read-only (get-last-token-id)
    (ok (- (var-get token-id-nonce) u1))
)

(define-read-only (get-token-uri (token-id uint))
    (ok (map-get? token-uris token-id))
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? skill-passport token-id))
)

(define-read-only (get-contract-uri)
    (ok (var-get contract-uri))
)

(define-read-only (get-skill-details (token-id uint))
    (ok (map-get? skills token-id))
)

(define-read-only (get-worker-skills (worker principal))
    (default-to (list) (map-get? worker-skills worker))
)

(define-read-only (is-verifier (verifier principal))
    (default-to false (map-get? verifiers verifier))
)

(define-read-only (is-skill-category-valid (category (string-ascii 50)))
    (default-to false (map-get? skill-categories category))
)

(define-read-only (get-skill-endorsements (token-id uint))
    (default-to (list) (map-get? skill-endorsements token-id))
)

(define-read-only (get-endorsement-count (token-id uint))
    (len (get-skill-endorsements token-id))
)

(define-read-only (get-endorser-activity (endorser principal))
    (default-to u0 (map-get? endorser-count endorser))
)

(define-read-only (has-endorsed-skill (endorser principal) (token-id uint))
    (is-some (index-of (get-skill-endorsements token-id) endorser))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) ERR-NOT-TOKEN-OWNER)
        (asserts! (is-eq sender (unwrap! (nft-get-owner? skill-passport token-id) ERR-TOKEN-NOT-FOUND)) ERR-NOT-TOKEN-OWNER)
        (try! (nft-transfer? skill-passport token-id sender recipient))
        (map-set token-owners token-id recipient)
        (unwrap-panic (update-worker-skills recipient token-id true))
        (unwrap-panic (update-worker-skills sender token-id false))
        (ok true)
    )
)

(define-public (add-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (map-set verifiers verifier true)
        (ok true)
    )
)

(define-public (remove-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (map-delete verifiers verifier)
        (ok true)
    )
)

(define-public (add-skill-category (category (string-ascii 50)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (map-set skill-categories category true)
        (ok true)
    )
)

(define-public (issue-skill-nft 
    (recipient principal)
    (skill-name (string-ascii 100))
    (skill-category (string-ascii 50))
    (verification-level uint)
    (expires-at (optional uint))
    (metadata (string-utf8 512))
    (token-uri (string-utf8 256))
)
    (let
        (
            (token-id (var-get token-id-nonce))
        )
        (asserts! (is-verifier tx-sender) ERR-NOT-AUTHORIZED)
        (asserts! (is-skill-category-valid skill-category) ERR-INVALID-SKILL)
        (try! (nft-mint? skill-passport token-id recipient))
        (map-set token-owners token-id recipient)
        (map-set token-uris token-id token-uri)
        (map-set skills token-id {
            skill-name: skill-name,
            skill-category: skill-category,
            verification-level: verification-level,
            issued-at: stacks-block-height,
            expires-at: expires-at,
            issuer: tx-sender,
            metadata: metadata
        })
        (unwrap-panic (update-worker-skills recipient token-id true))
        (var-set token-id-nonce (+ token-id u1))
        (ok token-id)
    )
)

(define-public (verify-skill (token-id uint) (new-verification-level uint))
    (let
        (
            (skill-details (unwrap! (map-get? skills token-id) ERR-TOKEN-NOT-FOUND))
        )
        (asserts! (is-verifier tx-sender) ERR-NOT-AUTHORIZED)
        (asserts! (> new-verification-level (get verification-level skill-details)) ERR-ALREADY-VERIFIED)
        (map-set skills token-id (merge skill-details { 
            verification-level: new-verification-level,
            issuer: tx-sender
        }))
        (ok true)
    )
)

(define-public (update-skill-metadata (token-id uint) (new-metadata (string-utf8 512)))
    (let
        (
            (skill-details (unwrap! (map-get? skills token-id) ERR-TOKEN-NOT-FOUND))
            (token-owner (unwrap! (nft-get-owner? skill-passport token-id) ERR-TOKEN-NOT-FOUND))
        )
        (asserts! (or (is-eq tx-sender token-owner) (is-verifier tx-sender)) ERR-NOT-AUTHORIZED)
        (map-set skills token-id (merge skill-details { metadata: new-metadata }))
        (ok true)
    )
)

(define-public (set-contract-uri (new-uri (optional (string-utf8 256))))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (var-set contract-uri new-uri)
        (ok true)
    )
)

(define-public (endorse-skill (token-id uint))
    (let
        (
            (skill-owner (unwrap! (nft-get-owner? skill-passport token-id) ERR-TOKEN-NOT-FOUND))
            (current-endorsements (get-skill-endorsements token-id))
            (endorser-activity (get-endorser-activity tx-sender))
        )
        (asserts! (not (is-eq tx-sender skill-owner)) ERR-CANNOT-ENDORSE-OWN-SKILL)
        (asserts! (not (has-endorsed-skill tx-sender token-id)) ERR-ALREADY-ENDORSED)
        (asserts! (< (len current-endorsements) u20) ERR-ENDORSEMENT-LIMIT-REACHED)
        (asserts! (> (len (get-worker-skills tx-sender)) u0) ERR-NOT-AUTHORIZED)
        (map-set skill-endorsements token-id (unwrap-panic (as-max-len? (append current-endorsements tx-sender) u20)))
        (map-set endorser-count tx-sender (+ endorser-activity u1))
        (ok true)
    )
)

(define-public (remove-endorsement (token-id uint))
    (let
        (
            (endorser-activity (get-endorser-activity tx-sender))
        )
        (begin
            (asserts! (has-endorsed-skill tx-sender token-id) ERR-TOKEN-NOT-FOUND)
            (map-set skill-endorsements token-id (list))
            (map-set endorser-count tx-sender (- endorser-activity u1))
            (ok true)
        )
    )
)

(define-private (update-worker-skills (worker principal) (target-token-id uint) (add bool))
    (let
        (
            (current-skills (get-worker-skills worker))
        )
        (if add
            (begin
                (map-set worker-skills worker (unwrap-panic (as-max-len? (append current-skills target-token-id) u50)))
                (ok true)
            )
            (begin
                (map-set worker-skills worker (list))
                (ok true)
            )
        )
    )
)

(begin
    (map-set verifiers CONTRACT-OWNER true)
    (map-set skill-categories "construction" true)
    (map-set skill-categories "cooking" true)
    (map-set skill-categories "cleaning" true)
    (map-set skill-categories "delivery" true)
    (map-set skill-categories "handyman" true)
    (map-set skill-categories "gardening" true)
    (map-set skill-categories "childcare" true)
    (map-set skill-categories "eldercare" true)
    (map-set skill-categories "tutoring" true)
    (map-set skill-categories "driving" true)
    (map-set skill-categories "tech-support" true)
    (map-set skill-categories "freelance-writing" true)
    (map-set skill-categories "photography" true)
    (map-set skill-categories "marketing" true)
    (map-set skill-categories "design" true)
)