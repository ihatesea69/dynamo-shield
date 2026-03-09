# Architecture: Fine-Grained Access Control for Amazon DynamoDB

## Overview

This project implements the pattern described in the [AWS blog post on Fine-Grained Access Control for DynamoDB](https://aws.amazon.com/blogs/aws/fine-grained-access-control-for-amazon-dynamodb/). It eliminates the need for a middle-tier proxy by pushing authorization logic directly into IAM policies.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│  Mobile / Web App                                               │
│                                                                 │
│   1. Authenticate with Identity Provider                        │
│      (Cognito, Amazon, Google, Facebook)                        │
│                                                                 │
│   2. Call STS:AssumeRoleWithWebIdentity                         │
│      ──────────────────────────────────►  AWS STS               │
│                                          Returns temp creds     │
│                                                                 │
│   3. Call DynamoDB directly with temp creds                     │
│      ──────────────────────────────────►  Amazon DynamoDB       │
│                                          IAM evaluates FGAC     │
│                                          policy conditions       │
└─────────────────────────────────────────────────────────────────┘
```

**Without FGAC (old):**
```
App → Proxy Server → DynamoDB
         ↑ extra latency, cost, complexity
```

**With FGAC (new):**
```
App → DynamoDB  (IAM enforces row/attribute restrictions inline)
```

## Components

### DynamoDB Table: `GameScores`

| Attribute  | Type   | Role        |
|------------|--------|-------------|
| `UserId`   | String | Hash key    |
| `GameTitle`| String | Range key   |
| `Score`    | Number | GSI sort key|
| `Wins`     | Number | Data        |
| `Losses`   | Number | Data        |

**Global Secondary Index** `GameTitleIndex`: enables leaderboard queries by game.

### IAM Role (Web Identity)

- **Trust policy**: allows `cognito-identity.amazonaws.com` to call `sts:AssumeRoleWithWebIdentity`
- **Access policy**: one of four FGAC types (see below)

### FGAC Policy Types

#### 1. Horizontal Access
Restricts access to rows where `UserId` matches the caller's Cognito subject (`sub`). Uses `dynamodb:LeadingKeys` condition.

```
User A ─── can only read/write ──► Row: UserId=A
User B ─── can only read/write ──► Row: UserId=B
```

#### 2. Vertical Access
All users can access all rows, but only specified attributes are readable. Uses `dynamodb:Attributes` condition.

```
Allowed: UserId, GameTitle, Score, Wins, Losses
Blocked: InternalRating, CheatFlags, etc.
```

#### 3. Combined Access (default)
Combines horizontal + vertical: each user sees only their own rows and only allowed attributes.

#### 4. Read-Only Access
Like horizontal, but with only `GetItem`, `BatchGetItem`, `Query` — no writes.

## IAM Condition Keys Reference

| Condition Key              | Description                                        |
|----------------------------|----------------------------------------------------|
| `dynamodb:LeadingKeys`     | Match on the table's hash key value                |
| `dynamodb:Attributes`      | Restrict which attributes can be read/written      |
| `dynamodb:Select`          | Restrict the `Select` parameter in queries         |

## Security Notes

- Temporary credentials issued by STS expire (default 1 hour)
- Server-side encryption (SSE) is enabled on the table
- Point-in-Time Recovery (PITR) is enabled by default
- Never embed long-term AWS credentials in mobile/web apps
