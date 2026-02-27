#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBHOST_DIR="$SCRIPT_DIR/src/SimplCommerce.WebHost"
DB_FILE="$WEBHOST_DIR/simplcommerce.db"
DB_DIR="$SCRIPT_DIR/src/Database"

# ── dotnet-ef ────────────────────────────────────────────────────────────────
if ! dotnet ef --version &>/dev/null 2>&1; then
    echo "Installing dotnet-ef 8.0.0..."
    dotnet tool install --global dotnet-ef --version 8.0.0
    export PATH="$PATH:$HOME/.dotnet/tools"
fi

# ── Build ────────────────────────────────────────────────────────────────────
dotnet restore && dotnet build

# ── Migrations ───────────────────────────────────────────────────────────────
rm -f "$DB_FILE"
rm -rf "$WEBHOST_DIR/Migrations"
mkdir -p "$WEBHOST_DIR/Migrations"

cd "$WEBHOST_DIR"
dotnet ef migrations add initialSchema
dotnet ef database update

# ── Seed static data ─────────────────────────────────────────────────────────
# The .sql files use SQL Server syntax; convert on-the-fly before importing.
python3 - "$DB_FILE" "$DB_DIR" <<'PYEOF'
import re, subprocess, sys, os

db   = sys.argv[1]
ddir = sys.argv[2]

def to_sqlite(sql):
    sql = re.sub(r'\[dbo\]\.', '', sql)                      # remove [dbo]. schema prefix
    sql = re.sub(r'^\s*GO\s*$', '', sql, flags=re.MULTILINE) # remove GO batch separators
    sql = re.sub(r"\bN'", "'", sql)                           # strip N'' unicode prefix
    sql = sql.replace('&amp;', '&')                          # unescape HTML entities
    lines = []
    for line in sql.splitlines():
        s = line.rstrip()
        if re.match(r'\s*INSERT\s+\[', s):                    # INSERT -> INSERT INTO
            s = re.sub(r'\bINSERT\s+\[', 'INSERT INTO [', s)
        if s.endswith(')') and re.match(r'\s*INSERT', s):     # add missing semicolons
            s += ';'
        lines.append(s)
    return '\n'.join(lines)

files = [
    "Countries.sql",
    "StaticData-US.sql",
    "StaticData-DefaultLocalization.sql",
]

for fname in files:
    path = os.path.join(ddir, fname)
    with open(path, encoding='utf-8-sig') as f:
        sql = to_sqlite(f.read())
    result = subprocess.run(["sqlite3", db], input=sql, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"  ERROR seeding {fname}:\n{result.stderr[:400]}")
        sys.exit(1)
    else:
        print(f"  Seeded: {fname}")
PYEOF

echo ""
echo "Done. SQLite database created at: $DB_FILE"
echo "Run the app with: cd src/SimplCommerce.WebHost && dotnet run"
echo "Admin: http://localhost:5000/Admin  |  admin@simplcommerce.com / 1qazZAQ!"
