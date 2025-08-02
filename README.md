# 🎯 Modular Skill Passport for Gig and Informal Workers

## 📋 Overview

A blockchain-based skill verification system that issues NFTs as proof of verified skills and training for gig and informal workers. This solution makes skills portable and verifiable without central gatekeepers, boosting access to employment opportunities.

## 🚀 Features

- 🎫 **NFT-based Skill Certificates**: Each verified skill is represented as a unique NFT
- 👨‍💼 **Authorized Verifiers**: Only approved verifiers can issue and validate skills
- 📊 **Verification Levels**: Multiple levels of skill verification (1-5)
- 🏷️ **Skill Categories**: Pre-defined categories for different types of work
- 📅 **Expiration Support**: Skills can have expiration dates for certifications
- 🔄 **Transferable**: Workers own their skill NFTs and can transfer them
- 📝 **Metadata Support**: Rich metadata for each skill certificate

## 🛠️ Pre-configured Skill Categories

- 🏗️ Construction
- 👨‍🍳 Cooking
- 🧹 Cleaning
- 🚚 Delivery
- 🔧 Handyman
- 🌱 Gardening
- 👶 Childcare
- 👴 Eldercare
- 📚 Tutoring
- 🚗 Driving
- 💻 Tech Support
- ✍️ Freelance Writing
- 📸 Photography
- 📈 Marketing
- 🎨 Design

## 🔧 Setup Instructions

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Node.js](https://nodejs.org/) (for testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Modular-Skill-Passport-for-Gig-and-Informal-Workers
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Check the project**
   ```bash
   clarinet check
   ```

4. **Run tests**
   ```bash
   clarinet test
   ```

## 📖 Usage Guide

### 🏢 For Contract Owners

**Add a new verifier:**
```clarity
(contract-call? .skill-passport add-verifier 'SP1234...VERIFIER)
```

**Add a new skill category:**
```clarity
(contract-call? .skill-passport add-skill-category "new-category")
```

### 👨‍🏫 For Verifiers

**Issue a skill NFT to a worker:**
```clarity
(contract-call? .skill-passport issue-skill-nft
    'SP1234...WORKER           ;; recipient
    "Plumbing Certification"   ;; skill name
    "construction"             ;; skill category
    u3                         ;; verification level (1-5)
    (some u144000)             ;; expires at block (optional)
    "Advanced plumbing skills with 5 years experience"  ;; metadata
    "https://example.com/cert/123.json"  ;; token URI
)
```

**Verify/upgrade a skill:**
```clarity
(contract-call? .skill-passport verify-skill u1 u4)  ;; token-id, new-level
```

### 👷 For Workers

**Transfer your skill NFT:**
```clarity
(contract-call? .skill-passport transfer u1 tx-sender 'SP5678...NEWOWNER)
```

**Update skill metadata (if authorized):**
```clarity
(contract-call? .skill-passport update-skill-metadata u1 "Updated experience details")
```

## 🔍 Read-Only Functions

**Get your skills:**
```clarity
(contract-call? .skill-passport get-worker-skills 'SP1234...WORKER)
```

**Get skill details:**
```clarity
(contract-call? .skill-passport get-skill-details u1)
```

**Check if someone is a verifier:**
```clarity
(contract-call? .skill-passport is-verifier 'SP1234...ADDRESS)
```

**Get NFT owner:**
```clarity
(contract-call? .skill-passport get-owner u1)
```

## 📊 Verification Levels

- **Level 1**: Basic self-attestation
- **Level 2**: Peer verification
- **Level 3**: Professional verification
- **Level 4**: Institutional certification
- **Level 5**: Government/Official certification

## 🎯 Use Cases

### 👨‍🔧 For Gig Workers
- Build a verifiable skill portfolio
- Prove competency to potential employers
- Transfer credentials between platforms
- Showcase progression in skill levels

### 🏢 For Employers
- Quickly verify worker credentials
- Access skill verification history
- Trust in blockchain-backed certificates
- Reduce hiring risk through verified skills

### 🎓 For Training Organizations
- Issue blockchain certificates
- Track student progress
- Provide portable credentials
- Build reputation as verifiers

## 🔐 Security Features

- Only authorized verifiers can issue skills
- Smart contract owner controls verifier list
- NFT ownership ensures skill portability
- Immutable verification history
- Expiration dates for time-sensitive skills

## 🚀 Future Enhancements

- Integration with job platforms
- Skill endorsement system
- Reputation scoring
- Training course integration
- Multi-chain compatibility

## 📄 License

MIT License - see LICENSE file for details

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📞 Support

For questions or support, please open an issue in the GitHub repository.

---

*Empowering informal workers with verifiable, portable skill credentials on the blockchain* 🌟
