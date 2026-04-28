# Bucket types

### General Purpose Buckets

- standard and most common
- replicated across at least three Availability Zones (high availability and durability)
- S3 Standard, S3 Intelligent-Tiering, S3 Standard-IA, S3 Glacier, and more within the same bucket to optimize cost and performance.
- Storing large datasets like images, videos, or analytics data

### Directory Buckets

- only one Availability Zone
- faster data access and reduced costs
- temporary storage

# ACLs

### When to use

- Simple Permission Needs
- Individual Object Permissions (per-object basis rather than at the bucket level)

### When not to use

- Complex Permissions (bucket policies)
- Using IAM (Identity and Access Management) roles and policies
- When preventing public access (S3 Block Public Access)

# Encryption types

### Server-Side Encryption with Amazon S3 Managed Keys (SSE-S3)

- Ease of Use (AWS handles all key management and encryption processes)
- Suitable for less sensitive data
- Minimize costs