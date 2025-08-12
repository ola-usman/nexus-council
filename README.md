# Nexus Council

[![Clarity](https://img.shields.io/badge/Clarity-v3-blue)](https://docs.stacks.co/clarity)
[![License: ISC](https://img.shields.io/badge/License-ISC-yellow.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-Vitest-green)](https://vitest.dev/)

> **Advanced Decentralized Governance Platform**  
> A next-generation governance framework that revolutionizes decentralized decision-making through innovative reputation mechanics, dynamic treasury management, and seamless inter-organization collaboration.

## 🌟 Overview

Nexus Council redefines organizational governance by combining traditional voting mechanisms with cutting-edge reputation algorithms and cross-platform partnership capabilities. Members earn influence through meaningful participation, stake assets for enhanced voting power, and collaborate across organizational boundaries.

### Key Differentiators

- **🏆 Dynamic Reputation System**: Merit-based influence that grows with meaningful participation
- **⚖️ Weighted Voting**: Sophisticated voting power calculation based on reputation and stake
- **🤝 Cross-DAO Collaboration**: Seamless partnerships between decentralized organizations
- **💰 Intelligent Treasury**: Automated fund management with transparent allocation
- **📊 Comprehensive Analytics**: Deep insights into member participation and governance health
- **🔒 Security-First Design**: Battle-tested security patterns and fail-safe mechanisms

## 🚀 Features

### Core Governance

- **Membership Management**: Join, exit, and member status tracking
- **Proposal Lifecycle**: Creation, voting, and execution of governance proposals
- **Weighted Voting System**: Reputation and stake-based voting power calculation
- **Time-locked Execution**: Community consensus requirements for proposal execution

### Economic Layer

- **Staking Mechanism**: Stake STX tokens to increase voting influence
- **Treasury Management**: Secure fund allocation and donation handling
- **Flexible Withdrawals**: Withdraw staked tokens with governance power adjustments
- **Economic Incentives**: Reward active participation and meaningful contributions

### Advanced Features

- **Reputation Engine**: Automatic reputation tracking and decay for inactive members
- **Collaboration Framework**: Inter-organization partnership protocols
- **Member Analytics**: Comprehensive participation metrics and performance tracking
- **System Health Monitoring**: Real-time governance activity and treasury status

## 📋 Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) v2.0+
- [Node.js](https://nodejs.org/) v18+
- [Stacks CLI](https://docs.stacks.co/build/cli) (optional)

## 🛠️ Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/ola-usman/nexus-council.git
   cd nexus-council
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Verify installation**

   ```bash
   clarinet check
   ```

## 🧪 Testing

### Run all tests

```bash
npm test
```

### Run tests with coverage

```bash
npm run test:report
```

### Watch mode for development

```bash
npm run test:watch
```

### Check contract syntax

```bash
clarinet check
```

## 📖 Usage

### Basic Contract Interaction

#### Join the Council

```clarity
(contract-call? .nexus-council join-nexus-council)
```

#### Stake Tokens for Voting Power

```clarity
(contract-call? .nexus-council stake-for-influence u1000000) ;; 1 STX
```

#### Create a Proposal

```clarity
(contract-call? .nexus-council create-governance-proposal
  "Community Fund Allocation"
  "Proposal to allocate 50 STX for community development initiatives"
  u50000000  ;; 50 STX
  "treasury"
)
```

#### Vote on Proposals

```clarity
(contract-call? .nexus-council cast-governance-vote u1 true) ;; Vote yes on proposal #1
```

#### Execute Approved Proposals

```clarity
(contract-call? .nexus-council execute-approved-proposal u1)
```

### Advanced Usage Examples

#### Check Member Profile

```clarity
(contract-call? .nexus-council get-member-profile 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

#### Initiate Cross-DAO Collaboration

```clarity
(contract-call? .nexus-council initiate-collaboration
  'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG  ;; Partner DAO
  u1  ;; Associated proposal ID
  "Joint treasury management initiative"
  u75  ;; Expected benefit score
)
```

#### Monitor Treasury Status

```clarity
(contract-call? .nexus-council get-treasury-status)
```

## 🏗️ Architecture

### Smart Contract Structure

```text
nexus-council.clar
├── Constants & Error Codes
├── Data Variables
├── Core Data Structures
│   ├── Members Map
│   ├── Proposals Map
│   ├── Votes Map
│   ├── Collaborations Map
│   └── Member Analytics Map
├── Utility Functions
├── Public Functions
│   ├── Membership Management
│   ├── Staking Operations
│   ├── Proposal Management
│   ├── Voting System
│   ├── Treasury Operations
│   └── Collaboration Framework
└── Read-Only Functions
```

### Key Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `PROPOSAL-DURATION` | 1440 blocks | ~10 days proposal voting period |
| `REPUTATION-MULTIPLIER` | 10 | Weight factor for reputation in voting power |
| `INACTIVITY-THRESHOLD` | 4320 blocks | ~30 days before reputation decay |

### Error Codes

| Code | Error | Description |
|------|-------|-------------|
| 100 | `ERR-NOT-AUTHORIZED` | Unauthorized operation |
| 102 | `ERR-ALREADY-MEMBER` | User is already a member |
| 103 | `ERR-NOT-MEMBER` | User is not a member |
| 105 | `ERR-INVALID-PROPOSAL` | Invalid proposal parameters |
| 110 | `ERR-INSUFFICIENT-FUNDS` | Insufficient treasury funds |

## 🔐 Security Considerations

### Access Controls

- **Member-only operations**: Most functions require active membership
- **Owner privileges**: Limited to reputation maintenance only
- **Proposal validation**: Comprehensive input validation and state checks

### Economic Security

- **Stake requirements**: Economic stake required for enhanced voting power
- **Treasury protection**: Multi-layer validation for fund operations
- **Reputation safeguards**: Minimum reputation enforcement to prevent gaming

### Operational Security

- **Time locks**: Proposals require waiting periods before execution
- **Consensus requirements**: Majority approval needed for proposal execution
- **Audit trails**: Comprehensive tracking of all votes and operations

## 🚀 Deployment

### Local Deployment

```bash
clarinet console
```

```clarity
::deploy_contracts
```

### Testnet Deployment

```bash
clarinet integrate
```

### Mainnet Deployment

```bash
clarinet publish --network mainnet
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Write tests for your changes
4. Ensure all tests pass: `npm test`
5. Check contract syntax: `clarinet check`
6. Commit your changes: `git commit -m 'Add amazing feature'`
7. Push to the branch: `git push origin feature/amazing-feature`
8. Open a Pull Request

### Code Standards

- Follow [Clarity best practices](https://docs.stacks.co/clarity/best-practices)
- Write comprehensive tests for all new features
- Document all public functions
- Use meaningful variable and function names
- Include error handling for all operations

## 📊 Governance Metrics

### Voting Power Calculation

```text
voting_power = (reputation × REPUTATION_MULTIPLIER + stake) × participation_multiplier
```

Where:

- `reputation`: Member's accumulated reputation points
- `stake`: Currently staked STX amount
- `participation_multiplier`: 2x for members with >10 votes, 1x otherwise

### Reputation System

- **Joining**: +1 reputation
- **Creating proposals**: +2 reputation
- **Voting**: +1 reputation
- **Successful proposals**: +5 reputation
- **Treasury contributions**: +3 reputation

## 🔗 Resources

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://docs.stacks.co/clarity)
- [Clarinet Documentation](https://github.com/hirosystems/clarinet)
- [Stacks Blockchain Explorer](https://explorer.stacks.co/)

## 📄 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## 🗺️ Roadmap

### Phase 1: Core Governance ✅

- [x] Basic membership management
- [x] Proposal creation and voting
- [x] Treasury operations
- [x] Reputation system

### Phase 2: Advanced Features 🚧

- [ ] Cross-chain collaboration protocols
- [ ] Advanced analytics dashboard
- [ ] Mobile governance app
- [ ] Integration with other DeFi protocols

### Phase 3: Ecosystem Expansion 📅

- [ ] Multi-chain deployment
- [ ] DAO-to-DAO marketplace
- [ ] Governance token launch
- [ ] Enterprise partnerships
