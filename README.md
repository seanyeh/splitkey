# splitkey

A command-line tool for splitting and combining secrets using Shamir's Secret Sharing.

## Installation

```bash
shards install
crystal build src/splitkey.cr --release
```

## Usage

### Split a secret

Split a secret into multiple shares, where a threshold number of shares is required to reconstruct it:

```bash
# Split into 5 shares, requiring 3 to reconstruct
# Generates share-1.txt, share-2.txt, share-3.txt, share-4.txt, share-5.txt
splitkey split -s "my password" -n 5 -k 3

# Generate QR codes (as png)
splitkey split -s "my password" -n 5 -k 3 --format qr
```

**Options:**
- `-s, --secret SECRET` - Secret to split (required)
- `-n, --shares N` - Total number of shares to create (required)
- `-k, --threshold K` - Minimum shares needed to reconstruct (required)
- `-o, --output PREFIX` - Output file prefix (default: share)
- `-f, --format FORMAT` - Output format: text, qr (default: text)

### Combine shares

Combine shares to recover the original secret:

```bash
# Combine text shares
splitkey combine share-1.txt share-2.txt share-3.txt
```

The recovered secret is printed to stdout.

## License

MIT
