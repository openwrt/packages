#!/bin/sh

[ "$1" = python3-openpyxl ] || exit 0

python3 - << 'EOF'
import openpyxl
import tempfile
import os

# Create a workbook and write data
wb = openpyxl.Workbook()
ws = wb.active
ws.title = "TestSheet"
ws["A1"] = "Hello"
ws["B1"] = 42
ws["A2"] = "World"
ws["B2"] = 3.14

# Save to a temp file and reload
with tempfile.NamedTemporaryFile(suffix=".xlsx", delete=False) as f:
    path = f.name

try:
    wb.save(path)
    wb2 = openpyxl.load_workbook(path)
    ws2 = wb2["TestSheet"]
    assert ws2["A1"].value == "Hello", f"Expected 'Hello', got {ws2['A1'].value}"
    assert ws2["B1"].value == 42, f"Expected 42, got {ws2['B1'].value}"
    assert ws2["A2"].value == "World"
    assert abs(ws2["B2"].value - 3.14) < 1e-9
finally:
    os.unlink(path)
EOF
