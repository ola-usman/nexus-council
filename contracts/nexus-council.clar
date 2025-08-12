;; Title: Nexus Council - Advanced Decentralized Governance Platform
;;
;; Summary: A next-generation governance framework that revolutionizes
;; decentralized decision-making through innovative reputation mechanics,
;; dynamic treasury management, and seamless inter-organization collaboration.
;;
;; Description: Nexus Council redefines organizational governance by combining
;; traditional voting mechanisms with cutting-edge reputation algorithms and
;; cross-platform partnership capabilities. Members earn influence through
;; meaningful participation, stake assets for enhanced voting power, and
;; collaborate across organizational boundaries. The platform features
;; automatic reputation decay for inactive participants, weighted voting
;; based on contribution history, and secure treasury operations with
;; transparent fund allocation. Built for the future of decentralized
;; organizations seeking scalable, fair, and efficient governance solutions.
;;
;; Key Features:
;; - Dynamic reputation-based voting power calculation
;; - Time-locked proposal execution with community consensus
;; - Cross-organizational collaboration protocols
;; - Automated member activity tracking and reputation adjustment
;; - Secure staking mechanisms with flexible withdrawal options
;; - Comprehensive treasury management with donation incentives

;; SYSTEM CONSTANTS & ERROR CODES

;; Core System Configuration
(define-constant CONTRACT-OWNER tx-sender)
(define-constant PROPOSAL-DURATION u1440) ;; Blocks until proposal expiration
(define-constant REPUTATION-MULTIPLIER u10) ;; Reputation weight in voting power
(define-constant INACTIVITY-THRESHOLD u4320) ;; Blocks before reputation decay

;; Authorization & Access Control Errors
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-OWNERSHIP-REQUIRED (err u101))

;; Membership Management Errors  
(define-constant ERR-ALREADY-MEMBER (err u102))
(define-constant ERR-NOT-MEMBER (err u103))
(define-constant ERR-MEMBER-NOT-FOUND (err u104))

;; Proposal Lifecycle Errors
(define-constant ERR-INVALID-PROPOSAL (err u105))
(define-constant ERR-PROPOSAL-EXPIRED (err u106))
(define-constant ERR-PROPOSAL-NOT-FOUND (err u107))
(define-constant ERR-ALREADY-VOTED (err u108))
(define-constant ERR-VOTING-PERIOD_ACTIVE (err u109))

;; Financial & Treasury Errors
(define-constant ERR-INSUFFICIENT-FUNDS (err u110))
(define-constant ERR-INVALID-AMOUNT (err u111))
(define-constant ERR-TRANSFER-FAILED (err u112))
(define-constant ERR-TREASURY-LOCKED (err u113))

;; Collaboration & Partnership Errors
(define-constant ERR-INVALID-COLLABORATION (err u114))
(define-constant ERR-COLLABORATION-NOT-FOUND (err u115))
(define-constant ERR-PARTNER-MISMATCH (err u116))

;; GLOBAL STATE VARIABLES

(define-data-var total-members uint u0)
(define-data-var total-proposals uint u0)
(define-data-var total-collaborations uint u0)
(define-data-var treasury-balance uint u0)
(define-data-var contract-initialized bool false)

;; CORE DATA STRUCTURES

;; Member Profile & Participation Tracking
(define-map members
  principal
  {
    reputation: uint, ;; Accumulated reputation points
    stake: uint, ;; Currently staked tokens
    last-interaction: uint, ;; Block height of last activity
    proposals-created: uint, ;; Total proposals created by member
    votes-cast: uint, ;; Total votes cast by member
    collaboration-score: uint, ;; Cross-DAO collaboration participation
  }
)

;; Comprehensive Proposal Management
(define-map proposals
  uint
  {
    creator: principal, ;; Proposal originator
    title: (string-ascii 50), ;; Proposal title
    description: (string-utf8 500), ;; Detailed proposal description
    amount: uint, ;; Requested funding amount
    yes-votes: uint, ;; Weighted yes votes
    no-votes: uint, ;; Weighted no votes
    status: (string-ascii 15), ;; Current proposal status
    created-at: uint, ;; Creation block height
    expires-at: uint, ;; Expiration block height
    execution-threshold: uint, ;; Required votes for execution
    category: (string-ascii 20), ;; Proposal category/type
  }
)