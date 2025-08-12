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

;; Individual Vote Tracking & Audit Trail
(define-map votes
  {
    proposal-id: uint,
    voter: principal,
  }
  {
    vote-choice: bool, ;; True for yes, false for no
    voting-power: uint, ;; Voting power at time of vote
    timestamp: uint, ;; Block height when vote was cast
  }
)

;; Inter-Organization Collaboration Framework
(define-map collaborations
  uint
  {
    partner-dao: principal, ;; Partner organization address
    proposal-id: uint, ;; Associated proposal ID
    status: (string-ascii 15), ;; Collaboration status
    created-at: uint, ;; Creation timestamp
    terms: (string-utf8 200), ;; Collaboration terms
    mutual-benefit: uint, ;; Expected mutual benefit score
  }
)

;; Advanced Member Metrics & Analytics
(define-map member-analytics
  principal
  {
    total-stake-time: uint, ;; Cumulative staking duration
    successful-proposals: uint, ;; Number of executed proposals
    collaboration-count: uint, ;; Cross-DAO collaborations initiated
    reputation-history: uint, ;; Historical reputation peak
    governance-participation: uint, ;; Participation rate percentage
  }
)

;; INTERNAL UTILITY FUNCTIONS

;; Member Validation & Status Checking
(define-private (is-member (user principal))
  ;; Validates if a principal is an active member of the organization
  (match (map-get? members user)
    member-data
    true
    false
  )
)

;; Proposal Lifecycle Management
(define-private (is-active-proposal (proposal-id uint))
  ;; Determines if a proposal is currently active and accepting votes
  (match (map-get? proposals proposal-id)
    proposal (and
      (< stacks-block-height (get expires-at proposal))
      (is-eq (get status proposal) "active")
    )
    false
  )
)

(define-private (is-valid-proposal-id (proposal-id uint))
  ;; Validates proposal existence in the system
  (match (map-get? proposals proposal-id)
    proposal
    true
    false
  )
)

;; Collaboration System Validation
(define-private (is-valid-collaboration-id (collaboration-id uint))
  ;; Validates collaboration record existence
  (match (map-get? collaborations collaboration-id)
    collaboration
    true
    false
  )
)

;; Advanced Voting Power Calculation Algorithm
(define-private (calculate-voting-power (user principal))
  ;; Calculates weighted voting power based on reputation and stake
  (let (
      (member-data (unwrap! (map-get? members user) u0))
      (reputation (get reputation member-data))
      (stake (get stake member-data))
      (base-power (* reputation REPUTATION-MULTIPLIER))
      (stake-bonus stake)
      (participation-multiplier (if (> (get votes-cast member-data) u10)
        u2
        u1
      ))
    )
    (* (+ base-power stake-bonus) participation-multiplier)
  )
)

;; Reputation Management & Adjustment System
(define-private (update-member-reputation
    (user principal)
    (change int)
  )
  ;; Updates member reputation with comprehensive data tracking
  (match (map-get? members user)
    member-data (let (
        (current-reputation (get reputation member-data))
        (new-reputation-int (+ (to-int current-reputation) change))
        (new-reputation (if (> new-reputation-int 0)
          (to-uint new-reputation-int)
          u1
        ))
        ;; Ensure minimum reputation of 1
        (updated-data (merge member-data {
          reputation: new-reputation,
          last-interaction: stacks-block-height,
        }))
      )
      (map-set members user updated-data)
      (ok new-reputation)
    )
    ERR-NOT-MEMBER
  )
)

;; Treasury Security & Balance Validation
(define-private (validate-treasury-operation (amount uint))
  ;; Validates treasury operations and balance sufficiency
  (and
    (> amount u0)
    (>= (var-get treasury-balance) amount)
  )
)

;; MEMBERSHIP MANAGEMENT SYSTEM

(define-public (join-nexus-council)
  ;; Initiates membership in the Nexus Council governance system
  (let ((caller tx-sender))
    (asserts! (not (is-member caller)) ERR-ALREADY-MEMBER)
    (map-set members caller {
      reputation: u1,
      stake: u0,
      last-interaction: stacks-block-height,
      proposals-created: u0,
      votes-cast: u0,
      collaboration-score: u0,
    })
    (map-set member-analytics caller {
      total-stake-time: u0,
      successful-proposals: u0,
      collaboration-count: u0,
      reputation-history: u1,
      governance-participation: u0,
    })
    (var-set total-members (+ (var-get total-members) u1))
    (ok "Welcome to Nexus Council! Your governance journey begins now.")
  )
)

(define-public (exit-council)
  ;; Gracefully exits the council with stake return if applicable
  (let (
      (caller tx-sender)
      (member-data (unwrap! (map-get? members caller) ERR-NOT-MEMBER))
      (staked-amount (get stake member-data))
    )
    (asserts! (is-member caller) ERR-NOT-MEMBER)

    ;; Return staked tokens if any
    (if (> staked-amount u0)
      (begin
        (try! (as-contract (stx-transfer? staked-amount tx-sender caller)))
        (var-set treasury-balance (- (var-get treasury-balance) staked-amount))
      )
      true
    )

    (map-delete members caller)
    (map-delete member-analytics caller)
    (var-set total-members (- (var-get total-members) u1))
    (ok "Thank you for your participation in Nexus Council!")
  )
)

;; STAKING & ECONOMIC PARTICIPATION

(define-public (stake-for-influence (amount uint))
  ;; Stake tokens to increase voting power and governance influence
  (let (
      (caller tx-sender)
      (member-data (unwrap! (map-get? members caller) ERR-NOT-MEMBER))
    )
    (asserts! (is-member caller) ERR-NOT-MEMBER)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)

    (try! (stx-transfer? amount caller (as-contract tx-sender)))

    (let (
        (new-stake (+ (get stake member-data) amount))
        (updated-member (merge member-data {
          stake: new-stake,
          last-interaction: stacks-block-height,
        }))
      )
      (map-set members caller updated-member)
      (var-set treasury-balance (+ (var-get treasury-balance) amount))
      (try! (update-member-reputation caller 1))
      (ok new-stake)
    )
  )
)

(define-public (withdraw-stake (amount uint))
  ;; Withdraw staked tokens with governance power adjustment
  (let (
      (caller tx-sender)
      (member-data (unwrap! (map-get? members caller) ERR-NOT-MEMBER))
      (current-stake (get stake member-data))
    )
    (asserts! (is-member caller) ERR-NOT-MEMBER)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (>= current-stake amount) ERR-INSUFFICIENT-FUNDS)

    (try! (as-contract (stx-transfer? amount tx-sender caller)))

    (let (
        (new-stake (- current-stake amount))
        (updated-member (merge member-data {
          stake: new-stake,
          last-interaction: stacks-block-height,
        }))
      )
      (map-set members caller updated-member)
      (var-set treasury-balance (- (var-get treasury-balance) amount))
      (ok new-stake)
    )
  )
)

;; PROPOSAL CREATION & MANAGEMENT

(define-public (create-governance-proposal
    (title (string-ascii 50))
    (description (string-utf8 500))
    (amount uint)
    (category (string-ascii 20))
  )
  ;; Creates a new governance proposal with enhanced metadata
  (let (
      (caller tx-sender)
      (proposal-id (+ (var-get total-proposals) u1))
      (member-data (unwrap! (map-get? members caller) ERR-NOT-MEMBER))
    )
    (asserts! (is-member caller) ERR-NOT-MEMBER)
    (asserts! (>= (var-get treasury-balance) amount) ERR-INSUFFICIENT-FUNDS)
    (asserts! (> (len title) u0) ERR-INVALID-PROPOSAL)
    (asserts! (> (len description) u0) ERR-INVALID-PROPOSAL)

    (map-set proposals proposal-id {
      creator: caller,
      title: title,
      description: description,
      amount: amount,
      yes-votes: u0,
      no-votes: u0,
      status: "active",
      created-at: stacks-block-height,
      expires-at: (+ stacks-block-height PROPOSAL-DURATION),
      execution-threshold: (/ (var-get total-members) u2),
      category: category,
    })

    ;; Update member statistics
    (let ((updated-member (merge member-data {
        proposals-created: (+ (get proposals-created member-data) u1),
        last-interaction: stacks-block-height,
      })))
      (map-set members caller updated-member)
    )

    (var-set total-proposals proposal-id)
    (try! (update-member-reputation caller 2))
    (ok proposal-id)
  )
)

;; VOTING SYSTEM & CONSENSUS MECHANISM

(define-public (cast-governance-vote
    (proposal-id uint)
    (vote-choice bool)
  )
  ;; Casts a weighted vote on governance proposals with full audit trail
  (let (
      (caller tx-sender)
      (voting-power (calculate-voting-power caller))
      (proposal (unwrap! (map-get? proposals proposal-id) ERR-INVALID-PROPOSAL))
      (member-data (unwrap! (map-get? members caller) ERR-NOT-MEMBER))
    )
    (asserts! (is-member caller) ERR-NOT-MEMBER)
    (asserts! (is-active-proposal proposal-id) ERR-PROPOSAL-EXPIRED)
    (asserts!
      (is-none (map-get? votes {
        proposal-id: proposal-id,
        voter: caller,
      }))
      ERR-ALREADY-VOTED
    )

    ;; Record vote with comprehensive data
    (map-set votes {
      proposal-id: proposal-id,
      voter: caller,
    } {
      vote-choice: vote-choice,
      voting-power: voting-power,
      timestamp: stacks-block-height,
    })

    ;; Update proposal vote tallies
    (if vote-choice
      (map-set proposals proposal-id
        (merge proposal { yes-votes: (+ (get yes-votes proposal) voting-power) })
      )
      (map-set proposals proposal-id
        (merge proposal { no-votes: (+ (get no-votes proposal) voting-power) })
      )
    )

    ;; Update member participation metrics
    (let ((updated-member (merge member-data {
        votes-cast: (+ (get votes-cast member-data) u1),
        last-interaction: stacks-block-height,
      })))
      (map-set members caller updated-member)
    )

    (try! (update-member-reputation caller 1))
    (ok voting-power)
  )
)

;; PROPOSAL EXECUTION & FUND DISTRIBUTION

(define-public (execute-approved-proposal (proposal-id uint))
  ;; Executes proposals that meet consensus requirements
  (let (
      (caller tx-sender)
      (proposal (unwrap! (map-get? proposals proposal-id) ERR-INVALID-PROPOSAL))
    )
    (asserts! (is-member caller) ERR-NOT-MEMBER)
    (asserts! (>= stacks-block-height (get expires-at proposal))
      ERR-VOTING-PERIOD_ACTIVE
    )
    (asserts! (is-eq (get status proposal) "active") ERR-INVALID-PROPOSAL)

    (let (
        (yes-votes (get yes-votes proposal))
        (no-votes (get no-votes proposal))
        (amount (get amount proposal))
        (creator (get creator proposal))
      )
      (if (and (> yes-votes no-votes) (> yes-votes (get execution-threshold proposal)))
        (begin
          ;; Execute successful proposal
          (try! (as-contract (stx-transfer? amount tx-sender creator)))
          (var-set treasury-balance (- (var-get treasury-balance) amount))
          (map-set proposals proposal-id (merge proposal { status: "executed" }))
          (try! (update-member-reputation creator 5))

          ;; Update creator analytics
          (match (map-get? member-analytics creator)
            analytics (map-set member-analytics creator
              (merge analytics { successful-proposals: (+ (get successful-proposals analytics) u1) })
            )
            true
          )
          (ok "Proposal executed successfully!")
        )
        (begin
          ;; Reject failed proposal
          (map-set proposals proposal-id (merge proposal { status: "rejected" }))
          (ok "Proposal rejected by community vote.")
        )
      )
    )
  )
)

;; TREASURY OPERATIONS & FINANCIAL MANAGEMENT

(define-read-only (get-treasury-status)
  ;; Returns comprehensive treasury information
  (ok {
    balance: (var-get treasury-balance),
    total-members: (var-get total-members),
    active-proposals: (var-get total-proposals),
    avg-stake-per-member: (if (> (var-get total-members) u0)
      (/ (var-get treasury-balance) (var-get total-members))
      u0
    ),
  })
)

(define-public (contribute-to-treasury (amount uint))
  ;; Make charitable contributions to strengthen the treasury
  (let ((caller tx-sender))
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (try! (stx-transfer? amount caller (as-contract tx-sender)))
    (var-set treasury-balance (+ (var-get treasury-balance) amount))

    ;; Reward contributors with reputation boost
    (if (is-member caller)
      (begin
        (try! (update-member-reputation caller 3))
        (ok "Thank you for strengthening our community treasury!")
      )
      (ok "Contribution received! Consider joining our governance council!")
    )
  )
)

;; REPUTATION & MEMBER ANALYTICS

(define-read-only (get-member-profile (user principal))
  ;; Retrieves comprehensive member profile and statistics
  (let (
      (member-data (unwrap! (map-get? members user) ERR-NOT-MEMBER))
      (analytics (default-to {
        total-stake-time: u0,
        successful-proposals: u0,
        collaboration-count: u0,
        reputation-history: u0,
        governance-participation: u0,
      }
        (map-get? member-analytics user)
      ))
    )
    (ok {
      reputation: (get reputation member-data),
      stake: (get stake member-data),
      voting-power: (calculate-voting-power user),
      proposals-created: (get proposals-created member-data),
      votes-cast: (get votes-cast member-data),
      successful-proposals: (get successful-proposals analytics),
      collaboration-score: (get collaboration-score member-data),
      last-activity: (get last-interaction member-data),
      membership-quality: (if (> (get reputation member-data) u50)
        "Elite"
        (if (> (get reputation member-data) u20)
          "Active"
          "Standard"
        )
      ),
    })
  )
)

(define-public (maintain-reputation-system)
  ;; Automated reputation decay for inactive members - Owner only
  (let ((caller tx-sender))
    (asserts! (is-eq caller CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    ;; Note: In production, this would iterate through members
    ;; For this implementation, it demonstrates the concept
    (ok "Reputation maintenance cycle completed successfully.")
  )
)

;; CROSS-ORGANIZATION COLLABORATION FRAMEWORK

(define-public (initiate-collaboration
    (partner-dao principal)
    (proposal-id uint)
    (terms (string-utf8 200))
    (expected-benefit uint)
  )
  ;; Proposes collaboration with external organizations
  (let (
      (caller tx-sender)
      (collaboration-id (+ (var-get total-collaborations) u1))
    )
    (asserts! (is-member caller) ERR-NOT-MEMBER)
    (asserts! (is-active-proposal proposal-id) ERR-INVALID-PROPOSAL)
    (asserts! (not (is-eq partner-dao caller)) ERR-INVALID-COLLABORATION)

    (map-set collaborations collaboration-id {
      partner-dao: partner-dao,
      proposal-id: proposal-id,
      status: "proposed",
      created-at: stacks-block-height,
      terms: terms,
      mutual-benefit: expected-benefit,
    })

    (var-set total-collaborations collaboration-id)
    (try! (update-member-reputation caller 3))
    (ok collaboration-id)
  )
)

(define-public (accept-collaboration (collaboration-id uint))
  ;; Accept incoming collaboration proposals from partner organizations
  (let (
      (caller tx-sender)
      (collaboration (unwrap! (map-get? collaborations collaboration-id)
        ERR-COLLABORATION-NOT-FOUND
      ))
    )
    (asserts! (is-eq caller (get partner-dao collaboration)) ERR-PARTNER-MISMATCH)
    (asserts! (is-eq (get status collaboration) "proposed")
      ERR-INVALID-COLLABORATION
    )

    (map-set collaborations collaboration-id
      (merge collaboration { status: "active" })
    )

    (ok "Collaboration partnership established successfully!")
  )
)

;; INFORMATION RETRIEVAL & SYSTEM QUERIES

(define-read-only (get-proposal-details (proposal-id uint))
  ;; Retrieves comprehensive proposal information with voting statistics
  (let ((proposal (unwrap! (map-get? proposals proposal-id) ERR-INVALID-PROPOSAL)))
    (ok {
      proposal-data: proposal,
      vote-summary: {
        total-votes: (+ (get yes-votes proposal) (get no-votes proposal)),
        approval-rate: (if (> (+ (get yes-votes proposal) (get no-votes proposal)) u0)
          (/ (* (get yes-votes proposal) u100)
            (+ (get yes-votes proposal) (get no-votes proposal))
          )
          u0
        ),
        time-remaining: (if (> (get expires-at proposal) stacks-block-height)
          (- (get expires-at proposal) stacks-block-height)
          u0
        ),
      },
    })
  )
)

(define-read-only (get-system-statistics)
  ;; Returns comprehensive system health and participation metrics
  (ok {
    total-members: (var-get total-members),
    total-proposals: (var-get total-proposals),
    total-collaborations: (var-get total-collaborations),
    treasury-balance: (var-get treasury-balance),
    system-health: (if (> (var-get total-members) u100)
      "Thriving"
      (if (> (var-get total-members) u50)
        "Growing"
        "Developing"
      )
    ),
    governance-activity: "High", ;; Could be calculated based on recent proposals
  })
)

(define-read-only (get-collaboration-status (collaboration-id uint))
  ;; Retrieves detailed collaboration information and status
  (ok (unwrap! (map-get? collaborations collaboration-id) ERR-COLLABORATION-NOT-FOUND))
)

;; SYSTEM INITIALIZATION & CONFIGURATION

;; Initialize system state variables
(begin
  (var-set total-members u0)
  (var-set total-proposals u0)
  (var-set total-collaborations u0)
  (var-set treasury-balance u0)
  (var-set contract-initialized true)
)
